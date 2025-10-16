// ========================================
// lib/features/inventory/data/models/article_detail_model.dart
// Model complet pour le détail d'un article
// VERSION 2.0 - Support de tous les champs de l'API
// ========================================

import '../../domain/entities/article_detail_entity.dart';
import '../../domain/entities/article_entity.dart';
import 'category_model.dart';
import 'brand_model.dart';
import 'supplier_model.dart';
import 'unit_of_measure_model.dart';
import 'article_model.dart';
import 'article_image_model.dart';
import 'additional_barcode_model.dart';

class ArticleDetailModel {
  // ==================== SECTION 1 : INFORMATIONS DE BASE ====================
  final String id;
  final String name;
  final String description;
  final String shortDescription;
  final String code;
  final String articleType;
  final String? barcode;
  final String? internalReference;
  final String? supplierReference;
  final String? tags;
  final String? notes;

  // ==================== SECTION 2 : CLASSIFICATION ====================
  final CategoryModel? category;
  final BrandModel? brand;
  final UnitOfMeasureModel? unitOfMeasure;
  final SupplierModel? mainSupplier;

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
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final ArticleModel? parentArticle;
  final String? variantAttributes;
  final String? image;
  final String? imageUrl;
  final bool isActive;
  final String statusDisplay;

  // ==================== DONNÉES COMPLEXES ====================
  final List<AdditionalBarcodeModel> additionalBarcodes;
  final List<ArticleImageModel> images;
  final List<dynamic> priceHistory;
  final List<ArticleModel> variants;

  // ==================== INFORMATIONS DE STOCK ====================
  final double currentStock;
  final double availableStock;
  final double? reservedStock;
  final bool isLowStock;

  // ==================== CALCULS ====================
  final double marginPercent;
  final String allBarcodes;
  final int variantsCount;

  // ==================== AUDIT ====================
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime updatedAt;
  final String? syncStatus;
  final bool needsSync;

  ArticleDetailModel({
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
    this.updatedBy = '',
    required this.updatedAt,
    this.syncStatus,
    required this.needsSync,
  });

