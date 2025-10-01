/// Constantes globales de l'application GESTORE
class AppConstants {
  // Application Info
  static const String appName = 'GESTORE';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '001';
  static const String appDescription = 'Système de Gestion Intégrée pour Commerces';

  // Company Info
  static const String defaultCurrency = 'XOF'; // Franc CFA
  static const String defaultCountry = 'CI'; // Côte d'Ivoire
  static const String defaultTimezone = 'Africa/Abidjan';
  static const String defaultLanguage = 'fr'; // Français

  // API Configuration
  static const int apiTimeoutSeconds = 30;
  static const int apiRetryAttempts = 3;
  static const int apiRetryDelaySeconds = 2;

  // Pagination
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;
  static const int minPageSize = 10;

  // Cache Duration
  static const int cacheDurationMinutes = 15;
  static const int tokenRefreshBeforeExpiryMinutes = 5;

  // Session
  static const int sessionTimeoutMinutes = 60; // 8 heures = 480 minutes
  static const int maxLoginAttempts = 5;
  static const int lockoutDurationMinutes = 15;

  // UI
  static const double defaultPadding = 16.0;
  static const double smallPadding = 8.0;
  static const double largePadding = 24.0;
  static const double borderRadius = 8.0;
  static const double iconSize = 24.0;
  static const double avatarSize = 40.0;

  // Animation
  static const int animationDurationMs = 300;
  static const int splashScreenDurationMs = 2000;

  // Database
  static const String databaseName = 'gestore.db';
  static const int databaseVersion = 1;

  // File Upload
  static const int maxFileUploadSizeMB = 10;
  static const List<String> allowedImageExtensions = ['jpg', 'jpeg', 'png', 'gif'];
  static const List<String> allowedDocumentExtensions = ['pdf', 'doc', 'docx', 'xls', 'xlsx'];

  // Formats
  static const String dateFormat = 'dd/MM/yyyy';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';
  static const String timeFormat = 'HH:mm';
  static const String currencyFormat = '#,##0.00';

  // Stock
  static const int lowStockThreshold = 10;
  static const int expiringDaysWarning = 30;
  static const int expiringDaysCritical = 7;

  // Sync
  static const int syncIntervalMinutes = 5;
  static const int syncBatchSize = 100;
  static const int maxSyncRetries = 3;

  // Permissions Modules
  static const String moduleAuth = 'authentication';
  static const String moduleInventory = 'inventory';
  static const String moduleSales = 'sales';
  static const String moduleSuppliers = 'suppliers';
  static const String moduleReporting = 'reporting';

  // User Roles (exemples communs)
  static const String roleSuperAdmin = 'super_admin';
  static const String roleAdmin = 'admin';
  static const String roleManager = 'manager';
  static const String roleCashier = 'cashier';
  static const String roleWarehouse = 'warehouse';

  // Error Messages
  static const String errorNetworkTitle = 'Erreur Réseau';
  static const String errorNetworkMessage = 'Impossible de se connecter au serveur';
  static const String errorAuthTitle = 'Erreur d\'Authentification';
  static const String errorAuthMessage = 'Identifiants invalides';
  static const String errorGenericTitle = 'Erreur';
  static const String errorGenericMessage = 'Une erreur s\'est produite';

  // Success Messages
  static const String successSaveTitle = 'Succès';
  static const String successSaveMessage = 'Données enregistrées avec succès';
  static const String successDeleteTitle = 'Succès';
  static const String successDeleteMessage = 'Données supprimées avec succès';

  // Validation Messages
  static const String validationRequired = 'Ce champ est requis';
  static const String validationEmail = 'Email invalide';
  static const String validationMinLength = 'Minimum {min} caractères';
  static const String validationMaxLength = 'Maximum {max} caractères';
  static const String validationNumeric = 'Doit être un nombre';
  static const String validationPositive = 'Doit être positif';

  // Regex Patterns
  static const String regexEmail = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const String regexPhone = r'^\+?[0-9]{8,15}$';
  static const String regexBarcode = r'^[0-9]{8,13}$';
}