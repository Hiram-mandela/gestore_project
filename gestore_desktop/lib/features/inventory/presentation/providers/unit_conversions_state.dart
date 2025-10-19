// ========================================
// lib/features/inventory/presentation/state/unit_conversions_state.dart
// États pour la gestion des conversions d'unités
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/unit_conversion_entity.dart';
import '../../domain/usecases/unit_conversion_usecases.dart';

/// État de base abstrait
abstract class UnitConversionsState extends Equatable {
  const UnitConversionsState();

  @override
  List<Object?> get props => [];
}

// ==================== ÉTATS DE LISTE ====================

/// État initial
class UnitConversionsInitial extends UnitConversionsState {
  const UnitConversionsInitial();
}

/// Chargement en cours
class UnitConversionsLoading extends UnitConversionsState {
  const UnitConversionsLoading();
}

/// Liste chargée avec succès
class UnitConversionsLoaded extends UnitConversionsState {
  final List<UnitConversionEntity> conversions;
  final String? filterFromUnitId;
  final String? filterToUnitId;

  const UnitConversionsLoaded({
    required this.conversions,
    this.filterFromUnitId,
    this.filterToUnitId,
  });

  /// Nombre de conversions
  int get count => conversions.length;

  /// Vérifie si la liste est vide
  bool get isEmpty => conversions.isEmpty;

  /// Vérifie si des filtres sont appliqués
  bool get hasFilters => filterFromUnitId != null || filterToUnitId != null;

  @override
  List<Object?> get props => [conversions, filterFromUnitId, filterToUnitId];
}

/// Erreur lors du chargement
class UnitConversionsError extends UnitConversionsState {
  final String message;

  const UnitConversionsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS DE DÉTAIL ====================

/// Chargement détail en cours
class UnitConversionDetailLoading extends UnitConversionsState {
  const UnitConversionDetailLoading();
}

/// Détail chargé avec succès
class UnitConversionDetailLoaded extends UnitConversionsState {
  final UnitConversionEntity conversion;

  const UnitConversionDetailLoaded(this.conversion);

  @override
  List<Object?> get props => [conversion];
}

/// Erreur détail
class UnitConversionDetailError extends UnitConversionsState {
  final String message;

  const UnitConversionDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS D'OPÉRATIONS CRUD ====================

/// Création/Modification en cours
class UnitConversionSaving extends UnitConversionsState {
  const UnitConversionSaving();
}

/// Sauvegarde réussie
class UnitConversionSaved extends UnitConversionsState {
  final UnitConversionEntity conversion;
  final String message;

  const UnitConversionSaved({
    required this.conversion,
    required this.message,
  });

  @override
  List<Object?> get props => [conversion, message];
}

/// Suppression en cours
class UnitConversionDeleting extends UnitConversionsState {
  const UnitConversionDeleting();
}

/// Suppression réussie
class UnitConversionDeleted extends UnitConversionsState {
  final String message;

  const UnitConversionDeleted(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS DE CALCUL ====================

/// Calcul de conversion en cours
class ConversionCalculating extends UnitConversionsState {
  const ConversionCalculating();
}

/// Calcul de conversion réussi
class ConversionCalculated extends UnitConversionsState {
  final ConversionResult result;

  const ConversionCalculated(this.result);

  @override
  List<Object?> get props => [result];
}

/// Erreur de calcul
class ConversionCalculationError extends UnitConversionsState {
  final String message;

  const ConversionCalculationError(this.message);

  @override
  List<Object?> get props => [message];
}