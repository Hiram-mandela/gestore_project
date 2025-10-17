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

/// Paramètres pour la mise à jour d'un article (VERSION 2.1 - 40+ champs)
class UpdateArticleParams {
  // ==================== ID ====================
  final String id; // Requis pour l'update

  // ==================== SECTION 1 : INFORMATIONS DE BASE ====================
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
  final String? categoryId;
  final String? brandId;
  final String? unitOfMeasureId;
  final String? mainSupplierId;

  // ==================== SECTION 3 : GESTION DE STOCK ====================
  final bool manageStock;
  final int? minStockLevel;
  final int? maxStockLevel;
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
  final String? parentArticleId;
  final String? variantAttributes;
  final String? imagePath;
  final bool isActive;

  // ==================== DONNÉES COMPLEXES ====================
  final List<Map<String, dynamic>>? images;
  final List<Map<String, dynamic>>? additionalBarcodes;

  const UpdateArticleParams({
    // ID requis
    required this.id,

    // Section 1
    required this.name,
    this.description = '',
    this.shortDescription = '',
    required this.code,
    this.articleType = 'product',
    this.barcode,
    this.internalReference,
    this.supplierReference,
    this.tags,
    this.notes,

    // Section 2
    this.categoryId,
    this.brandId,
    this.unitOfMeasureId,
    this.mainSupplierId,

    // Section 3
    this.manageStock = true,
    this.minStockLevel,
    this.maxStockLevel,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.isSellable = true,
    this.isPurchasable = true,
    this.allowNegativeStock = false,

    // Section 4
    this.purchasePrice = 0.0,
    this.sellingPrice = 0.0,

    // Section 5
    this.weight,
    this.length,
    this.width,
    this.height,
    this.parentArticleId,
    this.variantAttributes,
    this.imagePath,
    this.isActive = true,

    // Données complexes
    this.images,
    this.additionalBarcodes,
  });

  /// Validation des paramètres
  String? validate() {
    if (id.trim().isEmpty) {
      return 'L\'ID est requis pour la mise à jour';
    }
    if (name.trim().isEmpty) {
      return 'Le nom est requis';
    }
    if (name.trim().length < 2) {
      return 'Le nom doit contenir au moins 2 caractères';
    }
    if (code.trim().isEmpty) {
      return 'Le code est requis';
    }
    if (code.trim().length < 2) {
      return 'Le code doit contenir au moins 2 caractères';
    }
    if (purchasePrice < 0) {
      return 'Le prix d\'achat ne peut pas être négatif';
    }
    if (sellingPrice < 0) {
      return 'Le prix de vente ne peut pas être négatif';
    }
    if (minStockLevel != null && minStockLevel! < 0) {
      return 'Le stock minimum ne peut pas être négatif';
    }
    if (maxStockLevel != null && maxStockLevel! < 0) {
      return 'Le stock maximum ne peut pas être négatif';
    }
    if (minStockLevel != null &&
        maxStockLevel != null &&
        minStockLevel! > maxStockLevel!) {
      return 'Le stock minimum ne peut pas être supérieur au stock maximum';
    }
    return null;
  }

  /// ✅ CORRECTION: Convertit les paramètres en Map pour l'API
  /// Utilise les noms de champs corrects attendus par le backend
  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{
      // Section 1
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'article_type': articleType,
    };

    // Ajouter les champs optionnels
    if (description.isNotEmpty) data['description'] = description.trim();
    if (shortDescription.isNotEmpty) data['short_description'] = shortDescription.trim();
    if (barcode != null && barcode!.isNotEmpty) data['barcode'] = barcode;
    if (internalReference != null && internalReference!.isNotEmpty) {
      data['internal_reference'] = internalReference;
    }
    if (supplierReference != null && supplierReference!.isNotEmpty) {
      data['supplier_reference'] = supplierReference;
    }
    if (tags != null && tags!.isNotEmpty) data['tags'] = tags;
    if (notes != null && notes!.isNotEmpty) data['notes'] = notes;

    // ⭐ CORRECTION CRITIQUE: Section 2 - Relations avec suffixe _id
    // Le backend attend category_id, brand_id, unit_of_measure_id, main_supplier_id
    if (categoryId != null && categoryId!.isNotEmpty) {
      data['category_id'] = categoryId; // ✅ CORRIGÉ: category -> category_id
    }
    if (brandId != null && brandId!.isNotEmpty) {
      data['brand_id'] = brandId; // ✅ CORRIGÉ: brand -> brand_id
    }
    if (unitOfMeasureId != null && unitOfMeasureId!.isNotEmpty) {
      data['unit_of_measure_id'] = unitOfMeasureId; // ✅ CORRIGÉ: unit_of_measure -> unit_of_measure_id
    }
    if (mainSupplierId != null && mainSupplierId!.isNotEmpty) {
      data['main_supplier_id'] = mainSupplierId; // ✅ CORRIGÉ: main_supplier -> main_supplier_id
    }

    // Section 3 - Gestion de stock
    data['manage_stock'] = manageStock;
    if (minStockLevel != null) data['min_stock_level'] = minStockLevel;
    if (maxStockLevel != null) data['max_stock_level'] = maxStockLevel;
    data['requires_lot_tracking'] = requiresLotTracking;
    data['requires_expiry_date'] = requiresExpiryDate;
    data['is_sellable'] = isSellable;
    data['is_purchasable'] = isPurchasable;
    data['allow_negative_stock'] = allowNegativeStock;

    // Section 4 - Prix
    data['purchase_price'] = purchasePrice.toStringAsFixed(2);
    data['selling_price'] = sellingPrice.toStringAsFixed(2);

    // Section 5 - Métadonnées
    if (weight != null && weight! > 0) data['weight'] = weight!.toStringAsFixed(2);
    if (length != null && length! > 0) data['length'] = length!.toStringAsFixed(1);
    if (width != null && width! > 0) data['width'] = width!.toStringAsFixed(1);
    if (height != null && height! > 0) data['height'] = height!.toStringAsFixed(1);
    if (parentArticleId != null && parentArticleId!.isNotEmpty) {
      data['parent_article_id'] = parentArticleId; // ✅ Cohérence avec suffixe _id
    }
    if (variantAttributes != null && variantAttributes!.isNotEmpty) {
      data['variant_attributes'] = variantAttributes;
    }
    data['is_active'] = isActive;

    // ⭐ CORRECTION: Données complexes avec les bons noms de champs backend
    // Le backend attend 'images_data' et 'additional_barcodes_data' (write-only)
    if (images != null && images!.isNotEmpty) {
      data['images_data'] = images; // ✅ CORRIGÉ: images -> images_data
    }
    if (additionalBarcodes != null && additionalBarcodes!.isNotEmpty) {
      data['additional_barcodes_data'] = additionalBarcodes; // ✅ CORRIGÉ: additional_barcodes -> additional_barcodes_data
    }

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
    // Validation
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Appel repository avec ID, params.toJson() et params.imagePath
    return await repository.updateArticle(
      params.id,
      params.toJson(),
      params.imagePath,
    );
  }
}