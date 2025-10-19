// ========================================
// lib/features/inventory/domain/usecases/unit_conversion_usecases.dart
// Use Cases pour les conversions d'unités
// ========================================

import 'package:injectable/injectable.dart';
import '../entities/unit_conversion_entity.dart';
import '../repositories/inventory_repository.dart';

// ==================== GET UNIT CONVERSIONS ====================

@injectable
class GetUnitConversionsUseCase {
  final InventoryRepository repository;

  GetUnitConversionsUseCase(this.repository);

  Future<(List<UnitConversionEntity>?, String?)> call({
    String? fromUnitId,
    String? toUnitId,
  }) async {
    return await repository.getUnitConversions(
      fromUnitId: fromUnitId,
      toUnitId: toUnitId,
    );
  }
}

// ==================== GET UNIT CONVERSION BY ID ====================

@injectable
class GetUnitConversionByIdUseCase {
  final InventoryRepository repository;

  GetUnitConversionByIdUseCase(this.repository);

  Future<(UnitConversionEntity?, String?)> call(String id) async {
    return await repository.getUnitConversionById(id);
  }
}

// ==================== CREATE UNIT CONVERSION ====================

@injectable
class CreateUnitConversionUseCase {
  final InventoryRepository repository;

  CreateUnitConversionUseCase(this.repository);

  Future<(UnitConversionEntity?, String?)> call({
    required String fromUnitId,
    required String toUnitId,
    required double conversionFactor,
  }) async {
    final data = {
      'from_unit_id': fromUnitId,
      'to_unit_id': toUnitId,
      'conversion_factor': conversionFactor,
    };

    return await repository.createUnitConversion(data);
  }
}

// ==================== UPDATE UNIT CONVERSION ====================

@injectable
class UpdateUnitConversionUseCase {
  final InventoryRepository repository;

  UpdateUnitConversionUseCase(this.repository);

  Future<(UnitConversionEntity?, String?)> call({
    required String id,
    String? fromUnitId,
    String? toUnitId,
    double? conversionFactor,
  }) async {
    final data = <String, dynamic>{};

    if (fromUnitId != null) data['from_unit_id'] = fromUnitId;
    if (toUnitId != null) data['to_unit_id'] = toUnitId;
    if (conversionFactor != null) data['conversion_factor'] = conversionFactor;

    return await repository.updateUnitConversion(id, data);
  }
}

// ==================== DELETE UNIT CONVERSION ====================

@injectable
class DeleteUnitConversionUseCase {
  final InventoryRepository repository;

  DeleteUnitConversionUseCase(this.repository);

  Future<(void, String?)> call(String id) async {
    return await repository.deleteUnitConversion(id);
  }
}

// ==================== CALCULATE CONVERSION ====================

/// Use Case pour calculer une conversion à la volée
@injectable
class CalculateConversionUseCase {
  final InventoryRepository repository;

  CalculateConversionUseCase(this.repository);

  /// Calcule une conversion entre deux unités
  /// Retourne (quantité convertie, message d'erreur)
  Future<(ConversionResult?, String?)> call({
    required String fromUnitId,
    required String toUnitId,
    required double quantity,
  }) async {
    return await repository.calculateConversion(
      fromUnitId: fromUnitId,
      toUnitId: toUnitId,
      quantity: quantity,
    );
  }
}

/// Résultat d'un calcul de conversion
class ConversionResult {
  final double originalQuantity;
  final double convertedQuantity;
  final double conversionFactor;
  final String fromUnit;
  final String toUnit;

  ConversionResult({
    required this.originalQuantity,
    required this.convertedQuantity,
    required this.conversionFactor,
    required this.fromUnit,
    required this.toUnit,
  });

  /// Parse depuis le JSON de l'API
  factory ConversionResult.fromJson(Map<String, dynamic> json) {
    return ConversionResult(
      originalQuantity: _parseDouble(json['original_quantity']),
      convertedQuantity: _parseDouble(json['converted_quantity']),
      conversionFactor: _parseDouble(json['conversion_factor']),
      fromUnit: json['from_unit'] as String? ?? '',
      toUnit: json['to_unit'] as String? ?? '',
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  /// Texte formaté du résultat
  String get displayText =>
      '$originalQuantity $fromUnit = $convertedQuantity $toUnit';

  @override
  String toString() => displayText;
}