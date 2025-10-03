// ========================================
// lib/features/inventory/data/models/brand_model.dart
// Model pour le mapping JSON <-> Entity Brand
// ========================================

import '../../domain/entities/brand_entity.dart';

/// Model pour le mapping des marques depuis/vers l'API
class BrandModel {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? website;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  BrandModel({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.website,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory BrandModel.fromJson(Map<String, dynamic> json) {
    return BrandModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      logoUrl: json['logo_url'] as String?,
      website: json['website'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'logo_url': logoUrl,
      'website': website,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convertit le Model en Entity
  BrandEntity toEntity() {
    return BrandEntity(
      id: id,
      name: name,
      description: description,
      logoUrl: logoUrl,
      website: website,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crée un Model depuis une Entity
  factory BrandModel.fromEntity(BrandEntity entity) {
    return BrandModel(
      id: entity.id,
      name: entity.name,
      description: entity.description,
      logoUrl: entity.logoUrl,
      website: entity.website,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}