// ========================================
// lib/features/settings/presentation/widgets/connection_mode_selector.dart
// Widget pour sélectionner le mode de connexion
// ========================================

import 'package:flutter/material.dart';

import '../../../../core/network/connection_mode.dart';
import '../../../../shared/themes/app_theme.dart';

/// Widget pour sélectionner le mode de connexion
class ConnectionModeSelector extends StatelessWidget {
  final ConnectionConfig currentConfig;
  final Function(ConnectionConfig) onConfigSelected;
  final VoidCallback onCustomConfig;

  const ConnectionModeSelector({
    super.key,
    required this.currentConfig,
    required this.onConfigSelected,
    required this.onCustomConfig,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Configuration actuelle
        _CurrentConfigCard(config: currentConfig),

        const SizedBox(height: AppTheme.spacingLg),

        // Sélection rapide des modes
        Text(
          'Modes prédéfinis',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Localhost
        _ModeCard(
          mode: ConnectionMode.localhost,
          isSelected: currentConfig.mode == ConnectionMode.localhost &&
              currentConfig.serverUrl == '127.0.0.1',
          onTap: () {
            onConfigSelected(ConnectionConfig.localhost());
          },
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Local Network
        _ModeCard(
          mode: ConnectionMode.localNetwork,
          isSelected: currentConfig.mode == ConnectionMode.localNetwork,
          onTap: onCustomConfig, // Ouvrir config personnalisée
          subtitle: 'Configurer l\'adresse IP du serveur',
        ),

        const SizedBox(height: AppTheme.spacingMd),

        // Cloud
        _ModeCard(
          mode: ConnectionMode.cloud,
          isSelected: currentConfig.mode == ConnectionMode.cloud,
          onTap: onCustomConfig, // Ouvrir config personnalisée
          subtitle: 'Configurer le domaine cloud',
        ),

        const SizedBox(height: AppTheme.spacingLg),

        // Bouton configuration personnalisée
        OutlinedButton.icon(
          onPressed: onCustomConfig,
          icon: const Icon(Icons.settings_rounded),
          label: const Text('Configuration personnalisée'),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
          ),
        ),
      ],
    );
  }
}

/// Card affichant la configuration actuelle
class _CurrentConfigCard extends StatelessWidget {
  final ConnectionConfig config;

  const _CurrentConfigCard({required this.config});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.green.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.green.shade700,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Configuration active',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        config.mode.displayName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  config.mode.icon,
                  style: const TextStyle(fontSize: 28),
                ),
              ],
            ),
            const Divider(height: 24),
            _InfoRow(
              icon: Icons.dns_rounded,
              label: 'Serveur',
              value: config.serverUrl,
            ),
            const SizedBox(height: 8),
            _InfoRow(
              icon: Icons.link_rounded,
              label: 'URL',
              value: config.fullApiUrl,
            ),
            if (config.port != null) ...[
              const SizedBox(height: 8),
              _InfoRow(
                icon: Icons.settings_ethernet,
                label: 'Port',
                value: config.port.toString(),
              ),
            ],
            const SizedBox(height: 8),
            _InfoRow(
              icon: config.useHttps ? Icons.lock : Icons.lock_open,
              label: 'Protocole',
              value: config.useHttps ? 'HTTPS (Sécurisé)' : 'HTTP',
              valueColor: config.useHttps ? Colors.green : Colors.orange,
            ),
          ],
        ),
      ),
    );
  }
}

/// Widget pour une ligne d'information
class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey.shade600),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade600,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: valueColor,
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}

/// Card pour un mode de connexion
class _ModeCard extends StatelessWidget {
  final ConnectionMode mode;
  final bool isSelected;
  final VoidCallback onTap;
  final String? subtitle;

  const _ModeCard({
    required this.mode,
    required this.isSelected,
    required this.onTap,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: isSelected ? 4 : 1,
      color: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Row(
            children: [
              // Icône du mode
              Text(
                mode.icon,
                style: const TextStyle(fontSize: 32),
              ),

              const SizedBox(width: AppTheme.spacingMd),

              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mode.displayName,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : null,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle ?? mode.description,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    if (mode.requiresInternet) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.wifi,
                            size: 14,
                            color: Colors.orange.shade700,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Internet requis',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.orange.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Indicateur sélection
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).primaryColor,
                  size: 28,
                )
              else
                Icon(
                  Icons.chevron_right,
                  color: Colors.grey.shade400,
                ),
            ],
          ),
        ),
      ),
    );
  }
}