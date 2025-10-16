// ========================================
// lib/features/inventory/presentation/providers/article_form_provider.dart
// Provider Riverpod pour le formulaire article
// VERSION 3.2 FINALE - Utilisation correcte de CreateArticleParams et UpdateArticleParams
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:dio/dio.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/create_article_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/get_article_detail_usecase.dart';
import 'article_form_state.dart';

/// Provider pour le formulaire article avec cache
final articleFormProvider = StateNotifierProvider.family.autoDispose<
    ArticleFormNotifier,
    ArticleFormState,
    (ArticleFormMode, String?)>((ref, params) {
  final mode = params.$1;
  final articleId = params.$2;

  return ArticleFormNotifier(
    mode: mode,
    articleId: articleId,
    createArticleUseCase: getIt<CreateArticleUseCase>(),
    updateArticleUseCase: getIt<UpdateArticleUseCase>(),
    deleteArticleUseCase: getIt<DeleteArticleUseCase>(),
    getArticleDetailUseCase: getIt<GetArticleDetailUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer le formulaire article
class ArticleFormNotifier extends StateNotifier<ArticleFormState> {
  final ArticleFormMode mode;
  final String? articleId;
  final CreateArticleUseCase createArticleUseCase;
  final UpdateArticleUseCase updateArticleUseCase;
  final DeleteArticleUseCase deleteArticleUseCase;
  final GetArticleDetailUseCase getArticleDetailUseCase;
  final Logger logger;

  ArticleFormNotifier({
    required this.mode,
    this.articleId,
    required this.createArticleUseCase,
    required this.updateArticleUseCase,
    required this.deleteArticleUseCase,
    required this.getArticleDetailUseCase,
    required this.logger,
  }) : super(ArticleFormInitial(mode: mode, articleId: articleId)) {
    _initialize();
  }

  /// Initialise le formulaire
  Future<void> _initialize() async {
    if (mode == ArticleFormMode.edit && articleId != null) {
      await _loadArticleForEdit();
    } else {
      state = ArticleFormReady(
        mode: mode,
        formData: const ArticleFormData(),
      );
      logger.d('📝 Formulaire prêt pour création');
    }
  }

  /// Charge l'article pour édition
  Future<void> _loadArticleForEdit() async {
    try {
      logger.d('📝 Chargement article: $articleId');
      state = ArticleFormLoading(articleId: articleId!);

      final params = GetArticleDetailParams(articleId: articleId!);
      final result = await getArticleDetailUseCase(params);

      final error = result.$2;
      final article = result.$1;

      if (error != null || article == null) {
        logger.e('❌ Erreur: $error');
        state = ArticleFormError(message: error ?? 'Erreur inconnue', mode: mode);
        return;
      }

      // Conversion des images
      final images = article.images
          .map((img) => ArticleImageData(
        imagePath: img.imageUrl,
        caption: img.caption,
        altText: img.altText,
        order: img.order,
        isPrimary: img.isPrimary,
      ))
          .toList();

      // ✅ Conversion correcte des codes-barres additionnels
      final additionalBarcodes = article.additionalBarcodes
          .map((barcode) => AdditionalBarcodeData(
        barcode: barcode.barcode,
        barcodeType: barcode.barcodeType.value, // ✅ enum -> String
        isPrimary: barcode.isPrimary,
      ))
          .toList();

      final formData = ArticleFormData(
        name: article.name,
        code: article.code,
        description: article.description ?? '',
        shortDescription: article.shortDescription ?? '',
        articleType: article.articleType.value, // ✅ enum -> String
        barcode: article.barcode ?? '',
        internalReference: article.internalReference ?? '',
        supplierReference: article.supplierReference ?? '',
        tags: article.tags ?? '',
        notes: article.notes ?? '',
        categoryId: article.category?.id ?? '',
        brandId: article.brand?.id ?? '',
        unitOfMeasureId: article.unitOfMeasure?.id ?? '',
        manageStock: article.manageStock,
        minStockLevel: article.minStockLevel,
        maxStockLevel: article.maxStockLevel,
        requiresLotTracking: article.requiresLotTracking,
        requiresExpiryDate: article.requiresExpiryDate,
        isSellable: article.isSellable,
        isPurchasable: article.isPurchasable,
        allowNegativeStock: article.allowNegativeStock,
        purchasePrice: article.purchasePrice,
        sellingPrice: article.sellingPrice,
        mainSupplierId: article.mainSupplier?.id ?? '',
        weight: article.weight ?? 0.0,
        length: article.length ?? 0.0,
        width: article.width ?? 0.0,
        height: article.height ?? 0.0,
        parentArticleId: article.parentArticle?.id,
        variantAttributes: article.variantAttributes ?? '',
        isActive: article.isActive,
        imagePath: article.imageUrl ?? '',
        images: images,
        additionalBarcodes: additionalBarcodes,
      );

      state = ArticleFormReady(mode: mode, articleId: articleId, formData: formData);
      logger.i('✅ Article chargé: ${article.name}');
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = ArticleFormError(message: 'Erreur: $e', mode: mode);
    }
  }

  // ==================== GESTION DES CHAMPS ====================

  /// Met à jour un champ avec validation inline
  void updateField(String field, dynamic value) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    final Map<String, String> newErrors = Map.from(currentState.errors);
    final fieldError = _validateField(field, value);

    if (fieldError != null) {
      newErrors[field] = fieldError;
    } else {
      newErrors.remove(field);
    }

    ArticleFormData updatedData;
    switch (field) {
      case 'name':
        updatedData = currentState.formData.copyWith(name: value as String);
        break;
      case 'code':
        updatedData = currentState.formData.copyWith(code: value as String);
        break;
      case 'description':
        updatedData = currentState.formData.copyWith(description: value as String);
        break;
      case 'shortDescription':
        updatedData = currentState.formData.copyWith(shortDescription: value as String);
        break;
      case 'articleType':
        updatedData = currentState.formData.copyWith(articleType: value as String);
        break;
      case 'barcode':
        updatedData = currentState.formData.copyWith(barcode: value as String);
        break;
      case 'internalReference':
        updatedData = currentState.formData.copyWith(internalReference: value as String);
        break;
      case 'supplierReference':
        updatedData = currentState.formData.copyWith(supplierReference: value as String);
        break;
      case 'tags':
        updatedData = currentState.formData.copyWith(tags: value as String);
        break;
      case 'notes':
        updatedData = currentState.formData.copyWith(notes: value as String);
        break;
      case 'categoryId':
        updatedData = currentState.formData.copyWith(categoryId: value as String);
        break;
      case 'brandId':
        updatedData = currentState.formData.copyWith(brandId: value as String);
        break;
      case 'unitOfMeasureId':
        updatedData = currentState.formData.copyWith(unitOfMeasureId: value as String);
        break;
      case 'manageStock':
        updatedData = currentState.formData.copyWith(manageStock: value as bool);
        break;
      case 'minStockLevel':
        updatedData = currentState.formData.copyWith(minStockLevel: value as int);
        break;
      case 'maxStockLevel':
        updatedData = currentState.formData.copyWith(maxStockLevel: value as int);
        break;
      case 'requiresLotTracking':
        updatedData = currentState.formData.copyWith(requiresLotTracking: value as bool);
        break;
      case 'requiresExpiryDate':
        updatedData = currentState.formData.copyWith(requiresExpiryDate: value as bool);
        break;
      case 'isSellable':
        updatedData = currentState.formData.copyWith(isSellable: value as bool);
        break;
      case 'isPurchasable':
        updatedData = currentState.formData.copyWith(isPurchasable: value as bool);
        break;
      case 'allowNegativeStock':
        updatedData = currentState.formData.copyWith(allowNegativeStock: value as bool);
        break;
      case 'purchasePrice':
        updatedData = currentState.formData.copyWith(purchasePrice: value as double);
        break;
      case 'sellingPrice':
        updatedData = currentState.formData.copyWith(sellingPrice: value as double);
        break;
      case 'mainSupplierId':
        updatedData = currentState.formData.copyWith(mainSupplierId: value as String);
        break;
      case 'weight':
        updatedData = currentState.formData.copyWith(weight: value as double);
        break;
      case 'length':
        updatedData = currentState.formData.copyWith(length: value as double);
        break;
      case 'width':
        updatedData = currentState.formData.copyWith(width: value as double);
        break;
      case 'height':
        updatedData = currentState.formData.copyWith(height: value as double);
        break;
      case 'parentArticleId':
        updatedData = currentState.formData.copyWith(parentArticleId: value as String?);
        break;
      case 'variantAttributes':
        updatedData = currentState.formData.copyWith(variantAttributes: value as String);
        break;
      case 'isActive':
        updatedData = currentState.formData.copyWith(isActive: value as bool);
        break;
      case 'imagePath':
        updatedData = currentState.formData.copyWith(imagePath: value as String);
        break;
      case 'images':
        updatedData = currentState.formData.copyWith(images: value as List<ArticleImageData>);
        break;
      case 'additionalBarcodes':
        updatedData = currentState.formData.copyWith(additionalBarcodes: value as List<AdditionalBarcodeData>);
        break;
      default:
        updatedData = currentState.formData;
    }

    state = currentState.copyWith(formData: updatedData, errors: newErrors);
  }

  /// Valide un champ
  String? _validateField(String field, dynamic value) {
    switch (field) {
      case 'name':
        if (value == null || (value as String).trim().isEmpty) return 'Le nom est obligatoire';
        if (value.length < 3) return 'Minimum 3 caractères';
        break;
      case 'code':
        if (value == null || (value as String).trim().isEmpty) return 'Le code est obligatoire';
        if (value.length < 2) return 'Minimum 2 caractères';
        break;
      case 'shortDescription':
        if (value != null && (value as String).length > 150) return 'Maximum 150 caractères';
        break;
      case 'categoryId':
        if (value == null || (value as String).isEmpty) return 'La catégorie est obligatoire';
        break;
      case 'unitOfMeasureId':
        if (value == null || (value as String).isEmpty) return 'L\'unité est obligatoire';
        break;
      case 'sellingPrice':
      case 'purchasePrice':
        if (value != null && (value as double) < 0) return 'Le prix doit être positif';
        break;
      case 'minStockLevel':
      case 'maxStockLevel':
        if (value != null && (value as int) < 0) return 'La valeur doit être positive';
        break;
    }
    return null;
  }

  // ==================== NAVIGATION ====================

  void nextStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;
    if (!currentState.isLastStep) {
      state = currentState.copyWith(currentStep: currentState.currentStep + 1);
    }
  }

  void previousStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;
    if (!currentState.isFirstStep) {
      state = currentState.copyWith(currentStep: currentState.currentStep - 1);
    }
  }

  void goToStep(int step) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;
    if (step >= 0 && step < currentState.totalSteps) {
      state = currentState.copyWith(currentStep: step);
    }
  }

  // ==================== SOUMISSION ====================

  /// Soumet le formulaire
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    final errors = _validateForm(currentState.formData);
    if (errors.isNotEmpty) {
      state = currentState.copyWith(errors: errors);
      logger.w('⚠️ Erreurs: $errors');
      return;
    }

    try {
      logger.d('💾 Soumission...');
      state = ArticleFormSubmitting(mode: mode, formData: currentState.formData);

      if (mode == ArticleFormMode.create) {
        await _createArticle(currentState.formData);
      } else {
        await _updateArticle(currentState.formData);
      }
    } catch (e) {
      logger.e('❌ Erreur: $e');

      // ✅ Gestion erreurs API par champ
      if (e is DioException && e.response?.statusCode == 400) {
        final responseData = e.response?.data;
        if (responseData is Map<String, dynamic>) {
          final fieldErrors = _extractFieldErrors(responseData);
          if (fieldErrors.isNotEmpty) {
            state = ArticleFormReady(
              mode: mode,
              articleId: articleId,
              formData: currentState.formData,
              currentStep: currentState.currentStep,
              errors: fieldErrors,
            );
            return;
          }
        }
      }

      state = ArticleFormError(message: _getErrorMessage(e), mode: mode, formData: currentState.formData);
    }
  }

  /// Extrait les erreurs par champ de l'API
  Map<String, String> _extractFieldErrors(Map<String, dynamic> responseData) {
    final errors = <String, String>{};
    responseData.forEach((key, value) {
      if (value is List && value.isNotEmpty) {
        errors[key] = value.first.toString();
      } else if (value is String) {
        errors[key] = value;
      }
    });
    return errors;
  }

  /// Message d'erreur lisible
  String _getErrorMessage(dynamic error) {
    if (error is DioException) {
      switch (error.response?.statusCode) {
        case 400: return 'Données invalides';
        case 409: return 'Cet article existe déjà';
        case 404: return 'Article introuvable';
        case 500: return 'Erreur serveur';
      }
    }
    return 'Erreur: $error';
  }

  /// Valide le formulaire complet
  Map<String, String> _validateForm(ArticleFormData data) {
    final errors = <String, String>{};
    if (data.name.trim().isEmpty) errors['name'] = 'Le nom est obligatoire';
    if (data.code.trim().isEmpty) errors['code'] = 'Le code est obligatoire';
    if (data.categoryId.isEmpty) errors['categoryId'] = 'La catégorie est obligatoire';
    if (data.unitOfMeasureId.isEmpty) errors['unitOfMeasureId'] = 'L\'unité est obligatoire';
    if (data.sellingPrice < 0) errors['sellingPrice'] = 'Prix invalide';
    if (data.purchasePrice < 0) errors['purchasePrice'] = 'Prix invalide';
    if (data.minStockLevel < 0) errors['minStockLevel'] = 'Valeur invalide';
    if (data.maxStockLevel < data.minStockLevel) errors['maxStockLevel'] = 'Doit être >= stock minimum';
    return errors;
  }

  // ==================== CRÉATION / MISE À JOUR ====================

  /// ✅ Crée un article avec CreateArticleParams
  Future<void> _createArticle(ArticleFormData data) async {
    final params = CreateArticleParams(
      name: data.name,
      code: data.code,
      description: data.description.isNotEmpty ? data.description : '',
      shortDescription: data.shortDescription.isNotEmpty ? data.shortDescription : '',
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      tags: data.tags.isNotEmpty ? data.tags : null,
      notes: data.notes.isNotEmpty ? data.notes : null,
      categoryId: data.categoryId.isNotEmpty ? data.categoryId : null,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId.isNotEmpty ? data.unitOfMeasureId : null,
      mainSupplierId: data.mainSupplierId.isNotEmpty ? data.mainSupplierId : null,
      manageStock: data.manageStock,
      minStockLevel: data.minStockLevel,
      maxStockLevel: data.maxStockLevel,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      isSellable: data.isSellable,
      isPurchasable: data.isPurchasable,
      allowNegativeStock: data.allowNegativeStock,
      purchasePrice: data.purchasePrice,
      sellingPrice: data.sellingPrice,
      weight: data.weight > 0 ? data.weight : null,
      length: data.length > 0 ? data.length : null,
      width: data.width > 0 ? data.width : null,
      height: data.height > 0 ? data.height : null,
      parentArticleId: data.parentArticleId,
      variantAttributes: data.variantAttributes.isNotEmpty ? data.variantAttributes : null,
      imagePath: data.imagePath.isNotEmpty ? data.imagePath : null,
      isActive: data.isActive,
      images: data.images.isNotEmpty ? _prepareImagesForApi(data.images) : null,
      additionalBarcodes: data.additionalBarcodes.isNotEmpty ? _prepareBarcodesForApi(data.additionalBarcodes) : null,
    );

    final result = await createArticleUseCase(params);
    final error = result.$2;
    final article = result.$1;

    if (error != null || article == null) {
      throw Exception(error ?? 'Erreur création');
    }

    state = ArticleFormSuccess(article: article, message: 'Article créé');
    logger.i('✅ Créé: ${article.name}');
  }

  /// ✅ Met à jour un article avec UpdateArticleParams
  Future<void> _updateArticle(ArticleFormData data) async {
    if (articleId == null) throw Exception('ID manquant');

    final params = UpdateArticleParams(
      id: articleId!,
      name: data.name,
      code: data.code,
      description: data.description.isNotEmpty ? data.description : '',
      shortDescription: data.shortDescription.isNotEmpty ? data.shortDescription : '',
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      tags: data.tags.isNotEmpty ? data.tags : null,
      notes: data.notes.isNotEmpty ? data.notes : null,
      categoryId: data.categoryId.isNotEmpty ? data.categoryId : null,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId.isNotEmpty ? data.unitOfMeasureId : null,
      mainSupplierId: data.mainSupplierId.isNotEmpty ? data.mainSupplierId : null,
      manageStock: data.manageStock,
      minStockLevel: data.minStockLevel,
      maxStockLevel: data.maxStockLevel,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      isSellable: data.isSellable,
      isPurchasable: data.isPurchasable,
      allowNegativeStock: data.allowNegativeStock,
      purchasePrice: data.purchasePrice,
      sellingPrice: data.sellingPrice,
      weight: data.weight > 0 ? data.weight : null,
      length: data.length > 0 ? data.length : null,
      width: data.width > 0 ? data.width : null,
      height: data.height > 0 ? data.height : null,
      parentArticleId: data.parentArticleId,
      variantAttributes: data.variantAttributes.isNotEmpty ? data.variantAttributes : null,
      imagePath: data.imagePath.isNotEmpty ? data.imagePath : null,
      isActive: data.isActive,
      images: data.images.isNotEmpty ? _prepareImagesForApi(data.images) : null,
      additionalBarcodes: data.additionalBarcodes.isNotEmpty ? _prepareBarcodesForApi(data.additionalBarcodes) : null,
    );

    final result = await updateArticleUseCase(params);
    final error = result.$2;
    final article = result.$1;

    if (error != null || article == null) {
      throw Exception(error ?? 'Erreur mise à jour');
    }

    state = ArticleFormSuccess(article: article, message: 'Article mis à jour');
    logger.i('✅ Mis à jour: ${article.name}');
  }

  /// Prépare les images pour l'API
  List<Map<String, dynamic>> _prepareImagesForApi(List<ArticleImageData> images) {
    return images.map((img) => {
      if (img.id != null) 'id': img.id,
      'image_path': img.imagePath,
      'alt_text': img.altText,
      'caption': img.caption,
      'is_primary': img.isPrimary,
      'order': img.order,
    }).toList();
  }

  /// Prépare les codes-barres pour l'API
  List<Map<String, dynamic>> _prepareBarcodesForApi(List<AdditionalBarcodeData> barcodes) {
    return barcodes.map((barcode) => {
      if (barcode.id != null) 'id': barcode.id,
      'barcode': barcode.barcode,
      'barcode_type': barcode.barcodeType,
      'is_primary': barcode.isPrimary,
    }).toList();
  }

  /// Réinitialise le formulaire après une erreur
  void retryAfterError() {
    final currentState = state;
    if (currentState is ArticleFormError && currentState.formData != null) {
      state = ArticleFormReady(
        mode: mode,
        articleId: articleId,
        formData: currentState.formData!,
      );
    }
  }

  /// Annule et réinitialise le formulaire
  void cancel() {
    state = ArticleFormInitial(mode: mode, articleId: articleId);
  }
}