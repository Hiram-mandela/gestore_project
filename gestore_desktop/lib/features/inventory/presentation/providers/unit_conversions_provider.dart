// ========================================
// lib/features/inventory/presentation/providers/unit_conversions_provider.dart
// Provider Riverpod pour la gestion des conversions d'unités
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/unit_conversion_usecases.dart';
import 'unit_conversions_state.dart';

/// Provider du StateNotifier
final unitConversionsProvider =
StateNotifierProvider<UnitConversionsNotifier, UnitConversionsState>(
      (ref) => UnitConversionsNotifier(
    getUnitConversions: getIt<GetUnitConversionsUseCase>(),
    getUnitConversionById: getIt<GetUnitConversionByIdUseCase>(),
    createUnitConversion: getIt<CreateUnitConversionUseCase>(),
    updateUnitConversion: getIt<UpdateUnitConversionUseCase>(),
    deleteUnitConversion: getIt<DeleteUnitConversionUseCase>(),
    calculateConversion: getIt<CalculateConversionUseCase>(),
    logger: getIt<Logger>(),
  ),
);

/// StateNotifier pour gérer l'état des conversions d'unités
class UnitConversionsNotifier extends StateNotifier<UnitConversionsState> {
  final GetUnitConversionsUseCase getUnitConversions;
  final GetUnitConversionByIdUseCase getUnitConversionById;
  final CreateUnitConversionUseCase createUnitConversion;
  final UpdateUnitConversionUseCase updateUnitConversion;
  final DeleteUnitConversionUseCase deleteUnitConversion;
  final CalculateConversionUseCase calculateConversion;
  final Logger logger;

  UnitConversionsNotifier({
    required this.getUnitConversions,
    required this.getUnitConversionById,
    required this.createUnitConversion,
    required this.updateUnitConversion,
    required this.deleteUnitConversion,
    required this.calculateConversion,
    required this.logger,
  }) : super(const UnitConversionsInitial());

  // ==================== LISTE DES CONVERSIONS ====================

  /// Charge toutes les conversions (avec filtres optionnels)
  Future<void> loadConversions({
    String? fromUnitId,
    String? toUnitId,
  }) async {
    try {
      logger.i('🔄 Chargement conversions unités...');
      state = const UnitConversionsLoading();

      final (conversions, error) = await getUnitConversions(
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
      );

      if (error != null) {
        logger.e('❌ Erreur chargement conversions: $error');
        state = UnitConversionsError(error);
        return;
      }

      if (conversions == null) {
        logger.w('⚠️ Aucune conversion trouvée');
        state = UnitConversionsLoaded(
          conversions: const [],
          filterFromUnitId: fromUnitId,
          filterToUnitId: toUnitId,
        );
        return;
      }

      logger.i('✅ ${conversions.length} conversions chargées');
      state = UnitConversionsLoaded(
        conversions: conversions,
        filterFromUnitId: fromUnitId,
        filterToUnitId: toUnitId,
      );
    } catch (e) {
      logger.e('❌ Exception chargement conversions: $e');
      state = UnitConversionsError(e.toString());
    }
  }

  /// Recharge les conversions (garde les filtres)
  Future<void> refresh() async {
    if (state is UnitConversionsLoaded) {
      final currentState = state as UnitConversionsLoaded;
      await loadConversions(
        fromUnitId: currentState.filterFromUnitId,
        toUnitId: currentState.filterToUnitId,
      );
    } else {
      await loadConversions();
    }
  }

  // ==================== DÉTAIL D'UNE CONVERSION ====================

  /// Charge le détail d'une conversion
  Future<void> loadConversionDetail(String id) async {
    try {
      logger.i('🔄 Chargement détail conversion $id...');
      state = const UnitConversionDetailLoading();

      final (conversion, error) = await getUnitConversionById(id);

      if (error != null) {
        logger.e('❌ Erreur chargement détail: $error');
        state = UnitConversionDetailError(error);
        return;
      }

      if (conversion == null) {
        logger.w('⚠️ Conversion non trouvée');
        state = const UnitConversionDetailError('Conversion non trouvée');
        return;
      }

      logger.i('✅ Détail conversion chargé: ${conversion.conversionDisplay}');
      state = UnitConversionDetailLoaded(conversion);
    } catch (e) {
      logger.e('❌ Exception chargement détail: $e');
      state = UnitConversionDetailError(e.toString());
    }
  }

