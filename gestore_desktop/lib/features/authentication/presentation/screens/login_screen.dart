// ========================================
// features/authentication/presentation/screens/login_screen.dart
// VERSION CORRIGÉE AVEC GOROUTER
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';
import '../widgets/login_form.dart';
import '../widgets/logo_widget.dart';

/// Écran de connexion
class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Écouter les changements pour naviguer en cas de succès
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!context.mounted) return;

      if (next is AuthAuthenticated) {
        // Naviguer vers l'écran principal avec GoRouter
        context.go('/home');
      } else if (next is AuthError) {
        // Afficher l'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Logo et titre
                  const LogoWidget(),
                  const SizedBox(height: 48),

                  // Titre de connexion
                  Text(
                    'Connexion',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    'Connectez-vous pour accéder à votre espace',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Formulaire de connexion
                  const LoginForm(),
                  const SizedBox(height: 24),

                  // Version
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[500],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}