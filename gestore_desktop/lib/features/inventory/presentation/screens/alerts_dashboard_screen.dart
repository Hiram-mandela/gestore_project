// ========================================
// lib/features/inventory/presentation/pages/alerts_dashboard_screen.dart
// Page dashboard des alertes avec compteurs et graphiques - VERSION COMPLÈTE
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/stock_alert_entity.dart';
import '../providers/stock_alerts_provider.dart';
import '../providers/stock_alerts_state.dart';
import '../widgets/alert_card.dart';
import '../widgets/alert_level_indicator.dart';

class AlertsDashboardScreen extends ConsumerStatefulWidget {
  const AlertsDashboardScreen({super.key});

  @override
  ConsumerState<AlertsDashboardScreen> createState() =>
      _AlertsDashboardScreenState();
}

class _AlertsDashboardScreenState extends ConsumerState<AlertsDashboardScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref.read(stockAlertsProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockAlertsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard des Alertes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.read(stockAlertsProvider.notifier).loadDashboard();
            },
          ),
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'Voir toutes les alertes',
            onPressed: () {
              context.push('/inventory/alerts/list');
            },
          ),
        ],
      ),
      body: _buildBody(state, theme),
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
            Text('Erreur de chargement', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: theme.textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(stockAlertsProvider.notifier).loadDashboard();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockAlertsDashboardLoaded) {
      return _buildDashboard(state, theme);
    }

    return const Center(child: Text('Aucune donnée disponible'));
  }

  Widget _buildDashboard(StockAlertsDashboardLoaded state, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(stockAlertsProvider.notifier).loadDashboard();
      },
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildOverviewSection(state, theme),
            const SizedBox(height: 24),
            _buildAlertsByLevelSection(state, theme),
            const SizedBox(height: 24),
            _buildAlertsByTypeSection(state, theme),
            const SizedBox(height: 24),
            _buildRecentAlertsSection(state, theme),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewSection(
      StockAlertsDashboardLoaded state,
      ThemeData theme,
      ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.dashboard, color: theme.primaryColor),
                const SizedBox(width: 12),
                Text(
                  'Vue d\'ensemble',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.notifications_active,
                    label: 'Total alertes',
                    value: state.totalAlerts.toString(),
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.error,
                    label: 'Critiques',
                    value: state.criticalAlerts.toString(),
                    color: Colors.red,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.warning,
                    label: 'Avertissements',
                    value: state.warningAlerts.toString(),
                    color: Colors.orange,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildStatCard(
                    icon: Icons.info,
                    label: 'Informations',
                    value: state.infoAlerts.toString(),
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertsByLevelSection(
      StockAlertsDashboardLoaded state,
      ThemeData theme,
      ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par niveau de gravité',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                InkWell(
                  onTap: () => _navigateToFilteredAlerts('critical'),
                  child: AlertLevelIndicator(
                    level: AlertLevel.critical,
                    count: state.criticalAlerts,
                  ),
                ),
                InkWell(
                  onTap: () => _navigateToFilteredAlerts('warning'),
                  child: AlertLevelIndicator(
                    level: AlertLevel.warning,
                    count: state.warningAlerts,
                  ),
                ),
                InkWell(
                  onTap: () => _navigateToFilteredAlerts('info'),
                  child: AlertLevelIndicator(
                    level: AlertLevel.info,
                    count: state.infoAlerts,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAlertsByTypeSection(
      StockAlertsDashboardLoaded state,
      ThemeData theme,
      ) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Répartition par type',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _buildTypeRow(
              icon: Icons.trending_down,
              label: 'Stock bas',
              count: state.lowStockAlerts,
              color: Colors.orange,
              onTap: () => _navigateToFilteredAlerts('low_stock', byType: true),
            ),
            const Divider(height: 24),
            _buildTypeRow(
              icon: Icons.remove_shopping_cart,
              label: 'Rupture de stock',
              count: state.outOfStockAlerts,
              color: Colors.red,
              onTap: () =>
                  _navigateToFilteredAlerts('out_of_stock', byType: true),
            ),
            const Divider(height: 24),
            _buildTypeRow(
              icon: Icons.schedule,
              label: 'Péremption proche',
              count: state.expirySoonAlerts,
              color: Colors.amber,
              onTap: () =>
                  _navigateToFilteredAlerts('expiry_soon', byType: true),
            ),
            const Divider(height: 24),
            _buildTypeRow(
              icon: Icons.dangerous,
              label: 'Périmé',
              count: state.expiredAlerts,
              color: Colors.red.shade900,
              onTap: () => _navigateToFilteredAlerts('expired', byType: true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeRow({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: color),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey.shade400),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentAlertsSection(
      StockAlertsDashboardLoaded state,
      ThemeData theme,
      ) {
    if (state.recentAlerts.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Alertes récentes (24h)',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton.icon(
              onPressed: () {
                context.push('/inventory/alerts/list');
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Voir toutes'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ...state.recentAlerts.take(5).map(
              (alert) => AlertCard(
            alert: alert,
            onTap: () => _navigateToAlertDetail(alert.id),
            onAcknowledge: () => _acknowledgeAlert(alert.id),
          ),
        ),
      ],
    );
  }

  void _navigateToFilteredAlerts(String filter, {bool byType = false}) {
    if (byType) {
      context.push('/inventory/alerts/list?alertType=$filter');
    } else {
      context.push('/inventory/alerts/list?alertLevel=$filter');
    }
  }

  void _navigateToAlertDetail(String alertId) {
    context.push('/inventory/alerts/$alertId');
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

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte acquittée avec succès'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }
}