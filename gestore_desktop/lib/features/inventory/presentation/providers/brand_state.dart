// ========================================
// lib/features/inventory/presentation/providers/brand_state.dart
// États pour la gestion des marques
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/brand_entity.dart';

/// État de base pour les marques
abstract class BrandState extends Equatable {
  const BrandState();

  @override
  List<Object?> get props => [];
}

// ==================== ÉTATS LISTE ====================

/// État initial
class BrandInitial extends BrandState {
  const BrandInitial();
}

/// Chargement en cours
class BrandLoading extends BrandState {
  const BrandLoading();
}

/// Liste chargée avec succès
class BrandLoaded extends BrandState {
  final List<BrandEntity> brands;

  const BrandLoaded({required this.brands});

  @override
  List<Object?> get props => [brands];
}

/// Erreur
class BrandError extends BrandState {
  final String message;

  const BrandError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS FORMULAIRE ====================

/// Mode du formulaire marque
enum BrandFormMode {
  create,
  edit,
}

/// État de base pour le formulaire marque
abstract class BrandFormState extends Equatable {
  const BrandFormState();

  @override
  List<Object?> get props => [];
}

/// État initial du formulaire
class BrandFormInitial extends BrandFormState {
  final BrandFormMode mode;
  final String? brandId;

  const BrandFormInitial({
    required this.mode,
    this.brandId,
  });

  @override
  List<Object?> get props => [mode, brandId];
}

/// Chargement (pour mode édition)
class BrandFormLoading extends BrandFormState {
  final String brandId;

  const BrandFormLoading({required this.brandId});

  @override
  List<Object?> get props => [brandId];
}

/// Formulaire prêt
class BrandFormReady extends BrandFormState {
  final BrandFormMode mode;
  final String? brandId;
  final BrandFormData formData;
  final Map<String, String> errors;

  const BrandFormReady({
    required this.mode,
    this.brandId,
    required this.formData,
    this.errors = const {},
  });

  bool get isValid => errors.isEmpty;
  bool get isCreateMode => mode == BrandFormMode.create;
  bool get isEditMode => mode == BrandFormMode.edit;

  BrandFormReady copyWith({
    BrandFormData? formData,
    Map<String, String>? errors,
  }) {
    return BrandFormReady(
      mode: mode,
      brandId: brandId,
      formData: formData ?? this.formData,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [mode, brandId, formData, errors];
}

/// Soumission en cours
class BrandFormSubmitting extends BrandFormState {
  final BrandFormMode mode;

  const BrandFormSubmitting({required this.mode});

  @override
  List<Object?> get props => [mode];
}

/// Succès
class BrandFormSuccess extends BrandFormState {
  final BrandEntity brand;
  final BrandFormMode mode;

  const BrandFormSuccess({
    required this.brand,
    required this.mode,
  });

  @override
  List<Object?> get props => [brand, mode];
}

/// Erreur formulaire
class BrandFormError extends BrandFormState {
  final String message;
  final BrandFormMode mode;

  const BrandFormError({
    required this.message,
    required this.mode,
  });

  @override
  List<Object?> get props => [message, mode];
}

// ==================== DONNÉES FORMULAIRE ====================

/// Données du formulaire marque
class BrandFormData extends Equatable {
  final String name;
  final String description;
  final String? logoPath; // Chemin local du logo sélectionné
  final String? logoUrl; // URL du logo existant (mode édition)
  final String website;
  final bool isActive;

  const BrandFormData({
    this.name = '',
    this.description = '',
    this.logoPath,
    this.logoUrl,
    this.website = '',
    this.isActive = true,
  });

  /// Crée FormData depuis une Entity (pour édition)
  factory BrandFormData.fromEntity(BrandEntity entity) {
    return BrandFormData(
      name: entity.name,
      description: entity.description ?? '',
      logoUrl: entity.logoUrl,
      website: entity.website ?? '',
      isActive: entity.isActive,
    );
  }

  /// Copie avec modifications
  BrandFormData copyWith({
    String? name,
    String? description,
    String? logoPath,
    bool clearLogo = false,
    String? logoUrl,
    String? website,
    bool? isActive,
  }) {
    return BrandFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      logoPath: clearLogo ? null : (logoPath ?? this.logoPath),
      logoUrl: logoUrl ?? this.logoUrl,
      website: website ?? this.website,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      if (website.isNotEmpty) 'website': website,
      'is_active': isActive,
      // Note: logo sera géré séparément avec FormData/Multipart
    };
  }

  @override
  List<Object?> get props => [
    name,
    description,
    logoPath,
    logoUrl,
    website,
    isActive,
  ];
}