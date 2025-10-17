// ========================================
// lib/features/inventory/presentation/providers/article_form_state.dart
// États pour le formulaire article (création/édition)
// VERSION ÉTENDUE - Support complet de l'API (40+ champs)
// ========================================

import 'package:equatable/equatable.dart';

import '../../domain/entities/article_detail_entity.dart';
//import '../../domain/entities/article_entity.dart';

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
  final String? articleId;

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
  final int currentStep; // 0 à 4 (5 étapes)
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

  /// Nombre total d'étapes
  int get totalSteps => 5;

  /// Vérifie si on est à la première étape
  bool get isFirstStep => currentStep == 0;

  /// Vérifie si on est à la dernière étape
  bool get isLastStep => currentStep == totalSteps - 1;

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
  final ArticleDetailEntity article;
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
  final ArticleFormData? formData;

  const ArticleFormError({
    required this.message,
    required this.mode,
    this.formData,
  });

  @override
  List<Object?> get props => [message, mode, formData];
}

// ==================== DATA CLASSES ====================

/// Données du formulaire article (VERSION ÉTENDUE)
/// Reflète TOUS les champs de l'API ArticleDetail
class ArticleFormData extends Equatable {
  // ==================== SECTION 1: INFORMATIONS DE BASE ====================
  final String name;
  final String description;
  final String shortDescription; // ⭐ NOUVEAU
  final String code;
  final String articleType;
  final String barcode;
  final String internalReference;
  final String supplierReference;
  final String tags;
  final String notes;

  // ==================== SECTION 2: CLASSIFICATION ====================
  final String categoryId;
  final String brandId;
  final String unitOfMeasureId;

  // ==================== SECTION 3: GESTION DE STOCK ====================
  final bool manageStock;
  final int minStockLevel;
  final int maxStockLevel;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final bool isSellable;
  final bool isPurchasable;
  final bool allowNegativeStock;

  // ==================== SECTION 4: PRIX ET FOURNISSEUR ====================
  final double purchasePrice;
  final double sellingPrice;
  final String mainSupplierId;

  // ==================== SECTION 5: MÉTADONNÉES AVANCÉES ====================
  // Dimensions
  final double weight;
  final double length;
  final double width;
  final double height;

  // Variantes
  final String? parentArticleId; // ⭐ NOUVEAU
  final String variantAttributes; // ⭐ NOUVEAU (JSON string)

  // Statut
  final bool isActive;

  // Image principale
  final String imagePath;

  // ==================== DONNÉES COMPLEXES (TABLEAUX) ====================
  final List<ArticleImageData> images; // ⭐ NOUVEAU
  final List<AdditionalBarcodeData> additionalBarcodes; // ⭐ NOUVEAU

  const ArticleFormData({
    // Section 1
    this.name = '',
    this.description = '',
    this.shortDescription = '',
    this.code = '',
    this.articleType = 'product',
    this.barcode = '',
    this.internalReference = '',
    this.supplierReference = '',
    this.tags = '',
    this.notes = '',

    // Section 2
    this.categoryId = '',
    this.brandId = '',
    this.unitOfMeasureId = '',

    // Section 3
    this.manageStock = true,
    this.minStockLevel = 0,
    this.maxStockLevel = 0,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.isSellable = true,
    this.isPurchasable = true,
    this.allowNegativeStock = false,

    // Section 4
    this.purchasePrice = 0.0,
    this.sellingPrice = 0.0,
    this.mainSupplierId = '',

    // Section 5
    this.weight = 0.0,
    this.length = 0.0,
    this.width = 0.0,
    this.height = 0.0,
    this.parentArticleId,
    this.variantAttributes = '',
    this.isActive = true,
    this.imagePath = '',

    // Tableaux
    this.images = const [],
    this.additionalBarcodes = const [],
  });

  /// Calcul de la marge en pourcentage
  double get marginPercent {
    if (purchasePrice <= 0 || sellingPrice <= 0) return 0.0;
    return ((sellingPrice - purchasePrice) / purchasePrice) * 100;
  }

  /// Vérifie si l'article a une image
  bool get hasImage => imagePath.isNotEmpty || images.isNotEmpty;

  /// Vérifie si l'article a des codes-barres additionnels
  bool get hasAdditionalBarcodes => additionalBarcodes.isNotEmpty;

  /// Vérifie si l'article est une variante
  bool get isVariant => parentArticleId != null && parentArticleId!.isNotEmpty;

