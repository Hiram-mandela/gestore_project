# apps/sales/models.py

"""
Modèles de gestion des ventes pour GESTORE - VERSION MULTI-MAGASINS
Système complet de point de vente, transactions et paiements
MODIFICATION MAJEURE : Ajout du champ location pour tracer le magasin de chaque vente
"""
from django.db import models
from django.core.validators import MinValueValidator, MaxValueValidator
from django.utils import timezone
from django.contrib.auth import get_user_model
from apps.core.models import BaseModel, AuditableModel, NamedModel, ActivableModel
from apps.inventory.models import Article
from decimal import Decimal

User = get_user_model()


class Customer(BaseModel, NamedModel, ActivableModel):
    """
    Clients du magasin
    Gestion de la fidélité et historique d'achats
    """
    CUSTOMER_TYPES = [
        ('individual', 'Particulier'),
        ('company', 'Entreprise'),
        ('professional', 'Professionnel'),
    ]
    
    customer_type = models.CharField(
        max_length=20,
        choices=CUSTOMER_TYPES,
        default='individual',
        verbose_name="Type de client"
    )
    
    customer_code = models.CharField(
        max_length=20,
        unique=True,
        verbose_name="Code client",
        help_text="Code unique généré automatiquement"
    )
    
    # Informations de contact
    first_name = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Prénom"
    )
    
    last_name = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Nom de famille"
    )
    
    company_name = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="Nom de l'entreprise"
    )
    
    email = models.EmailField(
        blank=True,
        verbose_name="Email"
    )
    
    phone = models.CharField(
        max_length=20,
        blank=True,
        verbose_name="Téléphone"
    )
    
    address = models.TextField(
        blank=True,
        verbose_name="Adresse"
    )
    
    city = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="Ville"
    )
    
    postal_code = models.CharField(
        max_length=10,
        blank=True,
        verbose_name="Code postal"
    )
    
    country = models.CharField(
        max_length=50,
        default='Côte d\'Ivoire',
        verbose_name="Pays"
    )
    
    # Informations fiscales
    tax_number = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Numéro fiscal/TVA"
    )
    
    # Fidélité
    loyalty_card_number = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True,
        verbose_name="Numéro carte fidélité"
    )
    
    loyalty_points = models.IntegerField(
        default=0,
        verbose_name="Points fidélité"
    )
    
    # Statistiques
    total_purchases = models.DecimalField(
        max_digits=12,
        decimal_places=2,
        default=0.00,
        verbose_name="Total des achats"
    )
    
    purchase_count = models.IntegerField(
        default=0,
        verbose_name="Nombre d'achats"
    )
    
    last_purchase_date = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Dernier achat"
    )
    
    # Préférences
    preferred_payment_method = models.CharField(
        max_length=20,
        blank=True,
        verbose_name="Moyen de paiement préféré"
    )
    
    marketing_consent = models.BooleanField(
        default=False,
        verbose_name="Consent marketing",
        help_text="A consenti à recevoir des communications marketing"
    )
    
    def save(self, *args, **kwargs):
        if not self.customer_code:
            last_customer = Customer.objects.order_by('customer_code').last()
            
            if last_customer and last_customer.customer_code:
                try:
                    last_number = int(last_customer.customer_code[3:])
                    new_number = last_number + 1
                except (ValueError, IndexError):
                    new_number = 1
            else:
                new_number = 1
            
            self.customer_code = f"CLI{new_number:06d}"
        
        super().save(*args, **kwargs)
    
    def get_full_name(self):
        """Retourne le nom complet du client"""
        if self.customer_type == 'company':
            return self.company_name
        return f"{self.first_name} {self.last_name}".strip() or self.customer_code
    
    class Meta:
        db_table = 'sales_customer'
        verbose_name = 'Client'
        verbose_name_plural = 'Clients'
        ordering = ['customer_code']


