"""
Configuration de l'interface d'administration Django pour apps/core
Modèles abstraits - pas d'enregistrement direct
Classes de base pour les autres applications
"""
from django.contrib import admin
from django.utils.html import format_html
from django.utils import timezone


class BaseModelAdmin(admin.ModelAdmin):
    """
    Classe de base pour tous les ModelAdmin de GESTORE
    Fournit des fonctionnalités communes et une mise en forme cohérente
    """
    
    # Champs en lecture seule communs à tous les modèles
    readonly_fields = [
        'id', 'created_at', 'updated_at', 'deleted_at',
        'sync_status', 'last_sync_at', 'display_sync_badge'
    ]
    
    # Affichage des dates de manière lisible
    date_hierarchy = 'created_at'
    
    # Filtres par défaut
    list_filter = ['is_deleted', 'sync_status', 'created_at']
    
    # Actions en masse par défaut
    actions = ['mark_as_deleted', 'restore_deleted', 'mark_for_sync']
    
    def get_readonly_fields(self, request, obj=None):
        """
        Champs en lecture seule dynamiques
        """
        readonly = list(super().get_readonly_fields(request, obj))
        
        # Si modification d'objet existant, ajouter les champs audit
        if obj:
            if hasattr(obj, 'created_by'):
                readonly.append('created_by')
            if hasattr(obj, 'updated_by'):
                readonly.append('updated_by')
        
        return readonly
    
    def save_model(self, request, obj, form, change):
        """
        Enregistrer avec audit trail automatique
        """
        if hasattr(obj, 'updated_by'):
            obj.updated_by = request.user
        
        if not change and hasattr(obj, 'created_by'):
            obj.created_by = request.user
        
        super().save_model(request, obj, form, change)
    
    def display_sync_badge(self, obj):
        """
        Badge coloré pour l'état de synchronisation
        """
        if not hasattr(obj, 'sync_status'):
            return '-'
        
        colors = {
            'synced': '#28a745',      # Vert
            'pending': '#ffc107',     # Jaune
            'conflict': '#dc3545',    # Rouge
            'error': '#6c757d'        # Gris
        }
        
        labels = {
            'synced': '✓ Synchronisé',
            'pending': '⏳ En attente',
            'conflict': '⚠️ Conflit',
            'error': '✗ Erreur'
        }
        
        color = colors.get(obj.sync_status, '#6c757d')
        label = labels.get(obj.sync_status, obj.sync_status)
        
        return format_html(
            '<span style="background-color: {}; color: white; '
            'padding: 3px 10px; border-radius: 3px; font-weight: bold;">{}</span>',
            color,
            label
        )
    
    display_sync_badge.short_description = 'Synchronisation'
    
    # Actions en masse
    @admin.action(description='Marquer comme supprimé (suppression logique)')
    def mark_as_deleted(self, request, queryset):
        """Suppression logique des éléments sélectionnés"""
        updated = queryset.update(
            is_deleted=True,
            deleted_at=timezone.now()
        )
        self.message_user(
            request,
            f'{updated} élément(s) marqué(s) comme supprimé(s).'
        )
    
    @admin.action(description='Restaurer les éléments supprimés')
    def restore_deleted(self, request, queryset):
        """Restauration des éléments supprimés logiquement"""
        updated = queryset.update(
            is_deleted=False,
            deleted_at=None
        )
        self.message_user(
            request,
            f'{updated} élément(s) restauré(s).'
        )
    
    @admin.action(description='Marquer pour synchronisation')
    def mark_for_sync(self, request, queryset):
        """Forcer la synchronisation des éléments sélectionnés"""
        updated = queryset.update(sync_status='pending')
        self.message_user(
            request,
            f'{updated} élément(s) marqué(s) pour synchronisation.'
        )


class AuditableModelAdmin(BaseModelAdmin):
    """
    Admin pour les modèles avec audit trail complet
    Affiche created_by et updated_by
    """
    
    list_display_additions = ['created_by', 'updated_by']
    
    def get_list_display(self, request):
        """
        Ajouter les champs d'audit à l'affichage liste
        """
        list_display = list(super().get_list_display(request))
        
        # Ajouter created_by et updated_by à la fin si pas déjà présents
        for field in self.list_display_additions:
            if field not in list_display:
                list_display.append(field)
        
        return tuple(list_display)


class NamedModelAdmin(BaseModelAdmin):
    """
    Admin pour les modèles avec nom et description
    """
    
    list_display = ['name', 'description_preview']
    search_fields = ['name', 'description']
    ordering = ['name']
    
    def description_preview(self, obj):
        """
        Aperçu de la description (100 premiers caractères)
        """
        if not obj.description:
            return '-'
        
        preview = obj.description[:100]
        if len(obj.description) > 100:
            preview += '...'
        
        return preview
    
    description_preview.short_description = 'Description'


class CodedModelAdmin(BaseModelAdmin):
    """
    Admin pour les modèles avec code unique
    """
    
    list_display = ['code']
    search_fields = ['code']
    ordering = ['code']


class ActivableModelAdmin(BaseModelAdmin):
    """
    Admin pour les modèles activables/désactivables
    """
    
    list_display_additions = ['is_active_badge']
    list_filter = BaseModelAdmin.list_filter + ['is_active']
    
    actions = BaseModelAdmin.actions + ['activate_items', 'deactivate_items']
    
    def is_active_badge(self, obj):
        """
        Badge coloré pour l'état actif/inactif
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
    
    @admin.action(description='Activer les éléments sélectionnés')
    def activate_items(self, request, queryset):
        """Activer les éléments sélectionnés"""
        updated = queryset.update(is_active=True)
        self.message_user(
            request,
            f'{updated} élément(s) activé(s).'
        )
    
    @admin.action(description='Désactiver les éléments sélectionnés')
    def deactivate_items(self, request, queryset):
        """Désactiver les éléments sélectionnés"""
        updated = queryset.update(is_active=False)
        self.message_user(
            request,
            f'{updated} élément(s) désactivé(s).'
        )
    
    def get_list_display(self, request):
        """
        Ajouter le badge is_active à l'affichage liste
        """
        list_display = list(super().get_list_display(request))
        
        for field in self.list_display_additions:
            if field not in list_display:
                list_display.append(field)
        
        return tuple(list_display)


# Note: Les modèles abstraits de core ne sont pas enregistrés directement
# Ces classes de base sont héritées par les autres applications