// ========================================
// lib/features/inventory/domain/usecases/update_article_usecase.dart
// Use case pour mettre à jour un article
// VERSION 2.1 - CORRECTION: Noms de champs backend cohérents
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/article_detail_entity.dart';
//import '../entities/article_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour la mise à jour d'un article
class UpdateArticleParams {
  final String id;

  // Mêmes champs que CreateArticleParams
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
  final String? categoryId;
  final String? brandId;
  final String? unitOfMeasureId;
  final String? mainSupplierId;
  final bool manageStock;
  final int? minStockLevel;
  final int? maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;
  final double purchasePrice;
  final double sellingPrice;
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String? parentArticleId;
  final String? variantAttributes;
  final bool isActive;

  // ⭐ Images
  final String? primaryImagePath;
  final List<String>? secondaryImagePaths; // ⭐ NOUVEAU

  final List<Map<String, dynamic>>? images;
  final List<Map<String, dynamic>>? additionalBarcodes;

  UpdateArticleParams({
    required this.id,
    required this.name,
    required this.code,
    required this.description,
    required this.shortDescription,
    required this.articleType,
    this.barcode,
    this.internalReference,
    this.supplierReference,
    this.tags,
    this.notes,
    this.categoryId,
    this.brandId,
    this.unitOfMeasureId,
    this.mainSupplierId,
    this.manageStock = true,
    this.minStockLevel,
    this.maxStockLevel,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.isSellable = true,
    this.isPurchasable = true,
    this.allowNegativeStock = false,
    required this.purchasePrice,
    required this.sellingPrice,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.parentArticleId,
    this.variantAttributes,
    this.primaryImagePath,
    this.secondaryImagePaths, // ⭐ NOUVEAU
    this.isActive = true,
    this.images,
    this.additionalBarcodes,
  });

  String? validate() {
    if (id.trim().isEmpty) return 'L\'ID est requis';
    if (name.trim().isEmpty) return 'Le nom est requis';
    if (code.trim().isEmpty) return 'Le code est requis';
    if (articleType.isEmpty) return 'Le type d\'article est requis';
    if (categoryId == null || categoryId!.isEmpty) return 'La catégorie est requise';
    if (unitOfMeasureId == null || unitOfMeasureId!.isEmpty) return 'L\'unité de mesure est requise';
    if (purchasePrice < 0) return 'Le prix d\'achat ne peut pas être négatif';
    if (sellingPrice < 0) return 'Le prix de vente ne peut pas être négatif';
    return null;
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      'name': name,
      'code': code,
      'article_type': articleType,
      'category_id': categoryId,
      'unit_of_measure_id': unitOfMeasureId,
      'purchase_price': purchasePrice.toStringAsFixed(2),
      'selling_price': sellingPrice.toStringAsFixed(2),
      'manage_stock': manageStock,
      'min_stock_level': minStockLevel ?? 0,
      'max_stock_level': maxStockLevel ?? 0,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'is_sellable': isSellable,
      'is_purchasable': isPurchasable,
      'allow_negative_stock': allowNegativeStock,
      'is_active': isActive,
    };

    if (description.isNotEmpty) data['description'] = description;
    if (shortDescription.isNotEmpty) data['short_description'] = shortDescription;
    if (barcode != null && barcode!.isNotEmpty) data['barcode'] = barcode;
    if (internalReference != null && internalReference!.isNotEmpty) data['internal_reference'] = internalReference;
    if (supplierReference != null && supplierReference!.isNotEmpty) data['supplier_reference'] = supplierReference;
    if (tags != null && tags!.isNotEmpty) data['tags'] = tags;
    if (notes != null && notes!.isNotEmpty) data['notes'] = notes;
    if (brandId != null && brandId!.isNotEmpty) data['brand_id'] = brandId;
    if (mainSupplierId != null && mainSupplierId!.isNotEmpty) data['main_supplier_id'] = mainSupplierId;
    if (weight != null && weight! > 0) data['weight'] = weight!.toStringAsFixed(2);
    if (length != null && length! > 0) data['length'] = length!.toStringAsFixed(1);
    if (width != null && width! > 0) data['width'] = width!.toStringAsFixed(1);
    if (height != null && height! > 0) data['height'] = height!.toStringAsFixed(1);
    if (parentArticleId != null && parentArticleId!.isNotEmpty) data['parent_article_id'] = parentArticleId;
    if (variantAttributes != null && variantAttributes!.isNotEmpty) data['variant_attributes'] = variantAttributes;

    if (images != null && images!.isNotEmpty) data['images_data'] = images;
    if (additionalBarcodes != null && additionalBarcodes!.isNotEmpty) data['additional_barcodes_data'] = additionalBarcodes;

    return data;
  }
}

/// Use case pour mettre à jour un article
@lazySingleton
class UpdateArticleUseCase implements UseCase<ArticleDetailEntity, UpdateArticleParams> {
  final InventoryRepository repository;

  UpdateArticleUseCase({required this.repository});

  @override
  Future<(ArticleDetailEntity?, String?)> call(UpdateArticleParams params) async {
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // ⭐ Appel repository avec les 4 paramètres incluant les images secondaires
    return await repository.updateArticle(
      params.id,
      params.toJson(),
      params.primaryImagePath,
      params.secondaryImagePaths, // ✅ Nouveau paramètre
    );
  }
}