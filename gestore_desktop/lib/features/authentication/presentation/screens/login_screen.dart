// ========================================
// lib/features/authentication/presentation/screens/login_screen.dart
// VERSION AMÉLIORÉE - Affichage élégant des erreurs
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
    final authState = ref.watch(authProvider);

    // Écouter les changements pour naviguer en cas de succès
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!context.mounted) return;

      if (next is AuthAuthenticated) {
        // Naviguer vers l'écran principal avec GoRouter
        context.go('/dashboard');
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

                  // Sous-titre
                  Text(
                    'Connectez-vous pour accéder à GESTORE',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Message d'erreur (si présent)
                  if (authState is AuthError) ...[
                    _ErrorMessage(
                      message: authState.message,
                      fieldErrors: authState.fieldErrors,
                      onDismiss: () {
                        ref.read(authProvider.notifier).clearError();
                      },
                    ),
                    const SizedBox(height: 24),
                  ],

                  // Formulaire de connexion
                  const LoginForm(),
                  const SizedBox(height: 24),

                  // Lien mot de passe oublié (optionnel)
                  TextButton(
                    onPressed: () {
                      // TODO: Navigation vers mot de passe oublié
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Fonctionnalité à venir'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    },
                    child: Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ),

                  // Version de l'application
                  const SizedBox(height: 32),
                  Text(
                    'Version 1.0.0',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey[400],
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

/// Widget pour afficher un message d'erreur élégant
class _ErrorMessage extends StatelessWidget {
  final String message;
  final Map<String, List<String>>? fieldErrors;
  final VoidCallback? onDismiss;

  const _ErrorMessage({
    required this.message,
    this.fieldErrors,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header avec icône et bouton fermer
          Row(
            children: [
              Icon(
                Icons.error_outline,
                color: Colors.red.shade700,
                size: 24,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Erreur de connexion',
                  style: TextStyle(
                    color: Colors.red.shade900,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
              ),
              if (onDismiss != null)
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.red.shade700,
                    size: 20,
                  ),
                  onPressed: onDismiss,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 8),

          // Message principal
          Text(
            message,
            style: TextStyle(
              color: Colors.red.shade800,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          // Erreurs de champs (si présentes)
          if (fieldErrors != null && fieldErrors!.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...fieldErrors!.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.arrow_right,
                      color: Colors.red.shade600,
                      size: 20,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${_formatFieldName(entry.key)} : ${entry.value.join(", ")}',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ],
      ),
    );
  }

  /// Formater le nom du champ pour l'affichage
  String _formatFieldName(String fieldName) {
    switch (fieldName.toLowerCase()) {
      case 'username':
        return 'Nom d\'utilisateur';
      case 'password':
        return 'Mot de passe';
      case 'email':
        return 'Email';
      default:
      // Capitaliser la première lettre
        return fieldName[0].toUpperCase() + fieldName.substring(1);
    }
  }
}