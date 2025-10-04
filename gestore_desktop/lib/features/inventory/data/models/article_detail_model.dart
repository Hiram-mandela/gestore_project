// ========================================
// lib/features/inventory/data/models/article_detail_model.dart
// Model pour le mapping JSON <-> ArticleDetailEntity
// Correspond au ArticleDetailSerializer du backend
// ========================================

import '../../domain/entities/article_detail_entity.dart';
import '../../domain/entities/article_entity.dart';

/// Model pour le détail complet d'un article
class ArticleDetailModel {
  final String id;
  final String name;
  final String description;
  final String code;
  final String articleType;
  final String? barcode;
  final String? internalReference;
  final String? supplierReference;
  final Map<String, dynamic>? category;
  final Map<String, dynamic>? brand;
  final Map<String, dynamic>? unitOfMeasure;
  final Map<String, dynamic>? mainSupplier;
  final String purchasePrice;
  final String sellingPrice;
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;
  final Map<String, dynamic>? parentArticle;
  final String? variantAttributes;
  final String? image;
  final String? imageUrl;
  final String? weight;
  final String? length;
  final String? width;
  final String? height;
  final String? tags;
  final String? notes;
  final bool isActive;
  final String statusDisplay;
  final List<Map<String, dynamic>> additionalBarcodes;
  final List<Map<String, dynamic>> images;
  final List<Map<String, dynamic>> priceHistory;
  final List<Map<String, dynamic>> variants;
  final String currentStock;
  final String availableStock;
  final String reservedStock;
  final String isLowStock;
  final String marginPercent;
  final String createdBy;
  final String createdAt;
  final String? updatedBy;
  final String updatedAt;

