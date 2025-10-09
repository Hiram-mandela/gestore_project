// ========================================
// lib/config/dependencies.dart
// Configuration complète de l'injection de dépendances
// VERSION MISE À JOUR - Inventory 100% (Articles + Catégories + Marques + Unités)
// Date: 04 Octobre 2025
// ========================================

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Core
import '../core/network/api_client.dart';
import '../core/network/network_info.dart';
import '../core/utils/jwt_helper.dart';

// Environment
import 'environment.dart';

// ==================== AUTHENTICATION ====================
import '../features/authentication/data/datasources/auth_local_datasource.dart';
import '../features/authentication/data/datasources/auth_remote_datasource.dart';
import '../features/authentication/data/repositories/auth_repository_impl.dart';
import '../features/authentication/domain/repositories/auth_repository.dart';
import '../features/authentication/domain/usecases/check_auth_status_usecase.dart';
import '../features/authentication/domain/usecases/get_current_user_usecase.dart';
import '../features/authentication/domain/usecases/login_usecase.dart';
import '../features/authentication/domain/usecases/logout_usecase.dart';
import '../features/authentication/domain/usecases/refresh_token_usecase.dart';

// ==================== SETTINGS ====================
import '../features/settings/data/datasources/settings_local_datasource.dart';
import '../features/settings/data/repositories/settings_repository_impl.dart';
import '../features/settings/domain/repositories/settings_repository.dart';
import '../features/settings/domain/usecases/get_connection_config_usecase.dart';
import '../features/settings/domain/usecases/get_connection_history_usecase.dart';
import '../features/settings/domain/usecases/save_connection_config_usecase.dart';
import '../features/settings/domain/usecases/validate_connection_usecase.dart';

// ==================== INVENTORY ====================
// Data Layer
import '../features/inventory/data/datasources/inventory_remote_datasource.dart';
import '../features/inventory/data/repositories/inventory_repository_impl.dart';

// Domain Layer
import '../features/inventory/domain/repositories/inventory_repository.dart';

// Use Cases - Articles
import '../features/inventory/domain/usecases/get_articles_usecase.dart';
import '../features/inventory/domain/usecases/get_article_detail_usecase.dart';
import '../features/inventory/domain/usecases/search_articles_usecase.dart';
import '../features/inventory/domain/usecases/create_article_usecase.dart';
import '../features/inventory/domain/usecases/update_article_usecase.dart';
import '../features/inventory/domain/usecases/delete_article_usecase.dart';

// Use Cases - Catégories
import '../features/inventory/domain/usecases/get_categories_usecase.dart';
import '../features/inventory/domain/usecases/category_usecases.dart';

// Use Cases - Marques
import '../features/inventory/domain/usecases/get_brands_usecase.dart';
import '../features/inventory/domain/usecases/brand_usecases.dart';

