// ========================================
// lib/features/inventory/data/models/category_model.dart
// Model pour le mapping JSON <-> Entity Category
// ========================================

import '../../domain/entities/category_entity.dart';

/// Model pour le mapping des catégories depuis/vers l'API
class CategoryModel {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? parentId;
  final String? parentName;
  final String color;
  final double taxRate;
  final bool isActive;
  final int order;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.parentId,
    this.parentName,
    required this.color,
    required this.taxRate,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String?,
      parentId: json['parent_id'] as String?,
      parentName: json['parent_name'] as String?,
      color: json['color'] as String? ?? '#000000',
      taxRate: (json['tax_rate'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      'parent_id': parentId,
      'parent_name': parentName,
      'color': color,
      'tax_rate': taxRate,
      'is_active': isActive,
      'order': order,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convertit le Model en Entity
  CategoryEntity toEntity() {
    return CategoryEntity(
      id: id,
      name: name,
      code: code,
      description: description,
      parentId: parentId,
      parentName: parentName,
      color: color,
      taxRate: taxRate,
      isActive: isActive,
      order: order,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crée un Model depuis une Entity
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(
      id: entity.id,
      name: entity.name,
      code: entity.code,
      description: entity.description,
      parentId: entity.parentId,
      parentName: entity.parentName,
      color: entity.color,
      taxRate: entity.taxRate,
      isActive: entity.isActive,
      order: entity.order,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}