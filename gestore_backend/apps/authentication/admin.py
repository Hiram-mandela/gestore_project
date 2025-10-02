"""
Configuration de l'interface d'administration Django pour apps/authentication
Gestion complète des utilisateurs, rôles, profils et sessions
"""
from django.contrib import admin
from django.contrib.auth.admin import UserAdmin as BaseUserAdmin
from django.contrib.auth import get_user_model
from django.utils.html import format_html
from django.utils import timezone
from django.db.models import Count, Q
from django.urls import reverse
from django.utils.safestring import mark_safe

from apps.core.admin import (
    BaseModelAdmin, NamedModelAdmin, ActivableModelAdmin, AuditableModelAdmin
)
from .models import Role, UserProfile, UserSession, UserAuditLog

User = get_user_model()


# ========================
# ROLE ADMIN
# ========================

@admin.register(Role)
class RoleAdmin(NamedModelAdmin, ActivableModelAdmin):
    """
    Interface d'administration pour les rôles
    """
    list_display = [
        'name', 'role_type', 'users_count', 'is_active_badge',
        'permissions_summary', 'display_sync_badge'
    ]
    
    list_filter = [
        'role_type', 'is_active', 'can_manage_users', 
        'can_manage_inventory', 'can_manage_sales',
        'sync_status', 'created_at'
    ]
    
    search_fields = ['name', 'description', 'role_type']
    
    ordering = ['role_type', 'name']
    
    fieldsets = (
        ('Informations générales', {
            'fields': ('name', 'description', 'role_type', 'is_active')
        }),
        ('Permissions Modules', {
            'fields': (
                'can_manage_users',
                'can_manage_inventory',
                'can_manage_sales',
                'can_manage_suppliers',
                'can_view_reports',
                'can_manage_reports',
                'can_manage_settings',
            ),
            'classes': ('collapse',)
        }),
        ('Permissions Financières', {
            'fields': (
                'can_apply_discounts',
                'max_discount_percent',
                'can_void_transactions',
            ),
            'classes': ('collapse',)
        }),
        ('Permissions Django', {
            'fields': ('permissions',),
            'classes': ('collapse',)
        }),
        ('Métadonnées', {
            'fields': (
                'id', 'created_at', 'updated_at',
                'sync_status', 'last_sync_at', 'display_sync_badge'
            ),
            'classes': ('collapse',)
        }),
    )
    
    filter_horizontal = ['permissions']
    
    def users_count(self, obj):
        """
        Nombre d'utilisateurs ayant ce rôle
        """
        count = obj.users.count()
        
        if count > 0:
            url = reverse('admin:authentication_user_changelist')
            return format_html(
                '<a href="{}?role__id__exact={}">{} utilisateur(s)</a>',
                url, obj.id, count
            )
        
        return '0 utilisateur'
    
    users_count.short_description = 'Utilisateurs'
    users_count.admin_order_field = 'users__count'
    
    def permissions_summary(self, obj):
        """
        Résumé des permissions principales
        """
        perms = []
        
        if obj.can_manage_users:
            perms.append('👥 Users')
        if obj.can_manage_inventory:
            perms.append('📦 Stock')
        if obj.can_manage_sales:
            perms.append('💰 Ventes')
        if obj.can_manage_suppliers:
            perms.append('🏭 Fournisseurs')
        if obj.can_view_reports:
            perms.append('📊 Rapports')
        if obj.can_manage_settings:
            perms.append('⚙️ Config')
        
        if not perms:
            return format_html('<em>Aucune permission</em>')
        
        return format_html('<br>'.join(perms))
    
    permissions_summary.short_description = 'Permissions'
    
    def get_queryset(self, request):
        """
        Optimiser les requêtes avec comptage des utilisateurs
        """
        qs = super().get_queryset(request)
        return qs.annotate(users__count=Count('users'))


# ========================
# USER PROFILE INLINE
# ========================

class UserProfileInline(admin.StackedInline):
    """
    Inline pour le profil utilisateur dans l'admin User
    """
    model = UserProfile
    can_delete = False
    verbose_name = 'Profil utilisateur'
    verbose_name_plural = 'Profil utilisateur'
    
    fieldsets = (
        ('Informations personnelles', {
            'fields': (
                'avatar', 'birth_date', 'address',
                'emergency_contact', 'emergency_phone'
            )
        }),
        ('Préférences', {
            'fields': ('language', 'timezone', 'theme'),
            'classes': ('collapse',)
        }),
        ('Notifications', {
            'fields': ('email_notifications', 'sms_notifications'),
            'classes': ('collapse',)
        }),
        ('Statistiques', {
            'fields': ('last_login_ip', 'login_count'),
            'classes': ('collapse',)
        }),
    )
    
    readonly_fields = ['last_login_ip', 'login_count']


