// ========================================
// lib/features/inventory/domain/usecases/stock_usecases.dart
// Use cases pour la gestion des stocks
// ========================================

import '../entities/stock_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCKS ====================

class GetStocksUseCase {
  final InventoryRepository repository;

  GetStocksUseCase({required this.repository});

  Future<(List<StockEntity>?, String?)> call({
    String? articleId,
    String? locationId,
    DateTime? expiryDate,
  }) {
    return repository.getStocks(
      articleId: articleId,
      locationId: locationId,
      expiryDate: expiryDate,
    );
  }
}

// ==================== GET STOCK BY ID ====================

class GetStockByIdUseCase {
  final InventoryRepository repository;

  GetStockByIdUseCase({required this.repository});

  Future<(StockEntity?, String?)> call(String id) {
    return repository.getStockById(id);
  }
}

// ==================== ADJUST STOCK ====================

class AdjustStockUseCase {
  final InventoryRepository repository;

  AdjustStockUseCase({required this.repository});

  Future<(Map<String, dynamic>?, String?)> call({
    required String articleId,
    required String locationId,
    required double newQuantity,
    required String reason,
    String? referenceDocument,
    String? notes,
  }) {
    return repository.adjustStock(
      articleId: articleId,
      locationId: locationId,
      newQuantity: newQuantity,
      reason: reason,
      referenceDocument: referenceDocument,
      notes: notes,
    );
  }
}

// ==================== TRANSFER STOCK ====================

class TransferStockUseCase {
  final InventoryRepository repository;

  TransferStockUseCase({required this.repository});

  Future<(Map<String, dynamic>?, String?)> call({
    required String articleId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? referenceDocument,
    String? notes,
  }) {
    return repository.transferStock(
      articleId: articleId,
      fromLocationId: fromLocationId,
      toLocationId: toLocationId,
      quantity: quantity,
      referenceDocument: referenceDocument,
      notes: notes,
    );
  }
}

// ==================== GET STOCK VALUATION ====================

class GetStockValuationUseCase {
  final InventoryRepository repository;

  GetStockValuationUseCase({required this.repository});

  Future<(Map<String, dynamic>?, String?)> call() {
    return repository.getStockValuation();
  }
}