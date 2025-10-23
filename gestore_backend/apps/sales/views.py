# apps/sales/views.py

"""
Vues pour l'application sales - GESTORE - VERSION MULTI-MAGASINS
ViewSets complets pour la gestion des ventes et du POS
🔴 MODIFICATION MAJEURE : Ajout du filtrage multi-magasins via StoreFilterMixin
"""
from rest_framework import viewsets, status, serializers
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q, Sum, Count, F, Prefetch
from django.db import transaction
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from decimal import Decimal

# Import de la classe de base
from apps.authentication.views import OptimizedModelViewSet

# 🔴 IMPORT DU MIXIN MULTI-MAGASINS
from apps.core.mixins import StoreFilterMixin

# Import des permissions
from .permissions import (
    CanViewSales, CanVoidTransaction,
    CanApplyDiscounts, CanManageCustomers
)

from .models import (
    Customer, PaymentMethod, Sale, SaleItem, Payment,
    Discount, SaleDiscount, Receipt
)
from .serializers import (
    CustomerSerializer, CustomerListSerializer, PaymentMethodSerializer,
    SaleListSerializer, SaleDetailSerializer, SaleItemSerializer,
    PaymentSerializer, DiscountSerializer, ReceiptSerializer,
    CheckoutSerializer, VoidSaleSerializer, ReturnSaleSerializer
)
from apps.inventory.models import Article, Stock, StockMovement


class HealthCheckView(APIView):
    """Vue de vérification de santé pour sales"""
    permission_classes = []
    
    def get(self, request):
        today = timezone.now().date()
        return Response({
            "status": "ok",
            "app": "sales",
            "customers_count": Customer.objects.count(),
            "sales_today": Sale.objects.filter(sale_date__date=today).count(),
            "revenue_today": Sale.objects.filter(
                sale_date__date=today,
                status='completed'
            ).aggregate(total=Sum('total_amount'))['total'] or 0
        })


# ========================
# CLIENTS
# ========================

class CustomerViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les clients
    Note: Les clients ne sont PAS filtrés par magasin (ils sont globaux)
    """
    queryset = Customer.objects.all()
    permission_classes = [CanManageCustomers]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['customer_type', 'is_active', 'marketing_consent']
    search_fields = ['customer_code', 'first_name', 'last_name', 'company_name', 'email', 'phone']
    ordering_fields = ['customer_code', 'last_name', 'total_purchases', 'purchase_count', 'created_at']
    ordering = ['last_name', 'first_name']
    
    def get_serializer_class(self):
        """Serializer selon l'action"""
        if self.action == 'list':
            return CustomerListSerializer
        return CustomerSerializer
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste"""
        return queryset
    
    @action(detail=True, methods=['get'])
    def sales_history(self, request, pk=None):
        """Historique d'achats d'un client"""
        customer = self.get_object()
        sales = Sale.objects.filter(
            customer=customer,
            status__in=['completed', 'partially_refunded']
        ).select_related('cashier', 'location').prefetch_related('items').order_by('-sale_date')
        
        # Pagination
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 20))
        start = (page - 1) * page_size
        end = start + page_size
        
        serializer = SaleListSerializer(sales[start:end], many=True, context={'request': request})
        
        # Statistiques
        stats = sales.aggregate(
            total_spent=Sum('total_amount'),
            total_transactions=Count('id'),
            average_basket=Sum('total_amount') / Count('id') if sales.count() > 0 else 0
        )
        
        return Response({
            'customer': CustomerSerializer(customer).data,
            'results': serializer.data,
            'count': sales.count(),
            'page': page,
            'page_size': page_size,
            'statistics': stats
        })
    
    @action(detail=True, methods=['post'])
    def add_loyalty_points(self, request, pk=None):
        """Ajouter des points de fidélité"""
        customer = self.get_object()
        points = int(request.data.get('points', 0))
        
        if points <= 0:
            return Response(
                {'error': 'Le nombre de points doit être positif'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        customer.loyalty_points += points
        customer.save()
        
        return Response({
            'message': f'{points} points ajoutés',
            'new_balance': customer.loyalty_points
        })
    
    @action(detail=True, methods=['get'])
    def loyalty_summary(self, request, pk=None):
        """Résumé du programme de fidélité"""
        customer = self.get_object()
        
        # Calcul des points gagnés et utilisés
        sales = Sale.objects.filter(customer=customer, status='completed')
        total_earned = sales.aggregate(total=Sum('loyalty_points_earned'))['total'] or 0
        total_used = sales.aggregate(total=Sum('loyalty_points_used'))['total'] or 0
        
        return Response({
            'customer': CustomerListSerializer(customer).data,
            'current_balance': customer.loyalty_points,
            'total_earned': total_earned,
            'total_used': total_used,
            'can_use_points': customer.loyalty_points > 0
        })


# ========================
# MOYENS DE PAIEMENT
# ========================

class PaymentMethodViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les moyens de paiement
    Note: Les méthodes de paiement sont globales (non filtrées par magasin)
    """
    queryset = PaymentMethod.objects.all()
    serializer_class = PaymentMethodSerializer
    permission_classes = [CanViewSales]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['payment_type', 'is_active']
    search_fields = ['name', 'payment_type']
    ordering_fields = ['name', 'payment_type', 'created_at']
    ordering = ['payment_type', 'name']


