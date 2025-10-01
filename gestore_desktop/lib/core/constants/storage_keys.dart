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

  // App Settings
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

  // Sync Settings
  /// Mode hors ligne activé
  static const String offlineModeEnabled = 'offline_mode_enabled';

  /// Synchronisation automatique
  static const String autoSyncEnabled = 'auto_sync_enabled';

  /// Intervalle de synchronisation (minutes)
  static const String syncInterval = 'sync_interval';

  /// Dernière synchronisation
  static const String lastSyncDate = 'last_sync_date';

  /// Statut de la synchronisation
  static const String syncStatus = 'sync_status';

  /// Nombre d'enregistrements en attente de sync
  static const String pendingSyncCount = 'pending_sync_count';

  // API Settings
  /// URL de base de l'API
  static const String apiBaseUrl = 'api_base_url';

  /// Environnement actuel (dev/prod/local)
  static const String currentEnvironment = 'current_environment';

  // Business Settings
  /// Entrepôt par défaut
  static const String defaultWarehouse = 'default_warehouse';

  /// Devise par défaut
  static const String defaultCurrency = 'default_currency';

  /// Pays par défaut
  static const String defaultCountry = 'default_country';

  /// Fuseau horaire
  static const String timezone = 'timezone';

  // UI Preferences
  /// Taille de page pour la pagination
  static const String pageSize = 'page_size';

  /// Affichage grille ou liste
  static const String viewMode = 'view_mode';

  /// Tri par défaut
  static const String defaultSorting = 'default_sorting';

  /// Filtres sauvegardés (JSON)
  static const String savedFilters = 'saved_filters';

  // Cache Keys
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

  // Session
  /// Session ID
  static const String sessionId = 'session_id';

  /// Session active
  static const String isSessionActive = 'is_session_active';

  /// Session expiration
  static const String sessionExpiry = 'session_expiry';

  // POS (Point of Sale)
  /// Caisse ouverte
  static const String posSessionOpen = 'pos_session_open';

  /// ID de la session POS
  static const String posSessionId = 'pos_session_id';

  /// Montant de départ de caisse
  static const String posStartingCash = 'pos_starting_cash';

  /// Panier en cours (JSON)
  static const String posCurrentCart = 'pos_current_cart';

  // Debug & Development
  /// Mode debug activé
  static const String debugMode = 'debug_mode';

  /// Logs activés
  static const String loggingEnabled = 'logging_enabled';

  /// Niveau de logs
  static const String logLevel = 'log_level';
}