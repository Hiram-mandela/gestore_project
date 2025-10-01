// ========================================
// config/dependencies.dart
// VERSION CORRIGÉE (sans import inutilisé)
// ========================================
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../features/authentication/data/datasources/auth_local_datasource.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/refresh_token_usecase.dart';
import 'environment.dart';

/// Instance globale de GetIt
final getIt = GetIt.instance;

/// Configuration de l'injection de dépendances
Future<void> configureDependencies() async {
  // ==================== CORE DEPENDENCIES ====================

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

  // ==================== AUTHENTICATION FEATURE ====================

  // Data Sources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  getIt.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      getIt<FlutterSecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
      getIt<NetworkInfo>(),
      getIt<Logger>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton<LoginUseCase>(
        () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<LogoutUseCase>(
        () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<GetCurrentUserUseCase>(
        () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<RefreshTokenUseCase>(
        () => RefreshTokenUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton<CheckAuthStatusUseCase>(
        () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
  );
}