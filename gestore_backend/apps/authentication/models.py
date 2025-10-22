"""
Modèles d'authentification et de sécurité pour GESTORE - VERSION MULTI-MAGASINS
Système complet de gestion des utilisateurs, rôles et permissions
MODIFICATION MAJEURE : Ajout du champ assigned_store pour la gestion multi-magasins
"""
import uuid
from django.contrib.auth.models import AbstractUser, Group, Permission
from django.db import models
from django.utils import timezone
from django.core.validators import RegexValidator
from apps.core.models import BaseModel, AuditableModel, NamedModel, ActivableModel


class Role(BaseModel, NamedModel, ActivableModel):
    """
    Rôles utilisateur pour GESTORE
    Système flexible de rôles avec permissions granulaires
    """
    ROLE_TYPES = [
        ('admin', 'Administrateur Système'),
        ('manager', 'Directeur/Gérant'),
        ('stock_manager', 'Responsable Stock'),
        ('cashier', 'Caissier'),
        ('pharmacist', 'Pharmacien'),
        ('seller', 'Vendeur'),
        ('viewer', 'Consultation uniquement'),
    ]
    
    role_type = models.CharField(
        max_length=20,
        choices=ROLE_TYPES,
        unique=True,
        verbose_name="Type de rôle",
        help_text="Type prédéfini de rôle"
    )
    
    permissions = models.ManyToManyField(
        Permission,
        blank=True,
        verbose_name="Permissions",
        help_text="Permissions spécifiques à ce rôle"
    )
    
    # Permissions modules GESTORE
    can_manage_users = models.BooleanField(
        default=False,
        verbose_name="Gestion utilisateurs",
        help_text="Peut créer/modifier/supprimer des utilisateurs"
    )
    can_manage_inventory = models.BooleanField(
        default=False,
        verbose_name="Gestion stocks",
        help_text="Peut gérer les articles et stocks"
    )
    can_manage_sales = models.BooleanField(
        default=False,
        verbose_name="Gestion ventes",
        help_text="Peut effectuer des ventes"
    )
    can_manage_suppliers = models.BooleanField(
        default=False,
        verbose_name="Gestion fournisseurs",
        help_text="Peut gérer les fournisseurs et commandes"
    )
    can_view_reports = models.BooleanField(
        default=False,
        verbose_name="Consultation rapports",
        help_text="Peut consulter les rapports"
    )
    can_manage_reports = models.BooleanField(
        default=False,
        verbose_name="Gestion rapports",
        help_text="Peut créer et modifier les rapports"
    )
    can_manage_settings = models.BooleanField(
        default=False,
        verbose_name="Gestion paramètres",
        help_text="Peut modifier les paramètres système"
    )
    
    # Permissions financières
    can_apply_discounts = models.BooleanField(
        default=False,
        verbose_name="Application remises",
        help_text="Peut appliquer des remises"
    )
    max_discount_percent = models.DecimalField(
        max_digits=5,
        decimal_places=2,
        default=0,
        verbose_name="Remise maximum (%)",
        help_text="Pourcentage maximum de remise autorisé"
    )
    can_void_transactions = models.BooleanField(
        default=False,
        verbose_name="Annulation transactions",
        help_text="Peut annuler des transactions"
    )
    
    class Meta:
        db_table = 'auth_role'
        verbose_name = 'Rôle'
        verbose_name_plural = 'Rôles'
        ordering = ['role_type', 'name']


