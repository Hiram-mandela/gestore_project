// ========================================
// lib/features/inventory/presentation/widgets/alert_badge.dart
// Widget badge de notification pour les alertes (AppBar)
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/stock_alerts_provider.dart';
import '../providers/stock_alerts_state.dart';

class AlertBadge extends ConsumerStatefulWidget {
  const AlertBadge({super.key});

  @override
  ConsumerState<AlertBadge> createState() => _AlertBadgeState();
}

class _AlertBadgeState extends ConsumerState<AlertBadge> {
  @override
  void initState() {
    super.initState();
    // Charger le dashboard au démarrage
    Future.microtask(
          () => ref.read(stockAlertsProvider.notifier).loadDashboard(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockAlertsProvider);

    if (state is StockAlertsDashboardLoaded) {
      final criticalCount = state.criticalAlerts;
      final warningCount = state.warningAlerts;
      final totalCount = state.totalAlerts;

      // N'afficher que s'il y a des alertes
      if (totalCount == 0) {
        return IconButton(
          icon: const Icon(Icons.notifications_none),
          tooltip: 'Aucune alerte',
          onPressed: () {
            context.push('/inventory/alerts/dashboard');
          },
        );
      }

      // Couleur selon le niveau le plus élevé
      Color badgeColor = Colors.blue;
      if (criticalCount > 0) {
        badgeColor = Colors.red;
      } else if (warningCount > 0) {
        badgeColor = Colors.orange;
      }

      return Stack(
        children: [
          IconButton(
            icon: Icon(
              criticalCount > 0
                  ? Icons.notifications_active
                  : Icons.notifications,
              color: criticalCount > 0 ? badgeColor : null,
            ),
            tooltip: '$totalCount alerte(s)',
            onPressed: () {
              context.push('/inventory/alerts/dashboard');
            },
          ),
          if (totalCount > 0)
            Positioned(
              right: 8,
              top: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.white, width: 2),
                ),
                constraints: const BoxConstraints(
                  minWidth: 20,
                  minHeight: 20,
                ),
                child: Text(
                  totalCount > 99 ? '99+' : totalCount.toString(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
        ],
      );
    }

    // État de chargement ou erreur : afficher icône simple
    return IconButton(
      icon: const Icon(Icons.notifications_none),
      tooltip: 'Alertes',
      onPressed: () {
        context.push('/inventory/alerts/dashboard');
      },
    );
  }
}