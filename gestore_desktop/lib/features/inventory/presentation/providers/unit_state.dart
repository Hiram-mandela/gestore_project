// ========================================
// lib/features/inventory/presentation/providers/unit_state.dart
// États pour la gestion des unités de mesure
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/unit_of_measure_entity.dart';

/// État de base pour les unités de mesure
abstract class UnitState extends Equatable {
  const UnitState();

  @override
  List<Object?> get props => [];
}

// ==================== ÉTATS LISTE ====================

/// État initial
class UnitInitial extends UnitState {
  const UnitInitial();
}

/// Chargement en cours
class UnitLoading extends UnitState {
  const UnitLoading();
}

/// Liste chargée avec succès
class UnitLoaded extends UnitState {
  final List<UnitOfMeasureEntity> units;

  const UnitLoaded({required this.units});

  @override
  List<Object?> get props => [units];
}

/// Erreur
class UnitError extends UnitState {
  final String message;

  const UnitError({required this.message});

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS FORMULAIRE ====================

/// Mode du formulaire unité
enum UnitFormMode {
  create,
  edit,
}

/// État de base pour le formulaire unité
abstract class UnitFormState extends Equatable {
  const UnitFormState();

  @override
  List<Object?> get props => [];
}

/// État initial du formulaire
class UnitFormInitial extends UnitFormState {
  final UnitFormMode mode;
  final String? unitId;

  const UnitFormInitial({
    required this.mode,
    this.unitId,
  });

  @override
  List<Object?> get props => [mode, unitId];
}

/// Chargement (pour mode édition)
class UnitFormLoading extends UnitFormState {
  final String unitId;

  const UnitFormLoading({required this.unitId});

  @override
  List<Object?> get props => [unitId];
}

/// Formulaire prêt
class UnitFormReady extends UnitFormState {
  final UnitFormMode mode;
  final String? unitId;
  final UnitFormData formData;
  final Map<String, String> errors;

  const UnitFormReady({
    required this.mode,
    this.unitId,
    required this.formData,
    this.errors = const {},
  });

  bool get isValid => errors.isEmpty;
  bool get isCreateMode => mode == UnitFormMode.create;
  bool get isEditMode => mode == UnitFormMode.edit;

  UnitFormReady copyWith({
    UnitFormData? formData,
    Map<String, String>? errors,
  }) {
    return UnitFormReady(
      mode: mode,
      unitId: unitId,
      formData: formData ?? this.formData,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [mode, unitId, formData, errors];
}

/// Soumission en cours
class UnitFormSubmitting extends UnitFormState {
  final UnitFormMode mode;

  const UnitFormSubmitting({required this.mode});

  @override
  List<Object?> get props => [mode];
}

/// Succès
class UnitFormSuccess extends UnitFormState {
  final UnitOfMeasureEntity unit;
  final UnitFormMode mode;

  const UnitFormSuccess({
    required this.unit,
    required this.mode,
  });

  @override
  List<Object?> get props => [unit, mode];
}

/// Erreur formulaire
class UnitFormError extends UnitFormState {
  final String message;
  final UnitFormMode mode;

  const UnitFormError({
    required this.message,
    required this.mode,
  });

  @override
  List<Object?> get props => [message, mode];
}

// ==================== DONNÉES FORMULAIRE ====================

/// Données du formulaire unité de mesure
class UnitFormData extends Equatable {
  final String name;
  final String symbol;
  final String description;
  final bool isDecimal;
  final bool isActive;

  const UnitFormData({
    this.name = '',
    this.symbol = '',
    this.description = '',
    this.isDecimal = false,
    this.isActive = true,
  });

  /// Crée FormData depuis une Entity (pour édition)
  factory UnitFormData.fromEntity(UnitOfMeasureEntity entity) {
    return UnitFormData(
      name: entity.name,
      symbol: entity.symbol,
      description: entity.description ?? '',
      isDecimal: entity.isDecimal,
      isActive: entity.isActive,
    );
  }

  /// Copie avec modifications
  UnitFormData copyWith({
    String? name,
    String? symbol,
    String? description,
    bool? isDecimal,
    bool? isActive,
  }) {
    return UnitFormData(
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      description: description ?? this.description,
      isDecimal: isDecimal ?? this.isDecimal,
      isActive: isActive ?? this.isActive,
    );
  }

  /// Convertit en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'symbol': symbol,
      'description': description,
      'is_decimal': isDecimal,
      'is_active': isActive,
    };
  }

  @override
  List<Object?> get props => [
    name,
    symbol,
    description,
    isDecimal,
    isActive,
  ];
}