# ========================
# REMISES
# ========================

class DiscountViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les remises et promotions
    Note: Les remises sont globales (non filtrées par magasin)
    """
    queryset = Discount.objects.all()
    serializer_class = DiscountSerializer
    permission_classes = [CanApplyDiscounts]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['discount_type', 'scope', 'is_active']
    search_fields = ['name', 'description']
    ordering_fields = ['name', 'start_date', 'created_at']
    ordering = ['-start_date']
    
    def get_queryset(self):
        """Filtrage des remises actives"""
        queryset = super().get_queryset()
        
        # Filtre remises actives uniquement
        active_only = self.request.query_params.get('active_only')
        if active_only == 'true':
            now = timezone.now()
            queryset = queryset.filter(
                is_active=True,
                start_date__lte=now
            ).filter(
                Q(end_date__isnull=True) | Q(end_date__gte=now)
            )
        
        return queryset
    
    @action(detail=True, methods=['post'])
    def calculate(self, request, pk=None):
        """Calculer le montant d'une remise pour un montant donné"""
        discount = self.get_object()
        amount = Decimal(str(request.data.get('amount', 0)))
        
        if amount <= 0:
            return Response(
                {'error': 'Le montant doit être positif'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        discount_amount = discount.calculate_discount(amount)
        
        return Response({
            'original_amount': float(amount),
            'discount_amount': float(discount_amount),
            'final_amount': float(amount - discount_amount),
            'discount': DiscountSerializer(discount).data
        })


# ========================
# VENTES
# ========================

class SaleViewSet(StoreFilterMixin, OptimizedModelViewSet):
    """
    ViewSet COMPLET pour les ventes avec filtrage multi-magasins
    🔴 MODIFIÉ : Ajout StoreFilterMixin + actions void et daily_summary
    """
    queryset = Sale.objects.all()
    permission_classes = [CanViewSales]
    
    # 🔴 CONFIGURATION DU FILTRAGE MULTI-MAGASINS
    store_filter_field = 'location'  # Filtre sur Sale.location
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['status', 'sale_type', 'customer', 'cashier', 'location']
    search_fields = ['sale_number', 'customer__customer_code', 'customer__first_name', 'customer__last_name']
    ordering_fields = ['sale_date', 'total_amount', 'created_at']
    ordering = ['-sale_date']
    
    def get_serializer_class(self):
        """Serializer selon l'action"""
        if self.action == 'list':
            return SaleListSerializer
        return SaleDetailSerializer
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste"""
        return queryset.select_related(
            'customer', 'cashier', 'location'
        ).annotate(
            items_count=Count('items')
        )
    
    def optimize_detail_queryset(self, queryset):
        """Optimisations pour le détail"""
        return queryset.select_related(
            'customer', 'cashier', 'location', 'original_sale', 'receipt'
        ).prefetch_related(
            Prefetch('items', queryset=SaleItem.objects.select_related('article')),
            Prefetch('payments', queryset=Payment.objects.select_related('payment_method')),
            'applied_discounts__discount'
        )
    
    def get_queryset(self):
        """Filtrage personnalisé + filtrage magasin"""
        # 🔴 IMPORTANT : Appeler super() pour activer StoreFilterMixin
        queryset = super().get_queryset()
        
        # Filtre par période
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        
        if date_from:
            queryset = queryset.filter(sale_date__date__gte=date_from)
        if date_to:
            queryset = queryset.filter(sale_date__date__lte=date_to)
        
        # Filtre ventes non payées
        unpaid_only = self.request.query_params.get('unpaid_only')
        if unpaid_only == 'true':
            queryset = queryset.filter(paid_amount__lt=F('total_amount'))
        
        return queryset
    
    @action(detail=True, methods=['post'], permission_classes=[CanVoidTransaction])
    def void(self, request, pk=None):
        """Annuler une vente - Nécessite permission can_void_transactions"""
        sale = self.get_object()
        
        if sale.status in ['cancelled', 'refunded']:
            return Response(
                {'error': 'Cette vente est déjà annulée ou remboursée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        serializer = VoidSaleSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        with transaction.atomic():
            # Marquer la vente comme annulée
            sale.status = 'cancelled'
            sale.notes = f"{sale.notes}\n\nAnnulée le {timezone.now()}: {serializer.validated_data['reason']}"
            sale.save()
            
            # Remettre les stocks dans le même magasin
            for item in sale.items.all():
                stock = Stock.objects.filter(
                    article=item.article,
                    location=sale.location  # 🔴 Même magasin
                ).first()
                
                if stock:
                    old_quantity = stock.quantity_on_hand
                    stock.quantity_on_hand += item.quantity
                    stock.save()
                    
                    StockMovement.objects.create(
                        article=item.article,
                        stock=stock,
                        movement_type='return',
                        reason='return_customer',
                        quantity=item.quantity,
                        stock_before=old_quantity,
                        stock_after=stock.quantity_on_hand,
                        reference_document=sale.sale_number,
                        notes=f"Annulation vente {sale.sale_number}",
                        created_by=request.user
                    )
        
        return Response({
            'message': 'Vente annulée avec succès',
            'sale': SaleDetailSerializer(sale, context={'request': request}).data
        })
    
    @action(detail=False, methods=['get'])
    def daily_summary(self, request):
        """
        Résumé des ventes du jour pour le magasin de l'utilisateur
        🔴 MODIFIÉ : Filtré automatiquement par magasin grâce au Mixin
        """
        today = timezone.now().date()
        
        # Le queryset est déjà filtré par magasin grâce à StoreFilterMixin
        daily_sales = self.get_queryset().filter(
            sale_date__date=today,
            status='completed'
        )
        
        summary = daily_sales.aggregate(
            total_sales=Count('id'),
            total_revenue=Sum('total_amount'),
            total_items=Sum('items__quantity'),
        )
        
        # Calcul de la moyenne
        if daily_sales.count() > 0:
            summary['average_basket'] = summary['total_revenue'] / daily_sales.count()
        else:
            summary['average_basket'] = 0
        
        # Ventes par caissier
        by_cashier = daily_sales.values(
            'cashier__first_name', 'cashier__last_name'
        ).annotate(
            sales_count=Count('id'),
            total_amount=Sum('total_amount')
        )
        
        # Moyens de paiement
        by_payment = Payment.objects.filter(
            sale__in=daily_sales
        ).values('payment_method__name').annotate(
            count=Count('id'),
            total=Sum('amount')
        )
        
        return Response({
            'date': today,
            'summary': summary,
            'by_cashier': list(by_cashier),
            'by_payment_method': list(by_payment)
        })


# ========================
# CLASSE COMPLÈTE MODIFIÉE : POSViewSet
# ========================

class POSViewSet(StoreFilterMixin, viewsets.ViewSet):
    """
    ViewSet COMPLET pour les opérations de point de vente
    🔴 MODIFIÉ : Ajout StoreFilterMixin + TOUTES les actions
    Gère tout le workflow de caisse
    """
    permission_classes = [CanViewSales]
    
    # 🔴 CONFIGURATION DU FILTRAGE (utilisé dans les queryset internes)
    store_filter_field = 'location'
    
    @action(detail=False, methods=['post'])
    def checkout(self, request):
        """
        Finaliser une vente (checkout complet)
        🔴 MODIFIÉ : Assigne automatiquement le magasin de l'employé
        """
        serializer = CheckoutSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)

        data = serializer.validated_data

        try:
            with transaction.atomic():
                # 🔴 NOUVEAU : Assigner automatiquement le magasin de l'employé
                location = data.get('location')
                if not location and request.user.assigned_store:
                    location = request.user.assigned_store
                
                # 1. Créer la vente de base
                sale = Sale.objects.create(
                    sale_type='regular',
                    status='pending',
                    customer_id=data.get('customer_id'),
                    cashier=request.user,
                    location=location,  # 🔴 ASSIGNATION DU MAGASIN
                    sale_date=timezone.now(),
                    notes=data.get('notes', '')
                )

                # 2. Créer les lignes de vente
                for item_data in data['items']:
                    article = Article.objects.get(id=item_data['article_id'])
                    
                    SaleItem.objects.create(
                        sale=sale,
                        article=article,
                        quantity=Decimal(str(item_data['quantity'])),
                        unit_price=Decimal(str(item_data.get('unit_price', article.selling_price))),
                        discount_percentage=Decimal(str(item_data.get('discount_percentage', 0)))
                    )

                # 3. Calculer les totaux
                sale.calculate_totals()

                # 4. Utiliser les points de fidélité si demandé
                loyalty_points_to_use = data.get('loyalty_points_to_use', 0)
                if loyalty_points_to_use > 0 and sale.customer:
                    if sale.customer.loyalty_points >= loyalty_points_to_use:
                        sale.loyalty_points_used = loyalty_points_to_use
                        sale.customer.loyalty_points -= loyalty_points_to_use
                        sale.customer.save()
                        sale.total_amount -= Decimal(str(loyalty_points_to_use))
                        sale.save()

                # 5. Créer les paiements
                total_paid = Decimal('0')
                for payment_data in data['payments']:
                    payment = Payment.objects.create(
                        sale=sale,
                        payment_method_id=payment_data['payment_method_id'],
                        amount=Decimal(str(payment_data['amount'])),
                        status='completed',
                        reference_number=payment_data.get('reference_number', ''),
                        created_by=request.user
                    )
                    total_paid += payment.amount

                # 6. Finaliser la vente
                sale.paid_amount = total_paid
                if total_paid >= sale.total_amount:
                    sale.status = 'completed'
                    sale.change_amount = total_paid - sale.total_amount

                    if sale.customer:
                        sale.customer.total_purchases += sale.total_amount
                        sale.customer.purchase_count += 1
                        sale.customer.last_purchase_date = timezone.now()
                        if sale.loyalty_points_earned > 0:
                            sale.customer.loyalty_points += sale.loyalty_points_earned
                        sale.customer.save()
                else:
                    raise serializers.ValidationError({'payments': 'Le montant payé est insuffisant.'})

                sale.save()

                # 7. Mettre à jour les stocks (déduire quantités)
                for item in sale.items.all():
                    # 🔴 IMPORTANT : Ne déduire que du stock du magasin de la vente
                    stocks = Stock.objects.filter(
                        article=item.article,
                        location=sale.location,  # Même magasin que la vente
                        quantity_on_hand__gt=0
                    ).order_by('expiry_date', 'created_at')

                    remaining_qty = item.quantity

                    for stock in stocks:
                        if remaining_qty <= 0:
                            break

                        qty_to_deduct = min(stock.quantity_on_hand, remaining_qty)

                        # Créer mouvement de stock
                        StockMovement.objects.create(
                            article=item.article,
                            stock=stock,
                            movement_type='out',
                            reason='sale',
                            quantity=qty_to_deduct,
                            stock_before=stock.quantity_on_hand,
                            stock_after=stock.quantity_on_hand - qty_to_deduct,
                            reference_document=sale.sale_number,
                            created_by=request.user
                        )

                        stock.quantity_on_hand -= qty_to_deduct
                        stock.save()

                        remaining_qty -= qty_to_deduct

                # 8. Créer le ticket de caisse
                Receipt.objects.create(
                    sale=sale,
                    receipt_number=f"REC-{sale.sale_number}",
                    footer_text="Merci de votre visite !"
                )

                # 9. Retourner la vente complète
                return Response({
                    'message': 'Vente enregistrée avec succès',
                    'sale': SaleDetailSerializer(sale, context={'request': request}).data
                }, status=status.HTTP_201_CREATED)

        except serializers.ValidationError as e:
            return Response(e.detail, status=status.HTTP_400_BAD_REQUEST)
        except Article.DoesNotExist:
            return Response({'error': 'Un article spécifié est introuvable.'}, status=status.HTTP_404_NOT_FOUND)
        except Exception as e:
            return Response({'error': f'Une erreur inattendue est survenue: {str(e)}'}, status=status.HTTP_500_INTERNAL_SERVER_ERROR)

    @action(detail=False, methods=['post'])
    def quick_sale(self, request):
        """Vente rapide avec un seul article et paiement espèces"""
        article_id = request.data.get('article_id')
        quantity = Decimal(str(request.data.get('quantity', 1)))
        cash_received = Decimal(str(request.data.get('cash_received', 0)))
        
        if not article_id:
            return Response(
                {'error': 'Article requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            article = Article.objects.get(id=article_id)
        except Article.DoesNotExist:
            return Response(
                {'error': 'Article non trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        total = quantity * article.selling_price
        
        if cash_received < total:
            return Response(
                {'error': 'Montant insuffisant'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Utiliser le checkout avec les données simplifiées
        cash_payment_method = PaymentMethod.objects.filter(payment_type='cash').first()
        
        if not cash_payment_method:
            return Response(
                {'error': 'Aucun moyen de paiement espèces configuré'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        checkout_data = {
            'items': [{
                'article_id': article_id,
                'quantity': float(quantity)
            }],
            'payments': [{
                'payment_method_id': str(cash_payment_method.id),
                'amount': float(cash_received)
            }]
        }
        
        request._full_data = checkout_data
        return self.checkout(request)
    
    @action(detail=False, methods=['get'])
    def search_article(self, request):
        """Rechercher un article par code-barres ou nom"""
        query = request.query_params.get('q', '')
        
        if not query:
            return Response(
                {'error': 'Paramètre de recherche requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Recherche par code-barres ou nom
        articles = Article.objects.filter(
            Q(barcode=query) |
            Q(code=query) |
            Q(name__icontains=query) |
            Q(additional_barcodes__barcode=query),
            is_active=True,
            is_sellable=True
        ).select_related('category', 'brand', 'unit_of_measure').annotate(
            current_stock=Sum('stock_entries__quantity_available')
        ).distinct()[:10]
        
        from apps.inventory.serializers import ArticleListSerializer
        return Response({
            'results': ArticleListSerializer(articles, many=True, context={'request': request}).data
        })
    
    @action(detail=False, methods=['post'])
    def return_sale(self, request):
        """
        Retourner une vente
        🔴 MODIFIÉ : Remet le stock dans le même magasin
        """
        serializer = ReturnSaleSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        data = serializer.validated_data
        
        try:
            original_sale = Sale.objects.get(id=data['original_sale_id'])
        except Sale.DoesNotExist:
            return Response(
                {'error': 'Vente originale non trouvée'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        if not original_sale.can_be_returned():
            return Response(
                {'error': 'Cette vente ne peut pas être retournée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        with transaction.atomic():
            # Créer la vente de retour
            return_sale = Sale.objects.create(
                sale_type='return',
                status='completed',
                customer=original_sale.customer,
                cashier=request.user,
                location=original_sale.location,  # 🔴 Même magasin
                original_sale=original_sale,
                notes=data['reason'],
                created_by=request.user
            )
            
            # Créer les lignes de retour
            for item_data in data['items']:
                original_item = SaleItem.objects.get(id=item_data['sale_item_id'])
                
                SaleItem.objects.create(
                    sale=return_sale,
                    article=original_item.article,
                    quantity=-item_data['quantity'],  # Quantité négative
                    unit_price=original_item.unit_price,
                    discount_percentage=original_item.discount_percentage
                )
            
            # Calculer les totaux (négatifs)
            return_sale.calculate_totals()
            
            # Remettre en stock
            for item in return_sale.items.all():
                stock, created = Stock.objects.get_or_create(
                    article=item.article,
                    location=return_sale.location,  # 🔴 Même magasin
                    defaults={'quantity_on_hand': 0, 'unit_cost': item.article.purchase_price}
                )
                
                old_quantity = stock.quantity_on_hand
                stock.quantity_on_hand += abs(item.quantity)
                stock.save()
                
                StockMovement.objects.create(
                    article=item.article,
                    stock=stock,
                    movement_type='in',
                    reason='return_customer',
                    quantity=abs(item.quantity),
                    stock_before=old_quantity,
                    stock_after=stock.quantity_on_hand,
                    reference_document=return_sale.sale_number,
                    created_by=request.user
                )
            
            # Créer le paiement de remboursement
            refund_method = PaymentMethod.objects.filter(
                payment_type=data['refund_method']
            ).first()
            
            if refund_method:
                Payment.objects.create(
                    sale=return_sale,
                    payment_method=refund_method,
                    amount=-return_sale.total_amount,  # Montant négatif
                    status='completed',
                    notes=f"Remboursement vente {original_sale.sale_number}",
                    created_by=request.user
                )
            
            return_sale.paid_amount = -return_sale.total_amount
            return_sale.save()
            
            # Marquer la vente originale
            original_sale.status = 'refunded'
            original_sale.save()
        
        return Response({
            'message': 'Retour effectué avec succès',
            'return_sale': SaleDetailSerializer(return_sale, context={'request': request}).data
        })
    
    @action(detail=False, methods=['get'])
    def session_summary(self, request):
        """
        Résumé de la session de caisse en cours
        🔴 MODIFIÉ : Filtré automatiquement par magasin de l'employé
        """
        today = timezone.now().date()
        
        # Ventes du caissier aujourd'hui dans son magasin
        if request.user.assigned_store:
            session_sales = Sale.objects.filter(
                cashier=request.user,
                location=request.user.assigned_store,  # 🔴 Filtré par magasin
                sale_date__date=today,
                status='completed'
            )
        else:
            # Admin : toutes ses ventes
            session_sales = Sale.objects.filter(
                cashier=request.user,
                sale_date__date=today,
                status='completed'
            )
        
        summary = session_sales.aggregate(
            total_sales=Count('id'),
            total_revenue=Sum('total_amount'),
            total_cash=Sum(
                'payments__amount',
                filter=Q(payments__payment_method__payment_type='cash')
            ),
            total_card=Sum(
                'payments__amount',
                filter=Q(payments__payment_method__payment_type='card')
            ),
            total_mobile=Sum(
                'payments__amount',
                filter=Q(payments__payment_method__payment_type='mobile_money')
            )
        )
        
        return Response({
            'cashier': request.user.get_full_name(),
            'session_date': today,
            'summary': summary,
            'sales': SaleListSerializer(session_sales[:20], many=True, context={'request': request}).data
        })
       