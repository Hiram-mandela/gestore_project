// ========================================
// lib/features/inventory/domain/entities/unit_conversion_entity.dart
// Entity pour les conversions d'unités
// ========================================

import 'package:equatable/equatable.dart';
import 'unit_of_measure_entity.dart';

/// Entity représentant une conversion entre deux unités de mesure
/// Ex: 1 kg = 1000 g, 1 boîte = 12 pièces
class UnitConversionEntity extends Equatable {
  final String id;
  final UnitOfMeasureEntity fromUnit;
  final UnitOfMeasureEntity toUnit;
  final double conversionFactor;
  final String conversionDisplay;
  final DateTime createdAt;
  final DateTime updatedAt;

  const UnitConversionEntity({
    required this.id,
    required this.fromUnit,
    required this.toUnit,
    required this.conversionFactor,
    required this.conversionDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit une quantité de fromUnit vers toUnit
  double convert(double quantity) {
    return quantity * conversionFactor;
  }

  /// Convertit une quantité de toUnit vers fromUnit (conversion inverse)
  double convertReverse(double quantity) {
    return quantity / conversionFactor;
  }

  /// Vérifie si la conversion est valide
  bool get isValid => conversionFactor > 0;

  /// Texte formaté de la conversion
  /// Ex: "1 kg = 1000 g"
  String get displayText => conversionDisplay;

  /// Copie avec modifications
  UnitConversionEntity copyWith({
    String? id,
    UnitOfMeasureEntity? fromUnit,
    UnitOfMeasureEntity? toUnit,
    double? conversionFactor,
    String? conversionDisplay,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UnitConversionEntity(
      id: id ?? this.id,
      fromUnit: fromUnit ?? this.fromUnit,
      toUnit: toUnit ?? this.toUnit,
      conversionFactor: conversionFactor ?? this.conversionFactor,
      conversionDisplay: conversionDisplay ?? this.conversionDisplay,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    fromUnit,
    toUnit,
    conversionFactor,
    conversionDisplay,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() =>
      'UnitConversionEntity(id: $id, conversion: $conversionDisplay)';
}