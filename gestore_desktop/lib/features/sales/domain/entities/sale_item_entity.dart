// ========================================
// lib/features/sales/domain/entities/sale_item_entity.dart
// Entité SaleItem - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';

/// Entité représentant une ligne d'article dans une vente
class SaleItemEntity extends Equatable {
  final String id;
  final String articleId;
  final String articleName;
  final String articleCode;

  // Quantité et prix
  final double quantity;
  final double unitPrice;

  // Remises
  final double discountPercentage;
  final double discountAmount;

  // Taxes
  final double taxRate;
  final double taxAmount;

  // Montant total
  final double lineTotal;

  // Informations additionnelles
  final String? lotNumber;

  final DateTime createdAt;
  final DateTime? updatedAt;

  const SaleItemEntity({
    required this.id,
    required this.articleId,
    required this.articleName,
    required this.articleCode,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage = 0.0,
    required this.discountAmount,
    this.taxRate = 0.0,
    required this.taxAmount,
    required this.lineTotal,
    this.lotNumber,
    required this.createdAt,
    this.updatedAt,
  });

  /// Calcule le sous-total avant remise
  double get subtotal => quantity * unitPrice;

  /// Calcule le montant après remise mais avant taxe
  double get amountAfterDiscount => subtotal - discountAmount;

  /// Vérifie si l'article a une remise
  bool get hasDiscount => discountAmount > 0;

  /// Vérifie si l'article a une taxe
  bool get hasTax => taxAmount > 0;

  /// Copie avec modifications
  SaleItemEntity copyWith({
    String? id,
    String? articleId,
    String? articleName,
    String? articleCode,
    double? quantity,
    double? unitPrice,
    double? discountPercentage,
    double? discountAmount,
    double? taxRate,
    double? taxAmount,
    double? lineTotal,
    String? lotNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SaleItemEntity(
      id: id ?? this.id,
      articleId: articleId ?? this.articleId,
      articleName: articleName ?? this.articleName,
      articleCode: articleCode ?? this.articleCode,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      discountAmount: discountAmount ?? this.discountAmount,
      taxRate: taxRate ?? this.taxRate,
      taxAmount: taxAmount ?? this.taxAmount,
      lineTotal: lineTotal ?? this.lineTotal,
      lotNumber: lotNumber ?? this.lotNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    articleId,
    articleName,
    articleCode,
    quantity,
    unitPrice,
    discountPercentage,
    discountAmount,
    taxRate,
    taxAmount,
    lineTotal,
    lotNumber,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'SaleItemEntity(article: $articleName, qty: $quantity, total: $lineTotal)';
}