class PaymentMethod(BaseModel, NamedModel, ActivableModel):
    """
    Méthodes de paiement disponibles
    """
    PAYMENT_TYPES = [
        ('cash', 'Espèces'),
        ('card', 'Carte bancaire'),
        ('mobile_money', 'Mobile Money'),
        ('check', 'Chèque'),
        ('bank_transfer', 'Virement bancaire'),
        ('loyalty_points', 'Points fidélité'),
        ('voucher', 'Bon d\'achat'),
        ('other', 'Autre'),
    ]
    
    payment_type = models.CharField(
        max_length=20,
        choices=PAYMENT_TYPES,
        verbose_name="Type de paiement"
    )
    
    requires_reference = models.BooleanField(
        default=False,
        verbose_name="Référence requise",
        help_text="Nécessite une référence de transaction"
    )
    
    requires_authorization = models.BooleanField(
        default=False,
        verbose_name="Autorisation requise",
        help_text="Nécessite une autorisation managériale"
    )
    
    account_number = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Numéro de compte",
        help_text="Numéro de compte comptable associé"
    )
    
    max_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0)],
        verbose_name="Montant maximum",
        help_text="Montant maximum autorisé pour cette méthode de paiement"
    )
    
    fee_percentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0.00,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        verbose_name="Frais (%)",
        help_text="Pourcentage de frais appliqué sur cette méthode de paiement"
    )

    class Meta:
        db_table = 'sales_payment_method'
        verbose_name = 'Méthode de paiement'
        verbose_name_plural = 'Méthodes de paiement'
        ordering = ['name']


class Sale(AuditableModel):
    """
    Vente / Transaction
    Modèle principal pour enregistrer les ventes au POS
    
    MODIFICATION MAJEURE v1.8 : Ajout du champ location pour tracer le magasin
    """
    SALE_TYPES = [
        ('regular', 'Vente normale'),
        ('return', 'Retour'),
        ('exchange', 'Échange'),
        ('quote', 'Devis'),
    ]
    
    SALE_STATUS = [
        ('draft', 'Brouillon'),
        ('pending', 'En attente'),
        ('completed', 'Terminée'),
        ('cancelled', 'Annulée'),
        ('refunded', 'Remboursée'),
        ('partially_refunded', 'Partiellement remboursée'),
    ]
    
    sale_number = models.CharField(
        max_length=30,
        unique=True,
        verbose_name="Numéro de vente",
        help_text="Numéro unique généré automatiquement"
    )
    
    sale_type = models.CharField(
        max_length=20,
        choices=SALE_TYPES,
        default='regular',
        verbose_name="Type de vente"
    )
    
    status = models.CharField(
        max_length=20,
        choices=SALE_STATUS,
        default='draft',
        verbose_name="Statut"
    )
    
    # 🔴 NOUVEAU CHAMP CRITIQUE : MAGASIN OÙ LA VENTE A ÉTÉ EFFECTUÉE
    location = models.ForeignKey(
        'inventory.Location',
        on_delete=models.PROTECT,
        limit_choices_to={'location_type__in': ['store', 'aisle']},
        related_name='sales',
        verbose_name="Point de vente",
        help_text="Magasin/Emplacement où la vente a été effectuée"
    )
    
    # Client
    customer = models.ForeignKey(
        Customer,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name='sales',
        verbose_name="Client"
    )
    
    # Vendeur/Caissier
    cashier = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        related_name='sales_as_cashier',
        verbose_name="Caissier"
    )
    
    # Dates
    sale_date = models.DateTimeField(
        default=timezone.now,
        verbose_name="Date de vente"
    )
    
    # Montants
    subtotal = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Sous-total HT",
        help_text="Montant hors taxes avant remises"
    )
    
    discount_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant remise",
        help_text="Montant total des remises appliquées"
    )
    
    tax_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant TVA"
    )
    
    total_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant total TTC"
    )
    
    paid_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant payé"
    )
    
    change_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Monnaie rendue"
    )
    
    # Fidélité
    loyalty_points_earned = models.IntegerField(
        default=0,
        verbose_name="Points fidélité gagnés"
    )
    
    loyalty_points_used = models.IntegerField(
        default=0,
        verbose_name="Points fidélité utilisés"
    )
    
    # Vente liée (pour les retours/échanges)
    original_sale = models.ForeignKey(
        'self',
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name='related_sales',
        verbose_name="Vente d'origine"
    )
    
    # Notes
    notes = models.TextField(
        blank=True,
        verbose_name="Notes",
        help_text="Notes internes sur la vente"
    )
    
    customer_notes = models.TextField(
        blank=True,
        verbose_name="Notes client",
        help_text="Notes visibles sur le ticket"
    )
    
    # Configuration
    receipt_printed = models.BooleanField(
        default=False,
        verbose_name="Ticket imprimé"
    )
    
    receipt_emailed = models.BooleanField(
        default=False,
        verbose_name="Ticket envoyé par email"
    )
    
    def save(self, *args, **kwargs):
        if not self.sale_number:
            # Générer le numéro de vente
            today = timezone.now().date()
            prefix = f"VTE{today.strftime('%Y%m%d')}"
            
            last_sale = Sale.objects.filter(
                sale_number__startswith=prefix
            ).order_by('sale_number').last()
            
            if last_sale and last_sale.sale_number:
                try:
                    last_number = int(last_sale.sale_number[-4:])
                    self.sale_number = f"{prefix}{last_number + 1:04d}"
                except ValueError:
                    self.sale_number = f"{prefix}0001"
            else:
                self.sale_number = f"{prefix}0001"
        
        super().save(*args, **kwargs)
    
    def calculate_totals(self):
        """Recalcule tous les totaux de la vente"""
        items = self.items.all()
        
        # Utiliser Decimal pour les sommes
        self.subtotal = sum((item.line_total for item in items), Decimal('0.00'))
        self.tax_amount = sum((item.tax_amount for item in items), Decimal('0.00'))
        
        # S'assurer que discount_amount est un Decimal
        if not isinstance(self.discount_amount, Decimal):
            self.discount_amount = Decimal(str(self.discount_amount))
        
        self.total_amount = self.subtotal + self.tax_amount - self.discount_amount
        
        # Points fidélité (1 point par euro dépensé)
        if self.customer and self.total_amount > 0:
            self.loyalty_points_earned = int(self.total_amount)
        
        self.save()
    
    def is_paid(self):
        """Vérifie si la vente est entièrement payée"""
        return self.paid_amount >= self.total_amount
    
    def get_balance(self):
        """Retourne le solde restant à payer"""
        return self.total_amount - self.paid_amount
    
    def can_be_returned(self):
        """Vérifie si la vente peut être retournée"""
        return (
            self.status == 'completed' and
            self.sale_type == 'regular' and
            self.sale_date >= timezone.now() - timezone.timedelta(days=30)
        )

    class Meta:
        db_table = 'sales_sale'
        verbose_name = 'Vente'
        verbose_name_plural = 'Ventes'
        ordering = ['-sale_date']
        indexes = [
            models.Index(fields=['sale_number']),
            models.Index(fields=['sale_date']),
            models.Index(fields=['customer', 'sale_date']),
            models.Index(fields=['cashier', 'sale_date']),
            models.Index(fields=['location', 'sale_date']),  # NOUVEL INDEX
        ]


