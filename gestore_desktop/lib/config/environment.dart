/// Configuration des environnements GESTORE
/// Gère les différents environnements (dev, prod, local network)
class AppEnvironment {
  final String name;
  final String apiBaseUrl;
  final bool enableLogging;
  final bool enablePrettyJson;
  final int connectTimeout;
  final int receiveTimeout;

  const AppEnvironment({
    required this.name,
    required this.apiBaseUrl,
    this.enableLogging = true,
    this.enablePrettyJson = true,
    this.connectTimeout = 30000,
    this.receiveTimeout = 30000,
  });

  /// Environnement de développement
  static const development = AppEnvironment(
    name: 'Development',
    apiBaseUrl: 'http://localhost:8080/api',
    enableLogging: true,
    enablePrettyJson: true,
  );

  /// Environnement de production
  static const production = AppEnvironment(
    name: 'Production',
    apiBaseUrl: 'https://api.gestore.com',
    enableLogging: false,
    enablePrettyJson: false,
    connectTimeout: 20000,
    receiveTimeout: 20000,
  );

  /// Environnement réseau local
  static const localNetwork = AppEnvironment(
    name: 'Local Network',
    apiBaseUrl: 'http://127.0.0.1:8080/api', // À configurer selon votre réseau
    enableLogging: true,
    enablePrettyJson: true,
  );

  /// Environnement actuel (changez selon vos besoins)
  static AppEnvironment get current => development;

  @override
  String toString() => 'AppEnvironment: $name ($apiBaseUrl)';
}