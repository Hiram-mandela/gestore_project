// ========================================
// lib/features/inventory/domain/usecases/location_usecases.dart
// Use cases pour la gestion des emplacements
// ========================================

import '../entities/location_entity.dart';
import '../entities/stock_entity.dart'; // Phase 4
import '../repositories/inventory_repository.dart';

// ==================== GET LOCATIONS ====================

class GetLocationsUseCase {
  final InventoryRepository repository;

  GetLocationsUseCase({required this.repository});

  Future<(List<LocationEntity>?, String?)> call({
    bool? isActive,
    String? locationType,
    String? parentId,
  }) {
    return repository.getLocations(
      isActive: isActive,
      locationType: locationType,
      parentId: parentId,
    );
  }
}

// ==================== GET LOCATION BY ID ====================

class GetLocationByIdUseCase {
  final InventoryRepository repository;

  GetLocationByIdUseCase({required this.repository});

  Future<(LocationEntity?, String?)> call(String id) {
    return repository.getLocationById(id);
  }
}

// ==================== CREATE LOCATION ====================

class CreateLocationUseCase {
  final InventoryRepository repository;

  CreateLocationUseCase({required this.repository});

  Future<(LocationEntity?, String?)> call(Map<String, dynamic> data) {
    return repository.createLocation(data);
  }
}

// ==================== UPDATE LOCATION ====================

class UpdateLocationUseCase {
  final InventoryRepository repository;

  UpdateLocationUseCase({required this.repository});

  Future<(LocationEntity?, String?)> call(String id, Map<String, dynamic> data) {
    return repository.updateLocation(id, data);
  }
}

// ==================== DELETE LOCATION ====================

class DeleteLocationUseCase {
  final InventoryRepository repository;

  DeleteLocationUseCase({required this.repository});

  Future<(void, String?)> call(String id) {
    return repository.deleteLocation(id);
  }
}

// ==================== GET LOCATION STOCKS ====================

class GetLocationStocksUseCase {
  final InventoryRepository repository;

  GetLocationStocksUseCase({required this.repository});

  Future<(List<StockEntity>?, String?)> call(String locationId) {
    return repository.getLocationStocks(locationId);
  }
}