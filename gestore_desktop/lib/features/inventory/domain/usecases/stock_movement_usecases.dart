// ========================================
// lib/features/inventory/domain/usecases/stock_movement_usecases.dart
// Use Cases pour les mouvements de stock
// 🔴 SESSION 4 - MULTI-MAGASINS : Ajout paramètre storeId
// Date modification: 24 Octobre 2025
// ========================================

import 'package:injectable/injectable.dart';
import '../entities/stock_movement_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCK MOVEMENTS ====================

/// 🔴 MULTI-MAGASINS : Récupère les mouvements de stock avec filtrage optionnel par magasin
/// - storeId null : Backend filtre automatiquement (employés)
/// - storeId fourni : Backend filtre sur magasin spécifique (admins)
@injectable
class GetStockMovementsUseCase {
  final InventoryRepository repository;

  GetStockMovementsUseCase(this.repository);

  Future<(PaginatedResponseEntity<StockMovementEntity>?, String?)> call({
    String? storeId,  // 🔴 NOUVEAU : Filtrage par magasin
    int page = 1,
    int pageSize = 20,
    String? movementType,
    String? reason,
    String? articleId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
    String? search,
    String? ordering,
  }) async {
    return await repository.getStockMovements(
      storeId: storeId,  // 🔴 NOUVEAU
      page: page,
      pageSize: pageSize,
      movementType: movementType,
      reason: reason,
      articleId: articleId,
      locationId: locationId,
      dateFrom: dateFrom,
      dateTo: dateTo,
      search: search,
      ordering: ordering,
    );
  }
}

// ==================== GET STOCK MOVEMENT BY ID ====================

@injectable
class GetStockMovementByIdUseCase {
  final InventoryRepository repository;

  GetStockMovementByIdUseCase(this.repository);

  Future<(StockMovementEntity?, String?)> call(String id) async {
    return await repository.getStockMovementById(id);
  }
}

// ==================== GET MOVEMENTS SUMMARY ====================

@injectable
class GetMovementsSummaryUseCase {
  final InventoryRepository repository;

  GetMovementsSummaryUseCase(this.repository);

  Future<(MovementsSummary?, String?)> call({
    String? dateFrom,
    String? dateTo,
  }) async {
    return await repository.getMovementsSummary(
      dateFrom: dateFrom,
      dateTo: dateTo,
    );
  }
}

// ==================== CLASSES DE SUPPORT ====================

/// Résumé des mouvements de stock
class MovementsSummary {
  final int totalMovements;
  final int totalIn;
  final int totalOut;
  final int totalAdjustments;
  final List<DailySummary> dailySummary;

  MovementsSummary({
    required this.totalMovements,
    required this.totalIn,
    required this.totalOut,
    required this.totalAdjustments,
    required this.dailySummary,
  });

  /// Parse depuis le JSON de l'API
  factory MovementsSummary.fromJson(Map<String, dynamic> json) {
    final summary = json['summary'] as Map<String, dynamic>;
    final daily = json['daily_summary'] as List<dynamic>;

    return MovementsSummary(
      totalMovements: summary['total_movements'] as int? ?? 0,
      totalIn: summary['total_in'] as int? ?? 0,
      totalOut: summary['total_out'] as int? ?? 0,
      totalAdjustments: summary['total_adjustments'] as int? ?? 0,
      dailySummary: daily
          .map((item) => DailySummary.fromJson(item as Map<String, dynamic>))
          .toList(),
    );
  }
}

/// Résumé quotidien des mouvements
class DailySummary {
  final String date;
  final int totalMovements;
  final int totalIn;
  final int totalOut;

  DailySummary({
    required this.date,
    required this.totalMovements,
    required this.totalIn,
    required this.totalOut,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      date: json['date'] as String,
      totalMovements: json['total_movements'] as int? ?? 0,
      totalIn: json['in'] as int? ?? 0,
      totalOut: json['out'] as int? ?? 0,
    );
  }
}