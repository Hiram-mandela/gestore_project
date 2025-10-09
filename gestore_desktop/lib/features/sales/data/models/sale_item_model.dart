// ========================================
// lib/features/sales/data/models/sale_item_model.dart
// Model SaleItem - Data Layer
// ========================================

import '../../domain/entities/sale_item_entity.dart';

/// Model représentant une ligne d'article dans une vente
class SaleItemModel {
  final String id;
  final String articleId;
  final String articleName;
  final String articleCode;

  // Quantité et prix
  final String quantity;
  final String unitPrice;

  // Remises
  final String discountPercentage;
  final String discountAmount;

  // Taxes
  final String taxRate;
  final String taxAmount;

  // Montant total
  final String lineTotal;

  // Informations additionnelles
  final String? lotNumber;

  final String createdAt;
  final String? updatedAt;

  SaleItemModel({
    required this.id,
    required this.articleId,
    required this.articleName,
    required this.articleCode,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage = '0.00',
    required this.discountAmount,
    this.taxRate = '0.00',
    required this.taxAmount,
    required this.lineTotal,
    this.lotNumber,
    required this.createdAt,
    this.updatedAt,
  });

  /// Depuis JSON (API response)
  factory SaleItemModel.fromJson(Map<String, dynamic> json) {
    return SaleItemModel(
      id: json['id'] as String,
      articleId: json['article_id'] as String? ?? json['article']['id'] as String,
      articleName: json['article_name'] as String? ?? json['article']['name'] as String,
      articleCode: json['article_code'] as String? ?? json['article']['code'] as String,
      quantity: json['quantity']?.toString() ?? '1.000',
      unitPrice: json['unit_price']?.toString() ?? '0.00',
      discountPercentage: json['discount_percentage']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      taxRate: json['tax_rate']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      lineTotal: json['line_total']?.toString() ?? '0.00',
      lotNumber: json['lot_number'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'article_id': articleId,
      'article_name': articleName,
      'article_code': articleCode,
      'quantity': quantity,
      'unit_price': unitPrice,
      'discount_percentage': discountPercentage,
      'discount_amount': discountAmount,
      'tax_rate': taxRate,
      'tax_amount': taxAmount,
      'line_total': lineTotal,
      if (lotNumber != null) 'lot_number': lotNumber,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Conversion vers Entity
  SaleItemEntity toEntity() {
    return SaleItemEntity(
      id: id,
      articleId: articleId,
      articleName: articleName,
      articleCode: articleCode,
      quantity: double.tryParse(quantity) ?? 1.0,
      unitPrice: double.tryParse(unitPrice) ?? 0.0,
      discountPercentage: double.tryParse(discountPercentage) ?? 0.0,
      discountAmount: double.tryParse(discountAmount) ?? 0.0,
      taxRate: double.tryParse(taxRate) ?? 0.0,
      taxAmount: double.tryParse(taxAmount) ?? 0.0,
      lineTotal: double.tryParse(lineTotal) ?? 0.0,
      lotNumber: lotNumber,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// Depuis Entity (pour requêtes POST/PUT)
  static Map<String, dynamic> fromEntity(SaleItemEntity entity) {
    return {
      'article_id': entity.articleId,
      'quantity': entity.quantity,
      'unit_price': entity.unitPrice,
      'discount_percentage': entity.discountPercentage,
      if (entity.lotNumber != null) 'lot_number': entity.lotNumber,
    };
  }
}