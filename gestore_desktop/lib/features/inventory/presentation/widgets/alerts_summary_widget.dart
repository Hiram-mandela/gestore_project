// ========================================
// lib/features/inventory/presentation/widgets/alerts_summary_widget.dart
// Widget résumé des alertes pour le dashboard principal
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stock_alerts_provider.dart';
import '../providers/stock_alerts_state.dart';
import 'alert_level_indicator.dart';
import '../../domain/entities/stock_alert_entity.dart';

class AlertsSummaryWidget extends ConsumerStatefulWidget {
  const AlertsSummaryWidget({super.key});

  @override
  ConsumerState<AlertsSummaryWidget> createState() =>
      _AlertsSummaryWidgetState();
}

class _AlertsSummaryWidgetState extends ConsumerState<AlertsSummaryWidget> {
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

    return Card(
      elevation: 3,
      child: InkWell(
        onTap: () {
          context.push('/inventory/alerts/dashboard');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.notifications_active,
                    color: theme.primaryColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Alertes de stock',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.grey.shade400,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildContent(state, theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent(StockAlertsState state, ThemeData theme) {
    if (state is StockAlertsLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (state is StockAlertsError) {
      return Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade300),
          const SizedBox(height: 8),
          Text(
            'Erreur de chargement',
            style: TextStyle(color: Colors.red.shade700),
          ),
        ],
      );
    }

    if (state is StockAlertsDashboardLoaded) {
      final totalAlerts = state.totalAlerts;

      if (totalAlerts == 0) {
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.green.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Aucune alerte active\nTout est sous contrôle !',
                  style: TextStyle(
                    color: Colors.green.shade900,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Indicateurs par niveau
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: AlertLevelIndicator(
                  level: AlertLevel.critical,
                  count: state.criticalAlerts,
                  isCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AlertLevelIndicator(
                  level: AlertLevel.warning,
                  count: state.warningAlerts,
                  isCompact: false,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AlertLevelIndicator(
                  level: AlertLevel.info,
                  count: state.infoAlerts,
                  isCompact: false,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Résumé par type
          _buildTypeSummary(
            icon: Icons.trending_down,
            label: 'Stock bas',
            count: state.lowStockAlerts,
            color: Colors.orange,
          ),
          const SizedBox(height: 8),
          _buildTypeSummary(
            icon: Icons.remove_shopping_cart,
            label: 'Rupture',
            count: state.outOfStockAlerts,
            color: Colors.red,
          ),
          const SizedBox(height: 8),
          _buildTypeSummary(
            icon: Icons.dangerous,
            label: 'Périmé',
            count: state.expiredAlerts,
            color: Colors.red.shade900,
          ),

          const SizedBox(height: 16),

          // Bouton d'action
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.push('/inventory/alerts/list');
              },
              icon: const Icon(Icons.list),
              label: const Text('Voir toutes les alertes'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildTypeSummary({
    required IconData icon,
    required String label,
    required int count,
    required Color color,
  }) {
    if (count == 0) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              count.toString(),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}