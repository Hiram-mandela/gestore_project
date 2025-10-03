// ========================================
// lib/features/settings/presentation/widgets/server_config_form.dart
// Formulaire de configuration serveur
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/network/connection_mode.dart';
import '../../../../shared/themes/app_theme.dart';

/// Formulaire de configuration serveur
class ServerConfigForm extends StatefulWidget {
  final ConnectionConfig initialConfig;
  final Function(ConnectionConfig) onConfigChanged;

  const ServerConfigForm({
    super.key,
    required this.initialConfig,
    required this.onConfigChanged,
  });

  @override
  State<ServerConfigForm> createState() => _ServerConfigFormState();
}

class _ServerConfigFormState extends State<ServerConfigForm> {
  late ConnectionMode _selectedMode;
  late TextEditingController _serverController;
  late TextEditingController _portController;
  late TextEditingController _nameController;
  late bool _useHttps;

  @override
  void initState() {
    super.initState();
    _selectedMode = widget.initialConfig.mode;
    _serverController = TextEditingController(
      text: widget.initialConfig.serverUrl,
    );
    _portController = TextEditingController(
      text: widget.initialConfig.port?.toString() ?? '',
    );
    _nameController = TextEditingController(
      text: widget.initialConfig.customName ?? '',
    );
    _useHttps = widget.initialConfig.useHttps;

    // Écouter les changements
    _serverController.addListener(_notifyChange);
    _portController.addListener(_notifyChange);
    _nameController.addListener(_notifyChange);
  }

  @override
  void dispose() {
    _serverController.dispose();
    _portController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _notifyChange() {
    final config = ConnectionConfig(
      mode: _selectedMode,
      serverUrl: _serverController.text.trim(),
      port: int.tryParse(_portController.text),
      useHttps: _useHttps,
      customName: _nameController.text.trim().isEmpty
          ? null
          : _nameController.text.trim(),
    );

    widget.onConfigChanged(config);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Sélection du mode
            Text(
              'Mode de connexion',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            SegmentedButton<ConnectionMode>(
              segments: [
                ButtonSegment(
                  value: ConnectionMode.localhost,
                  label: Text(_modeShortName(ConnectionMode.localhost)),
                  icon: const Icon(Icons.computer),
                ),
                ButtonSegment(
                  value: ConnectionMode.localNetwork,
                  label: Text(_modeShortName(ConnectionMode.localNetwork)),
                  icon: const Icon(Icons.lan),
                ),
                ButtonSegment(
                  value: ConnectionMode.cloud,
                  label: Text(_modeShortName(ConnectionMode.cloud)),
                  icon: const Icon(Icons.cloud),
                ),
              ],
              selected: {_selectedMode},
              onSelectionChanged: (Set<ConnectionMode> selected) {
                setState(() {
                  _selectedMode = selected.first;

                  // Mettre à jour avec les valeurs par défaut
                  if (_selectedMode == ConnectionMode.localhost) {
                    _serverController.text = '127.0.0.1';
                    _portController.text = '8000';
                    _useHttps = false;
                  } else if (_selectedMode == ConnectionMode.localNetwork) {
                    _serverController.text = '192.168.1.100';
                    _portController.text = '8000';
                    _useHttps = false;
                  } else {
                    _serverController.text = 'api.gestore.com';
                    _portController.text = '443';
                    _useHttps = true;
                  }

                  _notifyChange();
                });
              },
              style: SegmentedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            // Nom personnalisé (optionnel)
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Nom personnalisé (optionnel)',
                hintText: 'Ex: Serveur principal',
                prefixIcon: Icon(Icons.label_outline),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Adresse du serveur
            TextField(
              controller: _serverController,
              decoration: InputDecoration(
                labelText: _selectedMode == ConnectionMode.cloud
                    ? 'Domaine'
                    : 'Adresse IP',
                hintText: _selectedMode == ConnectionMode.cloud
                    ? 'api.gestore.com'
                    : '192.168.1.100',
                prefixIcon: const Icon(Icons.dns_rounded),
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.url,
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // Port
            TextField(
              controller: _portController,
              decoration: const InputDecoration(
                labelText: 'Port',
                hintText: '8000',
                prefixIcon: Icon(Icons.settings_ethernet),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(5),
              ],
            ),

            const SizedBox(height: AppTheme.spacingMd),

            // HTTPS
            SwitchListTile(
              value: _useHttps,
              onChanged: (value) {
                setState(() {
                  _useHttps = value;
                  _notifyChange();
                });
              },
              title: const Text('Utiliser HTTPS'),
              subtitle: Text(
                _useHttps
                    ? 'Connexion sécurisée (recommandé pour le cloud)'
                    : 'Connexion non sécurisée',
                style: TextStyle(
                  fontSize: 12,
                  color: _useHttps ? Colors.green : Colors.orange,
                ),
              ),
              secondary: Icon(
                _useHttps ? Icons.lock : Icons.lock_open,
                color: _useHttps ? Colors.green : Colors.orange,
              ),
              contentPadding: EdgeInsets.zero,
            ),

            const Divider(height: 24),

            // Aperçu de l'URL
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.link,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'URL générée',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _buildPreviewUrl(),
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _modeShortName(ConnectionMode mode) {
    switch (mode) {
      case ConnectionMode.localhost:
        return 'Local';
      case ConnectionMode.localNetwork:
        return 'Réseau';
      case ConnectionMode.cloud:
        return 'Cloud';
    }
  }

  String _buildPreviewUrl() {
    final protocol = _useHttps ? 'https' : 'http';
    final server = _serverController.text.trim().isEmpty
        ? '<serveur>'
        : _serverController.text.trim();
    final port = _portController.text.trim();

    if (port.isEmpty ||
        (_useHttps && port == '443') ||
        (!_useHttps && port == '80')) {
      return '$protocol://$server/api';
    }

    return '$protocol://$server:$port/api';
  }
}