// ========================================
// lib/features/authentication/data/models/store_info_model.dart
// Model pour les informations de magasin dans le contexte d'authentification
// Modèle léger indépendant du module Inventory (respect Clean Architecture)
// Date: 23 Octobre 2025
// ========================================

import '../../domain/entities/store_info_entity.dart';

/// Model représentant les informations minimales d'un magasin
/// Ce modèle est volontairement séparé de LocationModel (module Inventory)
/// pour respecter l'indépendance des modules (Clean Architecture)
class StoreInfoModel extends StoreInfoEntity {
  const StoreInfoModel({
    required super.id,
    required super.name,
    required super.code,
    required super.isActive,
    super.description,
  });

  /// Convertit le JSON de l'API en Model
  /// Format attendu du backend:
  /// {
  ///   "id": "uuid",
  ///   "name": "Magasin de Lyon",
  ///   "code": "LYO001",
  ///   "is_active": true,
  ///   "description": "Magasin principal de Lyon"
  /// }
  factory StoreInfoModel.fromJson(Map<String, dynamic> json) {
    return StoreInfoModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      isActive: json['is_active'] as bool? ?? true,
      description: json['description'] as String?,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'is_active': isActive,
      if (description != null) 'description': description,
    };
  }

  /// Convertit le Model en Entity
  StoreInfoEntity toEntity() {
    return StoreInfoEntity(
      id: id,
      name: name,
      code: code,
      isActive: isActive,
      description: description,
    );
  }

  /// Crée un Model depuis une Entity
  factory StoreInfoModel.fromEntity(StoreInfoEntity entity) {
    return StoreInfoModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      isActive: entity.isActive,
      description: entity.description,
    );
  }

  /// Crée une copie avec des champs modifiés
  @override
  StoreInfoModel copyWith({
    String? id,
    String? name,
    String? code,
    bool? isActive,
    String? description,
  }) {
    return StoreInfoModel(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }

  @override
  String toString() => 'StoreInfoModel(id: $id, name: $name, code: $code, isActive: $isActive)';
}