class SaleItem(BaseModel):
    """
    Ligne de vente
    Article vendu dans une transaction
    """
    sale = models.ForeignKey(
        Sale,
        on_delete=models.CASCADE,
        related_name='items',
        verbose_name="Vente"
    )
    
    article = models.ForeignKey(
        Article,
        on_delete=models.PROTECT,
        verbose_name="Article"
    )
    
    # Informations au moment de la vente
    article_name = models.CharField(
        max_length=200,
        verbose_name="Nom article",
        help_text="Nom de l'article au moment de la vente"
    )
    
    article_code = models.CharField(
        max_length=50,
        verbose_name="Code article",
        help_text="Code de l'article au moment de la vente"
    )
    
    # Quantité et prix
    quantity = models.DecimalField(
        max_digits=10,
        decimal_places=3,
        validators=[MinValueValidator(0.001)],
        verbose_name="Quantité"
    )
    
    unit_price = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Prix unitaire",
        help_text="Prix unitaire au moment de la vente"
    )
    
    # Remises
    discount_percentage = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0.00,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        verbose_name="Remise (%)"
    )
    
    discount_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant remise"
    )
    
    # Totaux
    line_total = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Total ligne",
        help_text="Total de la ligne après remise"
    )
    
    # Taxes
    tax_rate = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0.00,
        verbose_name="Taux de TVA (%)"
    )
    
    tax_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        default=0.00,
        verbose_name="Montant TVA"
    )
    
    # Traçabilité stock
    stock_movement = models.ForeignKey(
        'inventory.StockMovement',
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        verbose_name="Mouvement de stock associé"
    )
    
    lot_number = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Numéro de lot vendu"
    )
    
    def save(self, *args, **kwargs):
        # Copier les informations de l'article
        if self.article:
            self.article_name = self.article.name
            self.article_code = self.article.code
            if not self.unit_price:
                self.unit_price = self.article.selling_price
            if not self.tax_rate:
                self.tax_rate = self.article.category.tax_rate
        
        # Calculer les montants
        gross_amount = self.quantity * self.unit_price
        
        # Forcer la conversion en Decimal
        if self.discount_percentage > 0:
            self.discount_amount = gross_amount * (self.discount_percentage / Decimal('100'))
        else:
            self.discount_amount = Decimal('0.00')
        
        self.line_total = gross_amount - self.discount_amount
        self.tax_amount = self.line_total * (self.tax_rate / Decimal('100'))
        
        super().save(*args, **kwargs)

    class Meta:
        db_table = 'sales_sale_item'
        verbose_name = 'Ligne de vente'
        verbose_name_plural = 'Lignes de vente'
        ordering = ['sale', 'created_at']


