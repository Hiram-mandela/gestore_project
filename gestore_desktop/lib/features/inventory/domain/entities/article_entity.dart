// ========================================
// lib/features/inventory/domain/entities/article_entity.dart
// Entity pour les articles
// ========================================

import 'package:equatable/equatable.dart';

/// Types d'article
enum ArticleType {
  product('product', 'Produit'),
  service('service', 'Service'),
  bundle('bundle', 'Pack/Bundle'),
  variant('variant', 'Variante');

  final String value;
  final String label;
  const ArticleType(this.value, this.label);

  static ArticleType fromString(String value) {
    return ArticleType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => ArticleType.product,
    );
  }
}

/// Entity représentant un article (version liste optimisée)
/// Correspond au serializer ArticleListSerializer du backend
class ArticleEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final ArticleType articleType;
  final String? barcode;

  // Relations (noms uniquement pour la liste)
  final String categoryName;
  final String categoryColor;
  final String? brandName;
  final String unitSymbol;

  // Prix
  final double purchasePrice;
  final double sellingPrice;

  // Image
  final String? imageUrl;

  // Champs calculés (viennent du backend)
  final double currentStock;
  final double availableStock;
  final bool isLowStock;
  final double marginPercent;

  // État
  final bool isSellable;
  final bool isActive;
  final String statusDisplay;

  // Métadonnées
  final DateTime createdAt;
  final DateTime updatedAt;

  const ArticleEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.articleType,
    this.barcode,
    required this.categoryName,
    required this.categoryColor,
    this.brandName,
    required this.unitSymbol,
    required this.purchasePrice,
    required this.sellingPrice,
    this.imageUrl,
    required this.currentStock,
    required this.availableStock,
    required this.isLowStock,
    required this.marginPercent,
    required this.isSellable,
    required this.isActive,
    required this.statusDisplay,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vérifie si l'article a une image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Vérifie si l'article a un code-barres
  bool get hasBarcode => barcode != null && barcode!.isNotEmpty;

  /// Vérifie si l'article a une marque
  bool get hasBrand => brandName != null && brandName!.isNotEmpty;

  /// Retourne la marge formatée
  String get formattedMargin => '${marginPercent.toStringAsFixed(1)}%';

  /// Retourne le prix de vente formaté
  String get formattedSellingPrice => '${sellingPrice.toStringAsFixed(2)} FCFA';

  /// Retourne le prix d'achat formaté
  String get formattedPurchasePrice => '${purchasePrice.toStringAsFixed(2)} FCFA';

  /// Retourne le stock formaté
  String get formattedStock => '${currentStock.toStringAsFixed(0)} $unitSymbol';

  /// Calcule le bénéfice unitaire
  double get unitProfit => sellingPrice - purchasePrice;

  /// Vérifie si l'article est en stock
  bool get isInStock => currentStock > 0;

  /// Vérifie si l'article est en rupture de stock
  bool get isOutOfStock => currentStock <= 0;

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    articleType,
    barcode,
    categoryName,
    categoryColor,
    brandName,
    unitSymbol,
    purchasePrice,
    sellingPrice,
    imageUrl,
    currentStock,
    availableStock,
    isLowStock,
    marginPercent,
    isSellable,
    isActive,
    statusDisplay,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'ArticleEntity(id: $id, name: $name, code: $code)';
}