  ArticleDetailModel({
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

  /// Crée un Model depuis le JSON de l'API
  factory ArticleDetailModel.fromJson(Map<String, dynamic> json) {
    return ArticleDetailModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      code: json['code'] as String,
      articleType: json['article_type'] as String,
      barcode: json['barcode'] as String?,
      internalReference: json['internal_reference'] as String?,
      supplierReference: json['supplier_reference'] as String?,
      category: json['category'] as Map<String, dynamic>?,
      brand: json['brand'] as Map<String, dynamic>?,
      unitOfMeasure: json['unit_of_measure'] as Map<String, dynamic>?,
      mainSupplier: json['main_supplier'] as Map<String, dynamic>?,
      purchasePrice: json['purchase_price']?.toString() ?? '0.00',
      sellingPrice: json['selling_price']?.toString() ?? '0.00',
      manageStock: json['manage_stock'] as bool? ?? true,
      minStockLevel: json['min_stock_level'] as int? ?? 0,
      maxStockLevel: json['max_stock_level'] as int? ?? 0,
      requiresLotTracking: json['requires_lot_tracking'] as bool? ?? false,
      requiresExpiryDate: json['requires_expiry_date'] as bool? ?? false,
      isSellable: json['is_sellable'] as bool? ?? true,
      isPurchasable: json['is_purchasable'] as bool? ?? true,
      allowNegativeStock: json['allow_negative_stock'] as bool? ?? false,
      parentArticle: json['parent_article'] as Map<String, dynamic>?,
      variantAttributes: json['variant_attributes'] as String?,
      image: json['image'] as String?,
      imageUrl: json['image_url'] as String?,
      weight: json['weight']?.toString(),
      length: json['length']?.toString(),
      width: json['width']?.toString(),
      height: json['height']?.toString(),
      tags: json['tags'] as String?,
      notes: json['notes'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      statusDisplay: json['status_display'] as String? ?? 'Inactif',
      additionalBarcodes: (json['additional_barcodes'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [],
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [],
      priceHistory: (json['price_history'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [],
      variants: (json['variants'] as List<dynamic>?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList() ?? [],
      currentStock: json['current_stock']?.toString() ?? '0',
      availableStock: json['available_stock']?.toString() ?? '0',
      reservedStock: json['reserved_stock']?.toString() ?? '0',
      isLowStock: json['is_low_stock']?.toString() ?? 'false',
      marginPercent: json['margin_percent']?.toString() ?? '0',
      createdBy: json['created_by'] as String? ?? 'System',
      createdAt: json['created_at'] as String,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] as String,
    );
  }

  /// Convertit le Model en Entity
  ArticleDetailEntity toEntity() {
    return ArticleDetailEntity(
      id: id,
      name: name,
      description: description,
      code: code,
      articleType: ArticleType.fromString(articleType),
      barcode: barcode,
      internalReference: internalReference,
      supplierReference: supplierReference,
      category: category != null
          ? CategoryDetailEntity(
        id: category!['id'] as String,
        name: category!['name'] as String,
        description: category!['description'] as String? ?? '',
        code: category!['code'] as String,
        parentId: category!['parent'] as String?,
        parentName: category!['parent_name'] as String?,
        taxRate: (category!['tax_rate'] as num?)?.toDouble() ?? 0.0,
        color: category!['color'] as String? ?? '#000000',
        isActive: category!['is_active'] as bool? ?? true,
      )
          : null,
      brand: brand != null
          ? BrandDetailEntity(
        id: brand!['id'] as String,
        name: brand!['name'] as String,
        description: brand!['description'] as String? ?? '',
        logoUrl: brand!['logo_url'] as String?,
        website: brand!['website'] as String?,
        isActive: brand!['is_active'] as bool? ?? true,
      )
          : null,
      unitOfMeasure: unitOfMeasure != null
          ? UnitOfMeasureDetailEntity(
        id: unitOfMeasure!['id'] as String,
        name: unitOfMeasure!['name'] as String,
        symbol: unitOfMeasure!['symbol'] as String,
        isDecimal: unitOfMeasure!['is_decimal'] as bool? ?? false,
        isActive: unitOfMeasure!['is_active'] as bool? ?? true,
      )
          : null,
      mainSupplier: mainSupplier != null
          ? SupplierSimpleEntity(
        id: mainSupplier!['id'] as String,
        name: mainSupplier!['name'] as String,
        contactPerson: mainSupplier!['contact_person'] as String?,
        phone: mainSupplier!['phone'] as String?,
        email: mainSupplier!['email'] as String?,
        isActive: mainSupplier!['is_active'] as bool? ?? true,
      )
          : null,
      purchasePrice: double.tryParse(purchasePrice) ?? 0.0,
      sellingPrice: double.tryParse(sellingPrice) ?? 0.0,
      manageStock: manageStock,
      minStockLevel: minStockLevel,
      maxStockLevel: maxStockLevel,
      requiresLotTracking: requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate,
      isSellable: isSellable,
      isPurchasable: isPurchasable,
      allowNegativeStock: allowNegativeStock,
      parentArticle: parentArticle != null
          ? ArticleSimpleEntity(
        id: parentArticle!['id'] as String,
        name: parentArticle!['name'] as String,
        code: parentArticle!['code'] as String,
        imageUrl: parentArticle!['image_url'] as String?,
        sellingPrice:
        double.tryParse(parentArticle!['selling_price']?.toString() ?? '0') ?? 0.0,
        currentStock:
        double.tryParse(parentArticle!['current_stock']?.toString() ?? '0') ?? 0.0,
        isActive: parentArticle!['is_active'] as bool? ?? true,
      )
          : null,
      variantAttributes: variantAttributes,
      image: image,
      imageUrl: imageUrl,
      weight: double.tryParse(weight ?? '0'),
      length: double.tryParse(length ?? '0'),
      width: double.tryParse(width ?? '0'),
      height: double.tryParse(height ?? '0'),
      tags: tags,
      notes: notes,
      isActive: isActive,
      statusDisplay: statusDisplay,
      additionalBarcodes: additionalBarcodes
          .map((json) => AdditionalBarcodeEntity(
        id: json['id'] as String,
        barcode: json['barcode'] as String,
        barcodeType: json['barcode_type'] as String,
        isPrimary: json['is_primary'] as bool? ?? false,
      ))
          .toList(),
      images: images
          .map((json) => ArticleImageEntity(
        id: json['id'] as String,
        imageUrl: json['image_url'] as String,
        altText: json['alt_text'] as String?,
        caption: json['caption'] as String?,
        isPrimary: json['is_primary'] as bool? ?? false,
        order: json['order'] as int? ?? 0,
      ))
          .toList(),
      priceHistory: priceHistory
          .map((json) => PriceHistoryEntity(
        id: json['id'] as String,
        oldPurchasePrice:
        double.tryParse(json['old_purchase_price']?.toString() ?? '0') ?? 0.0,
        oldSellingPrice:
        double.tryParse(json['old_selling_price']?.toString() ?? '0') ?? 0.0,
        newPurchasePrice:
        double.tryParse(json['new_purchase_price']?.toString() ?? '0') ?? 0.0,
        newSellingPrice:
        double.tryParse(json['new_selling_price']?.toString() ?? '0') ?? 0.0,
        reason: json['reason'] as String,
        notes: json['notes'] as String?,
        effectiveDate: DateTime.parse(json['effective_date'] as String),
        createdBy: json['created_by'] as String? ?? 'System',
      ))
          .toList(),
      variants: variants
          .map((json) => ArticleSimpleEntity(
        id: json['id'] as String,
        name: json['name'] as String,
        code: json['code'] as String,
        imageUrl: json['image_url'] as String?,
        sellingPrice:
        double.tryParse(json['selling_price']?.toString() ?? '0') ?? 0.0,
        currentStock:
        double.tryParse(json['current_stock']?.toString() ?? '0') ?? 0.0,
        isActive: json['is_active'] as bool? ?? true,
      ))
          .toList(),
      currentStock: double.tryParse(currentStock) ?? 0.0,
      availableStock: double.tryParse(availableStock) ?? 0.0,
      reservedStock: double.tryParse(reservedStock) ?? 0.0,
      isLowStock: isLowStock == 'true' || isLowStock == '1',
      marginPercent: double.tryParse(marginPercent) ?? 0.0,
      createdBy: createdBy,
      createdAt: DateTime.parse(createdAt),
      updatedBy: updatedBy,
      updatedAt: DateTime.parse(updatedAt),
    );
  }
}