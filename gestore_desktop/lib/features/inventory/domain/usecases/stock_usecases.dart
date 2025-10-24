// ========================================
// lib/features/inventory/domain/usecases/stock_usecases.dart
// Use cases pour la gestion des stocks
// 🔴 SESSION 4 - MULTI-MAGASINS : Ajout paramètre storeId
// Date modification: 24 Octobre 2025
// ========================================

import '../entities/stock_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET STOCKS ====================

/// 🔴 MULTI-MAGASINS : Récupère les stocks avec filtrage optionnel par magasin
/// - storeId null : Backend filtre automatiquement (employés mono-magasin)
/// - storeId fourni : Backend filtre explicitement sur ce magasin (admins)
class GetStocksUseCase {
  final InventoryRepository repository;

  GetStocksUseCase({required this.repository});

  Future<(List<StockEntity>?, String?)> call({
    String? storeId,  // 🔴 NOUVEAU : Filtrage par magasin
    String? articleId,
    String? locationId,
    DateTime? expiryDate,
  }) {
    return repository.getStocks(
      storeId: storeId,  // 🔴 NOUVEAU
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