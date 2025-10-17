// ========================================
// lib/config/dependencies.dart
// Configuration complète de l'injection de dépendances
// VERSION COMPLÈTE - Tous modules (Auth + Settings + Inventory + Sales)
// Date: 10 Octobre 2025 - CORRIGÉ
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
import '../features/inventory/domain/usecases/location_usecases.dart';

// Environment
import '../features/inventory/domain/usecases/stock_usecases.dart';
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

// ==================== SALES ====================
// Data Layer
import '../features/sales/data/datasources/sales_remote_datasource.dart';
import '../features/sales/data/repositories/sales_repository_impl.dart';

// Domain Layer
import '../features/sales/domain/repositories/sales_repository.dart';

// Use Cases - Customers
import '../features/sales/domain/usecases/customer_usecases.dart';

// Use Cases - Payment Methods
import '../features/sales/domain/usecases/payment_method_usecases.dart';
import '../features/sales/domain/usecases/create_payment_method_usecase.dart';
import '../features/sales/domain/usecases/update_payment_method_usecase.dart';
import '../features/sales/domain/usecases/delete_payment_method_usecase.dart';


// Use Cases - Discounts
import '../features/sales/domain/usecases/get_active_discounts_usecase.dart';
import '../features/sales/domain/usecases/get_discounts_usecase.dart';
import '../features/sales/domain/usecases/create_discount_usecase.dart';
import '../features/sales/domain/usecases/update_discount_usecase.dart';
import '../features/sales/domain/usecases/delete_discount_usecase.dart';
import '../features/sales/domain/usecases/calculate_discount_usecase.dart';

// Use Cases - Sales
import '../features/sales/domain/usecases/get_sales_usecase.dart';
import '../features/sales/domain/usecases/get_sale_detail_usecase.dart';
import '../features/sales/domain/usecases/void_sale_usecase.dart';
import '../features/sales/domain/usecases/get_daily_summary_usecase.dart';

// Use Cases - POS
import '../features/sales/domain/usecases/pos_checkout_usecase.dart';
import '../features/sales/domain/usecases/calculate_sale_usecase.dart';

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

  logger.i('✅ Core dependencies configurées (8 services)');

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

  getIt.registerLazySingleton(
        () => GetCategoriesUseCase(getIt<InventoryRepository>()),
  );

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

  getIt.registerLazySingleton(
        () => GetBrandsUseCase(getIt<InventoryRepository>()),
  );

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

  getIt.registerLazySingleton(
        () => GetUnitsUseCase(repository: getIt<InventoryRepository>()),
  );

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

  // ==================== LOCATIONS ====================
  logger.d('  → Locations Use Cases...');

  getIt.registerLazySingleton(
        () => GetLocationsUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetLocationByIdUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => CreateLocationUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => UpdateLocationUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => DeleteLocationUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetLocationStocksUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 6 Use Cases Locations');

  // ==================== STOCKS ====================
  logger.d('  → Stocks Use Cases...');

  getIt.registerLazySingleton(
        () => GetStocksUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetStockByIdUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => AdjustStockUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => TransferStockUseCase(repository: getIt<InventoryRepository>()),
  );

  getIt.registerLazySingleton(
        () => GetStockValuationUseCase(repository: getIt<InventoryRepository>()),
  );

  logger.d('    ✓ 5 Use Cases Stocks');

  logger.i('✅ Module Inventory configuré (40 services)');

  // ========================================
  // SALES FEATURE - MODULE COMPLET
  // ========================================

  logger.d('Configuration module Sales (complet)...');

  // Data Sources
  getIt.registerLazySingleton<SalesRemoteDataSource>(
        () => SalesRemoteDataSource(
      apiClient: getIt<ApiClient>(),
      logger: getIt<Logger>(),
    ),
  );

  // Repository
  getIt.registerLazySingleton<SalesRepository>(
        () => SalesRepositoryImpl(
      remoteDataSource: getIt<SalesRemoteDataSource>(),
      logger: getIt<Logger>(),
    ),
  );

  // ==================== CUSTOMERS ====================
  logger.d('  → Customers Use Cases...');

  getIt.registerLazySingleton(
        () => GetCustomersUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetCustomerByIdUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => CreateCustomerUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => UpdateCustomerUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => DeleteCustomerUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetCustomerLoyaltyUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  logger.d('    ✓ 6 Use Cases Customers');

  // ==================== PAYMENT METHODS ====================
  logger.d('  → Payment Methods Use Cases...');

  getIt.registerLazySingleton(
        () => GetPaymentMethodsUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetPaymentMethodByIdUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  // 🆕 NOUVEAUX Use Cases CRUD
  getIt.registerLazySingleton(
        () => CreatePaymentMethodUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => UpdatePaymentMethodUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => DeletePaymentMethodUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  logger.d('    ✓ 5 Use Cases Payment Methods');

  // ==================== DISCOUNTS ====================
  logger.d('  → Discounts Use Cases...');

  // Existants
  getIt.registerLazySingleton(
        () => GetActiveDiscountsUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetDiscountByIdUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  // 🆕 NOUVEAUX Use Cases CRUD
  getIt.registerLazySingleton(
        () => GetDiscountsUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => CreateDiscountUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => UpdateDiscountUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => DeleteDiscountUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => CalculateDiscountUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  logger.d('    ✓ 7 Use Cases Discounts');

  // ==================== SALES ====================
  logger.d('  → Sales Use Cases...');

  getIt.registerLazySingleton(
        () => GetSalesUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetSaleDetailUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => VoidSaleUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => GetDailySummaryUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  logger.d('    ✓ 4 Use Cases Sales');

  // ==================== POS ====================
  logger.d('  → POS Use Cases...');

  getIt.registerLazySingleton(
        () => PosCheckoutUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  getIt.registerLazySingleton(
        () => CalculateSaleUseCase(
      repository: getIt<SalesRepository>(),
      logger: getIt<Logger>(),
    ),
  );

  logger.d('    ✓ 2 Use Cases POS');

  logger.i('✅ Module Sales configuré (18 services)');

  // ========================================
  // RÉSUMÉ FINAL
  // ========================================

  logger.i('''
  
  ╔═══════════════════════════════════════════════════════╗
  ║  ✅ CONFIGURATION DES DÉPENDANCES TERMINÉE           ║
  ╠═══════════════════════════════════════════════════════╣
  ║  📦 Core:            8 services                       ║
  ║  🔐 Authentication:  8 services                       ║
  ║  ⚙️  Settings:        6 services                       ║
  ║  📦 Inventory:       23 services                      ║
  ║  💰 Sales:           18 services                      ║
  ╠═══════════════════════════════════════════════════════╣
  ║  🎉 TOTAL:           63 SERVICES ENREGISTRÉS          ║
  ╚═══════════════════════════════════════════════════════╝
  ''');
}