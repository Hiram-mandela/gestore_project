// ========================================
// lib/features/inventory/data/models/unit_conversion_model.dart
// Model pour le mapping JSON <-> Entity UnitConversion
// ========================================

import '../../domain/entities/unit_conversion_entity.dart';
import 'unit_of_measure_model.dart';

/// Model pour le mapping des conversions d'unités depuis/vers l'API
class UnitConversionModel {
  final String id;
  final UnitOfMeasureModel fromUnit;
  final UnitOfMeasureModel toUnit;
  final double conversionFactor;
  final String conversionDisplay;
  final String createdAt;
  final String updatedAt;

  UnitConversionModel({
    required this.id,
    required this.fromUnit,
    required this.toUnit,
    required this.conversionFactor,
    required this.conversionDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory UnitConversionModel.fromJson(Map<String, dynamic> json) {
    return UnitConversionModel(
      id: json['id'] as String,
      fromUnit: UnitOfMeasureModel.fromJson(json['from_unit'] as Map<String, dynamic>),
      toUnit: UnitOfMeasureModel.fromJson(json['to_unit'] as Map<String, dynamic>),
      conversionFactor: _parseDouble(json['conversion_factor']),
      conversionDisplay: json['conversion_display'] as String? ?? '',
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Parse robuste d'un nombre en double
  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value) ?? 0.0;
    }
    return 0.0;
  }

  /// Convertit le Model en JSON pour l'API (création/modification)
  Map<String, dynamic> toJson() {
    return {
      'from_unit_id': fromUnit.id,
      'to_unit_id': toUnit.id,
      'conversion_factor': conversionFactor,
    };
  }

  /// Convertit le Model en Entity
  UnitConversionEntity toEntity() {
    return UnitConversionEntity(
      id: id,
      fromUnit: fromUnit.toEntity(),
      toUnit: toUnit.toEntity(),
      conversionFactor: conversionFactor,
      conversionDisplay: conversionDisplay,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  /// Crée un Model depuis une Entity
  factory UnitConversionModel.fromEntity(UnitConversionEntity entity) {
    return UnitConversionModel(
      id: entity.id,
      fromUnit: UnitOfMeasureModel.fromEntity(entity.fromUnit),
      toUnit: UnitOfMeasureModel.fromEntity(entity.toUnit),
      conversionFactor: entity.conversionFactor,
      conversionDisplay: entity.conversionDisplay,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}