# ========================
# USER ADMIN
# ========================

@admin.register(User)
class UserAdmin(BaseUserAdmin):
    """
    Interface d'administration personnalisée pour les utilisateurs
    Note: User n'hérite pas de BaseModel donc pas de champs sync_status, etc.
    """
    
    # Affichage liste
    list_display = [
        'username', 'email', 'full_name', 'role',
        'is_active_badge', 'is_staff_badge', 'last_login',
        'account_status'
    ]
    
    list_filter = [
        'is_active', 'is_staff', 'is_superuser',
        'role', 'groups', 'date_joined', 'is_locked'
    ]
    
    search_fields = [
        'username', 'first_name', 'last_name',
        'email', 'phone_number', 'employee_code'
    ]
    
    ordering = ['-date_joined']
    
    # Configuration des fieldsets
    fieldsets = (
        ('Informations de connexion', {
            'fields': ('username', 'password')
        }),
        ('Informations personnelles', {
            'fields': (
                'first_name', 'last_name', 'email',
                'phone_number', 'employee_code'
            )
        }),
        ('Informations professionnelles', {
            'fields': ('hire_date', 'department'),
            'classes': ('collapse',)
        }),
        ('Permissions et rôles', {
            'fields': (
                'role', 'is_active', 'is_staff', 'is_superuser',
                'groups', 'user_permissions'
            ),
        }),
        ('Sécurité', {
            'fields': (
                'is_locked', 'locked_until',
                'failed_login_attempts',
                'last_password_change', 'password_expires_at'
            ),
            'classes': ('collapse',)
        }),
        ('Dates importantes', {
            'fields': ('last_login', 'date_joined', 'created_at', 'updated_at'),
            'classes': ('collapse',)
        }),
    )
    
    # Fieldsets pour la création d'utilisateur
    add_fieldsets = (
        ('Informations de connexion *', {
            'fields': ('username', 'password1', 'password2'),
        }),
        ('Informations personnelles', {
            'fields': ('first_name', 'last_name', 'email', 'phone_number'),
        }),
        ('Informations professionnelles', {
            'fields': ('employee_code', 'hire_date', 'department'),
        }),
        ('Rôle et permissions', {
            'fields': ('role', 'is_active', 'is_staff'),
        }),
    )
    
    readonly_fields = [
        'id', 'date_joined', 'last_login', 'employee_code',
        'failed_login_attempts', 'locked_until',
        'last_password_change', 'created_at', 'updated_at'
    ]
    
    filter_horizontal = ['groups', 'user_permissions']
    
    inlines = [UserProfileInline]
    
    # Actions personnalisées
    actions = [
        'activate_users', 'deactivate_users',
        'unlock_accounts', 'reset_failed_attempts'
    ]
    
    # Méthodes d'affichage personnalisées
    
    def full_name(self, obj):
        """
        Nom complet de l'utilisateur
        """
        full = obj.get_full_name()
        return full if full else '-'
    
    full_name.short_description = 'Nom complet'
    full_name.admin_order_field = 'first_name'
    
    def is_active_badge(self, obj):
        """
        Badge pour l'état actif/inactif
        """
        if obj.is_active:
            return format_html(
                '<span style="background-color: #28a745; color: white; '
                'padding: 3px 10px; border-radius: 3px;">✓ Actif</span>'
            )
        else:
            return format_html(
                '<span style="background-color: #dc3545; color: white; '
                'padding: 3px 10px; border-radius: 3px;">✗ Inactif</span>'
            )
    
    is_active_badge.short_description = 'État'
    is_active_badge.admin_order_field = 'is_active'
    
    def is_staff_badge(self, obj):
        """
        Badge pour le statut staff
        """
        if obj.is_superuser:
            return format_html(
                '<span style="background-color: #dc3545; color: white; '
                'padding: 3px 10px; border-radius: 3px;">⭐ SuperAdmin</span>'
            )
        elif obj.is_staff:
            return format_html(
                '<span style="background-color: #007bff; color: white; '
                'padding: 3px 10px; border-radius: 3px;">👑 Staff</span>'
            )
        else:
            return format_html(
                '<span style="background-color: #6c757d; color: white; '
                'padding: 3px 10px; border-radius: 3px;">👤 User</span>'
            )
    
    is_staff_badge.short_description = 'Type'
    is_staff_badge.admin_order_field = 'is_staff'
    
    def account_status(self, obj):
        """
        Statut du compte (verrouillé, tentatives échouées, etc.)
        """
        statuses = []
        
        if obj.is_account_locked():
            statuses.append(
                '<span style="color: #dc3545;">🔒 Verrouillé</span>'
            )
        
        if obj.failed_login_attempts > 0:
            statuses.append(
                f'<span style="color: #ffc107;">⚠️ {obj.failed_login_attempts} tentative(s) échouée(s)</span>'
            )
        
        if obj.password_expires_at and obj.password_expires_at < timezone.now():
            statuses.append(
                '<span style="color: #dc3545;">🔑 Mot de passe expiré</span>'
            )
        
        if not statuses:
            return format_html(
                '<span style="color: #28a745;">✓ OK</span>'
            )
        
        return format_html('<br>'.join(statuses))
    
    account_status.short_description = 'Statut compte'
    
    # Actions en masse
    
    @admin.action(description='Activer les utilisateurs sélectionnés')
    def activate_users(self, request, queryset):
        """Activer les utilisateurs sélectionnés"""
        updated = queryset.update(is_active=True)
        self.message_user(
            request,
            f'{updated} utilisateur(s) activé(s).'
        )
    
    @admin.action(description='Désactiver les utilisateurs sélectionnés')
    def deactivate_users(self, request, queryset):
        """Désactiver les utilisateurs sélectionnés"""
        updated = queryset.update(is_active=False)
        self.message_user(
            request,
            f'{updated} utilisateur(s) désactivé(s).'
        )
    
    @admin.action(description='Déverrouiller les comptes')
    def unlock_accounts(self, request, queryset):
        """Déverrouiller les comptes verrouillés"""
        updated = queryset.update(
            is_locked=False,
            locked_until=None,
            failed_login_attempts=0
        )
        self.message_user(
            request,
            f'{updated} compte(s) déverrouillé(s).'
        )
    
    @admin.action(description='Réinitialiser les tentatives échouées')
    def reset_failed_attempts(self, request, queryset):
        """Réinitialiser le compteur de tentatives échouées"""
        updated = queryset.update(failed_login_attempts=0)
        self.message_user(
            request,
            f'{updated} compteur(s) réinitialisé(s).'
        )


