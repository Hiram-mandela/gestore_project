// ========================================
// lib/features/inventory/presentation/providers/categories_crud_provider.dart
// Provider Riverpod pour le CRUD des catégories
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/usecases/get_categories_usecase.dart';
import '../../domain/usecases/category_usecases.dart';
import 'category_state.dart';

// ==================== PROVIDER LISTE CATÉGORIES ====================

/// Provider pour la liste des catégories
final categoriesListProvider = StateNotifierProvider<CategoriesListNotifier, CategoryState>((ref) {
  return CategoriesListNotifier(
    getCategoriesUseCase: getIt<GetCategoriesUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer la liste des catégories
class CategoriesListNotifier extends StateNotifier<CategoryState> {
  final GetCategoriesUseCase getCategoriesUseCase;
  final Logger logger;

  CategoriesListNotifier({
    required this.getCategoriesUseCase,
    required this.logger,
  }) : super(const CategoryInitial());

  /// Charge toutes les catégories
  Future<void> loadCategories({bool? isActive}) async {
    try {
      logger.i('📂 Chargement catégories...');
      state = const CategoryLoading();

      final params = GetCategoriesParams(isActive: isActive);
      final (categories, error) = await getCategoriesUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement catégories: $error');
        state = CategoryError(message: error);
        return;
      }

      if (categories != null) {
        // Organiser les catégories (racines et enfants)
        final rootCategories = categories.where((cat) => cat.parentId == null).toList();
        final childrenByParent = <String, List<CategoryEntity>>{};

        for (final category in categories) {
          if (category.parentId != null) {
            childrenByParent.putIfAbsent(category.parentId!, () => []).add(category);
          }
        }

        logger.i('✅ ${categories.length} catégories chargées (${rootCategories.length} racines)');
        state = CategoryLoaded(
          categories: categories,
          rootCategories: rootCategories,
          childrenByParent: childrenByParent,
        );
      }
    } catch (e) {
      logger.e('❌ Exception chargement catégories: $e');
      state = const CategoryError(message: 'Une erreur est survenue');
    }
  }

  /// Recharge les catégories
  Future<void> refresh() async {
    await loadCategories(isActive: true);
  }
}

// ==================== PROVIDER FORMULAIRE CATÉGORIE ====================

/// Provider pour le formulaire catégorie
final categoryFormProvider = StateNotifierProvider.family<
    CategoryFormNotifier,
    CategoryFormState,
    (CategoryFormMode, String?)>((ref, params) {
  final mode = params.$1;
  final categoryId = params.$2;

  return CategoryFormNotifier(
    mode: mode,
    categoryId: categoryId,
    createCategoryUseCase: getIt<CreateCategoryUseCase>(),
    updateCategoryUseCase: getIt<UpdateCategoryUseCase>(),
    deleteCategoryUseCase: getIt<DeleteCategoryUseCase>(),
    getCategoryByIdUseCase: getIt<GetCategoryByIdUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer le formulaire catégorie
class CategoryFormNotifier extends StateNotifier<CategoryFormState> {
  final CategoryFormMode mode;
  final String? categoryId;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;
  final GetCategoryByIdUseCase getCategoryByIdUseCase;
  final Logger logger;

  CategoryFormNotifier({
    required this.mode,
    this.categoryId,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
    required this.getCategoryByIdUseCase,
    required this.logger,
  }) : super(CategoryFormInitial(mode: mode, categoryId: categoryId)) {
    _initialize();
  }

  /// Initialise le formulaire
  Future<void> _initialize() async {
    if (mode == CategoryFormMode.edit && categoryId != null) {
      await _loadCategoryForEdit();
    } else {
      state = CategoryFormReady(
        mode: mode,
        formData: const CategoryFormData(),
      );
      logger.d('📝 Formulaire catégorie prêt pour création');
    }
  }

  /// Charge la catégorie pour édition
  Future<void> _loadCategoryForEdit() async {
    try {
      logger.d('📝 Chargement catégorie pour édition: $categoryId');
      state = CategoryFormLoading(categoryId: categoryId!);

      final params = GetCategoryByIdParams(categoryId: categoryId!);
      final (category, error) = await getCategoryByIdUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement: $error');
        state = CategoryFormError(message: error, mode: mode);
        return;
      }

      if (category != null) {
        state = CategoryFormReady(
          mode: mode,
          categoryId: categoryId,
          formData: CategoryFormData.fromEntity(category),
        );
        logger.i('✅ Catégorie chargée: ${category.name}');
      }
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = CategoryFormError(
        message: 'Erreur lors du chargement',
        mode: mode,
      );
    }
  }

  /// Met à jour un champ du formulaire
  void updateField(String field, dynamic value) {
    final currentState = state;
    if (currentState is! CategoryFormReady) return;

    CategoryFormData updatedData;

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
      case 'parentId':
        updatedData = currentState.formData.copyWith(
          parentId: value as String?,
          clearParent: value == null,
        );
        break;
      case 'taxRate':
        updatedData = currentState.formData.copyWith(taxRate: value as double);
        break;
      case 'color':
        updatedData = currentState.formData.copyWith(color: value as String);
        break;
      case 'requiresPrescription':
        updatedData = currentState.formData.copyWith(requiresPrescription: value as bool);
        break;
      case 'requiresLotTracking':
        updatedData = currentState.formData.copyWith(requiresLotTracking: value as bool);
        break;
      case 'requiresExpiryDate':
        updatedData = currentState.formData.copyWith(requiresExpiryDate: value as bool);
        break;
      case 'defaultMinStock':
        updatedData = currentState.formData.copyWith(defaultMinStock: value as int);
        break;
      case 'order':
        updatedData = currentState.formData.copyWith(order: value as int);
        break;
      case 'isActive':
        updatedData = currentState.formData.copyWith(isActive: value as bool);
        break;
      default:
        return;
    }

    // Validation en temps réel
    final errors = _validateFormData(updatedData);

    state = currentState.copyWith(
      formData: updatedData,
      errors: errors,
    );
  }

  /// Valide les données du formulaire
  Map<String, String> _validateFormData(CategoryFormData data) {
    final errors = <String, String>{};

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

    if (data.taxRate < 0 || data.taxRate > 100) {
      errors['taxRate'] = 'Le taux de TVA doit être entre 0 et 100';
    }

    if (data.defaultMinStock < 0) {
      errors['defaultMinStock'] = 'Le stock minimum doit être positif';
    }

    return errors;
  }

  /// Soumet le formulaire (création ou édition)
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! CategoryFormReady) return;

    // Validation finale
    final errors = _validateFormData(currentState.formData);
    if (errors.isNotEmpty) {
      state = currentState.copyWith(errors: errors);
      return;
    }

    state = CategoryFormSubmitting(mode: mode);

    try {
      if (mode == CategoryFormMode.create) {
        await _createCategory(currentState.formData);
      } else {
        await _updateCategory(currentState.formData);
      }
    } catch (e) {
      logger.e('❌ Erreur soumission: $e');
      state = CategoryFormError(
        message: 'Une erreur est survenue',
        mode: mode,
      );
    }
  }

  /// Crée une nouvelle catégorie
  Future<void> _createCategory(CategoryFormData data) async {
    logger.d('📝 Création catégorie "${data.name}"');

    final params = CreateCategoryParams(
      name: data.name,
      code: data.code,
      description: data.description,
      parentId: data.parentId,
      taxRate: data.taxRate,
      color: data.color,
      requiresPrescription: data.requiresPrescription,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      defaultMinStock: data.defaultMinStock,
      order: data.order,
      isActive: data.isActive,
    );

    final (category, error) = await createCategoryUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur création: $error');
      state = CategoryFormError(message: error, mode: mode);
      return;
    }

    if (category != null) {
      logger.i('✅ Catégorie créée: ${category.name}');
      state = CategoryFormSuccess(category: category, mode: mode);
    }
  }

  /// Met à jour une catégorie
  Future<void> _updateCategory(CategoryFormData data) async {
    if (categoryId == null) return;

    logger.d('📝 Mise à jour catégorie $categoryId');

    final params = UpdateCategoryParams(
      id: categoryId!,
      name: data.name,
      code: data.code,
      description: data.description,
      parentId: data.parentId,
      taxRate: data.taxRate,
      color: data.color,
      requiresPrescription: data.requiresPrescription,
      requiresLotTracking: data.requiresLotTracking,
      requiresExpiryDate: data.requiresExpiryDate,
      defaultMinStock: data.defaultMinStock,
      order: data.order,
      isActive: data.isActive,
    );

    final (category, error) = await updateCategoryUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur mise à jour: $error');
      state = CategoryFormError(message: error, mode: mode);
      return;
    }

    if (category != null) {
      logger.i('✅ Catégorie mise à jour: ${category.name}');
      state = CategoryFormSuccess(category: category, mode: mode);
    }
  }

  /// Supprime la catégorie (mode édition uniquement)
  Future<void> delete() async {
    if (categoryId == null || mode != CategoryFormMode.edit) return;

    logger.d('🗑️ Suppression catégorie $categoryId');

    state = CategoryFormSubmitting(mode: mode);

    final params = DeleteCategoryParams(categoryId: categoryId!);
    final (_, error) = await deleteCategoryUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur suppression: $error');
      state = CategoryFormError(message: error, mode: mode);
      return;
    }

    logger.i('✅ Catégorie supprimée');
    // On retourne un état Success avec une catégorie dummy pour indiquer la suppression
    state = CategoryFormSuccess(
      category: CategoryEntity(
        id: categoryId!,
        name: 'DELETED',
        code: 'DELETED',
        description: '',
        taxRate: 0.0,
        color: '#000000',
        requiresPrescription: false,
        requiresLotTracking: false,
        requiresExpiryDate: false,
        defaultMinStock: 0,
        order: 0,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      mode: mode,
    );
  }
}