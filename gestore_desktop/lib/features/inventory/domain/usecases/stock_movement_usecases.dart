// ========================================
// lib/features/inventory/domain/usecases/stock_movement_usecases.dart
// Use Cases pour les mouvements de stock
// ========================================

import 'package:injectable/injectable.dart';
import '../entities/stock_movement_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCK MOVEMENTS ====================

@injectable
class GetStockMovementsUseCase {
  final InventoryRepository repository;

  GetStockMovementsUseCase(this.repository);

  Future<(PaginatedResponseEntity<StockMovementEntity>?, String?)> call({
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

  /// Calcule le net (entrées - sorties)
  int get netMovement => totalIn - totalOut;

  /// Vérifie s'il y a des mouvements
  bool get hasMovements => totalMovements > 0;
}

/// Résumé quotidien des mouvements
class DailySummary {
  final String day;
  final int movementsCount;
  final int inCount;
  final int outCount;

  DailySummary({
    required this.day,
    required this.movementsCount,
    required this.inCount,
    required this.outCount,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      day: json['day'] as String,
      movementsCount: json['movements_count'] as int? ?? 0,
      inCount: json['in_count'] as int? ?? 0,
      outCount: json['out_count'] as int? ?? 0,
    );
  }

  /// Calcule le net du jour
  int get netMovement => inCount - outCount;

  /// Parse la date
  DateTime get date => DateTime.parse(day);

  /// Format de la date
  String get formattedDate {
    final dt = date;
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}