  /// Copie avec modifications
  ArticleFormData copyWith({
    // Section 1
    String? name,
    String? description,
    String? shortDescription,
    String? code,
    String? articleType,
    String? barcode,
    String? internalReference,
    String? supplierReference,
    String? tags,
    String? notes,

    // Section 2
    String? categoryId,
    String? brandId,
    String? unitOfMeasureId,

    // Section 3
    bool? manageStock,
    int? minStockLevel,
    int? maxStockLevel,
    bool? requiresLotTracking,
    bool? requiresExpiryDate,
    bool? isSellable,
    bool? isPurchasable,
    bool? allowNegativeStock,

    // Section 4
    double? purchasePrice,
    double? sellingPrice,
    String? mainSupplierId,

    // Section 5
    double? weight,
    double? length,
    double? width,
    double? height,
    String? parentArticleId,
    String? variantAttributes,
    bool? isActive,
    String? imagePath,

    // Tableaux
    List<ArticleImageData>? images,
    List<AdditionalBarcodeData>? additionalBarcodes,
  }) {
    return ArticleFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      shortDescription: shortDescription ?? this.shortDescription,
      code: code ?? this.code,
      articleType: articleType ?? this.articleType,
      barcode: barcode ?? this.barcode,
      internalReference: internalReference ?? this.internalReference,
      supplierReference: supplierReference ?? this.supplierReference,
      tags: tags ?? this.tags,
      notes: notes ?? this.notes,
      categoryId: categoryId ?? this.categoryId,
      brandId: brandId ?? this.brandId,
      unitOfMeasureId: unitOfMeasureId ?? this.unitOfMeasureId,
      manageStock: manageStock ?? this.manageStock,
      minStockLevel: minStockLevel ?? this.minStockLevel,
      maxStockLevel: maxStockLevel ?? this.maxStockLevel,
      requiresLotTracking: requiresLotTracking ?? this.requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      isSellable: isSellable ?? this.isSellable,
      isPurchasable: isPurchasable ?? this.isPurchasable,
      allowNegativeStock: allowNegativeStock ?? this.allowNegativeStock,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      mainSupplierId: mainSupplierId ?? this.mainSupplierId,
      weight: weight ?? this.weight,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      parentArticleId: parentArticleId ?? this.parentArticleId,
      variantAttributes: variantAttributes ?? this.variantAttributes,
      isActive: isActive ?? this.isActive,
      imagePath: imagePath ?? this.imagePath,
      images: images ?? this.images,
      additionalBarcodes: additionalBarcodes ?? this.additionalBarcodes,
    );
  }

  @override
  List<Object?> get props => [
    name, description, shortDescription, code, articleType, barcode,
    internalReference, supplierReference, tags, notes,
    categoryId, brandId, unitOfMeasureId,
    manageStock, minStockLevel, maxStockLevel,
    requiresLotTracking, requiresExpiryDate, isSellable,
    isPurchasable, allowNegativeStock,
    purchasePrice, sellingPrice, mainSupplierId,
    weight, length, width, height,
    parentArticleId, variantAttributes, isActive, imagePath,
    images, additionalBarcodes,
  ];
}

// ==================== CLASSES AUXILIAIRES ====================

/// Données pour une image d'article
class ArticleImageData extends Equatable {
  final String? id; // null si nouvelle image
  final String imagePath; // Path local ou URL
  final String altText;
  final String caption;
  final bool isPrimary;
  final int order;

  const ArticleImageData({
    this.id,
    required this.imagePath,
    this.altText = '',
    this.caption = '',
    this.isPrimary = false,
    this.order = 0,
  });

  ArticleImageData copyWith({
    String? id,
    String? imagePath,
    String? altText,
    String? caption,
    bool? isPrimary,
    int? order,
  }) {
    return ArticleImageData(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      altText: altText ?? this.altText,
      caption: caption ?? this.caption,
      isPrimary: isPrimary ?? this.isPrimary,
      order: order ?? this.order,
    );
  }

  @override
  List<Object?> get props => [id, imagePath, altText, caption, isPrimary, order];
}

/// Données pour un code-barres additionnel
class AdditionalBarcodeData extends Equatable {
  final String? id; // null si nouveau
  final String barcode;
  final String barcodeType; // EAN13, UPC, CODE128, etc.
  final bool isPrimary;

  const AdditionalBarcodeData({
    this.id,
    required this.barcode,
    this.barcodeType = 'EAN13',
    this.isPrimary = false,
  });

  AdditionalBarcodeData copyWith({
    String? id,
    String? barcode,
    String? barcodeType,
    bool? isPrimary,
  }) {
    return AdditionalBarcodeData(
      id: id ?? this.id,
      barcode: barcode ?? this.barcode,
      barcodeType: barcodeType ?? this.barcodeType,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }

  @override
  List<Object?> get props => [id, barcode, barcodeType, isPrimary];
}