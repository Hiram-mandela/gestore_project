// ========================================
// lib/features/settings/presentation/screens/settings_screen.dart
// Écran principal des paramètres
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/themes/app_theme.dart';
import '../../../../shared/widgets/section_header.dart';
import '../providers/settings_provider.dart';
import '../widgets/connection_mode_selector.dart';

/// Écran des paramètres
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(connectionSettingsProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Row(
              children: [
                Icon(
                  Icons.settings_rounded,
                  size: 32,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Text(
                  'Paramètres',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Section Connexion
            const SectionHeader(
              title: 'Mode de Connexion',
              icon: Icons.link_rounded,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            settingsAsync.when(
              data: (settings) {
                return ConnectionModeSelector(
                  currentConfig: settings.currentConfig,
                  onConfigSelected: (config) async {
                    final controller = ref.read(settingsControllerProvider);
                    final success = await controller.saveAndApplyConfig(config);

                    if (context.mounted) {
                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const Icon(Icons.check_circle,
                                    color: Colors.white),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Configuration appliquée avec succès',
                                    style:
                                    const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ],
                            ),
                            backgroundColor: Colors.green.shade600,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );

                        // Rafraîchir les données
                        ref.invalidate(connectionSettingsProvider);
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
                  },
                  onCustomConfig: () {
                    context.push('/settings/connection-config');
                  },
                );
              },
              loading: () => const Center(
                child: Padding(
                  padding: EdgeInsets.all(AppTheme.spacingXl),
                  child: CircularProgressIndicator(),
                ),
              ),
              error: (error, stack) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingXl),
                  child: Column(
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.shade400,
                      ),
                      const SizedBox(height: AppTheme.spacingMd),
                      Text(
                        'Erreur de chargement',
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        error.toString(),
                        style: TextStyle(color: Colors.red.shade600),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingXl),

            // Autres sections de paramètres (à venir)
            const SectionHeader(
              title: 'Apparence',
              icon: Icons.palette_rounded,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            _SettingTile(
              icon: Icons.dark_mode_rounded,
              title: 'Thème sombre',
              trailing: Switch(
                value: isDark,
                onChanged: (value) {
                  // TODO: Implémenter changement de thème
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fonctionnalité à venir'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                },
              ),
            ),

            const Divider(height: 1),

            const SizedBox(height: AppTheme.spacingXl),

            // Section À propos
            const SectionHeader(
              title: 'À propos',
              icon: Icons.info_rounded,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            _SettingTile(
              icon: Icons.info_outline_rounded,
              title: 'Version',
              subtitle: '1.0.0 (Build 001)',
              onTap: () {},
            ),

            const Divider(height: 1),

            _SettingTile(
              icon: Icons.description_rounded,
              title: 'Licences',
              onTap: () {
                showLicensePage(
                  context: context,
                  applicationName: 'GESTORE',
                  applicationVersion: '1.0.0',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour une ligne de paramètre
class _SettingTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, size: 24),
      title: Text(
        title,
        style: const TextStyle(
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: subtitle != null ? Text(subtitle!) : null,
      trailing: trailing ?? (onTap != null ? const Icon(Icons.chevron_right) : null),
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
    );
  }
}