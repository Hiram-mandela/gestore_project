// ========================================
// lib/features/inventory/presentation/providers/article_form_provider.dart
// Provider Riverpod pour le formulaire article
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
      logger.d('📝 Formulaire prêt pour création');
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

      // Remplir le formulaire avec les données de l'article
      final formData = ArticleFormData(
        name: article.name,
        code: article.code,
        description: article.description,
        articleType: article.articleType.value,
        barcode: article.barcode ?? '',
        internalReference: article.internalReference ?? '',
        supplierReference: article.supplierReference ?? '',
        categoryId: article.category?.id ?? '',
        brandId: article.brand?.id ?? '',
        unitOfMeasureId: article.unitOfMeasure?.id ?? '',
        mainSupplierId: article.mainSupplier?.id ?? '',
        purchasePrice: article.purchasePrice,
        sellingPrice: article.sellingPrice,
        manageStock: article.manageStock,
        minStockLevel: article.minStockLevel,
        maxStockLevel: article.maxStockLevel,
        requiresLotTracking: article.requiresLotTracking,
        requiresExpiryDate: article.requiresExpiryDate,
        isSellable: article.isSellable,
        isPurchasable: article.isPurchasable,
        allowNegativeStock: article.allowNegativeStock,
        imagePath: article.imageUrl ?? '',
        weight: article.weight ?? 0.0,
        length: article.length ?? 0.0,
        width: article.width ?? 0.0,
        height: article.height ?? 0.0,
        tags: article.tags ?? '',
        notes: article.notes ?? '',
        isActive: article.isActive,
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
      case 'name':
        updatedData = currentState.formData.copyWith(name: value as String);
        break;
      case 'code':
        updatedData = currentState.formData.copyWith(
          code: (value as String).toUpperCase(),
        );
        break;
      case 'description':
        updatedData = currentState.formData.copyWith(description: value as String);
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
      case 'categoryId':
        updatedData = currentState.formData.copyWith(categoryId: value as String);
        break;
      case 'brandId':
        updatedData = currentState.formData.copyWith(brandId: value as String);
        break;
      case 'unitOfMeasureId':
        updatedData = currentState.formData.copyWith(unitOfMeasureId: value as String);
        break;
      case 'mainSupplierId':
        updatedData = currentState.formData.copyWith(mainSupplierId: value as String);
        break;
      case 'purchasePrice':
        updatedData = currentState.formData.copyWith(purchasePrice: value as double);
        break;
      case 'sellingPrice':
        updatedData = currentState.formData.copyWith(sellingPrice: value as double);
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
      case 'imagePath':
        updatedData = currentState.formData.copyWith(imagePath: value as String);
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
      case 'tags':
        updatedData = currentState.formData.copyWith(tags: value as String);
        break;
      case 'notes':
        updatedData = currentState.formData.copyWith(notes: value as String);
        break;
      case 'isActive':
        updatedData = currentState.formData.copyWith(isActive: value as bool);
        break;
      default:
        logger.w('⚠️ Champ inconnu: $field');
        return;
    }

    // Valider et mettre à jour l'état
    final errors = _validateFormData(updatedData);
    state = currentState.copyWith(
      formData: updatedData,
      errors: errors,
    );
  }

  // ==================== VALIDATION ====================

  /// Valide les données du formulaire
  Map<String, String> _validateFormData(ArticleFormData data) {
    final errors = <String, String>{};

    // Nom
    if (data.name.trim().isEmpty) {
      errors['name'] = 'Le nom est requis';
    } else if (data.name.length < 3) {
      errors['name'] = 'Le nom doit contenir au moins 3 caractères';
    }

    // Code
    if (data.code.trim().isEmpty) {
      errors['code'] = 'Le code est requis';
    } else if (data.code.length < 2) {
      errors['code'] = 'Le code doit contenir au moins 2 caractères';
    }

    // Catégorie
    if (data.categoryId.trim().isEmpty) {
      errors['categoryId'] = 'La catégorie est requise';
    }

    // Unité de mesure
    if (data.unitOfMeasureId.trim().isEmpty) {
      errors['unitOfMeasureId'] = 'L\'unité de mesure est requise';
    }

    // Prix d'achat
    if (data.purchasePrice < 0) {
      errors['purchasePrice'] = 'Le prix d\'achat ne peut pas être négatif';
    }

    // Prix de vente
    if (data.sellingPrice < 0) {
      errors['sellingPrice'] = 'Le prix de vente ne peut pas être négatif';
    } else if (data.sellingPrice < data.purchasePrice) {
      errors['sellingPrice'] = 'Le prix de vente doit être ≥ prix d\'achat';
    }

    // Stock
    if (data.manageStock) {
      if (data.minStockLevel < 0) {
        errors['minStockLevel'] = 'Le stock minimum ne peut pas être négatif';
      }
      if (data.maxStockLevel < 0) {
        errors['maxStockLevel'] = 'Le stock maximum ne peut pas être négatif';
      }
      if (data.maxStockLevel > 0 && data.minStockLevel > data.maxStockLevel) {
        errors['minStockLevel'] = 'Le stock min ne peut pas être > stock max';
      }
    }

    return errors;
  }

  /// Valide une étape spécifique
  bool validateStep(int step) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return false;

    final errors = _validateFormData(currentState.formData);
    final stepErrors = <String, String>{};

    switch (step) {
      case 0: // Étape 1 : Informations de base
        if (errors.containsKey('name')) stepErrors['name'] = errors['name']!;
        if (errors.containsKey('code')) stepErrors['code'] = errors['code']!;
        if (errors.containsKey('categoryId')) {
          stepErrors['categoryId'] = errors['categoryId']!;
        }
        if (errors.containsKey('unitOfMeasureId')) {
          stepErrors['unitOfMeasureId'] = errors['unitOfMeasureId']!;
        }
        break;

      case 1: // Étape 2 : Prix et stock
        if (errors.containsKey('purchasePrice')) {
          stepErrors['purchasePrice'] = errors['purchasePrice']!;
        }
        if (errors.containsKey('sellingPrice')) {
          stepErrors['sellingPrice'] = errors['sellingPrice']!;
        }
        if (errors.containsKey('minStockLevel')) {
          stepErrors['minStockLevel'] = errors['minStockLevel']!;
        }
        if (errors.containsKey('maxStockLevel')) {
          stepErrors['maxStockLevel'] = errors['maxStockLevel']!;
        }
        break;

      case 2: // Étape 3 : Options avancées
      // Pas de validation obligatoire pour cette étape
        break;
    }

    if (stepErrors.isNotEmpty) {
      state = currentState.copyWith(errors: stepErrors);
      logger.w('⚠️ Erreurs validation étape $step: $stepErrors');
      return false;
    }

    // Étape valide
    state = currentState.copyWith(errors: {});
    return true;
  }

  // ==================== NAVIGATION ENTRE ÉTAPES ====================

  /// Passe à l'étape suivante
  void nextStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    // Valider l'étape actuelle
    if (!validateStep(currentState.currentStep)) {
      logger.w('⚠️ Étape ${currentState.currentStep} invalide');
      return;
    }

    // Passer à l'étape suivante
    final nextStep = currentState.currentStep + 1;
    if (nextStep <= 2) {
      state = currentState.copyWith(currentStep: nextStep);
      logger.d('➡️ Passage à l\'étape $nextStep');
    }
  }

  /// Retourne à l'étape précédente
  void previousStep() {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    final prevStep = currentState.currentStep - 1;
    if (prevStep >= 0) {
      state = currentState.copyWith(currentStep: prevStep);
      logger.d('⬅️ Retour à l\'étape $prevStep');
    }
  }

  /// Va à une étape spécifique
  void goToStep(int step) {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    if (step >= 0 && step <= 2) {
      state = currentState.copyWith(currentStep: step);
      logger.d('📍 Navigation vers étape $step');
    }
  }

  // ==================== SOUMISSION ====================

  /// Soumet le formulaire (création ou mise à jour)
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! ArticleFormReady) return;

    // Validation finale
    final errors = _validateFormData(currentState.formData);
    if (errors.isNotEmpty) {
      logger.w('⚠️ Formulaire invalide: $errors');
      state = currentState.copyWith(errors: errors);
      return;
    }

    logger.d('📤 Soumission formulaire (mode: $mode)');
    state = ArticleFormSubmitting(
      mode: mode,
      formData: currentState.formData,
    );

    try {
      if (mode == ArticleFormMode.create) {
        await _createArticle(currentState.formData);
      } else {
        await _updateArticle(currentState.formData);
      }
    } catch (e) {
      logger.e('❌ Erreur soumission: $e');
      state = ArticleFormError(
        message: 'Erreur inattendue: $e',
        mode: mode,
        formData: currentState.formData,
      );
    }
  }

  /// Crée un nouvel article
  Future<void> _createArticle(ArticleFormData data) async {
    final params = CreateArticleParams(
      name: data.name,
      code: data.code,
      description: data.description,
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      categoryId: data.categoryId,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId,
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
      state = ArticleFormError(
        message: 'ID article manquant pour la mise à jour',
        mode: mode,
        formData: data,
      );
      return;
    }

    final params = UpdateArticleParams(
      id: articleId!,
      name: data.name,
      code: data.code,
      description: data.description,
      articleType: data.articleType,
      barcode: data.barcode.isNotEmpty ? data.barcode : null,
      internalReference: data.internalReference.isNotEmpty ? data.internalReference : null,
      supplierReference: data.supplierReference.isNotEmpty ? data.supplierReference : null,
      categoryId: data.categoryId,
      brandId: data.brandId.isNotEmpty ? data.brandId : null,
      unitOfMeasureId: data.unitOfMeasureId,
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
      imagePath: data.imagePath.isNotEmpty && !data.imagePath.startsWith('http')
          ? data.imagePath
          : null,
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