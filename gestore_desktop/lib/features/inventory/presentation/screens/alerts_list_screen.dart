// ========================================
// lib/features/inventory/presentation/pages/alerts_list_screen.dart
// Page liste des alertes avec filtres et sélection multiple
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/stock_alert_entity.dart';
import '../providers/stock_alerts_provider.dart';
import '../providers/stock_alerts_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_level_indicator.dart';

class AlertsListScreen extends ConsumerStatefulWidget {
  final String? initialAlertType;
  final String? initialAlertLevel;
  final bool? initialIsAcknowledged;

  const AlertsListScreen({
    super.key,
    this.initialAlertType,
    this.initialAlertLevel,
    this.initialIsAcknowledged,
  });

  @override
  ConsumerState<AlertsListScreen> createState() => _AlertsListScreenState();
}

class _AlertsListScreenState extends ConsumerState<AlertsListScreen> {
  String? _selectedAlertType;
  String? _selectedAlertLevel;
  bool _showAcknowledged = false;
  bool _selectionMode = false;
  final Set<String> _selectedAlerts = {};

  @override
  void initState() {
    super.initState();
    _selectedAlertType = widget.initialAlertType;
    _selectedAlertLevel = widget.initialAlertLevel;
    _showAcknowledged = widget.initialIsAcknowledged ?? false;

    // Charger les alertes
    Future.microtask(() => _loadAlerts());
  }

