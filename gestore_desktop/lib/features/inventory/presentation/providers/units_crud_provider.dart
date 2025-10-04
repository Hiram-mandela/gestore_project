// ========================================
// lib/features/inventory/presentation/providers/units_crud_provider.dart
// Provider Riverpod pour le CRUD des unités de mesure
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/usecases/unit_usecases.dart';
import 'unit_state.dart';

// ==================== PROVIDER LISTE UNITÉS ====================

/// Provider pour la liste des unités de mesure
final unitsListProvider = StateNotifierProvider<UnitsListNotifier, UnitState>((ref) {
  return UnitsListNotifier(
    getUnitsUseCase: getIt<GetUnitsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer la liste des unités
class UnitsListNotifier extends StateNotifier<UnitState> {
  final GetUnitsUseCase getUnitsUseCase;
  final Logger logger;

  UnitsListNotifier({
    required this.getUnitsUseCase,
    required this.logger,
  }) : super(const UnitInitial());

  /// Charge toutes les unités
  Future<void> loadUnits({bool? isActive}) async {
    try {
      logger.i('📏 Chargement unités de mesure...');
      state = const UnitLoading();

      final params = GetUnitsParams(isActive: isActive);
      final (units, error) = await getUnitsUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement unités: $error');
        state = UnitError(message: error);
        return;
      }

      if (units != null) {
        logger.i('✅ ${units.length} unités chargées');
        state = UnitLoaded(units: units);
      }
    } catch (e) {
      logger.e('❌ Exception chargement unités: $e');
      state = const UnitError(message: 'Une erreur est survenue');
    }
  }

  /// Recharge les unités
  Future<void> refresh() async {
    await loadUnits(isActive: true);
  }
}

// ==================== PROVIDER FORMULAIRE UNITÉ ====================

/// Provider pour le formulaire unité de mesure
final unitFormProvider = StateNotifierProvider.family<
    UnitFormNotifier,
    UnitFormState,
    (UnitFormMode, String?)>((ref, params) {
  final mode = params.$1;
  final unitId = params.$2;

  return UnitFormNotifier(
    mode: mode,
    unitId: unitId,
    createUnitUseCase: getIt<CreateUnitUseCase>(),
    updateUnitUseCase: getIt<UpdateUnitUseCase>(),
    deleteUnitUseCase: getIt<DeleteUnitUseCase>(),
    getUnitByIdUseCase: getIt<GetUnitByIdUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer le formulaire unité
class UnitFormNotifier extends StateNotifier<UnitFormState> {
  final UnitFormMode mode;
  final String? unitId;
  final CreateUnitUseCase createUnitUseCase;
  final UpdateUnitUseCase updateUnitUseCase;
  final DeleteUnitUseCase deleteUnitUseCase;
  final GetUnitByIdUseCase getUnitByIdUseCase;
  final Logger logger;

  UnitFormNotifier({
    required this.mode,
    this.unitId,
    required this.createUnitUseCase,
    required this.updateUnitUseCase,
    required this.deleteUnitUseCase,
    required this.getUnitByIdUseCase,
    required this.logger,
  }) : super(UnitFormInitial(mode: mode, unitId: unitId)) {
    _initialize();
  }

  /// Initialise le formulaire
  Future<void> _initialize() async {
    if (mode == UnitFormMode.edit && unitId != null) {
      await _loadUnitForEdit();
    } else {
      state = UnitFormReady(
        mode: mode,
        formData: const UnitFormData(),
      );
      logger.d('📝 Formulaire unité prêt pour création');
    }
  }

  /// Charge l'unité pour édition
  Future<void> _loadUnitForEdit() async {
    try {
      logger.d('📝 Chargement unité pour édition: $unitId');
      state = UnitFormLoading(unitId: unitId!);

      final params = GetUnitByIdParams(unitId: unitId!);
      final (unit, error) = await getUnitByIdUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement: $error');
        state = UnitFormError(message: error, mode: mode);
        return;
      }

      if (unit != null) {
        state = UnitFormReady(
          mode: mode,
          unitId: unitId,
          formData: UnitFormData.fromEntity(unit),
        );
        logger.i('✅ Unité chargée: ${unit.name}');
      }
    } catch (e) {
      logger.e('❌ Exception: $e');
      state = UnitFormError(
        message: 'Erreur lors du chargement',
        mode: mode,
      );
    }
  }

  /// Met à jour un champ du formulaire
  void updateField(String field, dynamic value) {
    final currentState = state;
    if (currentState is! UnitFormReady) return;

    UnitFormData updatedData;

    switch (field) {
      case 'name':
        updatedData = currentState.formData.copyWith(name: value as String);
        break;
      case 'symbol':
        updatedData = currentState.formData.copyWith(symbol: value as String);
        break;
      case 'description':
        updatedData = currentState.formData.copyWith(description: value as String);
        break;
      case 'isDecimal':
        updatedData = currentState.formData.copyWith(isDecimal: value as bool);
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
  Map<String, String> _validateFormData(UnitFormData data) {
    final errors = <String, String>{};

    if (data.name.trim().isEmpty) {
      errors['name'] = 'Le nom est requis';
    } else if (data.name.trim().length < 2) {
      errors['name'] = 'Le nom doit contenir au moins 2 caractères';
    }

    if (data.symbol.trim().isEmpty) {
      errors['symbol'] = 'Le symbole est requis';
    } else if (data.symbol.trim().length > 10) {
      errors['symbol'] = 'Le symbole ne peut dépasser 10 caractères';
    }

    return errors;
  }

  /// Soumet le formulaire (création ou édition)
  Future<void> submit() async {
    final currentState = state;
    if (currentState is! UnitFormReady) return;

    // Validation finale
    final errors = _validateFormData(currentState.formData);
    if (errors.isNotEmpty) {
      state = currentState.copyWith(errors: errors);
      return;
    }

    state = UnitFormSubmitting(mode: mode);

    try {
      if (mode == UnitFormMode.create) {
        await _createUnit(currentState.formData);
      } else {
        await _updateUnit(currentState.formData);
      }
    } catch (e) {
      logger.e('❌ Erreur soumission: $e');
      state = UnitFormError(
        message: 'Une erreur est survenue',
        mode: mode,
      );
    }
  }

  /// Crée une nouvelle unité
  Future<void> _createUnit(UnitFormData data) async {
    logger.d('📝 Création unité "${data.name}"');

    final params = CreateUnitParams(
      name: data.name,
      symbol: data.symbol,
      description: data.description,
      isDecimal: data.isDecimal,
      isActive: data.isActive,
    );

    final (unit, error) = await createUnitUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur création: $error');
      state = UnitFormError(message: error, mode: mode);
      return;
    }

    if (unit != null) {
      logger.i('✅ Unité créée: ${unit.name}');
      state = UnitFormSuccess(unit: unit, mode: mode);
    }
  }

  /// Met à jour une unité
  Future<void> _updateUnit(UnitFormData data) async {
    if (unitId == null) return;

    logger.d('📝 Mise à jour unité $unitId');

    final params = UpdateUnitParams(
      id: unitId!,
      name: data.name,
      symbol: data.symbol,
      description: data.description,
      isDecimal: data.isDecimal,
      isActive: data.isActive,
    );

    final (unit, error) = await updateUnitUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur mise à jour: $error');
      state = UnitFormError(message: error, mode: mode);
      return;
    }

    if (unit != null) {
      logger.i('✅ Unité mise à jour: ${unit.name}');
      state = UnitFormSuccess(unit: unit, mode: mode);
    }
  }

  /// Supprime l'unité (mode édition uniquement)
  Future<void> delete() async {
    if (unitId == null || mode != UnitFormMode.edit) return;

    logger.d('🗑️ Suppression unité $unitId');

    state = UnitFormSubmitting(mode: mode);

    final params = DeleteUnitParams(unitId: unitId!);
    final (_, error) = await deleteUnitUseCase(params);

    if (error != null) {
      logger.e('❌ Erreur suppression: $error');
      state = UnitFormError(message: error, mode: mode);
      return;
    }

    logger.i('✅ Unité supprimée');
    state = UnitFormSuccess(
      unit: UnitOfMeasureEntity(
        id: unitId!,
        name: 'DELETED',
        symbol: '',
        isDecimal: false,
        isActive: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
      mode: mode,
    );
  }
}