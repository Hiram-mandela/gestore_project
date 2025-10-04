// ========================================
// lib/features/inventory/domain/entities/article_detail_entity.dart
// Entity complète pour le détail d'un article
// Correspond au ArticleDetailSerializer du backend
// ========================================

import 'package:equatable/equatable.dart';
import 'article_entity.dart';

/// Entity complète pour le détail d'un article
/// Contient toutes les informations et relations
class ArticleDetailEntity extends Equatable {
  // Informations de base
  final String id;
  final String name;
  final String description;
  final String code;
  final ArticleType articleType;
  final String? barcode;
  final String? internalReference;
  final String? supplierReference;

  // Relations complètes (objets complets)
  final CategoryDetailEntity? category;
  final BrandDetailEntity? brand;
  final UnitOfMeasureDetailEntity? unitOfMeasure;
  final SupplierSimpleEntity? mainSupplier;

  // Prix
  final double purchasePrice;
  final double sellingPrice;

  // Gestion du stock
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;

  // Options de vente/achat
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;

  // Article parent (pour les variantes)
  final ArticleSimpleEntity? parentArticle;
  final String? variantAttributes;

  // Image principale
  final String? image;
  final String? imageUrl;

  // Dimensions
  final double? weight;
  final double? length;
  final double? width;
  final double? height;

  // Autres
  final String? tags;
  final String? notes;
  final bool isActive;
  final String statusDisplay;

  // Relations multiples
  final List<AdditionalBarcodeEntity> additionalBarcodes;
  final List<ArticleImageEntity> images;
  final List<PriceHistoryEntity> priceHistory;
  final List<ArticleSimpleEntity> variants;

  // Informations de stock calculées
  final double currentStock;
  final double availableStock;
  final double reservedStock;
  final bool isLowStock;
  final double marginPercent;

  // Métadonnées
  final String createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;

  const ArticleDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    required this.articleType,
    this.barcode,
    this.internalReference,
    this.supplierReference,
    this.category,
    this.brand,
    this.unitOfMeasure,
    this.mainSupplier,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.manageStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.requiresLotTracking,
    required this.requiresExpiryDate,
    required this.isSellable,
    required this.isPurchasable,
    required this.allowNegativeStock,
    this.parentArticle,
    this.variantAttributes,
    this.image,
    this.imageUrl,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.tags,
    this.notes,
    required this.isActive,
    required this.statusDisplay,
    this.additionalBarcodes = const [],
    this.images = const [],
    this.priceHistory = const [],
    this.variants = const [],
    required this.currentStock,
    required this.availableStock,
    required this.reservedStock,
    required this.isLowStock,
    required this.marginPercent,
    required this.createdBy,
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
  });

  // ==================== GETTERS CALCULÉS ====================

  /// Marge formatée
  String get formattedMargin => '${marginPercent.toStringAsFixed(1)}%';

  /// Prix de vente formaté
  String get formattedSellingPrice => '${sellingPrice.toStringAsFixed(0)} FCFA';

  /// Prix d'achat formaté
  String get formattedPurchasePrice => '${purchasePrice.toStringAsFixed(0)} FCFA';

  /// Profit unitaire
  double get unitProfit => sellingPrice - purchasePrice;

  /// Profit unitaire formaté
  String get formattedUnitProfit => '${unitProfit.toStringAsFixed(0)} FCFA';

  /// Vérifie si l'article est en stock
  bool get isInStock => currentStock > 0;

  /// Vérifie si l'article est en rupture
  bool get isOutOfStock => currentStock <= 0;

  /// Vérifie si l'article a des variantes
  bool get hasVariants => variants.isNotEmpty;

  /// Nombre de variantes
  int get variantsCount => variants.length;

  /// Vérifie si l'article est une variante
  bool get isVariant => parentArticle != null;

  /// Vérifie si l'article a plusieurs images
  bool get hasMultipleImages => images.length > 1;

  /// Vérifie si l'article a un historique de prix
  bool get hasPriceHistory => priceHistory.isNotEmpty;

  /// Stock en pourcentage du stock maximum
  double get stockPercentage {
    if (maxStockLevel <= 0) return 0;
    return (currentStock / maxStockLevel * 100).clamp(0, 100);
  }

  /// Tous les codes-barres (principal + additionnels)
  List<String> get allBarcodes {
    final barcodes = <String>[];
    if (barcode != null) barcodes.add(barcode!);
    barcodes.addAll(additionalBarcodes.map((b) => b.barcode));
    return barcodes;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    code,
    articleType,
    barcode,
    category,
    brand,
    unitOfMeasure,
    purchasePrice,
    sellingPrice,
    currentStock,
    isActive,
  ];

  @override
  String toString() => 'ArticleDetailEntity(id: $id, name: $name, code: $code)';
}

