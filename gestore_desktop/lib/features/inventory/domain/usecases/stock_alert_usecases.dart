// ========================================
// lib/features/inventory/domain/usecases/stock_alert_usecases.dart
// Use Cases pour la gestion des alertes de stock
// ========================================

import 'package:logger/logger.dart';
import '../entities/stock_alert_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCK ALERTS ====================

class GetStockAlertsParams {
  final String? alertType;
  final String? alertLevel;
  final bool? isAcknowledged;

  const GetStockAlertsParams({
    this.alertType,
    this.alertLevel,
    this.isAcknowledged,
  });
}

class GetStockAlertsUseCase {
  final InventoryRepository repository;
  final Logger logger;

  GetStockAlertsUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(List<StockAlertEntity>?, String?)> call(
      GetStockAlertsParams params,
      ) async {
    logger.d('🎯 UseCase: GetStockAlerts');

    return await repository.getStockAlerts(
      alertType: params.alertType,
      alertLevel: params.alertLevel,
      isAcknowledged: params.isAcknowledged,
    );
  }
}

// ==================== GET STOCK ALERT BY ID ====================

class GetStockAlertByIdUseCase {
  final InventoryRepository repository;
  final Logger logger;

  GetStockAlertByIdUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(StockAlertEntity?, String?)> call(String id) async {
    logger.d('🎯 UseCase: GetStockAlertById - ID: $id');

    if (id.isEmpty) {
      logger.e('❌ UseCase: ID alerte vide');
      return (null, 'ID de l\'alerte requis');
    }

    return await repository.getStockAlertById(id);
  }
}

// ==================== ACKNOWLEDGE ALERT ====================

class AcknowledgeAlertUseCase {
  final InventoryRepository repository;
  final Logger logger;

  AcknowledgeAlertUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(String id) async {
    logger.d('🎯 UseCase: AcknowledgeAlert - ID: $id');

    if (id.isEmpty) {
      logger.e('❌ UseCase: ID alerte vide');
      return (null, 'ID de l\'alerte requis');
    }

    return await repository.acknowledgeAlert(id);
  }
}

// ==================== BULK ACKNOWLEDGE ALERTS ====================

class BulkAcknowledgeAlertsParams {
  final List<String> alertIds;

  const BulkAcknowledgeAlertsParams({
    required this.alertIds,
  });
}

class BulkAcknowledgeAlertsUseCase {
  final InventoryRepository repository;
  final Logger logger;

  BulkAcknowledgeAlertsUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(
      BulkAcknowledgeAlertsParams params,
      ) async {
    logger.d('🎯 UseCase: BulkAcknowledgeAlerts - ${params.alertIds.length} alertes');

    if (params.alertIds.isEmpty) {
      logger.e('❌ UseCase: Liste d\'alertes vide');
      return (null, 'Au moins une alerte doit être sélectionnée');
    }

    return await repository.bulkAcknowledgeAlerts(params.alertIds);
  }
}

// ==================== GET ALERTS DASHBOARD ====================

class GetAlertsDashboardUseCase {
  final InventoryRepository repository;
  final Logger logger;

  GetAlertsDashboardUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call() async {
    logger.d('🎯 UseCase: GetAlertsDashboard');

    return await repository.getAlertsDashboard();
  }
}