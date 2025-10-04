// ========================================
// lib/config/dependencies.dart
// Configuration complète de l'injection de dépendances
// VERSION COMPLÈTE - Avec Inventory CRUD
// ========================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';

// Authentication
import '../features/authentication/data/datasources/auth_local_datasource.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/refresh_token_usecase.dart';

// Settings
import '../features/settings/data/datasources/settings_local_datasource.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/domain/usecases/get_connection_config_usecase.dart';
import '../features/settings/domain/usecases/get_connection_history_usecase.dart';
import '../features/settings/domain/usecases/save_connection_config_usecase.dart';
import '../features/settings/domain/usecases/validate_connection_usecase.dart';

// Inventory
import '../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../features/inventory/data/repositories/inventory_repository_impl.dart';
import '../features/inventory/domain/repositories/inventory_repository.dart';
import '../features/inventory/domain/usecases/get_articles_usecase.dart';
import '../features/inventory/domain/usecases/get_article_detail_usecase.dart';
import '../features/inventory/domain/usecases/search_articles_usecase.dart';
import '../features/inventory/domain/usecases/get_categories_usecase.dart';
import '../features/inventory/domain/usecases/get_brands_usecase.dart';
import '../features/inventory/domain/usecases/create_article_usecase.dart';
import '../features/inventory/domain/usecases/update_article_usecase.dart';
import '../features/inventory/domain/usecases/delete_article_usecase.dart';

// Environment
import 'environment.dart';

/// Instance globale de GetIt
final getIt = GetIt.instance;

/// Configuration de l'injection de dépendances
/// IMPORTANT: Appeler cette fonction dans main() avant runApp()
Future<void> configureDependencies() async {
  final logger = Logger(
    printer: PrettyPrinter(
      methodCount: 2,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.onlyTimeAndSinceStart,
    ),
  );

  logger.i('🔧 Configuration des dépendances...');

  // ========================================
  // CORE DEPENDENCIES
  // ========================================

  // Logger
  getIt.registerLazySingleton<Logger>(() => logger);

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
  logger.d('Initialisation SharedPreferences...');
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

  logger.i('✅ Core dependencies configurées');

  // ========================================
  // AUTHENTICATION FEATURE
  // ========================================

  logger.d('Configuration module Authentication...');

  // Data Sources
  getIt.registerLazySingleton<AuthLocalDataSource>(
        () => AuthLocalDataSourceImpl(
      getIt<FlutterSecureStorage>(),
      getIt<SharedPreferences>(),
    ),
  );

  getIt.registerLazySingleton<AuthRemoteDataSource>(
        () => AuthRemoteDataSourceImpl(getIt<ApiClient>()),
  );

  // Repository
  getIt.registerLazySingleton<AuthRepository>(
        () => AuthRepositoryImpl(
      getIt<AuthRemoteDataSource>(),
      getIt<AuthLocalDataSource>(),
      getIt<NetworkInfo>(),
      getIt<Logger>(),
      getIt<ApiClient>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
        () => LoginUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
        () => LogoutUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
        () => RefreshTokenUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetCurrentUserUseCase(getIt<AuthRepository>()),
  );

  getIt.registerLazySingleton(
        () => CheckAuthStatusUseCase(getIt<AuthRepository>()),
  );

  logger.i('✅ Module Authentication configuré');

  // ========================================
  // SETTINGS FEATURE
  // ========================================

  logger.d('Configuration module Settings...');

  // Data Sources
  getIt.registerLazySingleton<SettingsLocalDataSource>(
        () => SettingsLocalDataSourceImpl(getIt<SharedPreferences>()),
  );

  // Repository
  getIt.registerLazySingleton<SettingsRepository>(
        () => SettingsRepositoryImpl(
      getIt<SettingsLocalDataSource>(),
      getIt<ApiClient>(),
      getIt<Logger>(),
    ),
  );

  // Use Cases
  getIt.registerLazySingleton(
        () => GetConnectionConfigUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton(
        () => SaveConnectionConfigUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton(
        () => ValidateConnectionUseCase(getIt<SettingsRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetConnectionHistoryUseCase(getIt<SettingsRepository>()),
  );

  logger.i('✅ Module Settings configuré');

  // ========================================
  // INVENTORY FEATURE (COMPLET AVEC CRUD)
  // ========================================

  logger.d('Configuration module Inventory...');

  // Data Sources
  getIt.registerLazySingleton<InventoryRemoteDataSource>(
        () => InventoryRemoteDataSourceImpl(
      apiClient: getIt<ApiClient>(),
      logger: getIt<Logger>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<InventoryRepository>(
        () => InventoryRepositoryImpl(
      remoteDataSource: getIt<InventoryRemoteDataSource>(),
      logger: getIt<Logger>(),
    ),
  );

  // Use Cases - Lecture
  getIt.registerLazySingleton(
        () => GetArticlesUseCase(getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetArticleDetailUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => SearchArticlesUseCase(getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetCategoriesUseCase(getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetBrandsUseCase(getIt<InventoryRepository>()),
  );

  // Use Cases - CRUD (Create, Update, Delete)
  getIt.registerLazySingleton(
        () => CreateArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.i('✅ Module Inventory (avec CRUD) configuré');

  // ========================================
  // AUTRES FEATURES À VENIR
  // ========================================
  // - Sales (POS)
  // - Suppliers
  // - Reporting
  // - Licensing

  logger.i('🎉 Toutes les dépendances configurées avec succès');
  logger.i('📊 Total services enregistrés');
}

// ========================================
// RÉCAPITULATIF DES DÉPENDANCES
// ========================================

/*
CORE (6 services):
  ✅ Logger
  ✅ AppEnvironment
  ✅ FlutterSecureStorage
  ✅ SharedPreferences
  ✅ Connectivity
  ✅ NetworkInfo
  ✅ ApiClient

AUTHENTICATION (8 services):
  ✅ AuthLocalDataSource
  ✅ AuthRemoteDataSource
  ✅ AuthRepository
  ✅ LoginUseCase
  ✅ LogoutUseCase
  ✅ RefreshTokenUseCase
  ✅ GetCurrentUserUseCase
  ✅ CheckAuthStatusUseCase

SETTINGS (6 services):
  ✅ SettingsLocalDataSource
  ✅ SettingsRepository
  ✅ GetConnectionConfigUseCase
  ✅ SaveConnectionConfigUseCase
  ✅ ValidateConnectionUseCase
  ✅ GetConnectionHistoryUseCase

INVENTORY (11 services):
  ✅ InventoryRemoteDataSource
  ✅ InventoryRepository
  ✅ GetArticlesUseCase
  ✅ GetArticleDetailUseCase
  ✅ SearchArticlesUseCase
  ✅ GetCategoriesUseCase
  ✅ GetBrandsUseCase
  ✅ CreateArticleUseCase          ⭐ CRUD
  ✅ UpdateArticleUseCase          ⭐ CRUD
  ✅ DeleteArticleUseCase          ⭐ CRUD

TOTAL: ~31 services enregistrés

USAGE DANS LE CODE:
  // Récupérer un service
  final logger = getIt<Logger>();
  final apiClient = getIt<ApiClient>();
  final loginUseCase = getIt<LoginUseCase>();

  // Dans les providers Riverpod
  final articlesProvider = StateNotifierProvider((ref) {
    return ArticlesNotifier(
      getArticlesUseCase: getIt<GetArticlesUseCase>(),
      logger: getIt<Logger>(),
    );
  });
*/