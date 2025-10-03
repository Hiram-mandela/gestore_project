// ========================================
// lib/features/settings/presentation/screens/connection_config_screen.dart
// Écran de configuration personnalisée de connexion
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/network/connection_mode.dart';
import '../../../../shared/themes/app_theme.dart';
import '../providers/settings_provider.dart';
import '../widgets/connection_test_widget.dart';
import '../widgets/server_config_form.dart';

/// Écran de configuration de connexion personnalisée
class ConnectionConfigScreen extends ConsumerStatefulWidget {
  final ConnectionConfig? initialConfig;

  const ConnectionConfigScreen({
    super.key,
    this.initialConfig,
  });

  @override
  ConsumerState<ConnectionConfigScreen> createState() =>
      _ConnectionConfigScreenState();
}

class _ConnectionConfigScreenState
    extends ConsumerState<ConnectionConfigScreen> {
  late ConnectionConfig _currentConfig;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _currentConfig = widget.initialConfig ?? ConnectionConfig.localhost();
  }

  void _onConfigChanged(ConnectionConfig newConfig) {
    setState(() {
      _currentConfig = newConfig;
      _hasChanges = true;
    });
  }

  Future<void> _saveAndApply() async {
    final controller = ref.read(settingsControllerProvider);

    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Application de la configuration...'),
              ],
            ),
          ),
        ),
      ),
    );

    final success = await controller.saveAndApplyConfig(_currentConfig);

    if (mounted) {
      Navigator.of(context).pop(); // Fermer le loader

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Configuration appliquée avec succès',
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Retourner à l'écran précédent
        context.pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Erreur lors de l\'application',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red.shade600,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration Serveur'),
        actions: [
          // Bouton Sauvegarder
          TextButton.icon(
            onPressed: _hasChanges ? _saveAndApply : null,
            icon: const Icon(Icons.save),
            label: const Text('Appliquer'),
            style: TextButton.styleFrom(
              foregroundColor: _hasChanges
                  ? Theme.of(context).primaryColor
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: Colors.blue.shade50,
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: Colors.blue.shade700,
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Expanded(
                      child: Text(
                        'Configurez les paramètres de connexion au serveur GESTORE',
                        style: TextStyle(
                          color: Colors.blue.shade900,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Formulaire de configuration
            ServerConfigForm(
              initialConfig: _currentConfig,
              onConfigChanged: _onConfigChanged,
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Widget de test de connexion
            ConnectionTestWidget(
              config: _currentConfig,
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Exemples de configuration
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppTheme.spacingMd),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline,
                          color: Colors.orange.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Exemples de configuration',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.orange.shade900,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildExample(
                      '💻 Localhost',
                      '127.0.0.1:8000',
                    ),
                    const Divider(height: 24),
                    _buildExample(
                      '🏢 Réseau Local',
                      '192.168.1.100:8000',
                    ),
                    const Divider(height: 24),
                    _buildExample(
                      '☁️ Cloud',
                      'api.gestore.com (HTTPS)',
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExample(String title, String url) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                url,
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}