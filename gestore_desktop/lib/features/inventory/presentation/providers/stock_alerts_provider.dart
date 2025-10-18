// ========================================
// lib/features/inventory/presentation/providers/stock_alerts_provider.dart
// Provider pour la gestion des alertes de stock
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/stock_alert_usecases.dart';
import 'stock_alerts_state.dart';

/// Provider pour l'état des alertes
final stockAlertsProvider =
StateNotifierProvider<StockAlertsNotifier, StockAlertsState>((ref) {
  return StockAlertsNotifier(
    getStockAlertsUseCase: getIt<GetStockAlertsUseCase>(),
    getStockAlertByIdUseCase: getIt<GetStockAlertByIdUseCase>(),
    acknowledgeAlertUseCase: getIt<AcknowledgeAlertUseCase>(),
    bulkAcknowledgeAlertsUseCase: getIt<BulkAcknowledgeAlertsUseCase>(),
    getAlertsDashboardUseCase: getIt<GetAlertsDashboardUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état des alertes
class StockAlertsNotifier extends StateNotifier<StockAlertsState> {
  final GetStockAlertsUseCase getStockAlertsUseCase;
  final GetStockAlertByIdUseCase getStockAlertByIdUseCase;
  final AcknowledgeAlertUseCase acknowledgeAlertUseCase;
  final BulkAcknowledgeAlertsUseCase bulkAcknowledgeAlertsUseCase;
  final GetAlertsDashboardUseCase getAlertsDashboardUseCase;
  final Logger logger;

  StockAlertsNotifier({
    required this.getStockAlertsUseCase,
    required this.getStockAlertByIdUseCase,
    required this.acknowledgeAlertUseCase,
    required this.bulkAcknowledgeAlertsUseCase,
    required this.getAlertsDashboardUseCase,
    required this.logger,
  }) : super(const StockAlertsInitial());

  /// Charge toutes les alertes avec filtres optionnels
  Future<void> loadAlerts({
    String? alertType,
    String? alertLevel,
    bool? isAcknowledged,
  }) async {
    logger.d('🔄 Chargement des alertes...');
    state = const StockAlertsLoading();

    final params = GetStockAlertsParams(
      alertType: alertType,
      alertLevel: alertLevel,
      isAcknowledged: isAcknowledged,
    );

    final (alerts, error) = await getStockAlertsUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur chargement alertes: $error');
      state = StockAlertsError(message: error);
      return;
    }

    if (alerts != null) {
      logger.i('✅ ${alerts.length} alertes chargées');
      state = StockAlertsLoaded(
        alerts: alerts,
        totalCount: alerts.length,
      );
    }
  }

  /// Charge le détail d'une alerte
  Future<void> loadAlertDetail(String id) async {
    logger.d('🔄 Chargement détail alerte $id...');
    state = const StockAlertsLoading();

    final (alert, error) = await getStockAlertByIdUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur chargement alerte: $error');
      state = StockAlertsError(message: error);
      return;
    }

    if (alert != null) {
      logger.i('✅ Alerte chargée');
      state = StockAlertDetailLoaded(alert: alert);
    }
  }

  /// Acquitte une alerte
  Future<void> acknowledgeAlert(String id) async {
    logger.d('🔄 Acquittement alerte $id...');

    final currentState = state;
    state = const StockAlertsLoading();

    final (result, error) = await acknowledgeAlertUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur acquittement: $error');
      state = StockAlertsError(message: error);
      return;
    }

    if (result != null) {
      logger.i('✅ Alerte acquittée');
      state = StockAlertAcknowledged(
        message: result['message'] ?? 'Alerte acquittée avec succès',
        alertId: id,
      );

      // Recharger les alertes après acquittement
      if (currentState is StockAlertsLoaded) {
        await loadAlerts(isAcknowledged: false);
      }
    }
  }

  /// Acquitte plusieurs alertes en masse
  Future<void> bulkAcknowledgeAlerts(List<String> alertIds) async {
    logger.d('🔄 Acquittement masse ${alertIds.length} alertes...');

    final currentState = state;
    state = const StockAlertsLoading();

    final params = BulkAcknowledgeAlertsParams(alertIds: alertIds);
    final (result, error) = await bulkAcknowledgeAlertsUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur acquittement masse: $error');
      state = StockAlertsError(message: error);
      return;
    }

    if (result != null) {
      final count = result['updated_count'] ?? alertIds.length;
      logger.i('✅ $count alertes acquittées');
      state = StockAlertsBulkAcknowledged(
        message: result['message'] ?? '$count alertes acquittées',
        count: count,
      );

      // Recharger les alertes après acquittement
      if (currentState is StockAlertsLoaded) {
        await loadAlerts(isAcknowledged: false);
      }
    }
  }

  /// Charge le dashboard des alertes
  Future<void> loadDashboard() async {
    logger.d('🔄 Chargement dashboard alertes...');
    state = const StockAlertsLoading();

    final (dashboard, error) = await getAlertsDashboardUseCase();

    if (error != null) {
      logger.e('❌ Erreur chargement dashboard: $error');
      state = StockAlertsError(message: error);
      return;
    }

    if (dashboard != null) {
      logger.i('✅ Dashboard chargé');

      // Extraire les alertes récentes du dashboard
      final recentAlertsJson = dashboard['recent_alerts'] as List? ?? [];
      final recentAlerts = recentAlertsJson
          .map((json) => getIt<GetStockAlertByIdUseCase>())
          .toList();

      state = StockAlertsDashboardLoaded(
        dashboard: dashboard,
        recentAlerts: [],
      );
    }
  }

  /// Filtre les alertes critiques non acquittées
  Future<void> loadCriticalAlerts() async {
    await loadAlerts(
      alertLevel: 'critical',
      isAcknowledged: false,
    );
  }

  /// Filtre les alertes par type
  Future<void> loadAlertsByType(String type) async {
    await loadAlerts(
      alertType: type,
      isAcknowledged: false,
    );
  }

  /// Réinitialise l'état
  void reset() {
    logger.d('🔄 Réinitialisation état alertes');
    state = const StockAlertsInitial();
  }
}