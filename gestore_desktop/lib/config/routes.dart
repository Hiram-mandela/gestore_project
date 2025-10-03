// ========================================
// lib/config/routes.dart
// VERSION MIS À JOUR - Ajout routes Settings
// ========================================
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
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

    // Inventory
    GoRoute(
      path: '/inventory',
      name: 'inventory',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Inventaire',
          icon: Icons.inventory_2_rounded,
        ),
      ),
    ),

    // Point of Sale
    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Point de vente',
          icon: Icons.point_of_sale_rounded,
        ),
      ),
    ),

    // Customers
    GoRoute(
      path: '/customers',
      name: 'customers',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Clients',
          icon: Icons.people_rounded,
        ),
      ),
    ),

    // Reports
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Rapports',
          icon: Icons.analytics_rounded,
        ),
      ),
    ),

    // Settings
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
          path: 'connection-config',
          name: 'connection-config',
          builder: (context, state) => const ConnectionConfigScreen(),
        ),
      ],
    ),
  ],
);

/// Widget placeholder pour les écrans à venir
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Cette fonctionnalité sera bientôt disponible',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}