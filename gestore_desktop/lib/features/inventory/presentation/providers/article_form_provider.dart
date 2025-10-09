// ========================================
// lib/features/inventory/presentation/providers/article_form_provider.dart
// Provider Riverpod pour le formulaire article
// VERSION 2.0 - Support complet 40+ champs + 5 étapes
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/create_article_usecase.dart';
import '../../domain/usecases/update_article_usecase.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/get_article_detail_usecase.dart';
import 'article_form_state.dart';

/// Provider pour le formulaire article
/// Prend en paramètres : mode et articleId (null si création)
final articleFormProvider = StateNotifierProvider.family<
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
      // Mode édition : charger l'article
      await _loadArticleForEdit();
    } else {
      // Mode création : formulaire vide
      state = ArticleFormReady(
        mode: mode,
        formData: const ArticleFormData(),
      );
      logger.d('📝 Formulaire prêt pour création (5 étapes)');
    }
  }

  /// Charge l'article pour édition
  Future<void> _loadArticleForEdit() async {
    try {
      logger.d('📝 Chargement article pour édition: $articleId');
      state = ArticleFormLoading(articleId: articleId!);

      final params = GetArticleDetailParams(articleId: articleId!);
      final result = await getArticleDetailUseCase(params);

      final error = result.$2;
      final article = result.$1;

      if (error != null || article == null) {
        logger.e('❌ Erreur chargement article: $error');
        state = ArticleFormError(
          message: error ?? 'Article non trouvé',
          mode: mode,
        );
        return;
      }

      // Mapper les images
      final images = article.images.map((img) {
        return ArticleImageData(
          id: img.id,
          imagePath: img.imageUrl,
          altText: img.altText,
          caption: img.caption,
          isPrimary: img.isPrimary,
          order: img.order,
        );
      }).toList() ?? [];

      // Mapper les codes-barres additionnels
      final additionalBarcodes = article.additionalBarcodes.map((barcode) {
        return AdditionalBarcodeData(
          id: barcode.id,
          barcode: barcode.barcode,
          barcodeType: barcode.barcodeType,
          isPrimary: barcode.isPrimary,
        );
      }).toList() ?? [];

      // Remplir le formulaire avec les données de l'article
      final formData = ArticleFormData(
        // Section 1: Informations de base
        name: article.name,
        code: article.code,
        description: article.description,
        shortDescription: article.shortDescription ?? '',
        articleType: article.articleType.value,
        barcode: article.barcode ?? '',
        internalReference: article.internalReference ?? '',
        supplierReference: article.supplierReference ?? '',
        tags: article.tags ?? '',
        notes: article.notes ?? '',

        // Section 2: Classification
        categoryId: article.category?.id ?? '',
        brandId: article.brand?.id ?? '',
        unitOfMeasureId: article.unitOfMeasure?.id ?? '',

        // Section 3: Gestion de stock
        manageStock: article.manageStock,
        minStockLevel: article.minStockLevel,
        maxStockLevel: article.maxStockLevel,
        requiresLotTracking: article.requiresLotTracking,
        requiresExpiryDate: article.requiresExpiryDate,
        isSellable: article.isSellable,
        isPurchasable: article.isPurchasable,
        allowNegativeStock: article.allowNegativeStock,

        // Section 4: Prix et fournisseur
        purchasePrice: article.purchasePrice,
        sellingPrice: article.sellingPrice,
        mainSupplierId: article.mainSupplier?.id ?? '',

        // Section 5: Métadonnées avancées
        weight: article.weight ?? 0.0,
        length: article.length ?? 0.0,
        width: article.width ?? 0.0,
        height: article.height ?? 0.0,
        parentArticleId: article.parentArticle?.id,
        variantAttributes: article.variantAttributes ?? '',
        isActive: article.isActive,
        imagePath: article.imageUrl ?? '',

        // Tableaux
        images: images,
        additionalBarcodes: additionalBarcodes,
      );

      state = ArticleFormReady(
        mode: mode,
        articleId: articleId,
        formData: formData,
      );

      logger.i('✅ Article chargé pour édition: ${article.name}');
    } catch (e) {
      logger.e('❌ Exception chargement article: $e');
      state = ArticleFormError(
        message: 'Erreur lors du chargement: $e',
        mode: mode,
      );
    }
  }

  // ==================== GESTION DES CHAMPS ====================

  /// Met à jour un champ du formulaire
  void updateField(String field, dynamic value) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    logger.d('📝 Mise à jour champ: $field = $value');

    ArticleFormData updatedData;

    switch (field) {
    // Section 1: Informations de base
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

    // Section 2: Classification
      case 'categoryId':
        updatedData = currentState.formData.copyWith(categoryId: value as String);
        break;
      case 'brandId':
        updatedData = currentState.formData.copyWith(brandId: value as String);
        break;
      case 'unitOfMeasureId':
        updatedData = currentState.formData.copyWith(unitOfMeasureId: value as String);
        break;

    // Section 3: Gestion de stock
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

    // Section 4: Prix et fournisseur
      case 'purchasePrice':
        updatedData = currentState.formData.copyWith(purchasePrice: value as double);
        break;
      case 'sellingPrice':
        updatedData = currentState.formData.copyWith(sellingPrice: value as double);
        break;
      case 'mainSupplierId':
        updatedData = currentState.formData.copyWith(mainSupplierId: value as String);
        break;

    // Section 5: Métadonnées avancées
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

    // Tableaux complexes
      case 'images':
        updatedData = currentState.formData.copyWith(
          images: value as List<ArticleImageData>,
        );
        break;
      case 'additionalBarcodes':
        updatedData = currentState.formData.copyWith(
          additionalBarcodes: value as List<AdditionalBarcodeData>,
        );
        break;

      default:
        logger.w('⚠️ Champ inconnu: $field');
        return;
    }

    // Valider et mettre à jour l'état
    final errors = _validateFormData(updatedData, currentState.currentStep);

    state = currentState.copyWith(
      formData: updatedData,
      errors: errors,
    );
  }

  // ==================== NAVIGATION ENTRE ÉTAPES ====================

  /// Passe à l'étape suivante
  void nextStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    if (currentState.isLastStep) {
      logger.w('⚠️ Déjà à la dernière étape');
      return;
    }

    // Valider l'étape actuelle avant de continuer
    final errors = _validateFormData(currentState.formData, currentState.currentStep);

    if (errors.isNotEmpty) {
      logger.w('⚠️ Erreurs de validation, impossible de continuer');
      state = currentState.copyWith(errors: errors);
      return;
    }

    final nextStep = currentState.currentStep + 1;
    logger.d('📝 Passage à l\'étape ${nextStep + 1}/5');

    state = currentState.copyWith(
      currentStep: nextStep,
      errors: {},
    );
  }

  /// Revient à l'étape précédente
  void previousStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    if (currentState.isFirstStep) {
      logger.w('⚠️ Déjà à la première étape');
      return;
    }

    final previousStep = currentState.currentStep - 1;
    logger.d('📝 Retour à l\'étape ${previousStep + 1}/5');

    state = currentState.copyWith(
      currentStep: previousStep,
      errors: {},
    );
  }

  /// Va directement à une étape spécifique
  void goToStep(int step) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    if (step < 0 || step >= 5) {
      logger.w('⚠️ Étape invalide: $step');
      return;
    }

    logger.d('📝 Navigation vers étape ${step + 1}/5');

    state = currentState.copyWith(
      currentStep: step,
      errors: {},
    );
  }

  // ==================== VALIDATION ====================

  /// Valide les données du formulaire selon l'étape
  Map<String, String> _validateFormData(ArticleFormData data, int step) {
    final errors = <String, String>{};

    switch (step) {
      case 0: // Étape 1: Informations de base
        if (data.name.trim().isEmpty) {
          errors['name'] = 'Le nom est requis';
        } else if (data.name.trim().length < 2) {
          errors['name'] = 'Le nom doit contenir au moins 2 caractères';
        }

        if (data.code.trim().isEmpty) {
          errors['code'] = 'Le code est requis';
        } else if (data.code.trim().length < 2) {
          errors['code'] = 'Le code doit contenir au moins 2 caractères';
        }
        break;

      case 1: // Étape 2: Classification
      // Optionnel, pas d'erreurs bloquantes
        break;

      case 2: // Étape 3: Gestion de stock
        if (data.manageStock) {
          if (data.minStockLevel < 0) {
            errors['minStockLevel'] = 'Le stock minimum doit être positif';
          }
          if (data.maxStockLevel < 0) {
            errors['maxStockLevel'] = 'Le stock maximum doit être positif';
          }
          if (data.maxStockLevel > 0 && data.maxStockLevel < data.minStockLevel) {
            errors['maxStockLevel'] = 'Le stock max doit être > au stock min';
          }
        }

        if (!data.isSellable && !data.isPurchasable) {
          errors['general'] = 'L\'article doit être vendable ou achetable';
        }
        break;

      case 3: // Étape 4: Prix et fournisseur
        if (data.purchasePrice < 0) {
          errors['purchasePrice'] = 'Le prix d\'achat doit être positif';
        }
        if (data.sellingPrice < 0) {
          errors['sellingPrice'] = 'Le prix de vente doit être positif';
        }
        if (data.sellingPrice > 0 && data.sellingPrice < data.purchasePrice) {
          errors['sellingPrice'] = 'Le prix de vente devrait être > au prix d\'achat';
        }
        break;

      case 4: // Étape 5: Métadonnées avancées
        if (data.weight < 0) {
          errors['weight'] = 'Le poids doit être positif';
        }
        if (data.length < 0) {
          errors['length'] = 'La longueur doit être positive';
        }
        if (data.width < 0) {
          errors['width'] = 'La largeur doit être positive';
        }
        if (data.height < 0) {
          errors['height'] = 'La hauteur doit être positive';
        }

        // Vérification variantes
        if (data.articleType == 'variant' &&
            (data.parentArticleId == null || data.parentArticleId!.isEmpty)) {
          errors['parentArticleId'] = 'Un article variante doit avoir un parent';
        }
        break;
    }

    return errors;
  }

  /// Validation finale avant soumission
  Map<String, String> _validateAll(ArticleFormData data) {
    final errors = <String, String>{};

    // Valider toutes les étapes
    for (int i = 0; i < 5; i++) {
      final stepErrors = _validateFormData(data, i);
      errors.addAll(stepErrors);
    }

    return errors;
  }

  // ==================== SOUMISSION ====================

  /// Soumet le formulaire (création ou mise à jour)
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    // Validation finale
    final errors = _validateAll(currentState.formData);
    if (errors.isNotEmpty) {
      logger.e('❌ Erreurs de validation: $errors');
      state = currentState.copyWith(errors: errors);
      return;
    }

    logger.i('📝 Soumission du formulaire en mode ${mode.name}');

    state = ArticleFormSubmitting(
      mode: mode,
      formData: currentState.formData,
    );

    if (mode == ArticleFormMode.create) {
      await _createArticle(currentState.formData);
    } else {
      await _updateArticle(currentState.formData);
    }
  }

  /// Crée un nouvel article
  Future<void> _createArticle(ArticleFormData data) async {
    logger.d('📝 Création article: ${data.name}');

    final params = CreateArticleParams(
      name: data.name,
      code: data.code,
      description: data.description.isNotEmpty ? data.description : null,
      shortDescription: data.shortDescription.isNotEmpty ? data.shortDescription : null,
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      categoryId: data.categoryId.isNotEmpty ? data.categoryId : null,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId.isNotEmpty ? data.unitOfMeasureId : null,
      mainSupplierId: data.mainSupplierId.isNotEmpty ? data.mainSupplierId : null,
      purchasePrice: data.purchasePrice,
      sellingPrice: data.sellingPrice,
      manageStock: data.manageStock,
      minStockLevel: data.minStockLevel,
      maxStockLevel: data.maxStockLevel,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      isSellable: data.isSellable,
      isPurchasable: data.isPurchasable,
      allowNegativeStock: data.allowNegativeStock,
      parentArticleId: data.parentArticleId,
      variantAttributes: data.variantAttributes.isNotEmpty ? data.variantAttributes : null,
      imagePath: data.imagePath.isNotEmpty ? data.imagePath : null,
      weight: data.weight > 0 ? data.weight : null,
      length: data.length > 0 ? data.length : null,
      width: data.width > 0 ? data.width : null,
      height: data.height > 0 ? data.height : null,
      tags: data.tags.isNotEmpty ? data.tags : null,
      notes: data.notes.isNotEmpty ? data.notes : null,
      isActive: data.isActive,
    );

    final result = await createArticleUseCase(params);
    final error = result.$2;
    final article = result.$1;

    if (error != null || article == null) {
      logger.e('❌ Erreur création article: $error');
      state = ArticleFormError(
        message: error ?? 'Erreur inconnue',
        mode: mode,
        formData: data,
      );
      return;
    }

    logger.i('✅ Article créé avec succès: ${article.name}');
    state = ArticleFormSuccess(
      article: article,
      message: 'Article "${article.name}" créé avec succès',
    );
  }

  /// Met à jour un article existant
  Future<void> _updateArticle(ArticleFormData data) async {
    if (articleId == null) {
      logger.e('❌ articleId manquant pour la mise à jour');
      state = ArticleFormError(
        message: 'Erreur: ID article manquant',
        mode: mode,
        formData: data,
      );
      return;
    }

    logger.d('📝 Mise à jour article: $articleId');

    final params = UpdateArticleParams(
      id: articleId!,
      name: data.name,
      code: data.code,
      description: data.description.isNotEmpty ? data.description : null,
      shortDescription: data.shortDescription.isNotEmpty ? data.shortDescription : null,
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      categoryId: data.categoryId.isNotEmpty ? data.categoryId : null,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId.isNotEmpty ? data.unitOfMeasureId : null,
      mainSupplierId: data.mainSupplierId.isNotEmpty ? data.mainSupplierId : null,
      purchasePrice: data.purchasePrice,
      sellingPrice: data.sellingPrice,
      manageStock: data.manageStock,
      minStockLevel: data.minStockLevel,
      maxStockLevel: data.maxStockLevel,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      isSellable: data.isSellable,
      isPurchasable: data.isPurchasable,
      allowNegativeStock: data.allowNegativeStock,
      parentArticleId: data.parentArticleId,
      variantAttributes: data.variantAttributes.isNotEmpty ? data.variantAttributes : null,
      imagePath: data.imagePath.isNotEmpty ? data.imagePath : null,
      weight: data.weight > 0 ? data.weight : null,
      length: data.length > 0 ? data.length : null,
      width: data.width > 0 ? data.width : null,
      height: data.height > 0 ? data.height : null,
      tags: data.tags.isNotEmpty ? data.tags : null,
      notes: data.notes.isNotEmpty ? data.notes : null,
      isActive: data.isActive,
    );

    final result = await updateArticleUseCase(params);
    final error = result.$2;
    final article = result.$1;

    if (error != null || article == null) {
      logger.e('❌ Erreur mise à jour article: $error');
      state = ArticleFormError(
        message: error ?? 'Erreur inconnue',
        mode: mode,
        formData: data,
      );
      return;
    }

    logger.i('✅ Article mis à jour avec succès: ${article.name}');
    state = ArticleFormSuccess(
      article: article,
      message: 'Article "${article.name}" mis à jour avec succès',
    );
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