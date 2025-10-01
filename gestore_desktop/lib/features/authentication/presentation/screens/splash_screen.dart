// ========================================
// features/authentication/presentation/screens/splash_screen.dart
// VERSION CORRIGÉE AVEC GOROUTER
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Écran de démarrage avec vérification authentification
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Attendre un peu pour l'animation du splash
    await Future.delayed(const Duration(seconds: 2));

    // Vérifier l'état d'authentification
    if (mounted) {
      await ref.read(authProvider.notifier).checkAuthStatus();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Écouter les changements d'état pour naviguer
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!mounted) return;

      if (next is AuthAuthenticated) {
        // Naviguer vers l'écran principal avec GoRouter
        context.go('/home');
      } else if (next is AuthUnauthenticated) {
        // Naviguer vers l'écran de login avec GoRouter
        context.go('/login');
      } else if (next is AuthError) {
        // En cas d'erreur, aller au login
        context.go('/login');
      }
    });

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Theme.of(context).colorScheme.primary,
              Theme.of(context).colorScheme.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo
              const Icon(
                Icons.store,
                size: 120,
                color: Colors.white,
              ),
              const SizedBox(height: 24),

              // Nom de l'application
              Text(
                'GESTORE',
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 8),

              Text(
                'Gestion Intégrée pour Commerces',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),

              // Indicateur de chargement
              const CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
              const SizedBox(height: 24),

              Text(
                'Chargement...',
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}