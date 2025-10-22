"""
Serializers pour l'application authentication - GESTORE - VERSION MULTI-MAGASINS
Gestion complète des utilisateurs, rôles et sécurité avec optimisations
MODIFICATION MAJEURE : Ajout contexte multi-magasins (assigned_store, available_stores)
"""
from rest_framework import serializers
from django.contrib.auth import authenticate, get_user_model
from django.contrib.auth.password_validation import validate_password
from django.core.exceptions import ValidationError as DjangoValidationError
from django.utils import timezone
from django.db import transaction
from apps.core.serializers import (
    BaseModelSerializer, AuditableSerializer, NamedModelSerializer, 
    ActivableModelSerializer
)
from .models import Role, UserProfile, UserSession, UserAuditLog

User = get_user_model()


class RoleSerializer(BaseModelSerializer, NamedModelSerializer, ActivableModelSerializer):
    """
    Serializer pour les rôles avec permissions détaillées
    """
    role_type = serializers.CharField()
    
    # Permissions modules
    can_manage_users = serializers.BooleanField()
    can_manage_inventory = serializers.BooleanField()
    can_manage_sales = serializers.BooleanField()
    can_manage_suppliers = serializers.BooleanField()
    can_view_reports = serializers.BooleanField()
    can_manage_reports = serializers.BooleanField()
    can_manage_settings = serializers.BooleanField()
    
    # Permissions financières
    can_apply_discounts = serializers.BooleanField()
    max_discount_percent = serializers.DecimalField(max_digits=5, decimal_places=2)
    can_void_transactions = serializers.BooleanField()
    
    # Champs calculés
    permissions_summary = serializers.SerializerMethodField()
    users_count = serializers.SerializerMethodField()
    
    class Meta:
        model = Role
        fields = [
            'id', 'name', 'description', 'role_type', 'is_active',
            'can_manage_users', 'can_manage_inventory', 'can_manage_sales',
            'can_manage_suppliers', 'can_view_reports', 'can_manage_reports',
            'can_manage_settings', 'can_apply_discounts', 'max_discount_percent',
            'can_void_transactions', 'permissions_summary', 'users_count',
            'created_at', 'updated_at', 'sync_status', 'needs_sync'
        ]
        
    def get_permissions_summary(self, obj):
        """Résumé textuel des permissions"""
        permissions = []
        
        if obj.can_manage_users:
            permissions.append("Gestion utilisateurs")
        if obj.can_manage_inventory:
            permissions.append("Gestion stocks")
        if obj.can_manage_sales:
            permissions.append("Gestion ventes")
        if obj.can_manage_suppliers:
            permissions.append("Gestion fournisseurs")
        if obj.can_view_reports:
            permissions.append("Consultation rapports")
        if obj.can_manage_reports:
            permissions.append("Gestion rapports")
        if obj.can_manage_settings:
            permissions.append("Gestion paramètres")
        if obj.can_apply_discounts:
            permissions.append(f"Remises ({obj.max_discount_percent}% max)")
        if obj.can_void_transactions:
            permissions.append("Annulation transactions")
        
        return permissions
    
    def get_users_count(self, obj):
        """Nombre d'utilisateurs avec ce rôle"""
        return getattr(obj, 'users_count', 0)
    
    def validate(self, attrs):
        """Validation globale du rôle"""
        if attrs.get('can_apply_discounts') and not attrs.get('max_discount_percent'):
            raise serializers.ValidationError({
                'max_discount_percent': 
                "Une limite de remise doit être définie si l'application de remises est autorisée."
            })
        
        return attrs


class UserProfileSerializer(BaseModelSerializer):
    """Serializer pour les profils utilisateur"""
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    avatar_url = serializers.SerializerMethodField()
    
    class Meta:
        model = UserProfile
        fields = [
            'id', 'user_name', 'avatar', 'avatar_url', 'birth_date', 
            'address', 'emergency_contact', 'emergency_phone',
            'language', 'timezone', 'theme', 'email_notifications',
            'sms_notifications', 'last_login_ip', 'login_count',
            'created_at', 'updated_at'
        ]
        
    def get_avatar_url(self, obj):
        """URL complète de l'avatar"""
        if obj.avatar:
            request = self.context.get('request')
            if request:
                return request.build_absolute_uri(obj.avatar.url)
            return obj.avatar.url
        return None


