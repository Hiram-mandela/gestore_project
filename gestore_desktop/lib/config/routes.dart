// ========================================
// config/routes.dart
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/authentication/presentation/providers/auth_provider.dart';
import '../features/authentication/presentation/screens/login_screen.dart';
import '../features/authentication/presentation/screens/splash_screen.dart';

/// Configuration des routes avec GoRouter
final goRouter = GoRouter(
  initialLocation: '/',
  debugLogDiagnostics: true,
  routes: [
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

    // Home Screen (temporaire - à remplacer par le vrai home)
    GoRoute(
      path: '/home',
      name: 'home',
      builder: (context, state) => const HomeScreenPlaceholder(),
    ),

    // TODO: Ajouter les autres routes (inventory, sales, etc.)
  ],

  // Gestion des erreurs de navigation
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 16),
          Text(
            'Page non trouvée',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text('${state.uri}'),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Retour à l\'accueil'),
          ),
        ],
      ),
    ),
  ),
);

/// Écran home temporaire (placeholder)
class HomeScreenPlaceholder extends ConsumerWidget {
  const HomeScreenPlaceholder({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('GESTORE - Accueil'),
        actions: [
          // Afficher l'utilisateur connecté
          if (currentUser != null) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Center(
                child: Text(
                  currentUser.fullName,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.logout),
              tooltip: 'Se déconnecter',
              onPressed: () async {
                // Afficher confirmation
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Déconnexion'),
                    content: const Text('Voulez-vous vraiment vous déconnecter ?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(false),
                        child: const Text('Annuler'),
                      ),
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(true),
                        child: const Text('Déconnexion'),
                      ),
                    ],
                  ),
                );

                if (confirm == true && context.mounted) {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) {
                    context.go('/login');
                  }
                }
              },
            ),
          ],
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle, size: 64, color: Colors.green),
            const SizedBox(height: 16),
            Text(
              'Connexion réussie !',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Écran d\'accueil temporaire'),
            const SizedBox(height: 24),
            const Text('Les modules seront ajoutés ici :'),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _ModuleCard(
                  icon: Icons.inventory,
                  title: 'Inventory',
                  subtitle: 'À venir',
                ),
                _ModuleCard(
                  icon: Icons.shopping_cart,
                  title: 'Sales',
                  subtitle: 'À venir',
                ),
                _ModuleCard(
                  icon: Icons.local_shipping,
                  title: 'Suppliers',
                  subtitle: 'À venir',
                ),
                _ModuleCard(
                  icon: Icons.bar_chart,
                  title: 'Reports',
                  subtitle: 'À venir',
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ModuleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _ModuleCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Container(
        width: 150,
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 48),
            const SizedBox(height: 8),
            Text(
              title,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            Text(
              subtitle,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}