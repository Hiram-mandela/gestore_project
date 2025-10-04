// ========================================
// lib/features/inventory/presentation/providers/article_form_state.dart
// États pour le formulaire article (création/édition)
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/article_entity.dart';

/// Mode du formulaire
enum ArticleFormMode {
  create, // Création d'un nouvel article
  edit, // Édition d'un article existant
}

/// État de base pour le formulaire article
abstract class ArticleFormState extends Equatable {
  const ArticleFormState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ArticleFormInitial extends ArticleFormState {
  final ArticleFormMode mode;
  final String? articleId; // ID si mode édition

  const ArticleFormInitial({
    required this.mode,
    this.articleId,
  });

  @override
  List<Object?> get props => [mode, articleId];
}

/// État de chargement (pour mode édition)
class ArticleFormLoading extends ArticleFormState {
  final String articleId;

  const ArticleFormLoading({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

/// État prêt pour édition/saisie
class ArticleFormReady extends ArticleFormState {
  final ArticleFormMode mode;
  final String? articleId;
  final ArticleFormData formData;
  final int currentStep;
  final Map<String, String> errors;

  const ArticleFormReady({
    required this.mode,
    this.articleId,
    required this.formData,
    this.currentStep = 0,
    this.errors = const {},
  });

  /// Vérifie si le formulaire est valide
  bool get isValid => errors.isEmpty;

  /// Vérifie si on est en mode création
  bool get isCreateMode => mode == ArticleFormMode.create;

  /// Vérifie si on est en mode édition
  bool get isEditMode => mode == ArticleFormMode.edit;

  /// Copie l'état avec modifications
  ArticleFormReady copyWith({
    ArticleFormData? formData,
    int? currentStep,
    Map<String, String>? errors,
  }) {
    return ArticleFormReady(
      mode: mode,
      articleId: articleId,
      formData: formData ?? this.formData,
      currentStep: currentStep ?? this.currentStep,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [mode, articleId, formData, currentStep, errors];
}

/// État de soumission
class ArticleFormSubmitting extends ArticleFormState {
  final ArticleFormMode mode;
  final ArticleFormData formData;

  const ArticleFormSubmitting({
    required this.mode,
    required this.formData,
  });

  @override
  List<Object?> get props => [mode, formData];
}

/// État de succès
class ArticleFormSuccess extends ArticleFormState {
  final ArticleEntity article;
  final String message;

  const ArticleFormSuccess({
    required this.article,
    required this.message,
  });

  @override
  List<Object?> get props => [article, message];
}

/// État d'erreur
class ArticleFormError extends ArticleFormState {
  final String message;
  final ArticleFormMode mode;
  final ArticleFormData? formData; // Pour revenir à l'édition

  const ArticleFormError({
    required this.message,
    required this.mode,
    this.formData,
  });

  @override
  List<Object?> get props => [message, mode, formData];
}

// ==================== DATA CLASS ====================

/// Données du formulaire
class ArticleFormData extends Equatable {
  // Étape 1 : Informations de base
  final String name;
  final String code;
  final String description;
  final String articleType;
  final String barcode;
  final String internalReference;
  final String supplierReference;
  final String categoryId;
  final String brandId;
  final String unitOfMeasureId;
  final String mainSupplierId;

  // Étape 2 : Prix et stock
  final double purchasePrice;
  final double sellingPrice;
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;

  // Étape 3 : Options avancées
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;
  final String imagePath;
  final double weight;
  final double length;
  final double width;
  final double height;
  final String tags;
  final String notes;
  final bool isActive;

  const ArticleFormData({
    this.name = '',
    this.code = '',
    this.description = '',
    this.articleType = 'product',
    this.barcode = '',
    this.internalReference = '',
    this.supplierReference = '',
    this.categoryId = '',
    this.brandId = '',
    this.unitOfMeasureId = '',
    this.mainSupplierId = '',
    this.purchasePrice = 0.0,
    this.sellingPrice = 0.0,
    this.manageStock = true,
    this.minStockLevel = 0,
    this.maxStockLevel = 0,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.isSellable = true,
    this.isPurchasable = true,
    this.allowNegativeStock = false,
    this.imagePath = '',
    this.weight = 0.0,
    this.length = 0.0,
    this.width = 0.0,
    this.height = 0.0,
    this.tags = '',
    this.notes = '',
    this.isActive = true,
  });

  /// Copie avec modifications
  ArticleFormData copyWith({
    String? name,
    String? code,
    String? description,
    String? articleType,
    String? barcode,
    String? internalReference,
    String? supplierReference,
    String? categoryId,
    String? brandId,
    String? unitOfMeasureId,
    String? mainSupplierId,
    double? purchasePrice,
    double? sellingPrice,
    bool? manageStock,
    int? minStockLevel,
    int? maxStockLevel,
    bool? requiresLotTracking,
    bool? requiresExpiryDate,
    bool? isSellable,
    bool? isPurchasable,
    bool? allowNegativeStock,
    String? imagePath,
    double? weight,
    double? length,
    double? width,
    double? height,
    String? tags,
    String? notes,
    bool? isActive,
  }) {
    return ArticleFormData(
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      articleType: articleType ?? this.articleType,
      barcode: barcode ?? this.barcode,
      internalReference: internalReference ?? this.internalReference,
      supplierReference: supplierReference ?? this.supplierReference,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      mainSupplierId: mainSupplierId ?? this.mainSupplierId,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      manageStock: manageStock ?? this.manageStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      requiresLotTracking: requiresLotTracking ?? this.requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      isSellable: isSellable ?? this.isSellable,
      isPurchasable: isPurchasable ?? this.isPurchasable,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      imagePath: imagePath ?? this.imagePath,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  List<Object?> get props => [
    name,
    code,
    description,
    articleType,
    categoryId,
    brandId,
    unitOfMeasureId,
    purchasePrice,
    sellingPrice,
    manageStock,
    minStockLevel,
    maxStockLevel,
    imagePath,
    isActive,
  ];
}