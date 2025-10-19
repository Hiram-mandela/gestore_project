// ========================================
// lib/config/routes.dart
// Configuration complète des routes avec GoRouter
// VERSION MISE À JOUR - AppLayout appliqué partout sauf PosScreen/Login/Splash
// Date: 18 Octobre 2025
// ========================================

import 'package:go_router/go_router.dart';
import '../core/network/connection_mode.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
// ==================== INVENTORY ====================
import '../features/inventory/presentation/screens/alert_detail_screen.dart';
import '../features/inventory/presentation/screens/alerts_dashboard_screen.dart';
import '../features/inventory/presentation/screens/alerts_list_screen.dart';
import '../features/inventory/presentation/screens/articles_list_screen.dart';
import '../features/inventory/presentation/screens/article_detail_screen.dart';
import '../features/inventory/presentation/screens/article_form_screen.dart';
import '../features/inventory/presentation/screens/categories_list_screen.dart';
import '../features/inventory/presentation/screens/brands_list_screen.dart';
import '../features/inventory/presentation/screens/location_detail_screen.dart';
import '../features/inventory/presentation/screens/location_form_screen.dart';
import '../features/inventory/presentation/screens/locations_list_screen.dart';
import '../features/inventory/presentation/screens/movement_detail_screen.dart';
import '../features/inventory/presentation/screens/movements_dashboard_screen.dart';
import '../features/inventory/presentation/screens/movements_list_screen.dart';
import '../features/inventory/presentation/screens/stock_adjustment_screen.dart';
import '../features/inventory/presentation/screens/stock_detail_screen.dart';
import '../features/inventory/presentation/screens/stock_transfer_screen.dart';
import '../features/inventory/presentation/screens/stock_valuation_screen.dart';
import '../features/inventory/presentation/screens/stocks_list_screen.dart';
import '../features/inventory/presentation/screens/unit_conversion_form_screen.dart';
import '../features/inventory/presentation/screens/unit_conversions_list_screen.dart';
import '../features/inventory/presentation/screens/units_list_screen.dart';
import '../features/inventory/presentation/providers/article_form_state.dart';
import '../features/inventory/presentation/providers/category_state.dart';
import '../features/inventory/presentation/providers/brand_state.dart';
import '../features/inventory/presentation/providers/unit_state.dart';
import '../features/inventory/presentation/screens/brand_form_screen.dart';
import '../features/inventory/presentation/screens/category_form_screen.dart';
import '../features/inventory/presentation/screens/unit_form_screen.dart';
// ==================== SALES ====================
import '../features/sales/presentation/screens/discount_form_screen.dart';
import '../features/sales/presentation/screens/discounts_list_screen.dart';
import '../features/sales/presentation/screens/payment_method_form_screen.dart';
import '../features/sales/presentation/screens/payment_methods_list_screen.dart';
import '../features/sales/presentation/screens/pos_screen.dart';
import '../features/sales/presentation/screens/customers_screen.dart';
import '../features/sales/presentation/screens/customer_form_screen.dart';
import '../features/sales/presentation/screens/sales_history_screen.dart';
import '../features/sales/presentation/screens/sale_detail_screen.dart';
// ==================== SETTINGS ====================
import '../features/settings/presentation/screens/connection_config_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
// ==================== SHARED ====================
import '../shared/widgets/app_layout.dart';

