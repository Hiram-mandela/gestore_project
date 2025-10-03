// ========================================
// lib/core/constants/storage_keys.dart
// VERSION MISE À JOUR - Ajout clés modes de connexion
// ========================================

/// Clés pour le stockage local (SharedPreferences & SecureStorage)
/// Organisation par catégorie pour faciliter la maintenance
class StorageKeys {
  // ==================== SECURE STORAGE (flutter_secure_storage) ====================
  // Pour les données sensibles uniquement

  /// Token d'accès JWT
  static const String accessToken = 'access_token';

  /// Token de rafraîchissement JWT
  static const String refreshToken = 'refresh_token';

  /// Mot de passe encrypté (si option "Remember me")
  static const String encryptedPassword = 'encrypted_password';

  /// Clé de chiffrement de la base de données locale
  static const String databaseEncryptionKey = 'db_encryption_key';

  // ==================== SHARED PREFERENCES ====================
  // Pour les préférences et données non sensibles

  // Authentication & User
  /// ID de l'utilisateur connecté
  static const String userId = 'user_id';

  /// Email de l'utilisateur
  static const String userEmail = 'user_email';

  /// Nom complet de l'utilisateur
  static const String userFullName = 'user_full_name';

  /// Rôle de l'utilisateur
  static const String userRole = 'user_role';

  /// Permissions de l'utilisateur (JSON)
  static const String userPermissions = 'user_permissions';

  /// Avatar URL de l'utilisateur
  static const String userAvatar = 'user_avatar';

  /// Dernière connexion
  static const String lastLoginDate = 'last_login_date';

  /// Option "Remember me"
  static const String rememberMe = 'remember_me';

  /// Utilisateur est authentifié
  static const String isAuthenticated = 'is_authenticated';

  // ==================== CONNECTION MODE (NOUVEAU) ====================

  /// Mode de connexion actuel (localhost/local_network/cloud)
  static const String connectionMode = 'connection_mode';

  /// Configuration de connexion complète (JSON)
  static const String connectionConfig = 'connection_config';

  /// URL du serveur actuel
  static const String serverUrl = 'server_url';

  /// Port du serveur
  static const String serverPort = 'server_port';

  /// Utilise HTTPS
  static const String useHttps = 'use_https';

  /// Nom personnalisé de la connexion
  static const String connectionCustomName = 'connection_custom_name';

  /// Historique des connexions (JSON Array)
  static const String connectionHistory = 'connection_history';

  /// Dernière validation de connexion
  static const String lastConnectionValidation = 'last_connection_validation';

  /// Statut de la dernière connexion
  static const String lastConnectionStatus = 'last_connection_status';

  // ==================== API SETTINGS ====================

  /// URL de base de l'API (calculée, dérivée du mode)
  static const String apiBaseUrl = 'api_base_url';

  /// Environnement actuel (dev/prod/local) - DEPRECATED, utiliser connectionMode
  @Deprecated('Utiliser connectionMode à la place')
  static const String currentEnvironment = 'current_environment';

  // ==================== APP SETTINGS ====================

  /// Langue de l'application
  static const String appLanguage = 'app_language';

  /// Thème de l'application (light/dark)
  static const String appTheme = 'app_theme';

  /// Première ouverture de l'app
  static const String isFirstLaunch = 'is_first_launch';

  /// Version de l'application
  static const String appVersion = 'app_version';

  /// Notifications activées
  static const String notificationsEnabled = 'notifications_enabled';

  // ==================== SYNC SETTINGS ====================
  // Note: Mode offline supprimé selon cahier des charges v1.7

  /// Synchronisation automatique (pour future utilisation)
  static const String autoSyncEnabled = 'auto_sync_enabled';

  /// Intervalle de synchronisation (minutes)
  static const String syncInterval = 'sync_interval';

  /// Dernière synchronisation
  static const String lastSyncDate = 'last_sync_date';

  // ==================== BUSINESS SETTINGS ====================

  /// Entrepôt par défaut
  static const String defaultWarehouse = 'default_warehouse';

  /// Devise par défaut
  static const String defaultCurrency = 'default_currency';

  /// Pays par défaut
  static const String defaultCountry = 'default_country';

  /// Fuseau horaire
  static const String timezone = 'timezone';

  // ==================== UI PREFERENCES ====================

  /// Taille de page pour la pagination
  static const String pageSize = 'page_size';

  /// Affichage grille ou liste
  static const String viewMode = 'view_mode';

  /// Tri par défaut
  static const String defaultSorting = 'default_sorting';

  /// Filtres sauvegardés (JSON)
  static const String savedFilters = 'saved_filters';

  // ==================== CACHE KEYS ====================

  /// Cache des catégories
  static const String cacheCategories = 'cache_categories';

  /// Cache des unités
  static const String cacheUnits = 'cache_units';

  /// Cache des marques
  static const String cacheBrands = 'cache_brands';

  /// Cache des entrepôts
  static const String cacheWarehouses = 'cache_warehouses';

  /// Timestamp du cache
  static const String cacheTimestamp = 'cache_timestamp';

  // ==================== SESSION ====================

  /// Session ID
  static const String sessionId = 'session_id';

  /// Session active
  static const String isSessionActive = 'is_session_active';

  /// Session expiration
  static const String sessionExpiry = 'session_expiry';

  // ==================== POS (Point of Sale) ====================

  /// Caisse ouverte
  static const String posSessionOpen = 'pos_session_open';

  /// ID de la session POS
  static const String posSessionId = 'pos_session_id';

  /// Montant de départ de caisse
  static const String posStartingCash = 'pos_starting_cash';

  /// Panier en cours (JSON)
  static const String posCurrentCart = 'pos_current_cart';

  // ==================== DEBUG & DEVELOPMENT ====================

  /// Mode debug activé
  static const String debugMode = 'debug_mode';

  /// Logs activés
  static const String loggingEnabled = 'logging_enabled';

  /// Niveau de logs
  static const String logLevel = 'log_level';
}