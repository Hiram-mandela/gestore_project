// ========================================
// lib/config/routes.dart
// Configuration complète des routes avec GoRouter
// VERSION COMPLÈTE - Inventory + Sales + Settings
// Date: 10 Octobre 2025
// ========================================

import 'package:go_router/go_router.dart';

import '../core/network/connection_mode.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';

// ==================== INVENTORY ====================
import '../features/inventory/presentation/screens/articles_list_screen.dart';
import '../features/inventory/presentation/screens/article_detail_screen.dart';
import '../features/inventory/presentation/screens/article_form_screen.dart';
import '../features/inventory/presentation/screens/categories_list_screen.dart';
import '../features/inventory/presentation/screens/brands_list_screen.dart';
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
    // SALES - POS (POINT OF SALE) ROUTE
    // ========================================

    GoRoute(
      path: '/sales/pos',
      name: 'pos',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const PosScreen(),
      ),
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
            child: const CustomerFormScreen(
            ),
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
            return SaleDetailScreen(saleId: saleId);
          },
        ),
      ],
    ),

    // Liste des moyens de paiement
    GoRoute(
      path: '/sales/payment-methods',
      name: 'payment-methods',
      builder: (context, state) => const PaymentMethodsListScreen(),
    ),

    // Nouveau moyen de paiement
    GoRoute(
      path: '/sales/payment-methods/new',
      name: 'payment-method-new',
      builder: (context, state) => const PaymentMethodFormScreen(),
    ),

    // Modifier un moyen de paiement
    GoRoute(
      path: '/sales/payment-methods/:id',
      name: 'payment-method-edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return PaymentMethodFormScreen(paymentMethodId: id);
      },
    ),

    GoRoute(
      path: '/sales/discounts',
      name: 'discounts-list',
      builder: (context, state) => const DiscountsListScreen(),
    ),
    GoRoute(
      path: '/sales/discounts/new',
      name: 'discount-create',
      builder: (context, state) => const DiscountFormScreen(),
    ),
    GoRoute(
      path: '/sales/discounts/:id',
      name: 'discount-edit',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return DiscountFormScreen(discountId: id);
      },
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