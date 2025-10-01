import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import 'environment.dart';

/// Instance globale de GetIt
final getIt = GetIt.instance;

/// Configuration de l'injection de dépendances
/// À appeler au démarrage de l'application
@InjectableInit(preferRelativeImports: false)
Future<void> configureDependencies() async {
  // Core dependencies - Enregistrées manuellement

  // Logger
  getIt.registerLazySingleton<Logger>(
        () => Logger(
      printer: PrettyPrinter(
        methodCount: 2,
        errorMethodCount: 8,
        lineLength: 120,
        colors: true,
        printEmojis: true,
        dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
      ),
    ),
  );

  // AppEnvironment
  getIt.registerLazySingleton<AppEnvironment>(() => AppEnvironment.current);

  // Secure Storage
  getIt.registerLazySingleton<FlutterSecureStorage>(
        () => const FlutterSecureStorage(
      aOptions: AndroidOptions(
        encryptedSharedPreferences: true,
      ),
    ),
  );

  // Shared Preferences
  final sharedPreferences = await SharedPreferences.getInstance();
  getIt.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  // Connectivity
  getIt.registerLazySingleton<Connectivity>(() => Connectivity());

  // Network Info
  getIt.registerLazySingleton<NetworkInfo>(
        () => NetworkInfoImpl(getIt<Connectivity>()),
  );

  // API Client
  getIt.registerLazySingleton<ApiClient>(
        () => ApiClient(
      secureStorage: getIt<FlutterSecureStorage>(),
      logger: getIt<Logger>(),
      environment: getIt<AppEnvironment>(),
    ),
  );

  // Les autres dépendances seront générées automatiquement par injectable
  // après avoir ajouté les annotations @injectable, @lazySingleton, etc.
  // dans les différentes classes

  // Exemple d'utilisation dans une classe:
  // @lazySingleton
  // class AuthRepository implements IAuthRepository { ... }
}