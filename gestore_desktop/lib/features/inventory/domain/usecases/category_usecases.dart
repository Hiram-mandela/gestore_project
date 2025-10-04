// ========================================
// lib/features/inventory/domain/usecases/category_usecases.dart
// Use Cases pour le CRUD des catégories
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== CREATE CATEGORY ====================

/// Paramètres pour créer une catégorie
class CreateCategoryParams {
  final String name;
  final String code;
  final String description;
  final String? parentId;
  final double taxRate;
  final String color;
  final bool requiresPrescription;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final int defaultMinStock;
  final int order;
  final bool isActive;

  const CreateCategoryParams({
    required this.name,
    required this.code,
    this.description = '',
    this.parentId,
    this.taxRate = 0.0,
    this.color = '#007bff',
    this.requiresPrescription = false,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.defaultMinStock = 5,
    this.order = 0,
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
    if (code.trim().isEmpty) {
      return 'Le code est requis';
    }
    if (code.trim().length < 2) {
      return 'Le code doit contenir au moins 2 caractères';
    }
    if (taxRate < 0 || taxRate > 100) {
      return 'Le taux de TVA doit être entre 0 et 100';
    }
    if (defaultMinStock < 0) {
      return 'Le stock minimum doit être positif';
    }
    return null;
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'description': description.trim(),
      if (parentId != null && parentId!.isNotEmpty) 'parent': parentId,
      'tax_rate': taxRate.toString(),
      'color': color,
      'requires_prescription': requiresPrescription,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'default_min_stock': defaultMinStock,
      'order': order,
      'is_active': isActive,
    };
  }
}

/// Use Case pour créer une catégorie
@lazySingleton
class CreateCategoryUseCase implements UseCase<CategoryEntity, CreateCategoryParams> {
  final InventoryRepository repository;

  CreateCategoryUseCase({required this.repository});

  @override
  Future<(CategoryEntity?, String?)> call(CreateCategoryParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.createCategory(params.toJson());
  }
}

// ==================== UPDATE CATEGORY ====================

/// Paramètres pour mettre à jour une catégorie
class UpdateCategoryParams {
  final String id;
  final String name;
  final String code;
  final String description;
  final String? parentId;
  final double taxRate;
  final String color;
  final bool requiresPrescription;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final int defaultMinStock;
  final int order;
  final bool isActive;

  const UpdateCategoryParams({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.parentId,
    this.taxRate = 0.0,
    this.color = '#007bff',
    this.requiresPrescription = false,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.defaultMinStock = 5,
    this.order = 0,
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
    if (code.trim().isEmpty) {
      return 'Le code est requis';
    }
    if (code.trim().length < 2) {
      return 'Le code doit contenir au moins 2 caractères';
    }
    if (taxRate < 0 || taxRate > 100) {
      return 'Le taux de TVA doit être entre 0 et 100';
    }
    if (defaultMinStock < 0) {
      return 'Le stock minimum doit être positif';
    }
    // Vérifier qu'on ne se met pas soi-même comme parent
    if (parentId != null && parentId == id) {
      return 'Une catégorie ne peut pas être son propre parent';
    }
    return null;
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'description': description.trim(),
      if (parentId != null && parentId!.isNotEmpty) 'parent': parentId,
      'tax_rate': taxRate.toString(),
      'color': color,
      'requires_prescription': requiresPrescription,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'default_min_stock': defaultMinStock,
      'order': order,
      'is_active': isActive,
    };
  }
}

/// Use Case pour mettre à jour une catégorie
@lazySingleton
class UpdateCategoryUseCase implements UseCase<CategoryEntity, UpdateCategoryParams> {
  final InventoryRepository repository;

  UpdateCategoryUseCase({required this.repository});

  @override
  Future<(CategoryEntity?, String?)> call(UpdateCategoryParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.updateCategory(params.id, params.toJson());
  }
}

// ==================== DELETE CATEGORY ====================

/// Paramètres pour supprimer une catégorie
class DeleteCategoryParams {
  final String categoryId;

  const DeleteCategoryParams({required this.categoryId});
}

/// Use Case pour supprimer une catégorie
@lazySingleton
class DeleteCategoryUseCase implements UseCase<void, DeleteCategoryParams> {
  final InventoryRepository repository;

  DeleteCategoryUseCase({required this.repository});

  @override
  Future<(void, String?)> call(DeleteCategoryParams params) async {
    if (params.categoryId.trim().isEmpty) {
      return (null, 'ID de la catégorie requis');
    }

    return await repository.deleteCategory(params.categoryId);
  }
}

// ==================== GET CATEGORY BY ID ====================

/// Paramètres pour récupérer une catégorie par ID
class GetCategoryByIdParams {
  final String categoryId;

  const GetCategoryByIdParams({required this.categoryId});
}

/// Use Case pour récupérer une catégorie par ID
@lazySingleton
class GetCategoryByIdUseCase implements UseCase<CategoryEntity, GetCategoryByIdParams> {
  final InventoryRepository repository;

  GetCategoryByIdUseCase({required this.repository});

  @override
  Future<(CategoryEntity?, String?)> call(GetCategoryByIdParams params) async {
    if (params.categoryId.trim().isEmpty) {
      return (null, 'ID de la catégorie requis');
    }

    return await repository.getCategoryById(params.categoryId);
  }
}