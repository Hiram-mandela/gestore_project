// ========================================
// lib/config/routes.dart
// Configuration complète des routes avec GoRouter
// VERSION COMPLÈTE - Avec Inventory CRUD
// ========================================

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../features/inventory/presentation/screens/articles_list_screen.dart';
import '../features/inventory/presentation/screens/article_detail_screen.dart';
import '../features/inventory/presentation/screens/article_form_screen.dart';
import '../features/inventory/presentation/providers/article_form_state.dart';
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
    // INVENTORY ROUTES - COMPLET
    // ========================================

    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const ArticlesListScreen(),
      ),
      routes: [
        // ==================== CRÉATION ====================
        // Créer un nouvel article
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

        // ==================== DÉTAIL + ÉDITION ====================
        // Détail d'un article
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
            // Éditer un article
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
    // POS (Point of Sale) - PLACEHOLDER
    // ========================================

    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Point de vente',
          icon: Icons.point_of_sale_rounded,
          description: 'Module POS à venir',
        ),
      ),
    ),

    // ========================================
    // CUSTOMERS - PLACEHOLDER
    // ========================================

    GoRoute(
      path: '/customers',
      name: 'customers',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Clients',
          icon: Icons.people_rounded,
          description: 'Module Clients à venir',
        ),
      ),
    ),

    // ========================================
    // REPORTS - PLACEHOLDER
    // ========================================

    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Rapports',
          icon: Icons.analytics_rounded,
          description: 'Module Rapports à venir',
        ),
      ),
    ),

    // ========================================
    // SETTINGS
    // ========================================

    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const SettingsScreen(),
      ),
      routes: [
        // Configuration de connexion
        GoRoute(
          path: 'connection',
          name: 'connection-config',
          builder: (context, state) => AppLayout(
            currentRoute: state.matchedLocation,
            child: const ConnectionConfigScreen(),
          ),
        ),
      ],
    ),
  ],
);

// ========================================
// PLACEHOLDER SCREEN (pour les routes non implémentées)
// ========================================

class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String description;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 120,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              title,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 32),
            FilledButton.icon(
              onPressed: () => context.go('/home'),
              icon: const Icon(Icons.home),
              label: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// ROUTES DISPONIBLES - RÉCAPITULATIF
// ========================================

/*
ROUTES PUBLIQUES:
  / (splash)                              → SplashScreen
  /login                                  → LoginScreen

ROUTES PROTÉGÉES:
  /home                                   → DashboardScreen

INVENTORY:
  /inventory                              → ArticlesListScreen (Liste)
  /inventory/new                          → ArticleFormScreen (Création)
  /inventory/article/:id                  → ArticleDetailScreen (Détail)
  /inventory/article/:id/edit             → ArticleFormScreen (Édition)

AUTRES MODULES:
  /pos                                    → PlaceholderScreen
  /customers                              → PlaceholderScreen
  /reports                                → PlaceholderScreen

SETTINGS:
  /settings                               → SettingsScreen
  /settings/connection                    → ConnectionConfigScreen

NAVIGATION EXAMPLES:
  context.go('/inventory')                       // Aller à la liste
  context.pushNamed('article-create')            // Créer article
  context.pushNamed(                             // Voir détail
    'article-detail',
    pathParameters: {'id': articleId},
  )
  context.pushNamed(                             // Éditer
    'article-edit',
    pathParameters: {'id': articleId},
  )
  context.pop()                                  // Retour arrière
*/