  // ==================== CRÉATION ====================

  /// Crée une nouvelle conversion
  Future<bool> createNewConversion({
    required String fromUnitId,
    required String toUnitId,
    required double conversionFactor,
  }) async {
    try {
      logger.i('🔄 Création conversion...');
      state = const UnitConversionSaving();

      final (conversion, error) = await createUnitConversion(
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
        conversionFactor: conversionFactor,
      );

      if (error != null) {
        logger.e('❌ Erreur création: $error');
        state = UnitConversionsError(error);
        return false;
      }

      if (conversion == null) {
        logger.w('⚠️ Conversion non créée');
        state = const UnitConversionsError('Erreur lors de la création');
        return false;
      }

      logger.i('✅ Conversion créée: ${conversion.conversionDisplay}');
      state = UnitConversionSaved(
        conversion: conversion,
        message: 'Conversion créée avec succès',
      );

      // Recharge la liste
      await loadConversions();
      return true;
    } catch (e) {
      logger.e('❌ Exception création: $e');
      state = UnitConversionsError(e.toString());
      return false;
    }
  }

  // ==================== MODIFICATION ====================

  /// Modifie une conversion existante
  Future<bool> updateExistingConversion({
    required String id,
    String? fromUnitId,
    String? toUnitId,
    double? conversionFactor,
  }) async {
    try {
      logger.i('🔄 Modification conversion $id...');
      state = const UnitConversionSaving();

      final (conversion, error) = await updateUnitConversion(
        id: id,
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
        conversionFactor: conversionFactor,
      );

      if (error != null) {
        logger.e('❌ Erreur modification: $error');
        state = UnitConversionsError(error);
        return false;
      }

      if (conversion == null) {
        logger.w('⚠️ Conversion non modifiée');
        state = const UnitConversionsError('Erreur lors de la modification');
        return false;
      }

      logger.i('✅ Conversion modifiée: ${conversion.conversionDisplay}');
      state = UnitConversionSaved(
        conversion: conversion,
        message: 'Conversion modifiée avec succès',
      );

      // Recharge la liste
      await loadConversions();
      return true;
    } catch (e) {
      logger.e('❌ Exception modification: $e');
      state = UnitConversionsError(e.toString());
      return false;
    }
  }

  // ==================== SUPPRESSION ====================

  /// Supprime une conversion
  Future<bool> deleteConversion(String id) async {
    try {
      logger.i('🔄 Suppression conversion $id...');
      state = const UnitConversionDeleting();

      final (_, error) = await deleteUnitConversion(id);

      if (error != null) {
        logger.e('❌ Erreur suppression: $error');
        state = UnitConversionsError(error);
        return false;
      }

      logger.i('✅ Conversion supprimée');
      state = const UnitConversionDeleted('Conversion supprimée avec succès');

      // Recharge la liste
      await loadConversions();
      return true;
    } catch (e) {
      logger.e('❌ Exception suppression: $e');
      state = UnitConversionsError(e.toString());
      return false;
    }
  }

  // ==================== CALCUL DE CONVERSION ====================

  /// Calcule une conversion à la volée
  Future<void> calculate({
    required String fromUnitId,
    required String toUnitId,
    required double quantity,
  }) async {
    try {
      logger.i('🔄 Calcul conversion $quantity...');
      state = const ConversionCalculating();

      final (result, error) = await calculateConversion(
        fromUnitId: fromUnitId,
        toUnitId: toUnitId,
        quantity: quantity,
      );

      if (error != null) {
        logger.e('❌ Erreur calcul: $error');
        state = ConversionCalculationError(error);
        return;
      }

      if (result == null) {
        logger.w('⚠️ Résultat non disponible');
        state = const ConversionCalculationError('Conversion non disponible');
        return;
      }

      logger.i('✅ Calcul effectué: ${result.displayText}');
      state = ConversionCalculated(result);
    } catch (e) {
      logger.e('❌ Exception calcul: $e');
      state = ConversionCalculationError(e.toString());
    }
  }

  // ==================== RESET ====================

  /// Réinitialise l'état
  void reset() {
    logger.i('🔄 Reset état conversions');
    state = const UnitConversionsInitial();
  }
}