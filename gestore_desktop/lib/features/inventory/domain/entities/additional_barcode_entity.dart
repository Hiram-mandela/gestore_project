// ========================================
// lib/features/inventory/domain/entities/additional_barcode_entity.dart
// Entity pour les codes-barres additionnels
// ========================================

import 'package:equatable/equatable.dart';

enum BarcodeType {
  ean13('EAN13'),
  ean8('EAN8'),
  upc('UPC'),
  code128('CODE128'),
  code39('CODE39'),
  qrCode('QR_CODE'),
  dataMatrix('DATA_MATRIX');

  final String value;
  const BarcodeType(this.value);

  static BarcodeType fromString(String value) {
    return BarcodeType.values.firstWhere(
          (e) => e.value == value.toUpperCase(),
      orElse: () => BarcodeType.ean13,
    );
  }
}

class AdditionalBarcodeEntity extends Equatable {
  final String id;
  final String barcode;
  final BarcodeType barcodeType;
  final bool isPrimary;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AdditionalBarcodeEntity({
    required this.id,
    required this.barcode,
    this.barcodeType = BarcodeType.ean13,
    this.isPrimary = false,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
    id,
    barcode,
    barcodeType,
    isPrimary,
    createdAt,
    updatedAt,
  ];
}