class UserSessionSerializer(BaseModelSerializer):
    """Serializer pour les sessions utilisateur"""
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    duration = serializers.SerializerMethodField()
    
    class Meta:
        model = UserSession
        fields = [
            'id', 'user_name', 'session_key', 'ip_address', 'user_agent',
            'login_at', 'logout_at', 'is_active', 'duration'
        ]
    
    def get_duration(self, obj):
        """Durée de la session"""
        if obj.logout_at:
            duration = obj.logout_at - obj.login_at
        else:
            duration = timezone.now() - obj.login_at
        
        total_seconds = int(duration.total_seconds())
        hours = total_seconds // 3600
        minutes = (total_seconds % 3600) // 60
        
        if hours > 0:
            return f"{hours}h {minutes}m"
        else:
            return f"{minutes}m"


class UserSerializer(BaseModelSerializer):
    """
    Serializer complet pour les utilisateurs avec contexte multi-magasins
    """
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    first_name = serializers.CharField(max_length=30, allow_blank=True, required=False)
    last_name = serializers.CharField(max_length=30, allow_blank=True, required=False)
    
    # Relations
    role = RoleSerializer(read_only=True)
    role_id = serializers.CharField(write_only=True, allow_null=True, required=False)
    profile = UserProfileSerializer(read_only=True)
    
    # 🔴 NOUVEAU : Champs multi-magasins
    assigned_store = serializers.SerializerMethodField()
    assigned_store_id = serializers.CharField(write_only=True, allow_null=True, required=False)
    is_multi_store_admin = serializers.SerializerMethodField()
    available_stores = serializers.SerializerMethodField()
    
    # Informations professionnelles
    employee_code = serializers.CharField(read_only=True)
    phone_number = serializers.CharField(allow_blank=True, required=False)
    hire_date = serializers.DateField(allow_null=True, required=False)
    department = serializers.CharField(allow_blank=True, required=False)
    
    # Sécurité
    is_locked = serializers.BooleanField(read_only=True)
    locked_until = serializers.DateTimeField(read_only=True)
    failed_login_attempts = serializers.IntegerField(read_only=True)
    last_password_change = serializers.DateTimeField(read_only=True)
    
    # Champs calculés
    full_name = serializers.SerializerMethodField()
    is_online = serializers.SerializerMethodField()
    permissions_summary = serializers.SerializerMethodField()
    last_login_formatted = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 'full_name',
            'employee_code', 'phone_number', 'hire_date', 'department',
            'role', 'role_id', 'profile', 
            # 🔴 NOUVEAUX CHAMPS
            'assigned_store', 'assigned_store_id', 'is_multi_store_admin', 'available_stores',
            # Fin nouveaux champs
            'is_active', 'is_locked', 'locked_until',
            'failed_login_attempts', 'last_login', 'last_login_formatted',
            'last_password_change', 'is_online', 'permissions_summary',
            'created_at', 'updated_at'
        ]
    
    def get_full_name(self, obj):
        """Nom complet de l'utilisateur"""
        return f"{obj.first_name} {obj.last_name}".strip() or obj.username
    
    def get_assigned_store(self, obj):
        """Informations du magasin assigné"""
        if obj.assigned_store:
            return {
                'id': str(obj.assigned_store.id),
                'name': obj.assigned_store.name,
                'code': obj.assigned_store.code,
                'location_type': obj.assigned_store.location_type
            }
        return None
    
    def get_is_multi_store_admin(self, obj):
        """Vérifie si l'utilisateur est admin multi-magasins"""
        return obj.is_multi_store_admin()
    
    def get_available_stores(self, obj):
        """Liste des magasins accessibles"""
        stores = obj.get_accessible_stores()
        return [
            {
                'id': str(store.id),
                'name': store.name,
                'code': store.code,
                'is_active': store.is_active
            }
            for store in stores
        ]
    
    def get_is_online(self, obj):
        """Indique si l'utilisateur est en ligne"""
        cutoff = timezone.now() - timezone.timedelta(minutes=15)
        return obj.sessions.filter(
            is_active=True,
            login_at__gte=cutoff
        ).exists()
    
    def get_permissions_summary(self, obj):
        """Résumé des permissions"""
        if obj.is_superuser:
            return ["Administrateur système (tous droits)"]
        
        if obj.role:
            return obj.role.permissions_summary if hasattr(obj.role, 'permissions_summary') else []
        
        return []
    
    def get_last_login_formatted(self, obj):
        """Dernière connexion formatée"""
        if obj.last_login:
            return obj.last_login.strftime('%d/%m/%Y à %H:%M')
        return "Jamais connecté"
    
    def validate_email(self, value):
        """Validation de l'email avec unicité"""
        if not value:
            raise serializers.ValidationError("L'email est obligatoire.")
        
        queryset = User.objects.filter(email__iexact=value)
        if self.instance:
            queryset = queryset.exclude(pk=self.instance.pk)
        
        if queryset.exists():
            raise serializers.ValidationError("Un utilisateur avec cet email existe déjà.")
        
        return value.lower()
    
    def validate_username(self, value):
        """Validation du nom d'utilisateur"""
        if not value:
            raise serializers.ValidationError("Le nom d'utilisateur est obligatoire.")
        
        queryset = User.objects.filter(username__iexact=value)
        if self.instance:
            queryset = queryset.exclude(pk=self.instance.pk)
        
        if queryset.exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est déjà pris.")
        
        return value