// ==================== ENTITIES AUXILIAIRES ====================

/// Catégorie détaillée
class CategoryDetailEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String code;
  final String? parentId;
  final String? parentName;
  final double taxRate;
  final String color;
  final bool isActive;

  const CategoryDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.code,
    this.parentId,
    this.parentName,
    required this.taxRate,
    required this.color,
    required this.isActive,
  });

  String get fullName {
    if (parentName != null && parentName!.isNotEmpty) {
      return '$parentName > $name';
    }
    return name;
  }

  @override
  List<Object?> get props => [id, name, code];
}

/// Marque détaillée
class BrandDetailEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String? logoUrl;
  final String? website;
  final bool isActive;

  const BrandDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    this.logoUrl,
    this.website,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Unité de mesure détaillée
class UnitOfMeasureDetailEntity extends Equatable {
  final String id;
  final String name;
  final String symbol;
  final bool isDecimal;
  final bool isActive;

  const UnitOfMeasureDetailEntity({
    required this.id,
    required this.name,
    required this.symbol,
    required this.isDecimal,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, symbol];
}

/// Fournisseur simplifié
class SupplierSimpleEntity extends Equatable {
  final String id;
  final String name;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final bool isActive;

  const SupplierSimpleEntity({
    required this.id,
    required this.name,
    this.contactPerson,
    this.phone,
    this.email,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name];
}

/// Article simplifié (pour variants et parent)
class ArticleSimpleEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? imageUrl;
  final double sellingPrice;
  final double currentStock;
  final bool isActive;

  const ArticleSimpleEntity({
    required this.id,
    required this.name,
    required this.code,
    this.imageUrl,
    required this.sellingPrice,
    required this.currentStock,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, code];
}

/// Code-barre additionnel
class AdditionalBarcodeEntity extends Equatable {
  final String id;
  final String barcode;
  final String barcodeType;
  final bool isPrimary;

  const AdditionalBarcodeEntity({
    required this.id,
    required this.barcode,
    required this.barcodeType,
    required this.isPrimary,
  });

  @override
  List<Object?> get props => [id, barcode];
}

/// Image d'article
class ArticleImageEntity extends Equatable {
  final String id;
  final String imageUrl;
  final String? altText;
  final String? caption;
  final bool isPrimary;
  final int order;

  const ArticleImageEntity({
    required this.id,
    required this.imageUrl,
    this.altText,
    this.caption,
    required this.isPrimary,
    required this.order,
  });

  @override
  List<Object?> get props => [id, imageUrl, order];
}

/// Historique des prix
class PriceHistoryEntity extends Equatable {
  final String id;
  final double oldPurchasePrice;
  final double oldSellingPrice;
  final double newPurchasePrice;
  final double newSellingPrice;
  final String reason;
  final String? notes;
  final DateTime effectiveDate;
  final String createdBy;

  const PriceHistoryEntity({
    required this.id,
    required this.oldPurchasePrice,
    required this.oldSellingPrice,
    required this.newPurchasePrice,
    required this.newSellingPrice,
    required this.reason,
    this.notes,
    required this.effectiveDate,
    required this.createdBy,
  });

  /// Changement du prix d'achat en pourcentage
  double get purchaseChangePercent {
    if (oldPurchasePrice == 0) return 0;
    return ((newPurchasePrice - oldPurchasePrice) / oldPurchasePrice * 100);
  }

  /// Changement du prix de vente en pourcentage
  double get sellingChangePercent {
    if (oldSellingPrice == 0) return 0;
    return ((newSellingPrice - oldSellingPrice) / oldSellingPrice * 100);
  }

  @override
  List<Object?> get props => [id, effectiveDate];
}