/// Configuration des routes avec GoRouter
final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
    // ========================================
    // ROUTES PUBLIQUES (sans layout)
    // ========================================
    // Splash Screen (route initiale)
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    // Login Screen
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),

    // ========================================
    // SALES - POS (POINT OF SALE) ROUTE
    // Demandé SANS AppLayout
    // ========================================
    GoRoute(
      path: '/sales/pos',
      name: 'pos',
      builder: (context, state) => const PosScreen(),
    ),

    // ========================================
    // ROUTES PROTÉGÉES (avec layout)
    // ========================================
    // Dashboard
    GoRoute(
      path: '/dashboard',
      name: 'dashboard',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const DashboardScreen(),
      ),
    ),
    // ========================================
    // INVENTORY - ARTICLES ROUTES
    // ========================================
    GoRoute(
      path: '/inventory/articles',
      name: 'articles',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const ArticlesListScreen(),
      ),
      routes: [
        // Créer un article
        GoRoute(
          path: 'new',
          name: 'article-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const ArticleFormScreen(
              mode: ArticleFormMode.create,
            ),
          ),
        ),
        // Détail article
        GoRoute(
          path: ':id',
          name: 'article-detail',
          builder: (context, state) {
            final articleId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: ArticleDetailScreen(articleId: articleId),
            );
          },
          routes: [
            // Éditer article
            GoRoute(
              path: 'edit',
              name: 'article-edit',
              builder: (context, state) {
                final articleId = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: ArticleFormScreen(
                    mode: ArticleFormMode.edit,
                    articleId: articleId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ========================================
    // INVENTORY - CATEGORIES ROUTES
    // ========================================
    GoRoute(
      path: '/inventory/categories',
      name: 'categories',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const CategoriesListScreen(),
      ),
      routes: [
        // Créer une catégorie
        GoRoute(
          path: 'new',
          name: 'category-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const CategoryFormScreen(
              mode: CategoryFormMode.create,
            ),
          ),
        ),
        // Détail/Édition catégorie
        GoRoute(
          path: ':id',
          name: 'category-detail',
          builder: (context, state) {
            final categoryId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: CategoryFormScreen(
                mode: CategoryFormMode.edit,
                categoryId: categoryId,
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'category-edit',
              builder: (context, state) {
                final categoryId = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: CategoryFormScreen(
                    mode: CategoryFormMode.edit,
                    categoryId: categoryId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ========================================
    // INVENTORY - BRANDS ROUTES
    // ========================================
    GoRoute(
      path: '/inventory/brands',
      name: 'brands',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const BrandsListScreen(),
      ),
      routes: [
        // Créer une marque
        GoRoute(
          path: 'new',
          name: 'brand-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const BrandFormScreen(
              mode: BrandFormMode.create,
            ),
          ),
        ),
        // Détail/Édition marque
        GoRoute(
          path: ':id',
          name: 'brand-detail',
          builder: (context, state) {
            final brandId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: BrandFormScreen(
                mode: BrandFormMode.edit,
                brandId: brandId,
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'brand-edit',
              builder: (context, state) {
                final brandId = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: BrandFormScreen(
                    mode: BrandFormMode.edit,
                    brandId: brandId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ========================================
    // INVENTORY - UNITS OF MEASURE ROUTES
    // ========================================
    GoRoute(
      path: '/inventory/units',
      name: 'units',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const UnitsListScreen(),
      ),
      routes: [
        // Créer une unité
        GoRoute(
          path: 'new',
          name: 'unit-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const UnitFormScreen(
              mode: UnitFormMode.create,
            ),
          ),
        ),
        // Détail/Édition unité
        GoRoute(
          path: ':id',
          name: 'unit-detail',
          builder: (context, state) {
            final unitId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: UnitFormScreen(
                mode: UnitFormMode.edit,
                unitId: unitId,
              ),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'unit-edit',
              builder: (context, state) {
                final unitId = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: UnitFormScreen(
                    mode: UnitFormMode.edit,
                    unitId: unitId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ========================================
    // INVENTORY - UNIT CONVERSIONS ROUTES
    // ========================================
    GoRoute(
      path: '/inventory/unit-conversions',
      name: 'unit-conversions',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const UnitConversionsListScreen(),
      ),
      routes: [
        // Créer une conversion
        GoRoute(
          path: 'new',
          name: 'unit-conversion-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const UnitConversionFormScreen(),
          ),
        ),
        // Modifier une conversion
        GoRoute(
          path: ':id/edit',
          name: 'unit-conversion-edit',
          builder: (context, state) {
            final conversionId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: UnitConversionFormScreen(conversionId: conversionId),
            );
          },
        ),
      ],
    ),
    // ==================== LOCATIONS (MISE À JOUR AVEC LAYOUT) ====================
    GoRoute(
      path: '/inventory/locations',
      name: 'locations',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const LocationsListScreen(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'location-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const LocationFormScreen(),
          ),
        ),
        GoRoute(
          path: ':id',
          name: 'location-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: LocationDetailScreen(locationId: id),
            );
          },
          routes: [
            GoRoute(
              path: 'edit',
              name: 'location-edit',
              builder: (context, state) {
                final id = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: LocationFormScreen(locationId: id),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ==================== STOCKS (MISE À JOUR AVEC LAYOUT) ====================
    GoRoute(
      path: '/inventory/stocks',
      name: 'stocks',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const StocksListScreen(),
      ),
      routes: [
        GoRoute(
          path: 'adjustment',
          name: 'stock-adjustment',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const StockAdjustmentScreen(),
          ),
        ),
        GoRoute(
          path: 'transfer',
          name: 'stock-transfer',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const StockTransferScreen(),
          ),
        ),
        GoRoute(
          path: 'valuation',
          name: 'stock-valuation',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const StockValuationScreen(),
          ),
        ),
        GoRoute(
          path: ':id',
          name: 'stock-detail',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: StockDetailScreen(stockId: id), // À créer si nécessaire
            );
          },
        ),
      ],
    ),
    // ==================== STOCK ALERTS (MISE À JOUR AVEC LAYOUT) ====================
    GoRoute(
      path: '/inventory/alerts/dashboard',
      name: 'alerts-dashboard',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const AlertsDashboardScreen(),
      ),
    ),
    GoRoute(
      path: '/inventory/alerts/list',
      name: 'alerts-list',
      builder: (context, state) {
        final queryParams = state.uri.queryParameters;
        return AppLayout(
          currentRoute: state.matchedLocation,
          child: AlertsListScreen(
            initialAlertType: queryParams['alertType'],
            initialAlertLevel: queryParams['alertLevel'],
            initialIsAcknowledged: queryParams['isAcknowledged'] == 'true',
          ),
        );
      },
    ),
    GoRoute(
      path: '/inventory/alerts/:alertId',
      name: 'alert-detail',
      builder: (context, state) {
        final alertId = state.pathParameters['alertId']!;
        return AppLayout(
          currentRoute: state.matchedLocation,
          child: AlertDetailScreen(alertId: alertId),
        );
      },
    ),
    // ========================================
    // INVENTORY - STOCK MOVEMENTS ROUTES (PHASE 5)
    // ========================================
    GoRoute(
      path: '/inventory/movements',
      name: 'movements',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const MovementsListScreen(),
      ),
      routes: [
        // Dashboard des mouvements
        GoRoute(
          path: 'dashboard',
          name: 'movements-dashboard',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const MovementsDashboardScreen(),
          ),
        ),
        // Détail d'un mouvement
        GoRoute(
          path: ':id',
          name: 'movement-detail',
          builder: (context, state) {
            final movementId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: MovementDetailScreen(movementId: movementId),
            );
          },
        ),
      ],
    ),
    // ========================================
    // SALES - CUSTOMERS ROUTES
    // ========================================
    GoRoute(
      path: '/sales/customers',
      name: 'customers',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const CustomersScreen(),
      ),
      routes: [
        // Créer un client
        GoRoute(
          path: 'new',
          name: 'customer-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const CustomerFormScreen(),
          ),
        ),
        // Détail/Édition client
        GoRoute(
          path: ':id',
          name: 'customer-detail',
          builder: (context, state) {
            final customerId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: CustomerFormScreen(
                customerId: customerId,
              ),
            );
          },
          routes: [
            // Éditer client
            GoRoute(
              path: 'edit',
              name: 'customer-edit',
              builder: (context, state) {
                final customerId = state.pathParameters['id']!;
                return AppLayout(
                  currentRoute: state.matchedLocation,
                  child: CustomerFormScreen(
                    customerId: customerId,
                  ),
                );
              },
            ),
          ],
        ),
      ],
    ),
    // ========================================
    // SALES - SALES HISTORY ROUTES
    // ========================================
    GoRoute(
      path: '/sales/history',
      name: 'sales-history',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const SalesHistoryScreen(),
      ),
      routes: [
        // Détail d'une vente
        GoRoute(
          path: ':id',
          name: 'sale-detail',
          builder: (context, state) {
            final saleId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: SaleDetailScreen(saleId: saleId),
            );
          },
        ),
      ],
    ),
    // ==================== PAYMENT METHODS (MISE À JOUR AVEC LAYOUT) ====================
    GoRoute(
      path: '/sales/payment-methods',
      name: 'payment-methods',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const PaymentMethodsListScreen(),
      ),
      routes: [
        // Nouveau moyen de paiement
        GoRoute(
          path: 'new',
          name: 'payment-method-new',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const PaymentMethodFormScreen(),
          ),
        ),
        // Modifier un moyen de paiement
        GoRoute(
          path: ':id',
          name: 'payment-method-edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: PaymentMethodFormScreen(paymentMethodId: id),
            );
          },
        ),
      ],
    ),
    // ==================== DISCOUNTS (MISE À JOUR AVEC LAYOUT) ====================
    GoRoute(
      path: '/sales/discounts',
      name: 'discounts-list',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const DiscountsListScreen(),
      ),
      routes: [
        GoRoute(
          path: 'new',
          name: 'discount-create',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const DiscountFormScreen(),
          ),
        ),
        GoRoute(
          path: ':id',
          name: 'discount-edit',
          builder: (context, state) {
            final id = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: DiscountFormScreen(discountId: id),
            );
          },
        ),
      ],
    ),
    // ========================================
    // SETTINGS ROUTES
    // ========================================
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const SettingsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'connection',
          name: 'connection-config',
          builder: (context, state) {
            // Récupérer la config initiale si passée en extra
            final initialConfig = state.extra as ConnectionConfig?;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: ConnectionConfigScreen(
                initialConfig: initialConfig,
              ),
            );
          },
        ),
      ],
    ),
  ],
);