class User(AbstractUser):
    """
    Modèle utilisateur personnalisé pour GESTORE avec support multi-magasins
    Étend le modèle User par défaut de Django
    
    MODIFICATION MAJEURE v1.8 : Ajout du champ assigned_store pour la gestion multi-magasins
    - Les employés sont assignés à UN magasin spécifique
    - Les admins ont assigned_store=NULL pour accès global
    """
    # Remplacer l'ID par UUID
    id = models.UUIDField(
        primary_key=True,
        default=uuid.uuid4,
        editable=False
    )
    
    # Informations de base étendues
    employee_code = models.CharField(
        max_length=20,
        unique=True,
        null=True,
        blank=True,
        verbose_name="Code employé",
        help_text="Code unique de l'employé"
    )
    
    phone_regex = RegexValidator(
        regex=r'^\+?1?\d{9,15}$',
        message="Le numéro doit être au format: '+999999999'. Jusqu'à 15 chiffres."
    )
    phone_number = models.CharField(
        validators=[phone_regex],
        max_length=17,
        blank=True,
        verbose_name="Téléphone",
        help_text="Numéro de téléphone"
    )
    
    # Rôle principal
    role = models.ForeignKey(
        Role,
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        related_name='users',
        verbose_name="Rôle principal",
        help_text="Rôle principal de l'utilisateur"
    )
    
    # 🔴 NOUVEAU CHAMP CRITIQUE : MAGASIN DE RATTACHEMENT
    assigned_store = models.ForeignKey(
        'inventory.Location',
        on_delete=models.PROTECT,
        null=True,
        blank=True,
        limit_choices_to={'location_type': 'store'},
        related_name='assigned_employees',
        verbose_name="Magasin de rattachement",
        help_text="Magasin auquel cet employé est assigné. NULL pour les administrateurs multi-magasins."
    )
    
    # Informations professionnelles
    hire_date = models.DateField(
        null=True,
        blank=True,
        verbose_name="Date d'embauche",
        help_text="Date d'embauche de l'employé"
    )
    
    department = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="Département",
        help_text="Département ou service"
    )
    
    # Sécurité
    is_locked = models.BooleanField(
        default=False,
        verbose_name="Compte verrouillé",
        help_text="Compte temporairement verrouillé"
    )
    
    locked_until = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Verrouillé jusqu'à",
        help_text="Date de fin de verrouillage"
    )
    
    failed_login_attempts = models.IntegerField(
        default=0,
        verbose_name="Tentatives échouées",
        help_text="Nombre de tentatives de connexion échouées"
    )
    
    last_password_change = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Dernier changement mot de passe"
    )
    
    password_expires_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Mot de passe expire le"
    )
    
    # Audit
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)
    
    def save(self, *args, **kwargs):
        # Générer le code employé automatiquement
        if not self.employee_code:
            last_user = User.objects.filter(
                employee_code__isnull=False
            ).order_by('employee_code').last()
            
            if last_user and last_user.employee_code:
                try:
                    last_number = int(last_user.employee_code[3:])
                    new_number = last_number + 1
                except (ValueError, IndexError):
                    new_number = 1
            else:
                new_number = 1
            
            self.employee_code = f"EMP{new_number:05d}"
        
        super().save(*args, **kwargs)
    
    def is_account_locked(self):
        """Vérifie si le compte est verrouillé"""
        if not self.is_locked:
            return False
        
        if self.locked_until and timezone.now() > self.locked_until:
            # Le verrouillage a expiré
            self.is_locked = False
            self.locked_until = None
            self.failed_login_attempts = 0
            self.save(update_fields=['is_locked', 'locked_until', 'failed_login_attempts'])
            return False
        
        return True
    
    def increment_failed_login(self):
        """Incrémente les tentatives échouées et verrouille si nécessaire"""
        self.failed_login_attempts += 1
        
        # Verrouiller après 5 tentatives
        if self.failed_login_attempts >= 5:
            self.is_locked = True
            self.locked_until = timezone.now() + timezone.timedelta(minutes=30)
        
        self.save(update_fields=['failed_login_attempts', 'is_locked', 'locked_until'])
    
    def reset_failed_login(self):
        """Réinitialise les tentatives échouées"""
        if self.failed_login_attempts > 0:
            self.failed_login_attempts = 0
            self.save(update_fields=['failed_login_attempts'])
    
    def get_all_permissions(self):
        """Récupère toutes les permissions de l'utilisateur"""
        permissions = set()
        
        # Permissions du rôle
        if self.role:
            permissions.update(self.role.permissions.all())
        
        # Permissions directes
        permissions.update(self.user_permissions.all())
        
        # Permissions des groupes
        for group in self.groups.all():
            permissions.update(group.permissions.all())
        
        return permissions
    
    def has_module_permission(self, module):
        """Vérifie si l'utilisateur a accès à un module"""
        if not self.role:
            return False
            
        module_permissions = {
            'inventory': self.role.can_manage_inventory,
            'sales': self.role.can_manage_sales,
            'suppliers': self.role.can_manage_suppliers,
            'reports': self.role.can_view_reports,
            'users': self.role.can_manage_users,
            'settings': self.role.can_manage_settings,
        }
        
        return module_permissions.get(module, False)
    
    def is_multi_store_admin(self):
        """
        Vérifie si l'utilisateur est un admin multi-magasins
        (Admin avec assigned_store = NULL)
        """
        return (
            self.role 
            and self.role.role_type == 'admin' 
            and self.assigned_store is None
        )
    
    def get_accessible_stores(self):
        """
        Retourne les magasins accessibles pour cet utilisateur
        - Admin multi-magasins : tous les magasins
        - Employé : son magasin uniquement
        """
        from apps.inventory.models import Location
        
        if self.is_multi_store_admin():
            return Location.objects.filter(
                location_type='store',
                is_active=True
            )
        elif self.assigned_store:
            return Location.objects.filter(
                id=self.assigned_store.id,
                is_active=True
            )
        
        return Location.objects.none()
    
    class Meta:
        db_table = 'auth_user'
        verbose_name = 'Utilisateur'
        verbose_name_plural = 'Utilisateurs'