class Payment(AuditableModel):
    """
    Paiement d'une vente
    Une vente peut avoir plusieurs paiements (paiement mixte)
    """
    PAYMENT_STATUS = [
        ('pending', 'En attente'),
        ('completed', 'Terminé'),
        ('failed', 'Échoué'),
        ('cancelled', 'Annulé'),
        ('refunded', 'Remboursé'),
    ]
    
    sale = models.ForeignKey(
        Sale,
        on_delete=models.CASCADE,
        related_name='payments',
        verbose_name="Vente"
    )
    
    payment_method = models.ForeignKey(
        PaymentMethod,
        on_delete=models.PROTECT,
        verbose_name="Méthode de paiement"
    )
    
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        validators=[MinValueValidator(0.01)],
        verbose_name="Montant"
    )
    
    status = models.CharField(
        max_length=20,
        choices=PAYMENT_STATUS,
        default='pending',
        verbose_name="Statut"
    )
    
    # Références externes
    reference_number = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="Numéro de référence",
        help_text="Référence de transaction externe"
    )
    
    authorization_code = models.CharField(
        max_length=50,
        blank=True,
        verbose_name="Code d'autorisation"
    )
    
    # Détails supplémentaires
    payment_date = models.DateTimeField(
        default=timezone.now,
        verbose_name="Date de paiement"
    )
    
    notes = models.TextField(
        blank=True,
        verbose_name="Notes"
    )

    class Meta:
        db_table = 'sales_payment'
        verbose_name = 'Paiement'
        verbose_name_plural = 'Paiements'
        ordering = ['-payment_date']