class UserCreateSerializer(BaseModelSerializer):
    """
    Serializer pour la création d'utilisateur avec mot de passe
    """
    username = serializers.CharField(max_length=150)
    email = serializers.EmailField()
    first_name = serializers.CharField(max_length=30, allow_blank=True, required=False)
    last_name = serializers.CharField(max_length=30, allow_blank=True, required=False)
    password = serializers.CharField(write_only=True, min_length=8)
    password_confirm = serializers.CharField(write_only=True)
    role_id = serializers.CharField(write_only=True, allow_null=True, required=False)
    
    # 🔴 NOUVEAU : Assignation du magasin
    assigned_store_id = serializers.CharField(write_only=True, allow_null=True, required=False)
    
    # Informations professionnelles
    phone_number = serializers.CharField(allow_blank=True, required=False)
    hire_date = serializers.DateField(allow_null=True, required=False)
    department = serializers.CharField(allow_blank=True, required=False)
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'first_name', 'last_name', 
            'password', 'password_confirm', 'role_id', 'assigned_store_id',
            'phone_number', 'hire_date', 'department'
        ]
    
    def validate_email(self, value):
        """Validation de l'email"""
        if not value:
            raise serializers.ValidationError("L'email est obligatoire.")
        
        if User.objects.filter(email__iexact=value).exists():
            raise serializers.ValidationError("Un utilisateur avec cet email existe déjà.")
        
        return value.lower()
    
    def validate_username(self, value):
        """Validation du nom d'utilisateur"""
        if User.objects.filter(username__iexact=value).exists():
            raise serializers.ValidationError("Ce nom d'utilisateur est déjà pris.")
        
        return value
    
    def validate(self, attrs):
        """Validation globale"""
        errors = {}
        
        # Validation mot de passe
        password = attrs.get('password')
        password_confirm = attrs.get('password_confirm')
        
        if password and password_confirm and password != password_confirm:
            errors['password_confirm'] = "Les mots de passe ne correspondent pas."
        elif password and not password_confirm:
            errors['password_confirm'] = "La confirmation du mot de passe est obligatoire."
        elif not password and password_confirm:
            errors['password'] = "Le mot de passe est obligatoire."
        
        # Validation du rôle
        role_id = attrs.get('role_id')
        if role_id:
            try:
                role = Role.objects.get(id=role_id, is_active=True)
                attrs['role'] = role
            except Role.DoesNotExist:
                errors['role_id'] = "Rôle non trouvé ou inactif."
        
        # 🔴 NOUVEAU : Validation du magasin assigné
        assigned_store_id = attrs.get('assigned_store_id')
        if assigned_store_id:
            from apps.inventory.models import Location
            try:
                store = Location.objects.get(id=assigned_store_id, location_type='store', is_active=True)
                attrs['assigned_store'] = store
            except Location.DoesNotExist:
                errors['assigned_store_id'] = "Magasin non trouvé ou inactif."
        
        if errors:
            raise serializers.ValidationError(errors)
        
        return attrs
    
    def create(self, validated_data):
        """Création avec mot de passe hashé"""
        validated_data.pop('password_confirm')
        password = validated_data.pop('password')
        role_id = validated_data.pop('role_id', None)
        assigned_store_id = validated_data.pop('assigned_store_id', None)
        
        with transaction.atomic():
            # Créer l'utilisateur
            user = User.objects.create_user(password=password, **validated_data)
            
            # Assigner le rôle
            if role_id:
                try:
                    role = Role.objects.get(id=role_id, is_active=True)
                    user.role = role
                    user.save()
                except Role.DoesNotExist:
                    pass
            
            # 🔴 NOUVEAU : Assigner le magasin
            if assigned_store_id:
                from apps.inventory.models import Location
                try:
                    store = Location.objects.get(id=assigned_store_id, location_type='store')
                    user.assigned_store = store
                    user.save()
                except Location.DoesNotExist:
                    pass
            
            # Créer le profil si inexistant
            if not hasattr(user, 'profile'):
                UserProfile.objects.create(user=user)
            
            return user


