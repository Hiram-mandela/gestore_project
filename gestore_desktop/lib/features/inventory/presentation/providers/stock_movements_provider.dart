// ========================================
// lib/features/inventory/presentation/providers/stock_movements_provider.dart
// Provider Riverpod pour la gestion des mouvements de stock
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/paginated_response_entity.dart';
import '../../domain/usecases/stock_movement_usecases.dart';
import 'stock_movements_state.dart';

/// Provider du StateNotifier
final stockMovementsProvider =
StateNotifierProvider<StockMovementsNotifier, StockMovementsState>(
      (ref) => StockMovementsNotifier(
    getStockMovements: getIt<GetStockMovementsUseCase>(),
    getStockMovementById: getIt<GetStockMovementByIdUseCase>(),
    getMovementsSummary: getIt<GetMovementsSummaryUseCase>(),
    logger: getIt<Logger>(),
  ),
);

/// StateNotifier pour gérer l'état des mouvements de stock
class StockMovementsNotifier extends StateNotifier<StockMovementsState> {
  final GetStockMovementsUseCase getStockMovements;
  final GetStockMovementByIdUseCase getStockMovementById;
  final GetMovementsSummaryUseCase getMovementsSummary;
  final Logger logger;

  StockMovementsNotifier({
    required this.getStockMovements,
    required this.getStockMovementById,
    required this.getMovementsSummary,
    required this.logger,
  }) : super(const StockMovementsInitial());

  // ==================== LISTE DES MOUVEMENTS ====================

  /// Charge les mouvements (avec pagination et filtres)
  Future<void> loadMovements({
    int page = 1,
    int pageSize = 20,
    String? movementType,
    String? reason,
    String? articleId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
    String? search,
    String? ordering = '-created_at',
  }) async {
    try {
      logger.i('🔄 Chargement mouvements page $page...');
      state = const StockMovementsLoading();

      final (response, error) = await getStockMovements(
        page: page,
        pageSize: pageSize,
        movementType: movementType,
        reason: reason,
        articleId: articleId,
        locationId: locationId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        search: search,
        ordering: ordering,
      );

      if (error != null) {
        logger.e('❌ Erreur chargement mouvements: $error');
        state = StockMovementsError(error);
        return;
      }

      if (response == null) {
        logger.w('⚠️ Aucun mouvement trouvé');
        state = StockMovementsLoaded(
          response: const PaginatedResponseEntity(
            count: 0,
            results: [],
          ),
          currentPage: page,
          filterMovementType: movementType,
          filterReason: reason,
          filterArticleId: articleId,
          filterLocationId: locationId,
          filterDateFrom: dateFrom,
          filterDateTo: dateTo,
          searchQuery: search,
        );
        return;
      }

      logger.i('✅ ${response.count} mouvements chargés (page $page)');
      state = StockMovementsLoaded(
        response: response,
        currentPage: page,
        filterMovementType: movementType,
        filterReason: reason,
        filterArticleId: articleId,
        filterLocationId: locationId,
        filterDateFrom: dateFrom,
        filterDateTo: dateTo,
        searchQuery: search,
      );
    } catch (e) {
      logger.e('❌ Exception chargement mouvements: $e');
      state = StockMovementsError(e.toString());
    }
  }

  /// Charge la page suivante
  Future<void> loadNextPage() async {
    if (state is StockMovementsLoaded) {
      final currentState = state as StockMovementsLoaded;
      if (currentState.hasNextPage) {
        await loadMovements(
          page: currentState.currentPage + 1,
          movementType: currentState.filterMovementType,
          reason: currentState.filterReason,
          articleId: currentState.filterArticleId,
          locationId: currentState.filterLocationId,
          dateFrom: currentState.filterDateFrom,
          dateTo: currentState.filterDateTo,
          search: currentState.searchQuery,
        );
      }
    }
  }

  /// Charge la page précédente
  Future<void> loadPreviousPage() async {
    if (state is StockMovementsLoaded) {
      final currentState = state as StockMovementsLoaded;
      if (currentState.hasPreviousPage && currentState.currentPage > 1) {
        await loadMovements(
          page: currentState.currentPage - 1,
          movementType: currentState.filterMovementType,
          reason: currentState.filterReason,
          articleId: currentState.filterArticleId,
          locationId: currentState.filterLocationId,
          dateFrom: currentState.filterDateFrom,
          dateTo: currentState.filterDateTo,
          search: currentState.searchQuery,
        );
      }
    }
  }

  /// Recharge les mouvements (garde les filtres et la page)
  Future<void> refresh() async {
    if (state is StockMovementsLoaded) {
      final currentState = state as StockMovementsLoaded;
      await loadMovements(
        page: currentState.currentPage,
        movementType: currentState.filterMovementType,
        reason: currentState.filterReason,
        articleId: currentState.filterArticleId,
        locationId: currentState.filterLocationId,
        dateFrom: currentState.filterDateFrom,
        dateTo: currentState.filterDateTo,
        search: currentState.searchQuery,
      );
    } else {
      await loadMovements();
    }
  }

  /// Recherche de mouvements
  Future<void> searchMovements(String query) async {
    final currentState = state is StockMovementsLoaded ? state as StockMovementsLoaded : null;

    await loadMovements(
      page: 1,
      search: query,
      movementType: currentState?.filterMovementType,
      reason: currentState?.filterReason,
      articleId: currentState?.filterArticleId,
      locationId: currentState?.filterLocationId,
      dateFrom: currentState?.filterDateFrom,
      dateTo: currentState?.filterDateTo,
    );
  }

  // ==================== DÉTAIL D'UN MOUVEMENT ====================

  /// Charge le détail d'un mouvement
  Future<void> loadMovementDetail(String id) async {
    try {
      logger.i('🔄 Chargement détail mouvement $id...');
      state = const StockMovementDetailLoading();

      final (movement, error) = await getStockMovementById(id);

      if (error != null) {
        logger.e('❌ Erreur chargement détail: $error');
        state = StockMovementDetailError(error);
        return;
      }

      if (movement == null) {
        logger.w('⚠️ Mouvement non trouvé');
        state = const StockMovementDetailError('Mouvement non trouvé');
        return;
      }

      logger.i('✅ Détail mouvement chargé');
      state = StockMovementDetailLoaded(movement);
    } catch (e) {
      logger.e('❌ Exception chargement détail: $e');
      state = StockMovementDetailError(e.toString());
    }
  }

  // ==================== RÉSUMÉ DES MOUVEMENTS ====================

  /// Charge le résumé des mouvements
  Future<void> loadSummary({
    String? dateFrom,
    String? dateTo,
  }) async {
    try {
      logger.i('🔄 Chargement résumé mouvements...');
      state = const MovementsSummaryLoading();

      final (summary, error) = await getMovementsSummary(
        dateFrom: dateFrom,
        dateTo: dateTo,
      );

      if (error != null) {
        logger.e('❌ Erreur chargement résumé: $error');
        state = MovementsSummaryError(error);
        return;
      }

      if (summary == null) {
        logger.w('⚠️ Résumé non disponible');
        state = const MovementsSummaryError('Résumé non disponible');
        return;
      }

      logger.i('✅ Résumé chargé: ${summary.totalMovements} mouvements');
      state = MovementsSummaryLoaded(summary);
    } catch (e) {
      logger.e('❌ Exception chargement résumé: $e');
      state = MovementsSummaryError(e.toString());
    }
  }

  // ==================== RESET ====================

  /// Réinitialise l'état
  void reset() {
    logger.i('🔄 Reset état mouvements');
    state = const StockMovementsInitial();
  }
}