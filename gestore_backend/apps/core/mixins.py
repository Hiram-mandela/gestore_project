"""
Mixins pour le filtrage multi-magasins - GESTORE
Système intelligent de filtrage des données par magasin selon le rôle de l'utilisateur
"""
from django.db.models import Q
from rest_framework.exceptions import PermissionDenied


class StoreFilterMixin:
    """
    Mixin pour filtrer automatiquement les données par magasin
    S'applique à TOUS les ViewSets qui gèrent des données liées aux Location
    
    STRATÉGIE :
    - Admins multi-magasins (assigned_store=NULL) : Accès à tous les magasins
    - Employés (assigned_store!=NULL) : Accès uniquement à leur magasin
    
    CONFIGURATION :
    - store_filter_field : Nom du champ à filtrer (par défaut 'location')
    - store_filter_disabled : Désactiver le filtrage pour ce ViewSet (par défaut False)
    """
    
    store_filter_field = 'location'  # Nom du champ à filtrer (peut être surchargé)
    store_filter_disabled = False     # Permet de désactiver le filtrage si nécessaire
    
    def get_queryset(self):
        """
        Filtre automatiquement selon le magasin de l'utilisateur
        """
        queryset = super().get_queryset()
        user = self.request.user
        
        # Cas 0 : Filtrage désactivé pour ce ViewSet
        if self.store_filter_disabled:
            return queryset
        
        # Cas 1 : Administrateur multi-magasins (assigned_store = NULL)
        if user.is_multi_store_admin():
            # Vérifier si un magasin spécifique est demandé via paramètre
            store_id = self.request.query_params.get('store_id')
            if store_id:
                return self._filter_by_store(queryset, store_id)
            
            # Sinon : retourner TOUS les magasins (pas de filtre)
            return queryset
        
        # Cas 2 : Employé avec magasin assigné
        elif user.assigned_store:
            # Filtrage OBLIGATOIRE sur son magasin et ses enfants
            return self._filter_by_store(queryset, user.assigned_store.id)
        
        # Cas 3 : Utilisateur sans rôle ou sans magasin (sécurité)
        else:
            # Retourner queryset vide par sécurité
            return queryset.none()
    
    def _filter_by_store(self, queryset, store_id):
        """
        Applique le filtre sur le magasin et tous ses emplacements enfants (hiérarchie)
        
        Args:
            queryset: QuerySet à filtrer
            store_id: UUID du magasin racine
        
        Returns:
            QuerySet filtré
        """
        from apps.inventory.models import Location
        
        try:
            store = Location.objects.get(id=store_id, location_type='store')
        except Location.DoesNotExist:
            # Magasin non trouvé : retourner queryset vide
            return queryset.none()
        
        # Récupérer le magasin + tous ses emplacements enfants (hiérarchie)
        store_locations = [store.id]
        store_locations.extend([child.id for child in store.get_children_recursive()])
        
        # Construire le filtre selon le champ configuré
        filter_field = self.store_filter_field
        
        # Gérer les relations (ex: 'stock__location', 'sale__location')
        if '__' in filter_field:
            # Relation : appliquer le filtre sur la relation
            filter_dict = {f"{filter_field}__in": store_locations}
        else:
            # Champ direct
            filter_dict = {f"{filter_field}__in": store_locations}
        
        return queryset.filter(**filter_dict)
    
    def perform_create(self, serializer):
        """
        Lors de la création, assigner automatiquement le magasin de l'utilisateur
        si nécessaire et vérifier les permissions
        """
        user = self.request.user
        
        # Si employé : vérifier qu'il crée dans son magasin
        if user.assigned_store and 'location_id' in self.request.data:
            self._validate_location_access(self.request.data['location_id'], user)
        
        # Si employé et pas de location_id fournie : assigner automatiquement
        elif user.assigned_store and 'location_id' not in self.request.data:
            # Assigner automatiquement le magasin de l'employé
            serializer.save(location=user.assigned_store)
            return
        
        super().perform_create(serializer)
    
    def perform_update(self, serializer):
        """
        Lors de la mise à jour, vérifier que l'utilisateur a accès au magasin
        """
        user = self.request.user
        instance = serializer.instance
        
        # Si employé : vérifier qu'il ne modifie que dans son magasin
        if user.assigned_store:
            # Vérifier le magasin de l'objet existant
            current_location = getattr(instance, self.store_filter_field.split('__')[0], None)
            if current_location:
                self._validate_location_access(current_location.id, user)
            
            # Vérifier le nouveau magasin si modification
            if 'location_id' in self.request.data:
                self._validate_location_access(self.request.data['location_id'], user)
        
        super().perform_update(serializer)
    
    def perform_destroy(self, instance):
        """
        Lors de la suppression, vérifier que l'utilisateur a accès au magasin
        """
        user = self.request.user
        
        # Si employé : vérifier qu'il supprime uniquement dans son magasin
        if user.assigned_store:
            current_location = getattr(instance, self.store_filter_field.split('__')[0], None)
            if current_location:
                self._validate_location_access(current_location.id, user)
        
        super().perform_destroy(instance)
    
    def _validate_location_access(self, location_id, user):
        """
        Vérifie qu'un employé a accès à un emplacement donné
        
        Args:
            location_id: UUID de l'emplacement à vérifier
            user: Utilisateur effectuant l'action
        
        Raises:
            PermissionDenied: Si l'employé n'a pas accès à cet emplacement
        """
        from apps.inventory.models import Location
        
        if not user.assigned_store:
            # Admin : accès complet
            return
        
        try:
            location = Location.objects.get(id=location_id)
        except Location.DoesNotExist:
            raise PermissionDenied("Emplacement non trouvé")
        
        # Vérifier que l'emplacement appartient au magasin de l'employé
        if not self._location_belongs_to_store(location, user.assigned_store):
            raise PermissionDenied(
                f"Vous n'avez pas accès à cet emplacement. "
                f"Vous êtes assigné au magasin : {user.assigned_store.name}"
            )
    
    def _location_belongs_to_store(self, location, store):
        """
        Vérifie qu'un emplacement appartient à un magasin (hiérarchie)
        
        Args:
            location: Instance Location à vérifier
            store: Instance Location du magasin racine
        
        Returns:
            bool: True si l'emplacement appartient au magasin
        """
        # Cas 1 : L'emplacement est le magasin lui-même
        if location.id == store.id:
            return True
        
        # Cas 2 : Remonter la hiérarchie jusqu'à trouver le magasin
        current = location
        while current:
            if current.id == store.id:
                return True
            current = current.parent
        
        return False


class MultiStoreContextMixin:
    """
    Mixin pour ajouter le contexte multi-magasins dans les réponses API
    Utilisé principalement pour les endpoints de login et user info
    """
    
    def get_store_context(self, user):
        """
        Retourne le contexte magasin pour un utilisateur
        
        Args:
            user: Instance User
        
        Returns:
            dict: Contexte avec assigned_store, is_multi_store_admin, available_stores
        """
        from apps.inventory.models import Location
        
        context = {
            'assigned_store': None,
            'is_multi_store_admin': user.is_multi_store_admin(),
            'available_stores': []
        }
        
        # Informations du magasin assigné
        if user.assigned_store:
            context['assigned_store'] = {
                'id': str(user.assigned_store.id),
                'name': user.assigned_store.name,
                'code': user.assigned_store.code,
                'description': user.assigned_store.description
            }
        
        # Liste des magasins accessibles
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