// ========================================
// lib/features/settings/presentation/widgets/connection_test_widget.dart
// Widget pour tester une connexion
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/network/connection_mode.dart';
import '../../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';

/// Widget pour tester une connexion
class ConnectionTestWidget extends ConsumerWidget {
  final ConnectionConfig config;

  const ConnectionTestWidget({
    super.key,
    required this.config,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final validationState = ref.watch(connectionValidationStateProvider);
    final controller = ref.read(settingsControllerProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  Icons.speed,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Text(
                  'Test de connexion',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Résultat du test
            if (validationState.isValidating)
              _buildLoadingState()
            else if (validationState.result != null)
              _buildResultState(validationState.result!)
            else if (validationState.errorMessage != null)
                _buildErrorState(validationState.errorMessage!)
              else
                _buildIdleState(),

            const SizedBox(height: AppTheme.spacingMd),

            // Bouton tester
            ElevatedButton.icon(
              onPressed: validationState.isValidating
                  ? null
                  : () async {
                // Réinitialiser l'état
                controller.resetValidationState();

                // Lancer le test
                await controller.validateConnection(config);
              },
              icon: validationState.isValidating
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.play_arrow),
              label: Text(
                validationState.isValidating
                    ? 'Test en cours...'
                    : 'Tester la connexion',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: Colors.blue.shade700,
            ),
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              'Test de la connexion en cours...',
              style: TextStyle(
                color: Colors.blue.shade900,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultState(ConnectionValidationResult result) {
    if (result.isValid) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.green.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.green.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.check_circle,
                  color: Colors.green.shade700,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    'Connexion réussie',
                    style: TextStyle(
                      color: Colors.green.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            if (result.responseTimeMs != null) ...[
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                'Temps de réponse: ${result.responseTimeMs}ms',
                style: TextStyle(
                  color: Colors.green.shade800,
                  fontSize: 14,
                ),
              ),
            ],
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Le serveur est accessible et fonctionne correctement.',
              style: TextStyle(
                color: Colors.green.shade800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    } else {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error,
                  color: Colors.red.shade700,
                  size: 24,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Text(
                    'Connexion échouée',
                    style: TextStyle(
                      color: Colors.red.shade900,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              result.errorMessage ?? 'Impossible de se connecter au serveur.',
              style: TextStyle(
                color: Colors.red.shade800,
                fontSize: 13,
              ),
            ),
          ],
        ),
      );
    }
  }

  Widget _buildErrorState(String errorMessage) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline,
            color: Colors.red.shade700,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              errorMessage,
              style: TextStyle(
                color: Colors.red.shade900,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIdleState() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            color: Colors.grey.shade600,
          ),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Text(
              'Cliquez sur le bouton pour tester la connexion au serveur.',
              style: TextStyle(
                color: Colors.grey.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}