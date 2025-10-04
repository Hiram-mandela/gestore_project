// ========================================
// lib/features/inventory/domain/usecases/update_article_usecase.dart
// Use Case pour mettre à jour un article
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/article_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour la mise à jour d'un article
class UpdateArticleParams {
  final String id; // ID de l'article à modifier
  final String name;
  final String code;
  final String? description;
  final String articleType;
  final String? barcode;
  final String? internalReference;
  final String? supplierReference;
  final String categoryId;
  final String? brandId;
  final String unitOfMeasureId;
  final String? mainSupplierId;
  final double purchasePrice;
  final double sellingPrice;
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;
  final String? imagePath; // Nouvelle image (optionnel)
  final double? weight;
  final double? length;
  final double? width;
  final double? height;
  final String? tags;
  final String? notes;
  final bool isActive;

  const UpdateArticleParams({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    required this.articleType,
    this.barcode,
    this.internalReference,
    this.supplierReference,
    required this.categoryId,
    this.brandId,
    required this.unitOfMeasureId,
    this.mainSupplierId,
    required this.purchasePrice,
    required this.sellingPrice,
    this.manageStock = true,
    this.minStockLevel = 0,
    this.maxStockLevel = 0,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.isSellable = true,
    this.isPurchasable = true,
    this.allowNegativeStock = false,
    this.imagePath,
    this.weight,
    this.length,
    this.width,
    this.height,
    this.tags,
    this.notes,
    this.isActive = true,
  });

  /// Validation des données
  String? validate() {
    if (id.trim().isEmpty) {
      return 'ID de l\'article requis';
    }
    if (name.trim().isEmpty) {
      return 'Le nom est requis';
    }
    if (name.length < 3) {
      return 'Le nom doit contenir au moins 3 caractères';
    }
    if (code.trim().isEmpty) {
      return 'Le code est requis';
    }
    if (code.length < 2) {
      return 'Le code doit contenir au moins 2 caractères';
    }
    if (categoryId.trim().isEmpty) {
      return 'La catégorie est requise';
    }
    if (unitOfMeasureId.trim().isEmpty) {
      return 'L\'unité de mesure est requise';
    }
    if (purchasePrice < 0) {
      return 'Le prix d\'achat ne peut pas être négatif';
    }
    if (sellingPrice < 0) {
      return 'Le prix de vente ne peut pas être négatif';
    }
    if (sellingPrice < purchasePrice) {
      return 'Le prix de vente doit être supérieur au prix d\'achat';
    }
    if (manageStock && minStockLevel < 0) {
      return 'Le stock minimum ne peut pas être négatif';
    }
    if (manageStock && maxStockLevel < 0) {
      return 'Le stock maximum ne peut pas être négatif';
    }
    if (manageStock && maxStockLevel > 0 && minStockLevel > maxStockLevel) {
      return 'Le stock minimum ne peut pas être supérieur au stock maximum';
    }
    return null;
  }

  /// Convertit en Map pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name.trim(),
      'code': code.trim().toUpperCase(),
      'description': description?.trim() ?? '',
      'article_type': articleType,
      'barcode': barcode?.trim(),
      'internal_reference': internalReference?.trim(),
      'supplier_reference': supplierReference?.trim(),
      'category': categoryId,
      'brand': brandId,
      'unit_of_measure': unitOfMeasureId,
      'main_supplier': mainSupplierId,
      'purchase_price': purchasePrice.toStringAsFixed(2),
      'selling_price': sellingPrice.toStringAsFixed(2),
      'manage_stock': manageStock,
      'min_stock_level': minStockLevel,
      'max_stock_level': maxStockLevel,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'is_sellable': isSellable,
      'is_purchasable': isPurchasable,
      'allow_negative_stock': allowNegativeStock,
      'weight': weight,
      'length': length,
      'width': width,
      'height': height,
      'tags': tags?.trim(),
      'notes': notes?.trim(),
      'is_active': isActive,
    };
  }
}

/// Use Case pour mettre à jour un article
@lazySingleton
class UpdateArticleUseCase implements UseCase<ArticleEntity, UpdateArticleParams> {
  final InventoryRepository repository;

  UpdateArticleUseCase({required this.repository});

  @override
  Future<(ArticleEntity?, String?)> call(UpdateArticleParams params) async {
    // Validation des paramètres
    final validationError = params.validate();
    if (validationError != null) {
      return (null, validationError);
    }

    // Mise à jour de l'article
    return await repository.updateArticle(params);
  }
}