class Discount(BaseModel, NamedModel, ActivableModel):
    """
    Remises et promotions
    Configuration des remises automatiques ou manuelles
    """
    DISCOUNT_TYPES = [
        ('percentage', 'Pourcentage'),
        ('fixed', 'Montant fixe'),
        ('buy_x_get_y', 'Achetez X obtenez Y'),
        ('bundle', 'Pack promotionnel'),
    ]
    
    DISCOUNT_SCOPES = [
        ('cart', 'Sur le panier'),
        ('category', 'Sur catégorie'),
        ('article', 'Sur article'),
        ('customer', 'Sur client'),
    ]
    
    discount_type = models.CharField(
        max_length=20,
        choices=DISCOUNT_TYPES,
        verbose_name="Type de remise"
    )
    
    scope = models.CharField(
        max_length=20,
        choices=DISCOUNT_SCOPES,
        verbose_name="Portée de la remise"
    )
    
    # Valeurs
    percentage_value = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0), MaxValueValidator(100)],
        verbose_name="Valeur pourcentage"
    )
    
    fixed_value = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0)],
        verbose_name="Valeur fixe"
    )
    
    # Conditions
    min_quantity = models.IntegerField(
        null=True,
        blank=True,
        validators=[MinValueValidator(1)],
        verbose_name="Quantité minimum"
    )
    
    min_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0)],
        verbose_name="Montant minimum"
    )
    
    max_amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        null=True,
        blank=True,
        validators=[MinValueValidator(0)],
        verbose_name="Montant maximum"
    )
    
    # Cibles
    target_categories = models.ManyToManyField(
        'inventory.Category',
        blank=True,
        verbose_name="Catégories cibles"
    )
    
    target_articles = models.ManyToManyField(
        Article,
        blank=True,
        verbose_name="Articles cibles"
    )
    
    target_customers = models.ManyToManyField(
        Customer,
        blank=True,
        verbose_name="Clients cibles"
    )
    
    # Période de validité
    start_date = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Date de début"
    )
    
    end_date = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Date de fin"
    )
    
    # Limitations
    max_uses = models.IntegerField(
        null=True,
        blank=True,
        validators=[MinValueValidator(1)],
        verbose_name="Utilisations maximum"
    )
    
    max_uses_per_customer = models.IntegerField(
        null=True,
        blank=True,
        validators=[MinValueValidator(1)],
        verbose_name="Utilisations max par client"
    )
    
    current_uses = models.IntegerField(
        default=0,
        verbose_name="Utilisations actuelles"
    )
    
    def is_valid(self):
        """Vérifie si la remise est valide actuellement"""
        now = timezone.now()
        
        if not self.is_active:
            return False
        
        if self.start_date and now < self.start_date:
            return False
        
        if self.end_date and now > self.end_date:
            return False
        
        if self.max_uses and self.current_uses >= self.max_uses:
            return False
        
        return True
    
    def calculate_discount(self, amount, quantity=1):
        """Calcule le montant de la remise"""
        if not self.is_valid():
            return Decimal('0.00')
        
        # Vérifier conditions minimum
        if self.min_quantity and quantity < self.min_quantity:
            return Decimal('0.00')
        
        if self.min_amount and amount < self.min_amount:
            return Decimal('0.00')
        
        # Calculer la remise
        if self.discount_type == 'percentage' and self.percentage_value:
            discount = amount * (self.percentage_value / Decimal('100'))
        elif self.discount_type == 'fixed' and self.fixed_value:
            discount = self.fixed_value
        else:
            discount = Decimal('0.00')
        
        # Limiter au montant de la transaction
        if discount > amount:
            discount = amount
        
        # Limiter au montant maximum si défini
        if self.max_amount is not None and discount > self.max_amount:
            discount = self.max_amount
        
        return discount.quantize(Decimal('0.01'))
    
    def increment_usage(self):
        """Incrémente le compteur d'utilisation"""
        if self.max_uses is not None:
            self.current_uses = models.F('current_uses') + 1
            self.save(update_fields=['current_uses'])

    class Meta:
        db_table = 'sales_discount'
        verbose_name = 'Remise'
        verbose_name_plural = 'Remises'
        ordering = ['-start_date', 'name']


class SaleDiscount(BaseModel):
    """
    Remises appliquées à une vente
    """
    sale = models.ForeignKey(
        Sale,
        on_delete=models.CASCADE,
        related_name='applied_discounts',
        verbose_name="Vente"
    )
    
    discount = models.ForeignKey(
        Discount,
        on_delete=models.PROTECT,
        verbose_name="Remise"
    )
    
    amount = models.DecimalField(
        max_digits=10,
        decimal_places=2,
        verbose_name="Montant de la remise"
    )
    
    authorized_by = models.ForeignKey(
        User,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        verbose_name="Autorisée par"
    )

    class Meta:
        db_table = 'sales_sale_discount'
        verbose_name = 'Remise appliquée'
        verbose_name_plural = 'Remises appliquées'


class Receipt(BaseModel):
    """
    Tickets de caisse
    Configuration et historique des impressions
    """
    sale = models.OneToOneField(
        Sale,
        on_delete=models.CASCADE,
        related_name='receipt',
        verbose_name="Vente"
    )
    
    receipt_number = models.CharField(
        max_length=30,
        unique=True,
        verbose_name="Numéro de ticket"
    )
    
    # Configuration d'impression
    header_text = models.TextField(
        blank=True,
        verbose_name="Texte d'en-tête"
    )
    
    footer_text = models.TextField(
        blank=True,
        verbose_name="Texte de pied de page"
    )
    
    # Impression
    printed_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Imprimé le"
    )
    
    print_count = models.IntegerField(
        default=0,
        verbose_name="Nombre d'impressions"
    )
    
    emailed_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Envoyé par email le"
    )

    class Meta:
        db_table = 'sales_receipt'
        verbose_name = 'Ticket de caisse'
        verbose_name_plural = 'Tickets de caisse'
        