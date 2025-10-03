// ========================================
// lib/core/network/connection_mode.dart
// Gestion des modes de connexion GESTORE
// ========================================

/// Enum représentant les 3 modes de connexion possibles
enum ConnectionMode {
  /// Mode Localhost - Tout sur une seule machine (127.0.0.1)
  localhost,

  /// Mode Local Network - Serveur local + clients sur LAN (192.168.x.x)
  localNetwork,

  /// Mode Cloud - Serveur distant accessible via internet (HTTPS)
  cloud,
}

/// Extension pour faciliter l'utilisation de ConnectionMode
extension ConnectionModeExtension on ConnectionMode {
  /// Nom d'affichage du mode
  String get displayName {
    switch (this) {
      case ConnectionMode.localhost:
        return 'Localhost';
      case ConnectionMode.localNetwork:
        return 'Réseau Local';
      case ConnectionMode.cloud:
        return 'Cloud';
    }
  }

  /// Description du mode
  String get description {
    switch (this) {
      case ConnectionMode.localhost:
        return 'Mode mono-poste. Tout fonctionne sur cette machine.';
      case ConnectionMode.localNetwork:
        return 'Mode multi-postes. Connexion à un serveur sur le réseau local.';
      case ConnectionMode.cloud:
        return 'Mode distant. Connexion à un serveur cloud via internet.';
    }
  }

  /// Icône représentative du mode
  String get icon {
    switch (this) {
      case ConnectionMode.localhost:
        return '💻'; // Computer
      case ConnectionMode.localNetwork:
        return '🏢'; // Office building
      case ConnectionMode.cloud:
        return '☁️'; // Cloud
    }
  }

  /// URL par défaut selon le mode
  String get defaultUrl {
    switch (this) {
      case ConnectionMode.localhost:
        return 'http://127.0.0.1:8000/api';
      case ConnectionMode.localNetwork:
        return 'http://192.168.1.100:8000/api';
      case ConnectionMode.cloud:
        return 'https://api.gestore.com/api';
    }
  }

  /// Port par défaut selon le mode
  int get defaultPort {
    switch (this) {
      case ConnectionMode.localhost:
      case ConnectionMode.localNetwork:
        return 8000;
      case ConnectionMode.cloud:
        return 443; // HTTPS
    }
  }

  /// Indique si le mode nécessite internet
  bool get requiresInternet {
    switch (this) {
      case ConnectionMode.localhost:
      case ConnectionMode.localNetwork:
        return false;
      case ConnectionMode.cloud:
        return true;
    }
  }

  /// Indique si le mode nécessite HTTPS
  bool get requiresHttps {
    switch (this) {
      case ConnectionMode.localhost:
      case ConnectionMode.localNetwork:
        return false;
      case ConnectionMode.cloud:
        return true;
    }
  }

  /// Convertir depuis une chaîne
  static ConnectionMode fromString(String value) {
    switch (value.toLowerCase()) {
      case 'localhost':
        return ConnectionMode.localhost;
      case 'localnetwork':
      case 'local_network':
        return ConnectionMode.localNetwork;
      case 'cloud':
        return ConnectionMode.cloud;
      default:
        return ConnectionMode.localhost; // Valeur par défaut
    }
  }

  /// Convertir en chaîne pour le stockage
  String toStorageString() {
    switch (this) {
      case ConnectionMode.localhost:
        return 'localhost';
      case ConnectionMode.localNetwork:
        return 'local_network';
      case ConnectionMode.cloud:
        return 'cloud';
    }
  }
}

/// Modèle représentant la configuration d'une connexion
class ConnectionConfig {
  final ConnectionMode mode;
  final String serverUrl;
  final int? port;
  final bool useHttps;
  final String? customName;

  const ConnectionConfig({
    required this.mode,
    required this.serverUrl,
    this.port,
    this.useHttps = false,
    this.customName,
  });

  /// Configuration par défaut pour localhost
  factory ConnectionConfig.localhost() {
    return const ConnectionConfig(
      mode: ConnectionMode.localhost,
      serverUrl: '127.0.0.1',
      port: 8000,
      useHttps: false,
    );
  }

