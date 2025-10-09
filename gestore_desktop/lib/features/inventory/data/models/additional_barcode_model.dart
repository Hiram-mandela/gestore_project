// ========================================
// lib/features/inventory/data/models/additional_barcode_model.dart
// Model pour les codes-barres additionnels
// ========================================

import '../../domain/entities/additional_barcode_entity.dart';

class AdditionalBarcodeModel {
  final String id;
  final String barcode;
  final String barcodeType;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  AdditionalBarcodeModel({
    required this.id,
    required this.barcode,
    this.barcodeType = 'EAN13',
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convertit le JSON de l'API en Model
  factory AdditionalBarcodeModel.fromJson(Map<String, dynamic> json) {
    return AdditionalBarcodeModel(
      id: json['id'] as String,
      barcode: json['barcode'] as String,
      barcodeType: json['barcode_type'] as String? ?? 'EAN13',
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convertit le Model en Entity
  AdditionalBarcodeEntity toEntity() {
    return AdditionalBarcodeEntity(
      id: id,
      barcode: barcode,
      barcodeType: BarcodeType.fromString(barcodeType),
      isPrimary: isPrimary,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'barcode': barcode,
      'barcode_type': barcodeType,
      'is_primary': isPrimary,
    };
  }
}