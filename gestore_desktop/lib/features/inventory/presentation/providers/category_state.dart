// ========================================
// lib/features/inventory/presentation/providers/category_state.dart
// États pour la gestion des catégories
// Pattern: Initial > Loading > Loaded/Error
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/category_entity.dart';

/// État de base pour les catégories
abstract class CategoryState extends Equatable {
  const CategoryState();

  @override
  List<Object?> get props => [];
}

// ==================== ÉTATS LISTE ====================

/// État initial
class CategoryInitial extends CategoryState {
  const CategoryInitial();
}

/// Chargement en cours
class CategoryLoading extends CategoryState {
  const CategoryLoading();
}

/// Liste chargée avec succès
class CategoryLoaded extends CategoryState {
  final List<CategoryEntity> categories;
  final List<CategoryEntity> rootCategories; // Catégories sans parent
  final Map<String, List<CategoryEntity>> childrenByParent; // Enfants par parent

  const CategoryLoaded({
    required this.categories,
    required this.rootCategories,
    required this.childrenByParent,
  });

  /// Récupère les enfants d'une catégorie
  List<CategoryEntity> getChildren(String parentId) {
    return childrenByParent[parentId] ?? [];
  }

  /// Vérifie si une catégorie a des enfants
  bool hasChildren(String categoryId) {
    return childrenByParent.containsKey(categoryId) &&
        childrenByParent[categoryId]!.isNotEmpty;
  }

  @override
  List<Object?> get props => [categories, rootCategories, childrenByParent];
}

/// Erreur
class CategoryError extends CategoryState {
  final String message;

  const CategoryError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS FORMULAIRE ====================

/// Mode du formulaire catégorie
enum CategoryFormMode {
  create,
  edit,
}

/// État de base pour le formulaire catégorie
abstract class CategoryFormState extends Equatable {
  const CategoryFormState();

  @override
  List<Object?> get props => [];
}

/// État initial du formulaire
class CategoryFormInitial extends CategoryFormState {
  final CategoryFormMode mode;
  final String? categoryId;

  const CategoryFormInitial({
    required this.mode,
    this.categoryId,
  });

  @override
  List<Object?> get props => [mode, categoryId];
}

/// Chargement (pour mode édition)
class CategoryFormLoading extends CategoryFormState {
  final String categoryId;

  const CategoryFormLoading({required this.categoryId});

  @override
  List<Object?> get props => [categoryId];
}

/// Formulaire prêt
class CategoryFormReady extends CategoryFormState {
  final CategoryFormMode mode;
  final String? categoryId;
  final CategoryFormData formData;
  final Map<String, String> errors;

  const CategoryFormReady({
    required this.mode,
    this.categoryId,
    required this.formData,
    this.errors = const {},
  });

  bool get isValid => errors.isEmpty;
  bool get isCreateMode => mode == CategoryFormMode.create;
  bool get isEditMode => mode == CategoryFormMode.edit;

  CategoryFormReady copyWith({
    CategoryFormData? formData,
    Map<String, String>? errors,
  }) {
    return CategoryFormReady(
      mode: mode,
      categoryId: categoryId,
      formData: formData ?? this.formData,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [mode, categoryId, formData, errors];
}

/// Soumission en cours
class CategoryFormSubmitting extends CategoryFormState {
  final CategoryFormMode mode;

  const CategoryFormSubmitting({required this.mode});

  @override
  List<Object?> get props => [mode];
}

/// Succès
class CategoryFormSuccess extends CategoryFormState {
  final CategoryEntity category;
  final CategoryFormMode mode;

  const CategoryFormSuccess({
    required this.category,
    required this.mode,
  });

  @override
  List<Object?> get props => [category, mode];
}

/// Erreur formulaire
class CategoryFormError extends CategoryFormState {
  final String message;
  final CategoryFormMode mode;

  const CategoryFormError({
    required this.message,
    required this.mode,
  });

  @override
  List<Object?> get props => [message, mode];
}

// ==================== DONNÉES FORMULAIRE ====================

/// Données du formulaire catégorie
class CategoryFormData extends Equatable {
  final String name;
  final String code;
  final String description;
  final String? parentId;
  final double taxRate;
  final String color;
  final bool requiresPrescription;
  final bool requiresLotTracking;
  final bool requiresExpiryDate;
  final int defaultMinStock;
  final int order;
  final bool isActive;

  const CategoryFormData({
    this.name = '',
    this.code = '',
    this.description = '',
    this.parentId,
    this.taxRate = 0.0,
    this.color = '#007bff',
    this.requiresPrescription = false,
    this.requiresLotTracking = false,
    this.requiresExpiryDate = false,
    this.defaultMinStock = 5,
    this.order = 0,
    this.isActive = true,
  });

  /// Crée FormData depuis une Entity (pour édition)
  factory CategoryFormData.fromEntity(CategoryEntity entity) {
    return CategoryFormData(
      name: entity.name,
      code: entity.code,
      description: entity.description,
      parentId: entity.parentId,
      taxRate: entity.taxRate,
      color: entity.color,
      requiresPrescription: entity.requiresPrescription,
      requiresLotTracking: entity.requiresLotTracking,
      requiresExpiryDate: entity.requiresExpiryDate,
      defaultMinStock: entity.defaultMinStock,
      order: entity.order,
      isActive: entity.isActive,
    );
  }

  /// Copie avec modifications
  CategoryFormData copyWith({
    String? name,
    String? code,
    String? description,
    String? parentId,
    bool clearParent = false,
    double? taxRate,
    String? color,
    bool? requiresPrescription,
    bool? requiresLotTracking,
    bool? requiresExpiryDate,
    int? defaultMinStock,
    int? order,
    bool? isActive,
  }) {
    return CategoryFormData(
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      taxRate: taxRate ?? this.taxRate,
      color: color ?? this.color,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      requiresLotTracking: requiresLotTracking ?? this.requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      defaultMinStock: defaultMinStock ?? this.defaultMinStock,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'code': code,
      'description': description,
      if (parentId != null) 'parent': parentId,
      'tax_rate': taxRate.toString(),
      'color': color,
      'requires_prescription': requiresPrescription,
      'requires_lot_tracking': requiresLotTracking,
      'requires_expiry_date': requiresExpiryDate,
      'default_min_stock': defaultMinStock,
      'order': order,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    name,
    code,
    description,
    parentId,
    taxRate,
    color,
    requiresPrescription,
    requiresLotTracking,
    requiresExpiryDate,
    defaultMinStock,
    order,
    isActive,
  ];
}