class UserProfile(BaseModel):
    """
    Profil utilisateur étendu
    Informations supplémentaires pour chaque utilisateur
    """
    user = models.OneToOneField(
        User,
        on_delete=models.CASCADE,
        related_name='profile',
        verbose_name="Utilisateur"
    )
    
    # Informations personnelles
    avatar = models.ImageField(
        upload_to='avatars/',
        null=True,
        blank=True,
        verbose_name="Photo de profil"
    )
    
    birth_date = models.DateField(
        null=True,
        blank=True,
        verbose_name="Date de naissance"
    )
    
    address = models.TextField(
        blank=True,
        verbose_name="Adresse"
    )
    
    emergency_contact = models.CharField(
        max_length=100,
        blank=True,
        verbose_name="Contact d'urgence"
    )
    
    emergency_phone = models.CharField(
        max_length=17,
        blank=True,
        verbose_name="Téléphone d'urgence"
    )
    
    # Préférences
    language = models.CharField(
        max_length=10,
        choices=[
            ('fr', 'Français'),
            ('en', 'English'),
        ],
        default='fr',
        verbose_name="Langue préférée"
    )
    
    timezone = models.CharField(
        max_length=50,
        default='UTC',
        verbose_name="Fuseau horaire"
    )
    
    theme = models.CharField(
        max_length=20,
        choices=[
            ('light', 'Clair'),
            ('dark', 'Sombre'),
            ('auto', 'Automatique'),
        ],
        default='light',
        verbose_name="Thème d'interface"
    )
    
    # Notifications
    email_notifications = models.BooleanField(
        default=True,
        verbose_name="Notifications email"
    )
    
    sms_notifications = models.BooleanField(
        default=False,
        verbose_name="Notifications SMS"
    )
    
    # Statistiques d'utilisation
    last_login_ip = models.GenericIPAddressField(
        null=True,
        blank=True,
        verbose_name="Dernière IP de connexion"
    )
    
    login_count = models.IntegerField(
        default=0,
        verbose_name="Nombre de connexions"
    )
    
    class Meta:
        db_table = 'auth_user_profile'
        verbose_name = 'Profil utilisateur'
        verbose_name_plural = 'Profils utilisateur'


class UserSession(BaseModel):
    """
    Sessions utilisateur pour traçabilité
    Enregistre toutes les sessions de connexion
    """
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='sessions',
        verbose_name="Utilisateur"
    )
    
    session_key = models.CharField(
        max_length=40,
        unique=True,
        verbose_name="Clé de session"
    )
    
    ip_address = models.GenericIPAddressField(
        verbose_name="Adresse IP"
    )
    
    user_agent = models.TextField(
        verbose_name="Agent utilisateur"
    )
    
    login_at = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Connexion à"
    )
    
    logout_at = models.DateTimeField(
        null=True,
        blank=True,
        verbose_name="Déconnexion à"
    )
    
    is_active = models.BooleanField(
        default=True,
        verbose_name="Session active"
    )
    
    class Meta:
        db_table = 'auth_user_session'
        verbose_name = 'Session utilisateur'
        verbose_name_plural = 'Sessions utilisateur'
        ordering = ['-login_at']


class UserAuditLog(BaseModel):
    """
    Journal d'audit des actions utilisateur
    Traçabilité complète des actions sensibles
    """
    ACTION_TYPES = [
        ('login', 'Connexion'),
        ('logout', 'Déconnexion'),
        ('create', 'Création'),
        ('read', 'Consultation'),
        ('update', 'Modification'),
        ('delete', 'Suppression'),
        ('export', 'Export de données'),
        ('import', 'Import de données'),
        ('print', 'Impression'),
        ('backup', 'Sauvegarde'),
        ('restore', 'Restauration'),
    ]
    
    user = models.ForeignKey(
        User,
        on_delete=models.CASCADE,
        related_name='audit_logs',
        verbose_name="Utilisateur"
    )
    
    action = models.CharField(
        max_length=20,
        choices=ACTION_TYPES,
        verbose_name="Action"
    )
    
    model_name = models.CharField(
        max_length=100,
        null=True,
        blank=True,
        verbose_name="Modèle concerné"
    )
    
    object_id = models.UUIDField(
        null=True,
        blank=True,
        verbose_name="ID de l'objet"
    )
    
    object_repr = models.CharField(
        max_length=200,
        blank=True,
        verbose_name="Représentation de l'objet"
    )
    
    changes = models.JSONField(
        null=True,
        blank=True,
        verbose_name="Détail des modifications"
    )
    
    ip_address = models.GenericIPAddressField(
        verbose_name="Adresse IP"
    )
    
    user_agent = models.TextField(
        blank=True,
        verbose_name="Agent utilisateur"
    )
    
    timestamp = models.DateTimeField(
        auto_now_add=True,
        verbose_name="Horodatage"
    )
    
    class Meta:
        db_table = 'auth_audit_log'
        verbose_name = 'Journal d\'audit'
        verbose_name_plural = 'Journaux d\'audit'
        ordering = ['-timestamp']

        