  /// Convertit le JSON de l'API en Model
  factory ArticleDetailModel.fromJson(Map<String, dynamic> json) {
    return ArticleDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      shortDescription: json['short_description'] as String? ?? '',
      code: json['code'] as String,
      articleType: json['article_type'] as String? ?? 'product',
      barcode: json['barcode'] as String?,
      internalReference: json['internal_reference'] as String?,
      supplierReference: json['supplier_reference'] as String?,

      // ⭐ CORRECTION: tags peut être String, List ou null
      tags: _parseStringOrList(json['tags']),
      notes: json['notes'] as String?,

      // Classification
      category: json['category'] != null
          ? CategoryModel.fromJson(json['category'] as Map<String, dynamic>)
          : null,
      brand: json['brand'] != null
          ? BrandModel.fromJson(json['brand'] as Map<String, dynamic>)
          : null,
      unitOfMeasure: json['unit_of_measure'] != null
          ? UnitOfMeasureModel.fromJson(json['unit_of_measure'] as Map<String, dynamic>)
          : null,
      mainSupplier: json['main_supplier'] != null
          ? SupplierModel.fromJson(json['main_supplier'] as Map<String, dynamic>)
          : null,

      // Stock
      manageStock: json['manage_stock'] as bool? ?? true,
      minStockLevel: json['min_stock_level'] as int? ?? 0,
      maxStockLevel: json['max_stock_level'] as int? ?? 0,
      requiresLotTracking: json['requires_lot_tracking'] as bool? ?? false,
      requiresExpiryDate: json['requires_expiry_date'] as bool? ?? false,
      isSellable: json['is_sellable'] as bool? ?? true,
      isPurchasable: json['is_purchasable'] as bool? ?? true,
      allowNegativeStock: json['allow_negative_stock'] as bool? ?? false,

      // Prix - ⭐ CORRECTION: Parse String ou num
      purchasePrice: _parsePrice(json['purchase_price']),
      sellingPrice: _parsePrice(json['selling_price']),

      // Dimensions - ⭐ CORRECTION: Parse String ou num
      weight: _parseDouble(json['weight']),
      length: _parseDouble(json['length']),
      width: _parseDouble(json['width']),
      height: _parseDouble(json['height']),

      // Variantes
      parentArticle: json['parent_article'] != null
          ? ArticleModel.fromJson(json['parent_article'] as Map<String, dynamic>)
          : null,
      variantAttributes: _parseStringOrNull(json['variant_attributes']),

      // Images
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,

      // Statut
      isActive: json['is_active'] as bool? ?? true,
      statusDisplay: json['status_display'] as String? ?? '',

      // Données complexes
      additionalBarcodes: (json['additional_barcodes'] as List<dynamic>?)
          ?.map((e) => AdditionalBarcodeModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => ArticleImageModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],
      priceHistory: json['price_history'] as List<dynamic>? ?? [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => ArticleModel.fromJson(e as Map<String, dynamic>))
          .toList() ??
          [],

      // Stock
      currentStock: _parseDouble(json['current_stock']) ?? 0.0,
      availableStock: _parseDouble(json['available_stock']) ?? 0.0,
      reservedStock: _parseDouble(json['reserved_stock']),
      isLowStock: _parseBool(json['is_low_stock']),

      // Calculs - ⭐ CORRECTION: all_barcodes peut être List ou String
      marginPercent: _parseDouble(json['margin_percent']) ?? 0.0,
      allBarcodes: _parseStringOrList(json['all_barcodes']) ?? '',
      variantsCount: _parseInt(json['variants_count']) ?? 0,

      // Audit
      createdBy: json['created_by'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedBy: json['updated_by'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: json['sync_status'] as String?,
      needsSync: _parseBool(json['needs_sync']),
    );
  }

  /// Convertit le Model en Entity
  ArticleDetailEntity toEntity() {
    return ArticleDetailEntity(
      id: id,
      name: name,
      description: description,
      shortDescription: shortDescription,
      code: code,
      articleType: ArticleType.fromString(articleType),
      barcode: barcode,
      internalReference: internalReference,
      supplierReference: supplierReference,
      tags: tags,
      notes: notes,
      category: category?.toEntity(),
      brand: brand?.toEntity(),
      unitOfMeasure: unitOfMeasure?.toEntity(),
      mainSupplier: mainSupplier?.toEntity(),
      manageStock: manageStock,
      minStockLevel: minStockLevel,
      maxStockLevel: maxStockLevel,
      requiresLotTracking: requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate,
      isSellable: isSellable,
      isPurchasable: isPurchasable,
      allowNegativeStock: allowNegativeStock,
      purchasePrice: purchasePrice,
      sellingPrice: sellingPrice,
      weight: weight,
      length: length,
      width: width,
      height: height,
      parentArticle: parentArticle?.toEntity(),
      variantAttributes: variantAttributes,
      image: image,
      imageUrl: imageUrl,
      isActive: isActive,
      statusDisplay: statusDisplay,
      additionalBarcodes: additionalBarcodes.map((e) => e.toEntity()).toList(),
      images: images.map((e) => e.toEntity()).toList(),
      priceHistory: priceHistory,
      variants: variants.map((e) => e.toEntity()).toList(),
      currentStock: currentStock,
      availableStock: availableStock,
      reservedStock: reservedStock,
      isLowStock: isLowStock,
      marginPercent: marginPercent,
      allBarcodes: allBarcodes,
      variantsCount: variantsCount,
      createdBy: createdBy,
      createdAt: createdAt,
      updatedBy: updatedBy,
      updatedAt: updatedAt,
      syncStatus: syncStatus,
      needsSync: needsSync,
    );
  }

  // ==================== HELPERS DE PARSING ====================

  /// Parse un prix depuis String, num ou null
  static double _parsePrice(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final cleaned = value.replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(cleaned) ?? 0.0;
    }
    return 0.0;
  }

  /// Parse un double depuis String, num ou null
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      if (value.isEmpty) return null;
      final cleaned = value.replaceAll(',', '').replaceAll(' ', '');
      return double.tryParse(cleaned);
    }
    return null;
  }

  /// Parse un int depuis String, num ou null
  static int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) {
      if (value.isEmpty) return null;
      return int.tryParse(value);
    }
    return null;
  }

  /// Parse un bool depuis diverses sources
  static bool _parseBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    if (value is int) return value != 0;
    return false;
  }

  /// Parse String ou null (gère les objets JSON vides)
  static String? _parseStringOrNull(dynamic value) {
    if (value == null) return null;
    if (value is String) {
      return value.isEmpty ? null : value;
    }
    if (value is Map && value.isEmpty) return null; // {} vide
    if (value is List && value.isEmpty) return null; // [] vide
    return value.toString();
  }

  /// ⭐ NOUVEAU: Parse une valeur qui peut être String, List ou null
  /// Si c'est une List, la convertit en String séparé par des virgules
  static String? _parseStringOrList(dynamic value) {
    if (value == null) return null;

    if (value is String) {
      return value.isEmpty ? null : value;
    }

    if (value is List) {
      if (value.isEmpty) return null;
      // Convertir la liste en string séparé par des virgules
      return value.map((e) => e.toString()).join(', ');
    }

    return value.toString();
  }
}