// ========================================
// lib/features/sales/presentation/providers/discounts_list_provider.dart
// Provider pour la liste des remises/promotions
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/get_discounts_usecase.dart';
import '../../domain/usecases/delete_discount_usecase.dart';
import '../../domain/usecases/update_discount_usecase.dart';
import 'discounts_list_state.dart';

/// Provider pour la liste des remises
final discountsListProvider =
StateNotifierProvider<DiscountsListNotifier, DiscountsListState>(
      (ref) {
    return DiscountsListNotifier(
      getDiscountsUseCase: getIt<GetDiscountsUseCase>(),
      deleteDiscountUseCase: getIt<DeleteDiscountUseCase>(),
      updateDiscountUseCase: getIt<UpdateDiscountUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour la gestion de la liste
class DiscountsListNotifier extends StateNotifier<DiscountsListState> {
  final GetDiscountsUseCase getDiscountsUseCase;
  final DeleteDiscountUseCase deleteDiscountUseCase;
  final UpdateDiscountUseCase updateDiscountUseCase;
  final Logger logger;

  // Filtres actuels
  String? _currentType;
  String? _currentScope;
  bool? _currentStatus;
  bool _showActiveOnly = false;
  String _searchQuery = '';

  DiscountsListNotifier({
    required this.getDiscountsUseCase,
    required this.deleteDiscountUseCase,
    required this.updateDiscountUseCase,
    required this.logger,
  }) : super(const DiscountsListInitial());

  /// Charge les remises avec pagination
  Future<void> loadDiscounts({int page = 1}) async {
    if (state is DiscountsListLoading) return;

    state = const DiscountsListLoading();
    logger.d('🎁 Chargement remises (page $page)...');

    final (paginatedResponse, error) = await getDiscountsUseCase(
      page: page,
      pageSize: 20,
      search: _searchQuery.isNotEmpty ? _searchQuery : null,
      discountType: _currentType,
      scope: _currentScope,
      isActive: _currentStatus,
      activeOnly: _showActiveOnly,
    );

    if (error != null) {
      logger.e('❌ Erreur chargement: $error');
      state = DiscountsListError(error);
      return;
    }

    if (paginatedResponse == null) {
      state = const DiscountsListError('Erreur lors du chargement des remises');
      return;
    }

    logger.i('✅ ${paginatedResponse.results.length} remises chargées');
    state = DiscountsListLoaded(
      discounts: paginatedResponse.results,
      totalCount: paginatedResponse.count,
      currentPage: page,
      hasNextPage: paginatedResponse.next != null,
      selectedType: _currentType,
      selectedScope: _currentScope,
      selectedStatus: _currentStatus,
      showActiveOnly: _showActiveOnly,
      searchQuery: _searchQuery,
    );
  }

  /// Charge la page suivante
  Future<void> loadNextPage() async {
    if (state is! DiscountsListLoaded) return;

    final currentState = state as DiscountsListLoaded;
    if (!currentState.hasNextPage) return;

    await loadDiscounts(page: currentState.currentPage + 1);
  }

  /// Filtre par type de remise
  void filterByType(String? type) {
    _currentType = type;
    logger.d('🔍 Filtre par type: $type');
    loadDiscounts();
  }

  /// Filtre par portée
  void filterByScope(String? scope) {
    _currentScope = scope;
    logger.d('🔍 Filtre par portée: $scope');
    loadDiscounts();
  }

  /// Filtre par statut actif/inactif
  void filterByStatus(bool? isActive) {
    _currentStatus = isActive;
    logger.d('🔍 Filtre par statut: $isActive');
    loadDiscounts();
  }

  /// Afficher uniquement les remises actuellement actives
  void toggleActiveOnly(bool activeOnly) {
    _showActiveOnly = activeOnly;
    logger.d('🔍 Afficher actives uniquement: $activeOnly');
    loadDiscounts();
  }

  /// Recherche par nom ou code
  void searchDiscounts(String query) {
    _searchQuery = query;
    logger.d('🔍 Recherche: $query');
    loadDiscounts();
  }

  /// Supprime une remise
  Future<void> deleteDiscount(String id) async {
    if (state is! DiscountsListLoaded) return;

    logger.d('🗑️ Suppression remise $id');

    final (_, error) = await deleteDiscountUseCase(id);

    if (error != null) {
      logger.e('❌ Erreur suppression: $error');
      state = DiscountsListError(error);
      return;
    }

    logger.i('✅ Remise supprimée');
    state = const DiscountDeleted('Remise supprimée avec succès');

    // Recharger la liste
    await loadDiscounts();
  }

  /// Bascule l'état actif/inactif d'une remise
  Future<void> toggleActivation(String id, bool currentStatus) async {
    if (state is! DiscountsListLoaded) return;

    logger.d('🔄 Toggle activation remise $id: ${!currentStatus}');

    final (_, error) = await updateDiscountUseCase(
      id,
      {'is_active': !currentStatus},
    );

    if (error != null) {
      logger.e('❌ Erreur toggle activation: $error');
      state = DiscountsListError(error);
      return;
    }

    logger.i('✅ État modifié');

    // Recharger la liste
    await loadDiscounts();
  }

  /// Réinitialise tous les filtres
  void resetFilters() {
    _currentType = null;
    _currentScope = null;
    _currentStatus = null;
    _showActiveOnly = false;
    _searchQuery = '';

    loadDiscounts();
  }
}