# ========================
# USER PROFILE ADMIN
# ========================

@admin.register(UserProfile)
class UserProfileAdmin(BaseModelAdmin):
    """
    Interface d'administration pour les profils utilisateur
    """
    list_display = [
        'user', 'language', 'theme', 'timezone',
        'login_count', 'last_login_ip'
    ]
    
    list_filter = [
        'language', 'theme', 'email_notifications',
        'sms_notifications', 'created_at'
    ]
    
    search_fields = [
        'user__username', 'user__email',
        'user__first_name', 'user__last_name',
        'address', 'emergency_contact'
    ]
    
    ordering = ['-created_at']
    
    fieldsets = (
        ('Utilisateur', {
            'fields': ('user',)
        }),
        ('Informations personnelles', {
            'fields': (
                'avatar', 'birth_date', 'address',
                'emergency_contact', 'emergency_phone'
            )
        }),
        ('Préférences', {
            'fields': ('language', 'timezone', 'theme')
        }),
        ('Notifications', {
            'fields': ('email_notifications', 'sms_notifications')
        }),
        ('Statistiques d\'utilisation', {
            'fields': ('last_login_ip', 'login_count'),
            'classes': ('collapse',)
        }),
        ('Métadonnées', {
            'fields': (
                'id', 'created_at', 'updated_at',
                'sync_status', 'last_sync_at'
            ),
            'classes': ('collapse',)
        }),
    )
    
    readonly_fields = [
        'id', 'last_login_ip', 'login_count',
        'created_at', 'updated_at', 'sync_status', 'last_sync_at'
    ]
    
    autocomplete_fields = ['user']


# ========================
# USER SESSION ADMIN
# ========================

