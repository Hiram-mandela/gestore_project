// ========================================
// lib/features/inventory/domain/usecases/brand_usecases.dart
// Use Cases pour le CRUD des marques
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/brand_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== CREATE BRAND ====================

/// Paramètres pour créer une marque
class CreateBrandParams {
  final String name;
  final String description;
  final String? logoPath;
  final String website;
  final bool isActive;

  const CreateBrandParams({
    required this.name,
    this.description = '',
    this.logoPath,
    this.website = '',
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
    if (website.isNotEmpty && !_isValidUrl(website)) {
      return 'URL du site web invalide';
    }
    return null;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      if (website.isNotEmpty) 'website': website.trim(),
      'is_active': isActive,
    };
  }
}

/// Use Case pour créer une marque
@lazySingleton
class CreateBrandUseCase implements UseCase<BrandEntity, CreateBrandParams> {
  final InventoryRepository repository;

  CreateBrandUseCase({required this.repository});

  @override
  Future<(BrandEntity?, String?)> call(CreateBrandParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.createBrand(params.toJson(), params.logoPath);
  }
}

// ==================== UPDATE BRAND ====================

/// Paramètres pour mettre à jour une marque
class UpdateBrandParams {
  final String id;
  final String name;
  final String description;
  final String? logoPath;
  final String website;
  final bool isActive;

  const UpdateBrandParams({
    required this.id,
    required this.name,
    this.description = '',
    this.logoPath,
    this.website = '',
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
    if (website.isNotEmpty && !_isValidUrl(website)) {
      return 'URL du site web invalide';
    }
    return null;
  }

  bool _isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (e) {
      return false;
    }
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'description': description.trim(),
      if (website.isNotEmpty) 'website': website.trim(),
      'is_active': isActive,
    };
  }
}

/// Use Case pour mettre à jour une marque
@lazySingleton
class UpdateBrandUseCase implements UseCase<BrandEntity, UpdateBrandParams> {
  final InventoryRepository repository;

  UpdateBrandUseCase({required this.repository});

  @override
  Future<(BrandEntity?, String?)> call(UpdateBrandParams params) async {
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository
    return await repository.updateBrand(params.id, params.toJson(), params.logoPath);
  }
}

// ==================== DELETE BRAND ====================

/// Paramètres pour supprimer une marque
class DeleteBrandParams {
  final String brandId;

  const DeleteBrandParams({required this.brandId});
}

/// Use Case pour supprimer une marque
@lazySingleton
class DeleteBrandUseCase implements UseCase<void, DeleteBrandParams> {
  final InventoryRepository repository;

  DeleteBrandUseCase({required this.repository});

  @override
  Future<(void, String?)> call(DeleteBrandParams params) async {
    if (params.brandId.trim().isEmpty) {
      return (null, 'ID de la marque requis');
    }

    return await repository.deleteBrand(params.brandId);
  }
}

// ==================== GET BRAND BY ID ====================

/// Paramètres pour récupérer une marque par ID
class GetBrandByIdParams {
  final String brandId;

  const GetBrandByIdParams({required this.brandId});
}

/// Use Case pour récupérer une marque par ID
@lazySingleton
class GetBrandByIdUseCase implements UseCase<BrandEntity, GetBrandByIdParams> {
  final InventoryRepository repository;

  GetBrandByIdUseCase({required this.repository});

  @override
  Future<(BrandEntity?, String?)> call(GetBrandByIdParams params) async {
    if (params.brandId.trim().isEmpty) {
      return (null, 'ID de la marque requis');
    }

    return await repository.getBrandById(params.brandId);
  }
}