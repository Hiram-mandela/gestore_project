// ========================================
// lib/features/inventory/data/models/unit_of_measure_model.dart
// Model pour le mapping JSON <-> Entity UnitOfMeasure
// ========================================

import '../../domain/entities/unit_of_measure_entity.dart';

/// Model pour le mapping des unités de mesure depuis/vers l'API
class UnitOfMeasureModel {
  final String id;
  final String name;
  final String symbol;
  final String? description;
  final bool isDecimal;
  final bool isActive;
  final String createdAt;
  final String updatedAt;

  UnitOfMeasureModel({
    required this.id,
    required this.name,
    required this.symbol,
    this.description,
    required this.isDecimal,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory UnitOfMeasureModel.fromJson(Map<String, dynamic> json) {
    return UnitOfMeasureModel(
      id: json['id'] as String,
      name: json['name'] as String,
      symbol: json['symbol'] as String,
      description: json['description'] as String?,
      isDecimal: json['is_decimal'] as bool? ?? false,
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
      'symbol': symbol,
      'description': description,
      'is_decimal': isDecimal,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }

  /// Convertit le Model en Entity
  UnitOfMeasureEntity toEntity() {
    return UnitOfMeasureEntity(
      id: id,
      name: name,
      symbol: symbol,
      description: description,
      isDecimal: isDecimal,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crée un Model depuis une Entity
  factory UnitOfMeasureModel.fromEntity(UnitOfMeasureEntity entity) {
    return UnitOfMeasureModel(
      id: entity.id,
      name: entity.name,
      symbol: entity.symbol,
      description: entity.description,
      isDecimal: entity.isDecimal,
      isActive: entity.isActive,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}