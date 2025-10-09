// ========================================
// lib/features/inventory/domain/entities/article_detail_entity.dart
// Entity complète pour le détail d'un article
// VERSION 2.0 - Support de tous les champs de l'API
// ========================================

import 'package:equatable/equatable.dart';
import 'category_entity.dart';
import 'brand_entity.dart';
import 'supplier_entity.dart';
import 'unit_of_measure_entity.dart';
import 'article_entity.dart';
import 'article_image_entity.dart';
import 'additional_barcode_entity.dart';

/// Entity principale pour le détail d'un article
class ArticleDetailEntity extends Equatable {
  // ==================== SECTION 1 : INFORMATIONS DE BASE ====================
  final String id;
  final String name;
  final String description;
  final String shortDescription; // ⭐ NOUVEAU
  final String code;
  final ArticleType articleType;
  final String? barcode;
  final String? internalReference;
  final String? supplierReference;
  final String? tags;
  final String? notes;

  // ==================== SECTION 2 : CLASSIFICATION ====================
  final CategoryEntity? category;
  final BrandEntity? brand;
  final UnitOfMeasureEntity? unitOfMeasure;
  final SupplierEntity? mainSupplier;

  // ==================== SECTION 3 : GESTION DE STOCK ====================
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;

  // ==================== SECTION 4 : PRIX ====================
  final double purchasePrice;
  final double sellingPrice;

  // ==================== SECTION 5 : MÉTADONNÉES AVANCÉES ====================
  // Dimensions
  final double? weight;
  final double? length;
  final double? width;
  final double? height;

  // Variantes
  final ArticleEntity? parentArticle; // ⭐ NOUVEAU
  final String? variantAttributes; // ⭐ NOUVEAU (JSON string)

  // Image principale
  final String? image;
  final String? imageUrl;

  // Statut
  final bool isActive;
  final String statusDisplay;

  // ==================== DONNÉES COMPLEXES (TABLEAUX) ====================
  final List<AdditionalBarcodeEntity> additionalBarcodes; // ⭐ NOUVEAU
  final List<ArticleImageEntity> images; // ⭐ NOUVEAU
  final List<dynamic> priceHistory; // ⭐ NOUVEAU (Entity à créer plus tard)
  final List<ArticleEntity> variants; // ⭐ NOUVEAU

  // ==================== INFORMATIONS DE STOCK ====================
  final double currentStock;
  final double availableStock;
  final double? reservedStock; // ⭐ NOUVEAU
  final bool isLowStock;

  // ==================== CALCULS ====================
  final double marginPercent;
  final String allBarcodes; // ⭐ NOUVEAU (liste tous les codes-barres)
  final int variantsCount; // ⭐ NOUVEAU

  // ==================== AUDIT ====================
  final String? createdBy; // ⭐ NOUVEAU
  final DateTime createdAt;
  final String? updatedBy; // ⭐ NOUVEAU
  final DateTime updatedAt;
  final String? syncStatus;
  final bool needsSync;

  const ArticleDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    this.shortDescription = '',
    required this.code,
    required this.articleType,
    this.barcode,
    this.internalReference,
    this.supplierReference,
    this.tags,
    this.notes,
    this.category,
    this.brand,
    this.unitOfMeasure,
    this.mainSupplier,
    required this.manageStock,
    required this.minStockLevel,
    required this.maxStockLevel,
    required this.requiresLotTracking,
    required this.requiresExpiryDate,
    required this.isSellable,
    required this.isPurchasable,
    required this.allowNegativeStock,
    required this.purchasePrice,
    required this.sellingPrice,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.parentArticle,
    this.variantAttributes,
    this.image,
    this.imageUrl,
    required this.isActive,
    required this.statusDisplay,
    this.additionalBarcodes = const [],
    this.images = const [],
    this.priceHistory = const [],
    this.variants = const [],
    required this.currentStock,
    required this.availableStock,
    this.reservedStock,
    required this.isLowStock,
    required this.marginPercent,
    this.allBarcodes = '',
    this.variantsCount = 0,
    this.createdBy = '',
    required this.createdAt,
    this.updatedBy,
    required this.updatedAt,
    this.syncStatus,
    required this.needsSync,
  });

  /// Vérifie si l'article a une image
  bool get hasImage => imageUrl != null && imageUrl!.isNotEmpty;

  /// Vérifie si l'article a plusieurs images
  bool get hasMultipleImages => images.length > 1;

  /// Vérifie si l'article a des codes-barres additionnels
  bool get hasAdditionalBarcodes => additionalBarcodes.isNotEmpty;

  /// Vérifie si l'article est une variante
  bool get isVariant => parentArticle != null;

  /// Vérifie si l'article a des variantes
  bool get hasVariants => variants.isNotEmpty;

  /// Retourne le nombre total de codes-barres
  int get totalBarcodes => 1 + additionalBarcodes.length;


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




  /// Vérifie si l'article a un historique de prix
  bool get hasPriceHistory => priceHistory.isNotEmpty;

  /// Stock en pourcentage du stock maximum
  double get stockPercentage {
    if (maxStockLevel <= 0) return 0;
    return (currentStock / maxStockLevel * 100).clamp(0, 100);
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    shortDescription,
    code,
    articleType,
    barcode,
    internalReference,
    supplierReference,
    tags,
    notes,
    category,
    brand,
    unitOfMeasure,
    mainSupplier,
    manageStock,
    minStockLevel,
    maxStockLevel,
    requiresLotTracking,
    requiresExpiryDate,
    isSellable,
    isPurchasable,
    allowNegativeStock,
    purchasePrice,
    sellingPrice,
    weight,
    length,
    width,
    height,
    parentArticle,
    variantAttributes,
    image,
    imageUrl,
    isActive,
    statusDisplay,
    additionalBarcodes,
    images,
    priceHistory,
    variants,
    currentStock,
    availableStock,
    reservedStock,
    isLowStock,
    marginPercent,
    allBarcodes,
    variantsCount,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
    syncStatus,
    needsSync,
  ];
}