// Use Cases - Unités de mesure
import '../features/inventory/domain/usecases/unit_usecases.dart';

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

  logger.i('🔧 Configuration des dépendances - Version Complète...');

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

  // JWT Helper
  getIt.registerLazySingleton(
        () => JwtHelper(getIt<Logger>()),
  );

  // API Client
  getIt.registerLazySingleton(
        () => ApiClient(
      secureStorage: getIt<FlutterSecureStorage>(),
      logger: getIt<Logger>(),
      jwtHelper: getIt<JwtHelper>(),
      environment: getIt<AppEnvironment>(),
    ),
  );

  logger.i('✅ Core dependencies configurées (7 services)');

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

  logger.i('✅ Module Authentication configuré (8 services)');

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

  logger.i('✅ Module Settings configuré (6 services)');

  // ========================================
  // INVENTORY FEATURE - MODULE COMPLET
  // ========================================

  logger.d('Configuration module Inventory (complet)...');

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

  // ==================== ARTICLES ====================
  logger.d('  → Articles Use Cases...');

  // Lecture
  getIt.registerLazySingleton(
        () => GetArticlesUseCase(getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetArticleDetailUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => SearchArticlesUseCase(getIt<InventoryRepository>()),
  );

  // CRUD
  getIt.registerLazySingleton(
        () => CreateArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteArticleUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 6 Use Cases Articles');

  // ==================== CATÉGORIES ====================
  logger.d('  → Catégories Use Cases...');

  // Liste
  getIt.registerLazySingleton(
        () => GetCategoriesUseCase(getIt<InventoryRepository>()),
  );

  // CRUD
  getIt.registerLazySingleton(
        () => CreateCategoryUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateCategoryUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteCategoryUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetCategoryByIdUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 5 Use Cases Catégories');

  // ==================== MARQUES ====================
  logger.d('  → Marques Use Cases...');

  // Liste
  getIt.registerLazySingleton(
        () => GetBrandsUseCase(getIt<InventoryRepository>()),
  );

  // CRUD
  getIt.registerLazySingleton(
        () => CreateBrandUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateBrandUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteBrandUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetBrandByIdUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 5 Use Cases Marques');

  // ==================== UNITÉS DE MESURE ====================
  logger.d('  → Unités de mesure Use Cases...');

  // Liste
  getIt.registerLazySingleton(
        () => GetUnitsUseCase(repository: getIt<InventoryRepository>()),
  );

  // CRUD
  getIt.registerLazySingleton(
        () => CreateUnitUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateUnitUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteUnitUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetUnitByIdUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 5 Use Cases Unités');

  logger.i('✅ Module Inventory configuré (23 services)');
  logger.i('   - 6 Articles (Get, Detail, Search, Create, Update, Delete)');
  logger.i('   - 5 Catégories (Get, Create, Update, Delete, GetById)');
  logger.i('   - 5 Marques (Get, Create, Update, Delete, GetById)');
  logger.i('   - 5 Unités (Get, Create, Update, Delete, GetById)');

  // ========================================
  // AUTRES FEATURES À VENIR
  // ========================================
  // - Sales (POS)
  // - Suppliers
  // - Reporting
  // - Licensing

  logger.i('');
  logger.i('🎉 Toutes les dépendances configurées avec succès');
  logger.i('📊 Total services enregistrés: ~44');
  logger.i('');
}

// ========================================
// RÉCAPITULATIF DES DÉPENDANCES
// ========================================

/*
═══════════════════════════════════════════════════════════════════════
                    GESTORE - DEPENDENCY INJECTION
═══════════════════════════════════════════════════════════════════════

CORE (7 services):
  ✅ Logger
  ✅ AppEnvironment
  ✅ FlutterSecureStorage
  ✅ SharedPreferences
  ✅ Connectivity
  ✅ NetworkInfo
  ✅ JwtHelper
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

INVENTORY (23 services):
  DataSource & Repository:
    ✅ InventoryRemoteDataSource
    ✅ InventoryRepository

  Articles (6):
    ✅ GetArticlesUseCase
    ✅ GetArticleDetailUseCase
    ✅ SearchArticlesUseCase
    ✅ CreateArticleUseCase
    ✅ UpdateArticleUseCase
    ✅ DeleteArticleUseCase

  Catégories (5):
    ✅ GetCategoriesUseCase
    ✅ CreateCategoryUseCase
    ✅ UpdateCategoryUseCase
    ✅ DeleteCategoryUseCase
    ✅ GetCategoryByIdUseCase

  Marques (5):
    ✅ GetBrandsUseCase
    ✅ CreateBrandUseCase
    ✅ UpdateBrandUseCase
    ✅ DeleteBrandUseCase
    ✅ GetBrandByIdUseCase

  Unités de mesure (5):
    ✅ GetUnitsUseCase
    ✅ CreateUnitUseCase
    ✅ UpdateUnitUseCase
    ✅ DeleteUnitUseCase
    ✅ GetUnitByIdUseCase

═══════════════════════════════════════════════════════════════════════
TOTAL: 44 services enregistrés
═══════════════════════════════════════════════════════════════════════

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

  // Dans les widgets
  @override
  Widget build(BuildContext context) {
    final useCase = getIt<CreateArticleUseCase>();
    // ...
  }

═══════════════════════════════════════════════════════════════════════
                        DÉVELOPPÉ AVEC ❤️ POUR GESTORE
═══════════════════════════════════════════════════════════════════════
*/