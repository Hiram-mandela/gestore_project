// ========================================
// lib/features/inventory/presentation/providers/stock_alerts_state.dart
// États pour la gestion des alertes de stock
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_alert_entity.dart';

abstract class StockAlertsState extends Equatable {
  const StockAlertsState();

  @override
  List<Object?> get props => [];
}

/// État initial
class StockAlertsInitial extends StockAlertsState {
  const StockAlertsInitial();
}

/// Chargement en cours
class StockAlertsLoading extends StockAlertsState {
  const StockAlertsLoading();
}

/// Alertes chargées avec succès
class StockAlertsLoaded extends StockAlertsState {
  final List<StockAlertEntity> alerts;
  final int totalCount;

  const StockAlertsLoaded({
    required this.alerts,
    required this.totalCount,
  });

  @override
  List<Object?> get props => [alerts, totalCount];

  /// Filtre les alertes par niveau
  List<StockAlertEntity> filterByLevel(String level) {
    return alerts.where((alert) => alert.alertLevel.value == level).toList();
  }

  /// Filtre les alertes par type
  List<StockAlertEntity> filterByType(String type) {
    return alerts.where((alert) => alert.alertType.value == type).toList();
  }

  /// Compte les alertes critiques non acquittées
  int get criticalCount {
    return alerts
        .where((a) => a.alertLevel == AlertLevel.critical && !a.isAcknowledged)
        .length;
  }

  /// Compte les alertes d'avertissement non acquittées
  int get warningCount {
    return alerts
        .where((a) => a.alertLevel == AlertLevel.warning && !a.isAcknowledged)
        .length;
  }

  /// Compte les alertes info non acquittées
  int get infoCount {
    return alerts
        .where((a) => a.alertLevel == AlertLevel.info && !a.isAcknowledged)
        .length;
  }

  /// Obtient les alertes non acquittées
  List<StockAlertEntity> get unacknowledgedAlerts {
    return alerts.where((a) => !a.isAcknowledged).toList();
  }
}

/// Dashboard des alertes chargé
class StockAlertsDashboardLoaded extends StockAlertsState {
  final Map<String, dynamic> dashboard;
  final List<StockAlertEntity> recentAlerts;

  const StockAlertsDashboardLoaded({
    required this.dashboard,
    required this.recentAlerts,
  });

  @override
  List<Object?> get props => [dashboard, recentAlerts];

  int get totalAlerts => (dashboard['counts']?['total'] ?? 0) as int;
  int get criticalAlerts => (dashboard['counts']?['critical'] ?? 0) as int;
  int get warningAlerts => (dashboard['counts']?['warning'] ?? 0) as int;
  int get infoAlerts => (dashboard['counts']?['info'] ?? 0) as int;
  int get lowStockAlerts => (dashboard['counts']?['low_stock'] ?? 0) as int;
  int get outOfStockAlerts => (dashboard['counts']?['out_of_stock'] ?? 0) as int;
  int get expirySoonAlerts => (dashboard['counts']?['expiry_soon'] ?? 0) as int;
  int get expiredAlerts => (dashboard['counts']?['expired'] ?? 0) as int;
}

/// Détail d'une alerte chargé
class StockAlertDetailLoaded extends StockAlertsState {
  final StockAlertEntity alert;

  const StockAlertDetailLoaded({required this.alert});

  @override
  List<Object?> get props => [alert];
}

/// Alerte acquittée avec succès
class StockAlertAcknowledged extends StockAlertsState {
  final String message;
  final String alertId;

  const StockAlertAcknowledged({
    required this.message,
    required this.alertId,
  });

  @override
  List<Object?> get props => [message, alertId];
}

/// Alertes acquittées en masse avec succès
class StockAlertsBulkAcknowledged extends StockAlertsState {
  final String message;
  final int count;

  const StockAlertsBulkAcknowledged({
    required this.message,
    required this.count,
  });

  @override
  List<Object?> get props => [message, count];
}

/// Erreur
class StockAlertsError extends StockAlertsState {
  final String message;

  const StockAlertsError({required this.message});

  @override
  List<Object?> get props => [message];
}