@admin.register(UserSession)
class UserSessionAdmin(BaseModelAdmin):
    """
    Interface d'administration pour les sessions utilisateur
    """
    list_display = [
        'user', 'session_key_preview', 'ip_address',
        'login_at', 'logout_at', 'is_active_badge',
        'duration'
    ]
    
    list_filter = [
        'is_active', 'login_at', 'logout_at'
    ]
    
    search_fields = [
        'user__username', 'user__email',
        'session_key', 'ip_address', 'user_agent'
    ]
    
    ordering = ['-login_at']
    
    readonly_fields = [
        'id', 'user', 'session_key', 'ip_address',
        'user_agent', 'login_at', 'logout_at',
        'created_at', 'updated_at', 'sync_status', 'last_sync_at'
    ]
    
    fieldsets = (
        ('Session', {
            'fields': ('user', 'session_key', 'is_active')
        }),
        ('Informations de connexion', {
            'fields': ('ip_address', 'user_agent', 'login_at', 'logout_at')
        }),
        ('Métadonnées', {
            'fields': (
                'id', 'created_at', 'updated_at',
                'sync_status', 'last_sync_at'
            ),
            'classes': ('collapse',)
        }),
    )
    
    actions = ['end_sessions']
    
    def session_key_preview(self, obj):
        """
        Aperçu de la clé de session (premiers et derniers caractères)
        """
        if len(obj.session_key) > 16:
            return f"{obj.session_key[:8]}...{obj.session_key[-8:]}"
        return obj.session_key
    
    session_key_preview.short_description = 'Session'
    
    def is_active_badge(self, obj):
        """
        Badge pour l'état actif/inactif de la session
        """
        if obj.is_active:
            return format_html(
                '<span style="background-color: #28a745; color: white; '
                'padding: 3px 10px; border-radius: 3px;">🟢 Active</span>'
            )
        else:
            return format_html(
                '<span style="background-color: #6c757d; color: white; '
                'padding: 3px 10px; border-radius: 3px;">⚫ Terminée</span>'
            )
    
    is_active_badge.short_description = 'État'
    is_active_badge.admin_order_field = 'is_active'
    
    def duration(self, obj):
        """
        Durée de la session
        """
        if not obj.logout_at:
            if obj.is_active:
                delta = timezone.now() - obj.login_at
                return f"En cours ({delta})"
            else:
                return "Non fermée"
        
        delta = obj.logout_at - obj.login_at
        
        # Formater la durée
        hours, remainder = divmod(delta.seconds, 3600)
        minutes, seconds = divmod(remainder, 60)
        
        if delta.days > 0:
            return f"{delta.days}j {hours}h {minutes}m"
        elif hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m {seconds}s"
    
    duration.short_description = 'Durée'
    
    @admin.action(description='Terminer les sessions sélectionnées')
    def end_sessions(self, request, queryset):
        """Terminer les sessions actives sélectionnées"""
        updated = queryset.filter(is_active=True).update(
            is_active=False,
            logout_at=timezone.now()
        )
        self.message_user(
            request,
            f'{updated} session(s) terminée(s).'
        )
    
    def has_add_permission(self, request):
        """
        Empêcher la création manuelle de sessions
        """
        return False


# ========================
# USER AUDIT LOG ADMIN
# ========================

@admin.register(UserAuditLog)
class UserAuditLogAdmin(BaseModelAdmin):
    """
    Interface d'administration pour les journaux d'audit
    """
    list_display = [
        'timestamp', 'user', 'action', 'model_name',
        'ip_address', 'status_badge'
    ]
    
    list_filter = [
        'action', 'model_name', 'timestamp'
    ]
    
    search_fields = [
        'user__username', 'user__email',
        'action', 'model_name', 'object_id',
        'ip_address', 'user_agent'
    ]
    
    ordering = ['-timestamp']
    
    readonly_fields = [
        'id', 'user', 'action', 'model_name', 'object_id',
        'changes', 'ip_address', 'user_agent', 'timestamp',
        'created_at', 'updated_at', 'sync_status', 'last_sync_at'
    ]
    
    fieldsets = (
        ('Action', {
            'fields': ('user', 'action', 'model_name', 'object_id', 'timestamp')
        }),
        ('Détails', {
            'fields': ('changes',)
        }),
        ('Informations techniques', {
            'fields': ('ip_address', 'user_agent'),
            'classes': ('collapse',)
        }),
        ('Métadonnées', {
            'fields': (
                'id', 'created_at', 'updated_at',
                'sync_status', 'last_sync_at'
            ),
            'classes': ('collapse',)
        }),
    )
    
    def status_badge(self, obj):
        """
        Badge coloré selon le type d'action
        """
        action_colors = {
            'create': '#28a745',
            'update': '#ffc107',
            'delete': '#dc3545',
            'login': '#007bff',
            'logout': '#6c757d',
        }
        
        color = action_colors.get(obj.action, '#17a2b8')
        
        return format_html(
            '<span style="background-color: {}; color: white; '
            'padding: 3px 10px; border-radius: 3px;">{}</span>',
            color,
            obj.action.upper()
        )
    
    status_badge.short_description = 'Type'
    status_badge.admin_order_field = 'action'
    
    def has_add_permission(self, request):
        """
        Empêcher la création manuelle de logs d'audit
        """
        return False
    
    def has_delete_permission(self, request, obj=None):
        """
        Empêcher la suppression des logs d'audit
        """
        return False
    
    def has_change_permission(self, request, obj=None):
        """
        Empêcher la modification des logs d'audit
        """
        return False