  /// Configuration par défaut pour réseau local
  factory ConnectionConfig.localNetwork({String serverIp = '192.168.1.100'}) {
    return ConnectionConfig(
      mode: ConnectionMode.localNetwork,
      serverUrl: serverIp,
      port: 8000,
      useHttps: false,
    );
  }

  /// Configuration par défaut pour cloud
  factory ConnectionConfig.cloud({String domain = 'api.gestore.com'}) {
    return ConnectionConfig(
      mode: ConnectionMode.cloud,
      serverUrl: domain,
      port: 443,
      useHttps: true,
    );
  }

  /// Créer depuis JSON
  factory ConnectionConfig.fromJson(Map<String, dynamic> json) {
    return ConnectionConfig(
      mode: ConnectionModeExtension.fromString(json['mode'] as String),
      serverUrl: json['server_url'] as String,
      port: json['port'] as int?,
      useHttps: json['use_https'] as bool? ?? false,
      customName: json['custom_name'] as String?,
    );
  }

  /// Convertir en JSON pour le stockage
  Map<String, dynamic> toJson() {
    return {
      'mode': mode.toStorageString(),
      'server_url': serverUrl,
      'port': port,
      'use_https': useHttps,
      'custom_name': customName,
    };
  }

  /// Obtenir l'URL API complète
  String get fullApiUrl {
    final protocol = useHttps ? 'https' : 'http';
    final portSuffix = port != null &&
        ((useHttps && port != 443) || (!useHttps && port != 80))
        ? ':$port'
        : '';

    // Nettoyer l'URL (enlever /api si déjà présent)
    final cleanUrl = serverUrl.replaceAll(RegExp(r'/api/?$'), '');

    return '$protocol://$cleanUrl$portSuffix/api';
  }

  /// Obtenir l'URL de base (sans /api)
  String get baseUrl {
    final protocol = useHttps ? 'https' : 'http';
    final portSuffix = port != null &&
        ((useHttps && port != 443) || (!useHttps && port != 80))
        ? ':$port'
        : '';

    final cleanUrl = serverUrl.replaceAll(RegExp(r'/api/?$'), '');
    return '$protocol://$cleanUrl$portSuffix';
  }

  /// Nom d'affichage de la configuration
  String get displayName {
    if (customName != null && customName!.isNotEmpty) {
      return customName!;
    }
    return '${mode.displayName} - $serverUrl';
  }

  /// Copier avec modifications
  ConnectionConfig copyWith({
    ConnectionMode? mode,
    String? serverUrl,
    int? port,
    bool? useHttps,
    String? customName,
  }) {
    return ConnectionConfig(
      mode: mode ?? this.mode,
      serverUrl: serverUrl ?? this.serverUrl,
      port: port ?? this.port,
      useHttps: useHttps ?? this.useHttps,
      customName: customName ?? this.customName,
    );
  }

  @override
  String toString() => 'ConnectionConfig($displayName - $fullApiUrl)';

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ConnectionConfig &&
        other.mode == mode &&
        other.serverUrl == serverUrl &&
        other.port == port &&
        other.useHttps == useHttps;
  }

  @override
  int get hashCode {
    return mode.hashCode ^
    serverUrl.hashCode ^
    port.hashCode ^
    useHttps.hashCode;
  }
}

/// Résultat de la validation d'une connexion
class ConnectionValidationResult {
  final bool isValid;
  final String? errorMessage;
  final int? responseTimeMs;

  const ConnectionValidationResult({
    required this.isValid,
    this.errorMessage,
    this.responseTimeMs,
  });

  factory ConnectionValidationResult.success({int? responseTimeMs}) {
    return ConnectionValidationResult(
      isValid: true,
      responseTimeMs: responseTimeMs,
    );
  }

  factory ConnectionValidationResult.failure(String errorMessage) {
    return ConnectionValidationResult(
      isValid: false,
      errorMessage: errorMessage,
    );
  }

  /// Message de succès formaté
  String get successMessage {
    if (responseTimeMs != null) {
      return 'Connexion établie avec succès (${responseTimeMs}ms)';
    }
    return 'Connexion établie avec succès';
  }
}