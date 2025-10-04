// ========================================
// lib/config/routes.dart
// Configuration complète des routes avec GoRouter
// VERSION COMPLÈTE - Avec Inventory, Categories, Brands, Units
// ========================================

import 'package:go_router/go_router.dart';

import '../core/network/connection_mode.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
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
import '../features/inventory/presentation/widgets/brand_form_screen.dart';
import '../features/inventory/presentation/widgets/category_form_screen.dart';
import '../features/inventory/presentation/widgets/unit_form_screen.dart';
import '../features/settings/presentation/screens/connection_config_screen.dart';
import '../features/settings/presentation/screens/settings_screen.dart';
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

    // Home/Dashboard
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const DashboardScreen(),
      ),
    ),

    // ========================================
    // INVENTORY - ARTICLES ROUTES
    // ========================================

    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const ArticlesListScreen(),
      ),
      routes: [
        // ==================== CRÉATION ARTICLE ====================
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

        // ==================== DÉTAIL + ÉDITION ARTICLE ====================
        GoRoute(
          path: 'article/:id',
          name: 'article-detail',
          builder: (context, state) {
            final articleId = state.pathParameters['id']!;
            return AppLayout(
              currentRoute: state.matchedLocation,
              child: ArticleDetailScreen(articleId: articleId),
            );
          },
          routes: [
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