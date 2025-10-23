"""
Vues pour l'application inventory - GESTORE
ViewSets complets avec optimisations et permissions granulaires
VERSION SÉCURISÉE - Option 2
"""
from rest_framework import viewsets, status
from rest_framework.parsers import MultiPartParser, FormParser
from rest_framework.decorators import action
from rest_framework.response import Response
from rest_framework.views import APIView
from django.db.models import Q, Prefetch, Count, Sum, F
from django.db import transaction
from django.utils import timezone
from django_filters.rest_framework import DjangoFilterBackend
from rest_framework.filters import SearchFilter, OrderingFilter
from decimal import Decimal
import csv
import io
from django.http import HttpResponse

# Import de la classe de base existante
from apps.authentication.views import OptimizedModelViewSet

# Import des permissions globales (core)
from apps.core.permissions import CanManageInventory

from apps.core.mixins import StoreFilterMixin

# Import des permissions granulaires spécifiques à inventory
from .permissions import (
    CanViewInventory,
    CanModifyPrices,
    CanManageStockMovements,
    CanAdjustStock
)

from .models import (
    UnitOfMeasure, UnitConversion, Category, Brand, Supplier,
    Article, ArticleBarcode, ArticleImage, PriceHistory,
    Location, Stock, StockMovement, StockAlert
)
from .serializers import (
    UnitOfMeasureSerializer, UnitConversionSerializer, CategorySerializer, CategoryTreeSerializer,
    BrandSerializer, SupplierSerializer, ArticleListSerializer, ArticleDetailSerializer,
    PriceHistorySerializer, LocationSerializer, StockSerializer,
    StockMovementSerializer, StockAlertSerializer, ArticleBulkUpdateSerializer,
    StockAdjustmentSerializer, StockTransferSerializer
)


class HealthCheckView(APIView):
    """Vue de vérification de santé pour inventory"""
    permission_classes = []
    
    def get(self, request):
        return Response({
            "status": "ok", 
            "app": "inventory",
            "articles_count": Article.objects.count(),
            "active_articles": Article.objects.filter(is_active=True).count(),
            "categories_count": Category.objects.count(),
            "brands_count": Brand.objects.count(),
            "locations_count": Location.objects.count(),
            "total_stock_value": Stock.objects.aggregate(
                total=Sum(F('quantity_on_hand') * F('unit_cost'))
            )['total'] or 0
        })


# ========================
# CONFIGURATION DE BASE
# ========================

class UnitOfMeasureViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les unités de mesure
    Permissions : Lecture pour tous, modification selon can_manage_inventory
    """
    queryset = UnitOfMeasure.objects.all()
    serializer_class = UnitOfMeasureSerializer
    permission_classes = [CanViewInventory]  # Lecture autorisée, écriture selon permission
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['is_active', 'is_decimal']
    search_fields = ['name', 'symbol', 'description']
    ordering_fields = ['name', 'symbol', 'created_at']
    ordering = ['name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des unités"""
        return queryset.annotate(
            articles_count=Count('article', filter=Q(article__is_active=True)),
            conversion_count=Count('conversions_from') + Count('conversions_to')
        )

    def retrieve(self, request, pk=None):
        """Récupère une unité de mesure par son ID"""
        try:
            unit = self.get_object()
            serializer = self.get_serializer(unit)
            return Response(serializer.data)
        except UnitOfMeasure.DoesNotExist:
            return Response(
                {'error': 'Unité de mesure non trouvée'},
                status=status.HTTP_404_NOT_FOUND
            )
    
    @action(detail=True, methods=['get'])
    def conversions(self, request, pk=None):
        """Conversions disponibles pour cette unité"""
        unit = self.get_object()
        from_conversions = UnitConversion.objects.filter(from_unit=unit).select_related('to_unit')
        to_conversions = UnitConversion.objects.filter(to_unit=unit).select_related('from_unit')
        
        return Response({
            'from_conversions': UnitConversionSerializer(from_conversions, many=True).data,
            'to_conversions': UnitConversionSerializer(to_conversions, many=True).data
        })
    
    @action(detail=True, methods=['get'])
    def articles(self, request, pk=None):
        """Articles utilisant cette unité"""
        unit = self.get_object()
        articles = Article.objects.filter(unit_of_measure=unit, is_active=True)
        
        # Pagination simple
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 20))
        start = (page - 1) * page_size
        end = start + page_size
        
        serializer = ArticleListSerializer(articles[start:end], many=True, context={'request': request})
        return Response({
            'results': serializer.data,
            'count': articles.count(),
            'page': page,
            'page_size': page_size
        })


class UnitConversionViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les conversions d'unités
    Permissions : Lecture pour tous, modification selon can_manage_inventory
    """
    queryset = UnitConversion.objects.all()
    serializer_class = UnitConversionSerializer
    permission_classes = [CanViewInventory]
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des conversions"""
        return queryset.select_related('from_unit', 'to_unit')
    
    @action(detail=False, methods=['post'])
    def calculate(self, request):
        """Calcule une conversion entre unités - Accessible à tous"""
        from_unit_id = request.data.get('from_unit_id')
        to_unit_id = request.data.get('to_unit_id')
        quantity = Decimal(str(request.data.get('quantity', 0)))
        
        if not all([from_unit_id, to_unit_id, quantity]):
            return Response(
                {'error': 'from_unit_id, to_unit_id et quantity sont requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        try:
            conversion = UnitConversion.objects.get(
                from_unit_id=from_unit_id,
                to_unit_id=to_unit_id
            )
            converted_quantity = quantity * conversion.conversion_factor
            
            return Response({
                'original_quantity': float(quantity),
                'converted_quantity': float(converted_quantity),
                'conversion_factor': float(conversion.conversion_factor),
                'from_unit': conversion.from_unit.symbol,
                'to_unit': conversion.to_unit.symbol
            })
        except UnitConversion.DoesNotExist:
            return Response(
                {'error': 'Conversion non trouvée entre ces unités'},
                status=status.HTTP_404_NOT_FOUND
            )


class CategoryViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les catégories avec hiérarchie
    Permissions : Lecture pour tous, modification selon can_manage_inventory
    """
    queryset = Category.objects.all()
    serializer_class = CategorySerializer
    permission_classes = [CanViewInventory]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['is_active', 'parent', 'requires_prescription', 'requires_lot_tracking']
    search_fields = ['name', 'code', 'description']
    ordering_fields = ['name', 'code', 'order', 'created_at']
    ordering = ['parent__name', 'order', 'name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des catégories"""
        return queryset.select_related('parent').annotate(
            children_count=Count('children', filter=Q(children__is_active=True)),
            articles_count=Count('article', filter=Q(article__is_active=True))
        )
    
    def optimize_detail_queryset(self, queryset):
        """Optimisations pour le détail d'une catégorie"""
        return queryset.select_related('parent').prefetch_related(
            'children',
            Prefetch('article_set', queryset=Article.objects.filter(is_active=True))
        )
    
    @action(detail=False, methods=['get'])
    def tree(self, request):
        """Arborescence complète des catégories - Accessible à tous"""
        root_categories = Category.objects.filter(
            parent=None, is_active=True
        ).prefetch_related(
            'children__children__children'
        ).order_by('order', 'name')
        
        serializer = CategoryTreeSerializer(root_categories, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def children(self, request, pk=None):
        """Enfants directs d'une catégorie - Accessible à tous"""
        category = self.get_object()
        children = category.children.filter(is_active=True).annotate(
            children_count=Count('children', filter=Q(children__is_active=True)),
            articles_count=Count('article', filter=Q(article__is_active=True))
        ).order_by('order', 'name')
        
        serializer = CategorySerializer(children, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[CanManageInventory])
    def move(self, request, pk=None):
        """
        Déplace une catégorie dans l'arborescence
        Nécessite : can_manage_inventory
        """
        category = self.get_object()
        new_parent_id = request.data.get('parent_id')
        new_order = request.data.get('order', 0)
        
        # Vérifications
        if new_parent_id and new_parent_id == str(category.id):
            return Response(
                {'error': 'Une catégorie ne peut pas être son propre parent'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Vérifier que le nouveau parent n'est pas un descendant
        if new_parent_id:
            try:
                new_parent = Category.objects.get(id=new_parent_id)
                if category in new_parent.get_children_recursive() or category == new_parent:
                    return Response(
                        {'error': 'Le nouveau parent ne peut pas être un descendant de cette catégorie'},
                        status=status.HTTP_400_BAD_REQUEST
                    )
                category.parent = new_parent
            except Category.DoesNotExist:
                return Response(
                    {'error': 'Parent non trouvé'},
                    status=status.HTTP_404_NOT_FOUND
                )
        else:
            category.parent = None
        
        category.order = new_order
        category.save()
        
        serializer = CategorySerializer(category, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['get'])
    def articles(self, request, pk=None):
        """Articles d'une catégorie - Accessible à tous"""
        category = self.get_object()
        include_children = request.query_params.get('include_children', 'false').lower() == 'true'
        
        if include_children:
            categories = [category] + category.get_children_recursive()
            articles = Article.objects.filter(
                category__in=categories, is_active=True
            ).select_related('category', 'brand', 'unit_of_measure')
        else:
            articles = Article.objects.filter(
                category=category, is_active=True
            ).select_related('category', 'brand', 'unit_of_measure')
        
        # Pagination simple
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 20))
        start = (page - 1) * page_size
        end = start + page_size
        
        serializer = ArticleListSerializer(articles[start:end], many=True, context={'request': request})
        return Response({
            'results': serializer.data,
            'count': articles.count(),
            'page': page,
            'page_size': page_size,
            'include_children': include_children
        })


class BrandViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les marques
    Permissions : Lecture pour tous, modification selon can_manage_inventory
    """
    queryset = Brand.objects.all()
    serializer_class = BrandSerializer
    permission_classes = [CanViewInventory]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['is_active']
    search_fields = ['name', 'description', 'website']
    ordering_fields = ['name', 'created_at']
    ordering = ['name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des marques"""
        return queryset.annotate(
            articles_count=Count('article', filter=Q(article__is_active=True))
        )
    
    @action(detail=True, methods=['get'])
    def articles(self, request, pk=None):
        """Articles d'une marque - Accessible à tous"""
        brand = self.get_object()
        articles = Article.objects.filter(brand=brand, is_active=True).select_related(
            'category', 'unit_of_measure'
        )
        
        # Pagination simple
        page = int(request.query_params.get('page', 1))
        page_size = int(request.query_params.get('page_size', 20))
        start = (page - 1) * page_size
        end = start + page_size
        
        serializer = ArticleListSerializer(articles[start:end], many=True, context={'request': request})
        return Response({
            'results': serializer.data,
            'count': articles.count(),
            'page': page,
            'page_size': page_size
        })


class SupplierViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les fournisseurs (version simplifiée)
    Permissions : Lecture pour tous, modification selon can_manage_inventory
    """
    queryset = Supplier.objects.all()
    serializer_class = SupplierSerializer
    permission_classes = [CanViewInventory]
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['is_active']
    search_fields = ['name', 'code', 'contact_person', 'email']
    ordering_fields = ['name', 'code', 'created_at']
    ordering = ['name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des fournisseurs"""
        return queryset.annotate(
            articles_count=Count('article', filter=Q(article__is_active=True))
        )


# ========================
# ARTICLES
# ========================

class ArticleViewSet(OptimizedModelViewSet):
    """
    ViewSet pour les articles avec logique métier complète
    Permissions granulaires selon les actions
    """
    queryset = Article.objects.all()
    parser_classes = (MultiPartParser, FormParser)
    permission_classes = [CanViewInventory]  # Par défaut : lecture pour tous
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = [
        'is_active', 'article_type', 'category', 'brand', 'is_sellable',
        'manage_stock', 'requires_lot_tracking', 'requires_expiry_date'
    ]
    search_fields = ['name', 'code', 'barcode', 'internal_reference', 'short_description']
    ordering_fields = ['name', 'code', 'purchase_price', 'selling_price', 'created_at']
    ordering = ['category__name', 'name']
    
    def get_serializer_class(self):
        """Serializer différent selon l'action"""
        if self.action == 'list':
            return ArticleListSerializer
        return ArticleDetailSerializer
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des articles"""
        return queryset.select_related(
            'category', 'brand', 'unit_of_measure', 'main_supplier'
        ).annotate(
            current_stock=Sum('stock_entries__quantity_on_hand'),
            available_stock=Sum('stock_entries__quantity_available'),
            variants_count=Count('variants', filter=Q(variants__is_active=True))
        )
    
    def optimize_detail_queryset(self, queryset):
        """Optimisations pour le détail d'un article"""
        return queryset.select_related(
            'category', 'brand', 'unit_of_measure', 'main_supplier', 'parent_article'
        ).prefetch_related(
            'additional_barcodes',
            'images',
            'price_history__created_by',
            'variants',
            'stock_entries__location'
        )
    
    def get_queryset(self):
        """Filtrage selon les paramètres"""
        queryset = super().get_queryset()
        
        # Filtre par code-barres
        barcode = self.request.query_params.get('barcode')
        if barcode:
            queryset = queryset.filter(
                Q(barcode=barcode) | 
                Q(additional_barcodes__barcode=barcode)
            )
        
        # Filtre stock bas
        low_stock = self.request.query_params.get('low_stock')
        if low_stock == 'true':
            queryset = queryset.filter(
                manage_stock=True
            ).annotate(
                current_stock_calc=Sum('stock_entries__quantity_on_hand')
            ).filter(
                current_stock_calc__lte=F('min_stock_level')
            )
        
        # Filtre par fournisseur
        supplier_id = self.request.query_params.get('supplier')
        if supplier_id:
            queryset = queryset.filter(
                Q(main_supplier_id=supplier_id) |
                Q(suppliers__supplier_id=supplier_id)
            )
        
        return queryset
    
    # Ajoutez cette méthode pour la création
    def perform_create(self, serializer):
        """
        Assigne automatiquement l'utilisateur connecté lors de la création d'un article.
        """
        # On passe l'utilisateur de la requête (self.request.user) 
        # au serializer au moment de la sauvegarde.
        serializer.save(created_by=self.request.user)

    # Ajoutez cette méthode pour la mise à jour
    def perform_update(self, serializer):
        """
        Assigne automatiquement l'utilisateur connecté lors de la mise à jour d'un article.
        """
        # On fait de même pour le champ updated_by
        serializer.save(updated_by=self.request.user)

    @action(detail=True, methods=['get'])
    def stock_summary(self, request, pk=None):
        """
        Résumé des stocks d'un article
        Accessible à tous (lecture)
        """
        article = self.get_object()
        stocks = Stock.objects.filter(article=article).select_related('location').annotate(
            stock_value=F('quantity_on_hand') * F('unit_cost')
        )
        
        total_stock = stocks.aggregate(
            total_quantity=Sum('quantity_on_hand'),
            total_available=Sum('quantity_available'),
            total_reserved=Sum('quantity_reserved'),
            total_value=Sum('stock_value'),
            locations_count=Count('location', distinct=True)
        )
        
        # Stocks par emplacement
        stock_by_location = []
        for stock in stocks:
            stock_by_location.append({
                'location': LocationSerializer(stock.location).data,
                'quantity_on_hand': stock.quantity_on_hand,
                'quantity_available': stock.quantity_available,
                'quantity_reserved': stock.quantity_reserved,
                'lot_number': stock.lot_number,
                'expiry_date': stock.expiry_date,
                'unit_cost': stock.unit_cost,
                'stock_value': float(stock.stock_value),
                'is_expired': stock.is_expired(),
                'days_until_expiry': stock.days_until_expiry()
            })
        
        return Response({
            'article': ArticleListSerializer(article, context={'request': request}).data,
            'total_stock': total_stock,
            'stock_by_location': stock_by_location,
            'is_low_stock': article.is_low_stock(),
            'manage_stock': article.manage_stock,
            'min_stock_level': article.min_stock_level,
            'max_stock_level': article.max_stock_level
        })
    
    @action(detail=True, methods=['get'])
    def price_history(self, request, pk=None):
        """
        Historique des prix d'un article
        Accessible à tous (lecture)
        """
        article = self.get_object()
        history = PriceHistory.objects.filter(article=article).select_related('created_by').order_by('-effective_date')
        
        serializer = PriceHistorySerializer(history, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=True, methods=['post'], permission_classes=[CanManageInventory])
    def duplicate(self, request, pk=None):
        """
        Duplique un article avec modifications
        Nécessite : can_manage_inventory
        """
        original_article = self.get_object()
        
        # Données pour le nouvel article
        duplicate_data = request.data.copy()
        duplicate_data['name'] = f"Copie de {original_article.name}"
        duplicate_data['code'] = f"{original_article.code}_COPY_{timezone.now().strftime('%Y%m%d_%H%M%S')}"
        duplicate_data['barcode'] = None  # Nouveau code-barres requis
        duplicate_data['internal_reference'] = None
        
        # Copier les propriétés de l'original si non spécifiées
        fields_to_copy = [
            'article_type', 'category_id', 'brand_id', 'unit_of_measure_id',
            'main_supplier_id', 'purchase_price', 'selling_price', 'manage_stock',
            'min_stock_level', 'max_stock_level', 'requires_lot_tracking',
            'requires_expiry_date', 'is_sellable', 'is_purchasable',
            'allow_negative_stock', 'weight', 'length', 'width', 'height'
        ]
        
        for field in fields_to_copy:
            if field not in duplicate_data:
                value = getattr(original_article, field.replace('_id', ''))
                if hasattr(value, 'id'):
                    duplicate_data[field] = str(value.id)
                else:
                    duplicate_data[field] = value
        
        serializer = ArticleDetailSerializer(data=duplicate_data, context={'request': request})
        if serializer.is_valid():
            new_article = serializer.save()
            
            # Copier les images si demandé
            if request.data.get('copy_images', False):
                for image in original_article.images.all():
                    ArticleImage.objects.create(
                        article=new_article,
                        image=image.image,
                        alt_text=image.alt_text,
                        caption=image.caption,
                        order=image.order
                    )
            
            # Copier les codes-barres additionnels si demandé
            if request.data.get('copy_barcodes', False):
                for barcode in original_article.additional_barcodes.all():
                    ArticleBarcode.objects.create(
                        article=new_article,
                        barcode=f"{barcode.barcode}_COPY",
                        barcode_type=barcode.barcode_type
                    )
            
            return Response(serializer.data, status=status.HTTP_201_CREATED)
        
        return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
    
    @action(detail=False, methods=['post'], permission_classes=[CanModifyPrices])
    def bulk_update_prices(self, request):
        """
        Mise à jour en masse des prix
        Nécessite : CanModifyPrices (admins/managers uniquement)
        """
        updates = request.data.get('updates', [])
        if not updates:
            return Response(
                {'error': 'Liste des mises à jour requise'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        updated_count = 0
        errors = []
        
        with transaction.atomic():
            for update in updates:
                try:
                    article = Article.objects.get(id=update['article_id'])
                    
                    # Sauvegarder l'historique
                    PriceHistory.objects.create(
                        article=article,
                        old_purchase_price=article.purchase_price,
                        old_selling_price=article.selling_price,
                        new_purchase_price=update.get('purchase_price', article.purchase_price),
                        new_selling_price=update.get('selling_price', article.selling_price),
                        reason=update.get('reason', 'bulk_update'),
                        notes=update.get('notes', ''),
                        created_by=request.user
                    )
                    
                    # Mettre à jour les prix
                    if 'purchase_price' in update:
                        article.purchase_price = update['purchase_price']
                    if 'selling_price' in update:
                        article.selling_price = update['selling_price']
                    
                    article.save()
                    updated_count += 1
                    
                except Article.DoesNotExist:
                    errors.append(f"Article {update['article_id']} non trouvé")
                except Exception as e:
                    errors.append(f"Erreur pour article {update['article_id']}: {str(e)}")
        
        return Response({
            'message': f'{updated_count} articles mis à jour',
            'updated_count': updated_count,
            'errors': errors
        })
    
    @action(detail=False, methods=['post'], permission_classes=[CanManageInventory])
    def bulk_operations(self, request):
        """
        Opérations en masse sur les articles
        Nécessite : can_manage_inventory
        """
        serializer = ArticleBulkUpdateSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        action_type = serializer.validated_data['action']
        article_ids = serializer.validated_data['ids']
        data = serializer.validated_data.get('data', {})
        
        articles = Article.objects.filter(id__in=article_ids)
        if not articles.exists():
            return Response(
                {'error': 'Aucun article trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        updated_count = 0
        
        with transaction.atomic():
            if action_type == 'activate':
                updated_count = articles.update(is_active=True)
            elif action_type == 'deactivate':
                updated_count = articles.update(is_active=False)
            elif action_type == 'delete':
                updated_count = articles.update(is_deleted=True)
            elif action_type == 'update_category' and 'category_id' in data:
                updated_count = articles.update(category_id=data['category_id'])
            elif action_type == 'update_supplier' and 'supplier_id' in data:
                updated_count = articles.update(main_supplier_id=data['supplier_id'])
        
        return Response({
            'message': f'Action {action_type} appliquée avec succès',
            'action': action_type,
            'updated_count': updated_count
        })
    
    @action(detail=False, methods=['post'], permission_classes=[CanManageInventory])
    def import_csv(self, request):
        """
        Import d'articles depuis un fichier CSV
        Nécessite : can_manage_inventory
        """
        csv_file = request.FILES.get('file')
        if not csv_file:
            return Response(
                {'error': 'Fichier CSV requis'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # Traitement du CSV
        decoded_file = csv_file.read().decode('utf-8')
        csv_data = csv.DictReader(io.StringIO(decoded_file))
        
        created_count = 0
        updated_count = 0
        errors = []
        
        with transaction.atomic():
            for row_num, row in enumerate(csv_data, start=2):
                try:
                    # Validation des champs requis
                    if not row.get('name') or not row.get('code'):
                        errors.append(f"Ligne {row_num}: nom et code requis")
                        continue
                    
                    # Recherche ou création de l'article
                    article, created = Article.objects.get_or_create(
                        code=row['code'],
                        defaults={
                            'name': row['name'],
                            'description': row.get('description', ''),
                            'purchase_price': Decimal(row.get('purchase_price', '0')),
                            'selling_price': Decimal(row.get('selling_price', '0')),
                            'created_by': request.user
                        }
                    )
                    
                    if created:
                        created_count += 1
                    else:
                        # Mise à jour si existant
                        article.name = row['name']
                        article.description = row.get('description', article.description)
                        if row.get('purchase_price'):
                            article.purchase_price = Decimal(row['purchase_price'])
                        if row.get('selling_price'):
                            article.selling_price = Decimal(row['selling_price'])
                        article.save()
                        updated_count += 1
                
                except Exception as e:
                    errors.append(f"Ligne {row_num}: {str(e)}")
        
        return Response({
            'message': 'Import terminé',
            'created_count': created_count,
            'updated_count': updated_count,
            'errors': errors
        })
    
    @action(detail=False, methods=['get'])
    def export_csv(self, request):
        """
        Export des articles en CSV
        Accessible à tous (lecture)
        """
        articles = self.filter_queryset(self.get_queryset())
        
        response = HttpResponse(content_type='text/csv')
        response['Content-Disposition'] = 'attachment; filename="articles.csv"'
        
        writer = csv.writer(response)
        writer.writerow([
            'Code', 'Nom', 'Description', 'Catégorie', 'Marque', 'Prix achat',
            'Prix vente', 'Stock actuel', 'Stock minimum', 'Unité', 'Actif'
        ])
        
        for article in articles.select_related('category', 'brand', 'unit_of_measure'):
            writer.writerow([
                article.code,
                article.name,
                article.description,
                article.category.name if article.category else '',
                article.brand.name if article.brand else '',
                article.purchase_price,
                article.selling_price,
                article.get_current_stock(),
                article.min_stock_level,
                article.unit_of_measure.symbol if article.unit_of_measure else '',
                'Oui' if article.is_active else 'Non'
            ])
        
        return response


# ========================
# EMPLACEMENTS ET STOCKS
# ========================

class LocationViewSet(StoreFilterMixin, OptimizedModelViewSet):
    """
    ViewSet COMPLET pour les emplacements avec filtrage multi-magasins
    🔴 MODIFIÉ : Ajout StoreFilterMixin
    """
    queryset = Location.objects.all()
    serializer_class = LocationSerializer
    permission_classes = [CanViewInventory]
    
    # 🔴 CONFIGURATION DU FILTRAGE
    store_filter_field = 'id'  # Filtre direct sur Location.id
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['is_active', 'location_type', 'parent']
    search_fields = ['name', 'code', 'barcode']
    ordering_fields = ['name', 'code', 'location_type', 'created_at']
    ordering = ['location_type', 'code', 'name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des emplacements"""
        return queryset.select_related('parent').annotate(
            children_count=Count('children', filter=Q(children__is_active=True)),
            stocks_count=Count('stock', filter=Q(stock__quantity_on_hand__gt=0))
        )
    
    @action(detail=True, methods=['get'])
    def stocks(self, request, pk=None):
        """Stocks dans cet emplacement - Accessible à tous (lecture)"""
        location = self.get_object()
        stocks = Stock.objects.filter(
            location=location,
            quantity_on_hand__gt=0
        ).select_related('article__category', 'article__brand')
        
        serializer = StockSerializer(stocks, many=True, context={'request': request})
        return Response(serializer.data)
    

class StockViewSet(StoreFilterMixin, OptimizedModelViewSet):
    """
    ViewSet COMPLET pour les stocks avec filtrage multi-magasins
    🔴 MODIFIÉ : Ajout StoreFilterMixin + TOUTES LES ACTIONS
    """
    queryset = Stock.objects.all()
    serializer_class = StockSerializer
    permission_classes = [CanManageStockMovements]
    
    # 🔴 CONFIGURATION DU FILTRAGE
    store_filter_field = 'location'  # Filtre sur Stock.location
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['article', 'location', 'expiry_date']
    search_fields = ['article__name', 'article__code', 'location__name', 'lot_number']
    ordering_fields = ['article__name', 'location__name', 'expiry_date', 'quantity_on_hand']
    ordering = ['article__name', 'location__name']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des stocks"""
        return queryset.select_related(
            'article__category', 'article__brand', 'article__unit_of_measure',
            'location'
        )
    
    def get_queryset(self):
        """Filtrage selon les paramètres + filtrage magasin"""
        # 🔴 IMPORTANT : Appeler super() pour activer StoreFilterMixin
        queryset = super().get_queryset()
        
        # Filtre stock positif uniquement
        positive_only = self.request.query_params.get('positive_only', 'false')
        if positive_only.lower() == 'true':
            queryset = queryset.filter(quantity_on_hand__gt=0)
        
        # Filtre produits expirés
        expired = self.request.query_params.get('expired')
        if expired == 'true':
            queryset = queryset.filter(expiry_date__lt=timezone.now().date())
        elif expired == 'false':
            queryset = queryset.filter(
                Q(expiry_date__gte=timezone.now().date()) | Q(expiry_date__isnull=True)
            )
        
        # Filtre expiration prochaine (30 jours)
        expiring_soon = self.request.query_params.get('expiring_soon')
        if expiring_soon == 'true':
            future_date = timezone.now().date() + timezone.timedelta(days=30)
            queryset = queryset.filter(
                expiry_date__gte=timezone.now().date(),
                expiry_date__lte=future_date
            )
        
        return queryset
    
    @action(detail=False, methods=['post'], permission_classes=[CanAdjustStock])
    def adjustment(self, request):
        """Ajustement de stock (inventaire) - Nécessite : CanAdjustStock"""
        serializer = StockAdjustmentSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        data = serializer.validated_data
        
        try:
            article = Article.objects.get(id=data['article_id'])
            location = Location.objects.get(id=data['location_id'])
        except (Article.DoesNotExist, Location.DoesNotExist):
            return Response(
                {'error': 'Article ou emplacement non trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # 🔴 Le Mixin valide déjà l'accès à la location dans perform_create
        
        # Rechercher ou créer le stock
        stock, created = Stock.objects.get_or_create(
            article=article,
            location=location,
            defaults={'quantity_on_hand': 0, 'unit_cost': article.purchase_price}
        )
        
        old_quantity = stock.quantity_on_hand
        new_quantity = data['new_quantity']
        adjustment_quantity = new_quantity - old_quantity
        
        with transaction.atomic():
            # Mettre à jour le stock
            stock.quantity_on_hand = new_quantity
            stock.save()
            
            # Créer le mouvement
            StockMovement.objects.create(
                article=article,
                stock=stock,
                movement_type='adjustment',
                reason=data['reason'],
                quantity=abs(adjustment_quantity),
                stock_before=old_quantity,
                stock_after=new_quantity,
                reference_document=data.get('reference_document', ''),
                notes=data.get('notes', ''),
                created_by=request.user
            )
        
        return Response({
            'message': 'Ajustement effectué avec succès',
            'old_quantity': float(old_quantity),
            'new_quantity': float(new_quantity),
            'adjustment': float(adjustment_quantity),
            'stock': StockSerializer(stock, context={'request': request}).data
        })
    
    @action(detail=False, methods=['post'], permission_classes=[CanManageStockMovements])
    def transfer(self, request):
        """Transfert de stock entre emplacements - Nécessite : CanManageStockMovements"""
        serializer = StockTransferSerializer(data=request.data)
        if not serializer.is_valid():
            return Response(serializer.errors, status=status.HTTP_400_BAD_REQUEST)
        
        data = serializer.validated_data
        
        try:
            article = Article.objects.get(id=data['article_id'])
            from_location = Location.objects.get(id=data['from_location_id'])
            to_location = Location.objects.get(id=data['to_location_id'])
        except (Article.DoesNotExist, Location.DoesNotExist):
            return Response(
                {'error': 'Article ou emplacement non trouvé'},
                status=status.HTTP_404_NOT_FOUND
            )
        
        # Vérifier le stock source
        try:
            from_stock = Stock.objects.get(article=article, location=from_location)
        except Stock.DoesNotExist:
            return Response(
                {'error': 'Pas de stock dans l\'emplacement source'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        if from_stock.quantity_available < data['quantity']:
            return Response(
                {'error': 'Stock disponible insuffisant'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        with transaction.atomic():
            # Sortie du stock source
            from_stock.quantity_on_hand -= data['quantity']
            from_stock.save()
            
            StockMovement.objects.create(
                article=article,
                stock=from_stock,
                movement_type='out',
                reason='transfer',
                quantity=data['quantity'],
                stock_before=from_stock.quantity_on_hand + data['quantity'],
                stock_after=from_stock.quantity_on_hand,
                reference_document=data.get('reference_document', ''),
                notes=data.get('notes', ''),
                created_by=request.user
            )
            
            # Entrée dans le stock cible
            to_stock, created = Stock.objects.get_or_create(
                article=article,
                location=to_location,
                defaults={'quantity_on_hand': 0, 'unit_cost': article.purchase_price}
            )
            
            old_to_quantity = to_stock.quantity_on_hand
            to_stock.quantity_on_hand += data['quantity']
            to_stock.save()
            
            StockMovement.objects.create(
                article=article,
                stock=to_stock,
                movement_type='in',
                reason='transfer',
                quantity=data['quantity'],
                stock_before=old_to_quantity,
                stock_after=to_stock.quantity_on_hand,
                reference_document=data.get('reference_document', ''),
                notes=data.get('notes', ''),
                created_by=request.user
            )
        
        return Response({
            'message': 'Transfert effectué avec succès',
            'quantity': float(data['quantity']),
            'from_location': LocationSerializer(from_location).data,
            'to_location': LocationSerializer(to_location).data
        })
    
    @action(detail=False, methods=['get'])
    def alerts(self, request):
        """Alertes de stock actives - Accessible à tous (lecture)"""
        # 🔴 Le queryset est déjà filtré par magasin grâce au Mixin
        alerts = StockAlert.objects.filter(
            is_acknowledged=False
        ).select_related(
            'article__category', 'article__brand', 'stock__location'
        ).order_by('alert_level', '-created_at')
        
        serializer = StockAlertSerializer(alerts, many=True, context={'request': request})
        return Response(serializer.data)
    
    @action(detail=False, methods=['get'])
    def valuation(self, request):
        """Valorisation du stock - Accessible à tous (lecture)"""
        # 🔴 Le queryset est déjà filtré par magasin grâce au Mixin
        stocks = self.get_queryset().filter(quantity_on_hand__gt=0).select_related('article')
        
        total_value = stocks.aggregate(
            value=Sum(F('quantity_on_hand') * F('unit_cost'))
        )['value'] or 0
        
        # Valorisation par catégorie
        by_category = {}
        for stock in stocks:
            category_name = stock.article.category.name if stock.article.category else 'Sans catégorie'
            if category_name not in by_category:
                by_category[category_name] = {
                    'articles_count': 0,
                    'total_quantity': 0,
                    'total_value': 0
                }
            
            value = float(stock.quantity_on_hand * stock.unit_cost)
            by_category[category_name]['articles_count'] += 1
            by_category[category_name]['total_quantity'] += float(stock.quantity_on_hand)
            by_category[category_name]['total_value'] += value
        
        return Response({
            'total_value': float(total_value),
            'total_articles': stocks.count(),
            'by_category': by_category
        })


class StockMovementViewSet(StoreFilterMixin, viewsets.ReadOnlyModelViewSet):
    """
    ViewSet COMPLET en lecture seule pour les mouvements de stock
    🔴 MODIFIÉ : Ajout StoreFilterMixin + TOUTES LES ACTIONS
    """
    queryset = StockMovement.objects.all()
    serializer_class = StockMovementSerializer
    permission_classes = [CanViewInventory]
    
    # 🔴 CONFIGURATION DU FILTRAGE
    store_filter_field = 'stock__location'  # Filtre via relation Stock
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['movement_type', 'reason', 'article', 'stock__location']
    search_fields = ['article__name', 'article__code', 'reference_document', 'notes']
    ordering_fields = ['created_at', 'quantity']
    ordering = ['-created_at']
    
    def get_queryset(self):
        """Optimisations et filtres + filtrage magasin"""
        # 🔴 IMPORTANT : Appeler super() pour activer StoreFilterMixin
        queryset = super().get_queryset().select_related(
            'article__category', 'article__brand', 'stock__location', 'created_by'
        )
        
        # Filtre par période
        date_from = self.request.query_params.get('date_from')
        date_to = self.request.query_params.get('date_to')
        
        if date_from:
            queryset = queryset.filter(created_at__date__gte=date_from)
        if date_to:
            queryset = queryset.filter(created_at__date__lte=date_to)
        
        return queryset
    
    @action(detail=False, methods=['get'])
    def summary(self, request):
        """Résumé des mouvements par période - Accessible à tous (lecture)"""
        # 🔴 Le queryset est déjà filtré par magasin grâce au Mixin
        movements = self.filter_queryset(self.get_queryset())
        
        summary = movements.aggregate(
            total_movements=Count('id'),
            total_in=Count('id', filter=Q(movement_type='in')),
            total_out=Count('id', filter=Q(movement_type='out')),
            total_adjustments=Count('id', filter=Q(movement_type='adjustment')),
        )
        
        # Groupement par jour
        daily_summary = movements.extra(
            select={'day': 'date(created_at)'}
        ).values('day').annotate(
            movements_count=Count('id'),
            in_count=Count('id', filter=Q(movement_type='in')),
            out_count=Count('id', filter=Q(movement_type='out'))
        ).order_by('day')
        
        return Response({
            'summary': summary,
            'daily_summary': list(daily_summary)
        })
    

class StockAlertViewSet(StoreFilterMixin, OptimizedModelViewSet):
    """
    ViewSet COMPLET pour les alertes de stock avec filtrage multi-magasins
    🔴 MODIFIÉ : Ajout StoreFilterMixin + TOUTES LES ACTIONS
    """
    queryset = StockAlert.objects.all()
    serializer_class = StockAlertSerializer
    permission_classes = [CanViewInventory]
    
    # 🔴 CONFIGURATION DU FILTRAGE
    store_filter_field = 'stock__location'  # Filtre via relation Stock
    
    filter_backends = [DjangoFilterBackend, SearchFilter, OrderingFilter]
    filterset_fields = ['alert_type', 'alert_level', 'is_acknowledged']
    search_fields = ['article__name', 'article__code', 'message']
    ordering_fields = ['created_at', 'alert_level']
    ordering = ['-created_at']
    
    def optimize_list_queryset(self, queryset):
        """Optimisations pour la liste des alertes"""
        return queryset.select_related(
            'article__category', 'article__brand', 'stock__location', 'acknowledged_by'
        )
    
    @action(detail=True, methods=['post'], permission_classes=[CanManageStockMovements])
    def acknowledge(self, request, pk=None):
        """Acquitter une alerte - Nécessite : CanManageStockMovements"""
        alert = self.get_object()
        
        if alert.is_acknowledged:
            return Response(
                {'error': 'Alerte déjà acquittée'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        alert.is_acknowledged = True
        alert.acknowledged_by = request.user
        alert.acknowledged_at = timezone.now()
        alert.save()
        
        return Response({
            'message': 'Alerte acquittée avec succès',
            'acknowledged_at': alert.acknowledged_at,
            'acknowledged_by': alert.acknowledged_by.get_full_name()
        })
    
    @action(detail=False, methods=['post'], permission_classes=[CanManageStockMovements])
    def bulk_acknowledge(self, request):
        """Acquitter plusieurs alertes - Nécessite : CanManageStockMovements"""
        alert_ids = request.data.get('alert_ids', [])
        if not alert_ids:
            return Response(
                {'error': 'Liste des IDs d\'alertes requise'},
                status=status.HTTP_400_BAD_REQUEST
            )
        
        # 🔴 Le queryset est déjà filtré par magasin grâce au Mixin
        alerts = self.get_queryset().filter(
            id__in=alert_ids,
            is_acknowledged=False
        )
        
        updated_count = alerts.update(
            is_acknowledged=True,
            acknowledged_by=request.user,
            acknowledged_at=timezone.now()
        )
        
        return Response({
            'message': f'{updated_count} alertes acquittées',
            'updated_count': updated_count
        })
    
    @action(detail=False, methods=['get'])
    def dashboard(self, request):
        """Dashboard des alertes - Accessible à tous (lecture)"""
        # 🔴 Le queryset est déjà filtré par magasin grâce au Mixin
        alerts = self.get_queryset().filter(is_acknowledged=False)
        
        counts = alerts.aggregate(
            total=Count('id'),
            critical=Count('id', filter=Q(alert_level='critical')),
            warning=Count('id', filter=Q(alert_level='warning')),
            info=Count('id', filter=Q(alert_level='info')),
            low_stock=Count('id', filter=Q(alert_type='low_stock')),
            out_of_stock=Count('id', filter=Q(alert_type='out_of_stock')),
            expiry_soon=Count('id', filter=Q(alert_type='expiry_soon')),
            expired=Count('id', filter=Q(alert_type='expired'))
        )
        
        # Alertes récentes (dernières 24h)
        recent_alerts = alerts.filter(
            created_at__gte=timezone.now() - timezone.timedelta(days=1)
        ).order_by('-created_at')[:10]
        
        return Response({
            'counts': counts,
            'recent_alerts': StockAlertSerializer(recent_alerts, many=True, context={'request': request}).data
        })

   