class UserListSerializer(BaseModelSerializer):
    """Serializer allégé pour les listes"""
    full_name = serializers.SerializerMethodField()
    role_name = serializers.CharField(source='role.name', read_only=True)
    role_type = serializers.CharField(source='role.role_type', read_only=True)
    
    # 🔴 NOUVEAU
    assigned_store_name = serializers.CharField(source='assigned_store.name', read_only=True)
    
    is_online = serializers.SerializerMethodField()
    last_login_formatted = serializers.SerializerMethodField()
    
    class Meta:
        model = User
        fields = [
            'id', 'username', 'email', 'full_name', 'employee_code',
            'role_name', 'role_type', 'assigned_store_name',
            'is_active', 'is_locked', 'is_online', 'last_login_formatted'
        ]
    
    def get_full_name(self, obj):
        return f"{obj.first_name} {obj.last_name}".strip() or obj.username
    
    def get_is_online(self, obj):
        if hasattr(obj, '_is_online'):
            return obj._is_online > 0
        return False
    
    def get_last_login_formatted(self, obj):
        if obj.last_login:
            return obj.last_login.strftime('%d/%m/%Y')
        return "Jamais"


class PasswordChangeSerializer(serializers.Serializer):
    """Serializer pour le changement de mot de passe"""
    current_password = serializers.CharField(write_only=True)
    new_password = serializers.CharField(write_only=True)
    new_password_confirm = serializers.CharField(write_only=True)
    
    def validate_current_password(self, value):
        user = self.context['request'].user
        if not user.check_password(value):
            raise serializers.ValidationError("Mot de passe actuel incorrect.")
        return value
    
    def validate_new_password(self, value):
        try:
            validate_password(value, self.context['request'].user)
        except DjangoValidationError as e:
            raise serializers.ValidationError(e.messages)
        return value
    
    def validate(self, attrs):
        if attrs['new_password'] != attrs['new_password_confirm']:
            raise serializers.ValidationError({
                'new_password_confirm': 'Les nouveaux mots de passe ne correspondent pas.'
            })
        return attrs
    
    def save(self):
        user = self.context['request'].user
        user.set_password(self.validated_data['new_password'])
        user.save()
        return user


class LoginSerializer(serializers.Serializer):
    """
    Serializer pour la connexion avec contexte multi-magasins
    """
    username = serializers.CharField()
    password = serializers.CharField(write_only=True)
    
    def validate(self, attrs):
        """Validation des identifiants avec contexte magasin"""
        username = attrs.get('username')
        password = attrs.get('password')
        
        if username and password:
            user = authenticate(
                request=self.context.get('request'),
                username=username,
                password=password
            )
            
            if not user:
                raise serializers.ValidationError(
                    "Nom d'utilisateur ou mot de passe incorrect."
                )
            
            if not user.is_active:
                raise serializers.ValidationError(
                    "Ce compte est désactivé."
                )
            
            if user.is_account_locked():
                raise serializers.ValidationError(
                    f"Compte verrouillé jusqu'à {user.locked_until.strftime('%H:%M')}."
                )
            
            # 🔴 NOUVEAU : Ajouter le contexte multi-magasins
            attrs['user'] = user
            attrs['store_context'] = self._get_store_context(user)
            
            return attrs
        else:
            raise serializers.ValidationError(
                "Le nom d'utilisateur et le mot de passe sont requis."
            )
    
    def _get_store_context(self, user):
        """
        Génère le contexte magasin pour la réponse de login
        """
        from apps.inventory.models import Location
        
        context = {
            'assigned_store': None,
            'is_multi_store_admin': user.is_multi_store_admin(),
            'available_stores': []
        }
        
        # Magasin assigné
        if user.assigned_store:
            context['assigned_store'] = {
                'id': str(user.assigned_store.id),
                'name': user.assigned_store.name,
                'code': user.assigned_store.code,
                'description': user.assigned_store.description
            }
        
        # Magasins accessibles
        accessible_stores = user.get_accessible_stores()
        context['available_stores'] = [
            {
                'id': str(store.id),
                'name': store.name,
                'code': store.code,
                'is_active': store.is_active
            }
            for store in accessible_stores
        ]
        
        return context


class UserAuditLogSerializer(BaseModelSerializer):
    """Serializer pour les logs d'audit"""
    user_name = serializers.CharField(source='user.get_full_name', read_only=True)
    action_display = serializers.CharField(source='get_action_display', read_only=True)
    
    class Meta:
        model = UserAuditLog
        fields = [
            'id', 'user_name', 'action', 'action_display', 'model_name',
            'object_id', 'object_repr', 'changes', 'ip_address',
            'user_agent', 'timestamp'
        ]