// ========================================
// lib/config/environment.dart
// VERSION REFACTORISÉE - Gestion dynamique des environnements
// Supporte les 3 modes de connexion avec configuration à chaud
// ========================================

import '../core/network/connection_mode.dart';

/// Configuration dynamique de l'environnement GESTORE
/// Permet de changer de mode de connexion sans redémarrer l'app
class AppEnvironment {
  final String name;
  final String apiBaseUrl;
  final ConnectionMode connectionMode;
  final bool enableLogging;
  final bool enablePrettyJson;
  final int connectTimeout;
  final int receiveTimeout;

  const AppEnvironment({
    required this.name,
    required this.apiBaseUrl,
    required this.connectionMode,
    this.enableLogging = true,
    this.enablePrettyJson = true,
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
  });

  // ==================== CONFIGURATIONS PRÉDÉFINIES ====================

  /// Configuration localhost par défaut
  static const localhost = AppEnvironment(
    name: 'Localhost',
    apiBaseUrl: 'http://127.0.0.1:8080/api',
    connectionMode: ConnectionMode.localhost,
    enableLogging: true,
    enablePrettyJson: true,
  );

  /// Configuration réseau local par défaut
  static const localNetwork = AppEnvironment(
    name: 'Local Network',
    apiBaseUrl: 'http://192.168.1.100:8080/api',
    connectionMode: ConnectionMode.localNetwork,
    enableLogging: true,
    enablePrettyJson: true,
  );

  /// Configuration cloud par défaut
  static const cloud = AppEnvironment(
    name: 'Cloud',
    apiBaseUrl: 'https://api.gestore.com/api',
    connectionMode: ConnectionMode.cloud,
    enableLogging: false,
    enablePrettyJson: false,
    connectTimeout: 20000,
    receiveTimeout: 20000,
  );

  /// Configuration développement (pour les tests)
  static const development = AppEnvironment(
    name: 'Development',
    apiBaseUrl: 'http://localhost:8080/api',
    connectionMode: ConnectionMode.localhost,
    enableLogging: true,
    enablePrettyJson: true,
  );

  // ==================== CRÉATION DYNAMIQUE ====================

  /// Créer un environnement depuis une configuration de connexion
  factory AppEnvironment.fromConnectionConfig(ConnectionConfig config) {
    return AppEnvironment(
      name: config.displayName,
      apiBaseUrl: config.fullApiUrl,
      connectionMode: config.mode,
      enableLogging: config.mode != ConnectionMode.cloud,
      enablePrettyJson: config.mode != ConnectionMode.cloud,
      connectTimeout: config.mode == ConnectionMode.cloud ? 20000 : 30000,
      receiveTimeout: config.mode == ConnectionMode.cloud ? 20000 : 30000,
    );
  }

  /// Créer un environnement localhost personnalisé
  factory AppEnvironment.customLocalhost({
    String host = '127.0.0.1',
    int port = 8080,
  }) {
    return AppEnvironment(
      name: 'Localhost Custom',
      apiBaseUrl: 'http://$host:$port/api',
      connectionMode: ConnectionMode.localhost,
      enableLogging: true,
      enablePrettyJson: true,
    );
  }

  /// Créer un environnement réseau local personnalisé
  factory AppEnvironment.customLocalNetwork({
    required String serverIp,
    int port = 8080,
    bool useHttps = false,
  }) {
    final protocol = useHttps ? 'https' : 'http';
    return AppEnvironment(
      name: 'Local Network - $serverIp',
      apiBaseUrl: '$protocol://$serverIp:$port/api',
      connectionMode: ConnectionMode.localNetwork,
      enableLogging: true,
      enablePrettyJson: true,
    );
  }

  /// Créer un environnement cloud personnalisé
  factory AppEnvironment.customCloud({
    required String domain,
    int port = 443,
  }) {
    final portSuffix = port != 443 ? ':$port' : '';
    return AppEnvironment(
      name: 'Cloud - $domain',
      apiBaseUrl: 'https://$domain$portSuffix/api',
      connectionMode: ConnectionMode.cloud,
      enableLogging: false,
      enablePrettyJson: false,
      connectTimeout: 20000,
      receiveTimeout: 20000,
    );
  }

  // ==================== ENVIRONNEMENT PAR DÉFAUT ====================

  /// Environnement par défaut au démarrage
  /// IMPORTANT: Sera écrasé dynamiquement lors du chargement des préférences
  static AppEnvironment _currentEnvironment = localhost;

  /// Obtenir l'environnement actuel
  static AppEnvironment get current => _currentEnvironment;

  /// Définir l'environnement actuel
  /// Utilisé par le ConnectionService pour changer de mode à chaud
  static void setCurrent(AppEnvironment environment) {
    _currentEnvironment = environment;
  }

  // ==================== MÉTHODES UTILITAIRES ====================

  /// Obtenir l'URL de base (sans /api)
  String get baseUrl {
    return apiBaseUrl.replaceAll(RegExp(r'/api/?$'), '');
  }

  /// Vérifier si l'environnement nécessite HTTPS
  bool get requiresHttps {
    return apiBaseUrl.startsWith('https://');
  }

  /// Vérifier si l'environnement nécessite internet
  bool get requiresInternet {
    return connectionMode.requiresInternet;
  }

  /// Extraire l'hôte de l'URL
  String get host {
    final uri = Uri.parse(apiBaseUrl);
    return uri.host;
  }

  /// Extraire le port de l'URL
  int get port {
    final uri = Uri.parse(apiBaseUrl);
    return uri.port;
  }

  /// Copier avec modifications
  AppEnvironment copyWith({
    String? name,
    String? apiBaseUrl,
    ConnectionMode? connectionMode,
    bool? enableLogging,
    bool? enablePrettyJson,
    int? connectTimeout,
    int? receiveTimeout,
  }) {
    return AppEnvironment(
      name: name ?? this.name,
      apiBaseUrl: apiBaseUrl ?? this.apiBaseUrl,
      connectionMode: connectionMode ?? this.connectionMode,
      enableLogging: enableLogging ?? this.enableLogging,
      enablePrettyJson: enablePrettyJson ?? this.enablePrettyJson,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      receiveTimeout: receiveTimeout ?? this.receiveTimeout,
    );
  }

  @override
  String toString() => 'AppEnvironment: $name ($apiBaseUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppEnvironment &&
        other.name == name &&
        other.apiBaseUrl == apiBaseUrl &&
        other.connectionMode == connectionMode;
  }

  @override
  int get hashCode {
    return name.hashCode ^ apiBaseUrl.hashCode ^ connectionMode.hashCode;
  }
}