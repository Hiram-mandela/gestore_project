// ========================================
// lib/config/routes.dart
// Configuration des routes avec GoRouter et AppLayout
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';
import '../features/dashboard/presentation/screens/dashboard_screen.dart';
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
          message: 'Module en développement',
        ),
      ),
      routes: [
        // Nouveau article
        GoRoute(
          path: 'new',
          name: 'inventory_new',
          builder: (context, state) => AppLayout(
            currentRoute: '/inventory',
            child: const _PlaceholderScreen(
              title: 'Nouvel article',
              icon: Icons.add_box_rounded,
              message: 'Formulaire de création',
            ),
          ),
        ),
      ],
    ),

    // Point de vente (POS)
    GoRoute(
      path: '/pos',
      name: 'pos',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Point de vente',
          icon: Icons.point_of_sale_rounded,
          message: 'Interface POS en développement',
        ),
      ),
    ),

    // Clients
    GoRoute(
      path: '/customers',
      name: 'customers',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Clients',
          icon: Icons.people_rounded,
          message: 'Gestion des clients',
        ),
      ),
      routes: [
        // Nouveau client
        GoRoute(
          path: 'new',
          name: 'customers_new',
          builder: (context, state) => AppLayout(
            currentRoute: '/customers',
            child: const _PlaceholderScreen(
              title: 'Nouveau client',
              icon: Icons.person_add_rounded,
              message: 'Formulaire d\'enregistrement',
            ),
          ),
        ),
      ],
    ),

    // Rapports
    GoRoute(
      path: '/reports',
      name: 'reports',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Rapports',
          icon: Icons.analytics_rounded,
          message: 'Analytics et statistiques',
        ),
      ),
    ),

    // Paramètres
    GoRoute(
      path: '/settings',
      name: 'settings',
      builder: (context, state) => AppLayout(
        currentRoute: state.matchedLocation,
        child: const _PlaceholderScreen(
          title: 'Paramètres',
          icon: Icons.settings_rounded,
          message: 'Configuration de l\'application',
        ),
      ),
    ),
  ],

  // Gestion des erreurs de navigation
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            'Page non trouvée',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 12),
          Text(
            state.uri.toString(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () => context.go('/home'),
            icon: const Icon(Icons.home),
            label: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    ),
  ),
);

/// Écran placeholder pour les modules en développement
class _PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const _PlaceholderScreen({
    required this.title,
    required this.icon,
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icône
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Icon(
                  icon,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

              const SizedBox(height: 32),

              // Titre
              Text(
                title,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Message
              Text(
                message,
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 32),

              // Indicateur
              const CircularProgressIndicator(),

              const SizedBox(height: 16),

              Text(
                'En cours de développement...',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}