  void _loadAlerts() {
    ref.read(stockAlertsProvider.notifier).loadAlerts(
      alertType: _selectedAlertType,
      alertLevel: _selectedAlertLevel,
      isAcknowledged: _showAcknowledged ? null : false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockAlertsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertes de stock'),
        actions: [
          // Bouton mode sélection
          if (!_selectionMode)
            IconButton(
              icon: const Icon(Icons.checklist),
              tooltip: 'Mode sélection',
              onPressed: () {
                setState(() {
                  _selectionMode = true;
                  _selectedAlerts.clear();
                });
              },
            ),

          // Bouton annuler sélection
          if (_selectionMode)
            IconButton(
              icon: const Icon(Icons.close),
              tooltip: 'Annuler',
              onPressed: () {
                setState(() {
                  _selectionMode = false;
                  _selectedAlerts.clear();
                });
              },
            ),

          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: _loadAlerts,
          ),

          IconButton(
            icon: const Icon(Icons.dashboard),
            tooltip: 'Dashboard',
            onPressed: () {
              context.push('/inventory/alerts/dashboard');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filtres
          _buildFiltersSection(theme),

          // Stats rapides
          if (state is StockAlertsLoaded) _buildQuickStats(state, theme),

          // Liste des alertes
          Expanded(child: _buildBody(state, theme)),
        ],
      ),

      // Barre d'actions flottante pour sélection multiple
      floatingActionButton: _selectionMode && _selectedAlerts.isNotEmpty
          ? _buildBulkActionsBar()
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildFiltersSection(ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Filtres',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              // Filtre par niveau
              Expanded(
                child: _buildLevelFilter(),
              ),
              const SizedBox(width: 12),

              // Filtre par type
              Expanded(
                child: _buildTypeFilter(),
              ),
              const SizedBox(width: 12),

              // Switch alertes acquittées
              Expanded(
                child: SwitchListTile(
                  title: const Text(
                    'Acquittées',
                    style: TextStyle(fontSize: 14),
                  ),
                  value: _showAcknowledged,
                  onChanged: (value) {
                    setState(() {
                      _showAcknowledged = value;
                    });
                    _loadAlerts();
                  },
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),

              // Bouton réinitialiser
              IconButton(
                icon: const Icon(Icons.clear_all),
                tooltip: 'Réinitialiser filtres',
                onPressed: () {
                  setState(() {
                    _selectedAlertType = null;
                    _selectedAlertLevel = null;
                    _showAcknowledged = false;
                  });
                  _loadAlerts();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLevelFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedAlertLevel,
      decoration: const InputDecoration(
        labelText: 'Niveau',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tous')),
        DropdownMenuItem(value: 'critical', child: Text('🔴 Critique')),
        DropdownMenuItem(value: 'warning', child: Text('🟠 Avertissement')),
        DropdownMenuItem(value: 'info', child: Text('🔵 Information')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAlertLevel = value;
        });
        _loadAlerts();
      },
    );
  }

  Widget _buildTypeFilter() {
    return DropdownButtonFormField<String>(
      value: _selectedAlertType,
      decoration: const InputDecoration(
        labelText: 'Type',
        border: OutlineInputBorder(),
        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        isDense: true,
      ),
      items: const [
        DropdownMenuItem(value: null, child: Text('Tous')),
        DropdownMenuItem(value: 'low_stock', child: Text('Stock bas')),
        DropdownMenuItem(value: 'out_of_stock', child: Text('Rupture')),
        DropdownMenuItem(value: 'expiry_soon', child: Text('Péremption proche')),
        DropdownMenuItem(value: 'expired', child: Text('Périmé')),
        DropdownMenuItem(value: 'overstock', child: Text('Surstock')),
      ],
      onChanged: (value) {
        setState(() {
          _selectedAlertType = value;
        });
        _loadAlerts();
      },
    );
  }

  Widget _buildQuickStats(StockAlertsLoaded state, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade300),
        ),
      ),
      child: Row(
        children: [
          Text(
            '${state.totalCount} alertes',
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 16),
          AlertLevelIndicator(
            level: AlertLevel.critical,
            count: state.criticalCount,
            showLabel: false,
            isCompact: true,
          ),
          const SizedBox(width: 8),
          AlertLevelIndicator(
            level: AlertLevel.warning,
            count: state.warningCount,
            showLabel: false,
            isCompact: true,
          ),
          const SizedBox(width: 8),
          AlertLevelIndicator(
            level: AlertLevel.info,
            count: state.infoCount,
            showLabel: false,
            isCompact: true,
          ),
        ],
      ),
    );
  }

  Widget _buildBody(StockAlertsState state, ThemeData theme) {
    if (state is StockAlertsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StockAlertsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Erreur', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAlerts,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockAlertsLoaded) {
      if (state.alerts.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.check_circle, size: 64, color: Colors.green.shade300),
              const SizedBox(height: 16),
              Text(
                'Aucune alerte',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              const Text('Tout est sous contrôle !'),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () async => _loadAlerts(),
        child: ListView.builder(
          padding: const EdgeInsets.only(bottom: 80),
          itemCount: state.alerts.length,
          itemBuilder: (context, index) {
            final alert = state.alerts[index];
            final isSelected = _selectedAlerts.contains(alert.id);

            return AlertCard(
              alert: alert,
              isSelected: isSelected,
              onSelected: _selectionMode
                  ? (selected) {
                setState(() {
                  if (selected == true) {
                    _selectedAlerts.add(alert.id);
                  } else {
                    _selectedAlerts.remove(alert.id);
                  }
                });
              }
                  : null,
              onTap: _selectionMode
                  ? null
                  : () => context.push('/inventory/alerts/${alert.id}'),
              onAcknowledge: _selectionMode
                  ? null
                  : () => _acknowledgeAlert(alert.id),
              showActions: !_selectionMode,
            );
          },
        ),
      );
    }

    if (state is StockAlertAcknowledged) {
      // Recharger après acquittement
      Future.microtask(() => _loadAlerts());
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StockAlertsBulkAcknowledged) {
      // Recharger après acquittement en masse
      Future.microtask(() {
        _loadAlerts();
        setState(() {
          _selectionMode = false;
          _selectedAlerts.clear();
        });
      });
      return const Center(child: CircularProgressIndicator());
    }

    return const Center(child: Text('Aucune donnée'));
  }

  Widget _buildBulkActionsBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${_selectedAlerts.length} sélectionnée(s)',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 20),
          ElevatedButton.icon(
            onPressed: () => _bulkAcknowledge(),
            icon: const Icon(Icons.check_circle),
            label: const Text('Acquitter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _acknowledgeAlert(String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acquitter l\'alerte'),
        content: const Text(
          'Êtes-vous sûr de vouloir acquitter cette alerte ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Acquitter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(stockAlertsProvider.notifier).acknowledgeAlert(alertId);
    }
  }

  Future<void> _bulkAcknowledge() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acquitter les alertes'),
        content: Text(
          'Êtes-vous sûr de vouloir acquitter ${_selectedAlerts.length} alerte(s) ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Acquitter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref
          .read(stockAlertsProvider.notifier)
          .bulkAcknowledgeAlerts(_selectedAlerts.toList());
    }
  }
}