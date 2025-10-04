// ========================================
// lib/features/inventory/data/models/category_model.dart
// VERSION COMPLÈTE - Model pour le mapping JSON <-> Entity Category
// ========================================

import '../../domain/entities/category_entity.dart';

/// Model pour le mapping des catégories depuis/vers l'API
class CategoryModel {
  final String id;
  final String name;
  final String code;
  final String description;
  final String? parentId;
  final String? parentName;
  final double taxRate;
  final String color;
  final bool requiresPrescription;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final int defaultMinStock;
  final int order;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  CategoryModel({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.parentId,
    this.parentName,
    required this.taxRate,
    required this.color,
    required this.requiresPrescription,
    required this.requiresLotTracking,
    required this.requiresExpiryDate,
    required this.defaultMinStock,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      name: json['name'] as String,
      code: json['code'] as String,
      description: json['description'] as String? ?? '',
      parentId: json['parent'] as String?,
      parentName: json['parent_name'] as String?,
      taxRate: _parseDouble(json['tax_rate']),
      color: json['color'] as String? ?? '#007bff',
      requiresPrescription: json['requires_prescription'] as bool? ?? false,
      requiresLotTracking: json['requires_lot_tracking'] as bool? ?? false,
      requiresExpiryDate: json['requires_expiry_date'] as bool? ?? false,
      defaultMinStock: json['default_min_stock'] as int? ?? 5,
      order: json['order'] as int? ?? 0,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Helper pour parser les doubles (peut être string ou number)
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'description': description,
      if (parentId != null && parentId!.isNotEmpty) 'parent': parentId,
      'tax_rate': taxRate.toString(),
      'color': color,
      'requires_prescription': requiresPrescription,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'default_min_stock': defaultMinStock,
      'order': order,
      'is_active': isActive,
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
      taxRate: taxRate,
      color: color,
      requiresPrescription: requiresPrescription,
      requiresLotTracking: requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate,
      defaultMinStock: defaultMinStock,
      order: order,
      isActive: isActive,
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
      taxRate: entity.taxRate,
      color: entity.color,
      requiresPrescription: entity.requiresPrescription,
      requiresLotTracking: entity.requiresLotTracking,
      requiresExpiryDate: entity.requiresExpiryDate,
      defaultMinStock: entity.defaultMinStock,
      order: entity.order,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}