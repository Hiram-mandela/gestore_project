// ========================================
// lib/features/inventory/domain/usecases/unit_usecases.dart
// Use Cases pour le CRUD des unités de mesure
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/unit_of_measure_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== CREATE UNIT ====================

/// Paramètres pour créer une unité de mesure
class CreateUnitParams {
  final String name;
  final String symbol;
  final String description;
  final bool isDecimal;
  final bool isActive;

  const CreateUnitParams({
    required this.name,
    required this.symbol,
    this.description = '',
    this.isDecimal = false,
    this.isActive = true,
  });

  /// Validation
  String? validate() {
    if (name.trim().isEmpty) {
      return 'Le nom est requis';
    }
    if (name.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (symbol.trim().isEmpty) {
      return 'Le symbole est requis';
    }
    if (symbol.trim().length > 10) {
      return 'Le symbole ne peut dépasser 10 caractères';
    }
    return null;
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'symbol': symbol.trim(),
      'description': description.trim(),
      'is_decimal': isDecimal,
      'is_active': isActive,
    };
  }
}

/// Use Case pour créer une unité de mesure
@lazySingleton
class CreateUnitUseCase implements UseCase<UnitOfMeasureEntity, CreateUnitParams> {
  final InventoryRepository repository;

  CreateUnitUseCase({required this.repository});

  @override
  Future<(UnitOfMeasureEntity?, String?)> call(CreateUnitParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.createUnit(params.toJson());
  }
}

// ==================== UPDATE UNIT ====================

/// Paramètres pour mettre à jour une unité de mesure
class UpdateUnitParams {
  final String id;
  final String name;
  final String symbol;
  final String description;
  final bool isDecimal;
  final bool isActive;

  const UpdateUnitParams({
    required this.id,
    required this.name,
    required this.symbol,
    this.description = '',
    this.isDecimal = false,
    this.isActive = true,
  });

  /// Validation
  String? validate() {
    if (id.trim().isEmpty) {
      return 'ID requis';
    }
    if (name.trim().isEmpty) {
      return 'Le nom est requis';
    }
    if (name.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (symbol.trim().isEmpty) {
      return 'Le symbole est requis';
    }
    if (symbol.trim().length > 10) {
      return 'Le symbole ne peut dépasser 10 caractères';
    }
    return null;
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'symbol': symbol.trim(),
      'description': description.trim(),
      'is_decimal': isDecimal,
      'is_active': isActive,
    };
  }
}

/// Use Case pour mettre à jour une unité de mesure
@lazySingleton
class UpdateUnitUseCase implements UseCase<UnitOfMeasureEntity, UpdateUnitParams> {
  final InventoryRepository repository;

  UpdateUnitUseCase({required this.repository});

  @override
  Future<(UnitOfMeasureEntity?, String?)> call(UpdateUnitParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.updateUnit(params.id, params.toJson());
  }
}

// ==================== DELETE UNIT ====================

/// Paramètres pour supprimer une unité de mesure
class DeleteUnitParams {
  final String unitId;

  const DeleteUnitParams({required this.unitId});
}

/// Use Case pour supprimer une unité de mesure
@lazySingleton
class DeleteUnitUseCase implements UseCase<void, DeleteUnitParams> {
  final InventoryRepository repository;

  DeleteUnitUseCase({required this.repository});

  @override
  Future<(void, String?)> call(DeleteUnitParams params) async {
    if (params.unitId.trim().isEmpty) {
      return (null, 'ID de l\'unité requis');
    }

    return await repository.deleteUnit(params.unitId);
  }
}

// ==================== GET UNITS (LISTE) ====================

/// Paramètres pour récupérer les unités
class GetUnitsParams {
  final bool? isActive;

  const GetUnitsParams({this.isActive});
}

/// Use Case pour récupérer toutes les unités de mesure
@lazySingleton
class GetUnitsUseCase implements UseCase<List<UnitOfMeasureEntity>, GetUnitsParams> {
  final InventoryRepository repository;

  GetUnitsUseCase({required this.repository});

  @override
  Future<(List<UnitOfMeasureEntity>?, String?)> call(GetUnitsParams params) async {
    return await repository.getUnitsOfMeasure(isActive: params.isActive);
  }
}

// ==================== GET UNIT BY ID ====================

/// Paramètres pour récupérer une unité par ID
class GetUnitByIdParams {
  final String unitId;

  const GetUnitByIdParams({required this.unitId});
}

/// Use Case pour récupérer une unité de mesure par ID
@lazySingleton
class GetUnitByIdUseCase implements UseCase<UnitOfMeasureEntity, GetUnitByIdParams> {
  final InventoryRepository repository;

  GetUnitByIdUseCase({required this.repository});

  @override
  Future<(UnitOfMeasureEntity?, String?)> call(GetUnitByIdParams params) async {
    if (params.unitId.trim().isEmpty) {
      return (null, 'ID de l\'unité requis');
    }

    return await repository.getUnitById(params.unitId);
  }
}