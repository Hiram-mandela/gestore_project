// ========================================
// lib/features/inventory/presentation/state/stock_movements_state.dart
// États pour la gestion des mouvements de stock
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../../domain/entities/paginated_response_entity.dart';
import '../../domain/usecases/stock_movement_usecases.dart';

/// État de base abstrait
abstract class StockMovementsState extends Equatable {
  const StockMovementsState();

  @override
  List<Object?> get props => [];
}

// ==================== ÉTATS DE LISTE ====================

/// État initial
class StockMovementsInitial extends StockMovementsState {
  const StockMovementsInitial();
}

/// Chargement en cours
class StockMovementsLoading extends StockMovementsState {
  const StockMovementsLoading();
}

/// Liste chargée avec succès
class StockMovementsLoaded extends StockMovementsState {
  final PaginatedResponseEntity<StockMovementEntity> response;
  final int currentPage;
  final String? filterMovementType;
  final String? filterReason;
  final String? filterArticleId;
  final String? filterLocationId;
  final String? filterDateFrom;
  final String? filterDateTo;
  final String? searchQuery;

  const StockMovementsLoaded({
    required this.response,
    required this.currentPage,
    this.filterMovementType,
    this.filterReason,
    this.filterArticleId,
    this.filterLocationId,
    this.filterDateFrom,
    this.filterDateTo,
    this.searchQuery,
  });

  /// Nombre total de mouvements
  int get totalCount => response.count;

  /// Nombre de mouvements dans cette page
  int get count => response.resultsCount;

  /// Vérifie si la liste est vide
  bool get isEmpty => response.isEmpty;

  /// Vérifie s'il y a une page suivante
  bool get hasNextPage => response.hasNext;

  /// Vérifie s'il y a une page précédente
  bool get hasPreviousPage => response.hasPrevious;

  /// Vérifie si des filtres sont appliqués
  bool get hasFilters =>
      filterMovementType != null ||
          filterReason != null ||
          filterArticleId != null ||
          filterLocationId != null ||
          filterDateFrom != null ||
          filterDateTo != null ||
          (searchQuery != null && searchQuery!.isNotEmpty);

  @override
  List<Object?> get props => [
    response,
    currentPage,
    filterMovementType,
    filterReason,
    filterArticleId,
    filterLocationId,
    filterDateFrom,
    filterDateTo,
    searchQuery,
  ];
}

/// Erreur lors du chargement
class StockMovementsError extends StockMovementsState {
  final String message;

  const StockMovementsError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS DE DÉTAIL ====================

/// Chargement détail en cours
class StockMovementDetailLoading extends StockMovementsState {
  const StockMovementDetailLoading();
}

/// Détail chargé avec succès
class StockMovementDetailLoaded extends StockMovementsState {
  final StockMovementEntity movement;

  const StockMovementDetailLoaded(this.movement);

  @override
  List<Object?> get props => [movement];
}

/// Erreur détail
class StockMovementDetailError extends StockMovementsState {
  final String message;

  const StockMovementDetailError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== ÉTATS DE RÉSUMÉ ====================

/// Chargement résumé en cours
class MovementsSummaryLoading extends StockMovementsState {
  const MovementsSummaryLoading();
}

/// Résumé chargé avec succès
class MovementsSummaryLoaded extends StockMovementsState {
  final MovementsSummary summary;

  const MovementsSummaryLoaded(this.summary);

  @override
  List<Object?> get props => [summary];
}

/// Erreur résumé
class MovementsSummaryError extends StockMovementsState {
  final String message;

  const MovementsSummaryError(this.message);

  @override
  List<Object?> get props => [message];
}