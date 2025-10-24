// ========================================
// lib/features/inventory/domain/usecases/stock_alert_usecases.dart
// Use Cases pour la gestion des alertes de stock
// 🔴 SESSION 4 - MULTI-MAGASINS : Ajout storeId dans GetStockAlertsParams
// Date modification: 24 Octobre 2025
// ========================================

import 'package:logger/logger.dart';
import '../entities/stock_alert_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCK ALERTS ====================

/// 🔴 MULTI-MAGASINS : Paramètres pour la récupération des alertes de stock
/// - storeId null : Backend filtre automatiquement (employés)
/// - storeId fourni : Backend filtre sur magasin spécifique (admins)
class GetStockAlertsParams {
  final String? storeId;  // 🔴 NOUVEAU : Filtrage par magasin
  final String? alertType;
  final String? alertLevel;
  final bool? isAcknowledged;

  const GetStockAlertsParams({
    this.storeId,  // 🔴 NOUVEAU
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
    logger.d('🎯 UseCase: GetStockAlerts${params.storeId != null ? " - Store: ${params.storeId}" : ""}');

    return await repository.getStockAlerts(
      storeId: params.storeId,  // 🔴 NOUVEAU
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
      return (null, 'Au moins une alerte doit être fournie');
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