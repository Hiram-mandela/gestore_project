// ========================================
// lib/features/inventory/presentation/providers/articles_provider.dart
// Provider pour la gestion des articles
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/get_articles_usecase.dart';
import '../../domain/usecases/search_articles_usecase.dart';
import 'inventory_state.dart';

/// Provider pour l'état des articles
final articlesProvider =
StateNotifierProvider<ArticlesNotifier, InventoryState>((ref) {
  return ArticlesNotifier(
    getArticlesUseCase: getIt<GetArticlesUseCase>(),
    searchArticlesUseCase: getIt<SearchArticlesUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état des articles
class ArticlesNotifier extends StateNotifier<InventoryState> {
  final GetArticlesUseCase getArticlesUseCase;
  final SearchArticlesUseCase searchArticlesUseCase;
  final Logger logger;

  ArticlesNotifier({
    required this.getArticlesUseCase,
    required this.searchArticlesUseCase,
    required this.logger,
  }) : super(const InventoryInitial());

  /// Charge la première page des articles
  Future<void> loadArticles({
    String? search,
    String? categoryId,
    String? brandId,
    bool? isActive,
    bool? isLowStock,
    String? ordering,
  }) async {
    logger.i('📦 Chargement articles...');
    state = const InventoryLoading();

    try {
      final params = GetArticlesParams(
        page: 1,
        pageSize: 20,
        search: search,
        categoryId: categoryId,
        brandId: brandId,
        isActive: isActive,
        isLowStock: isLowStock,
        ordering: ordering,
      );

      final (response, error) = await getArticlesUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement articles: $error');
        state = InventoryError(message: error);
        return;
      }

      if (response != null) {
        logger.i('✅ Articles chargés: ${response.count} total');
        state = InventoryLoaded(
          response: response,
          currentPage: 1,
          currentSearch: search,
          currentCategoryId: categoryId,
          currentBrandId: brandId,
          currentIsActive: isActive,
          currentIsLowStock: isLowStock,
        );
      }
    } catch (e) {
      logger.e('❌ Exception chargement articles: $e');
      state = InventoryError(message: 'Une erreur est survenue');
    }
  }

  /// Charge la page suivante (pagination)
  Future<void> loadMoreArticles() async {
    final currentState = state;
    if (currentState is! InventoryLoaded) return;
    if (!currentState.hasMore) return;

    logger.i('📦 Chargement page suivante...');
    state = InventoryLoadingMore(currentArticles: currentState.articles);

    try {
      final nextPage = currentState.currentPage + 1;

      final params = GetArticlesParams(
        page: nextPage,
        pageSize: 20,
        search: currentState.currentSearch,
        categoryId: currentState.currentCategoryId,
        brandId: currentState.currentBrandId,
        isActive: currentState.currentIsActive,
        isLowStock: currentState.currentIsLowStock,
      );

      final (response, error) = await getArticlesUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur chargement page suivante: $error');
        // Revenir à l'état précédent
        state = currentState;
        return;
      }

      if (response != null) {
        logger.i('✅ Page $nextPage chargée: ${response.results.length} articles');
        state = currentState.copyWithMoreArticles(
          newArticles: response.results,
          newPage: nextPage,
          hasNext: response.hasNext,
        );
      }
    } catch (e) {
      logger.e('❌ Exception chargement page suivante: $e');
      // Revenir à l'état précédent en cas d'erreur
      state = currentState;
    }
  }

  /// Recherche des articles
  Future<void> searchArticles(String query) async {
    if (query.trim().isEmpty) {
      // Si la recherche est vide, recharger tous les articles
      await loadArticles();
      return;
    }

    logger.i('🔍 Recherche: "$query"');
    state = const InventoryLoading();

    try {
      final params = SearchArticlesParams(query: query, page: 1);
      final (response, error) = await searchArticlesUseCase(params);

      if (error != null) {
        logger.e('❌ Erreur recherche: $error');
        state = InventoryError(message: error);
        return;
      }

      if (response != null) {
        logger.i('✅ Résultats recherche: ${response.count} trouvés');
        state = InventoryLoaded(
          response: response,
          currentPage: 1,
          currentSearch: query,
        );
      }
    } catch (e) {
      logger.e('❌ Exception recherche: $e');
      state = InventoryError(message: 'Une erreur est survenue');
    }
  }

  /// Filtre par catégorie
  Future<void> filterByCategory(String? categoryId) async {
    final currentState = state;
    final currentSearch =
    currentState is InventoryLoaded ? currentState.currentSearch : null;

    await loadArticles(
      search: currentSearch,
      categoryId: categoryId,
    );
  }

  /// Filtre par marque
  Future<void> filterByBrand(String? brandId) async {
    final currentState = state;
    final currentSearch =
    currentState is InventoryLoaded ? currentState.currentSearch : null;

    await loadArticles(
      search: currentSearch,
      brandId: brandId,
    );
  }

  /// Filtre stock bas
  Future<void> filterLowStock(bool lowStock) async {
    final currentState = state;
    final currentSearch =
    currentState is InventoryLoaded ? currentState.currentSearch : null;

    await loadArticles(
      search: currentSearch,
      isLowStock: lowStock ? true : null,
    );
  }

  /// Actualise la liste
  Future<void> refresh() async {
    final currentState = state;
    if (currentState is InventoryLoaded) {
      await loadArticles(
        search: currentState.currentSearch,
        categoryId: currentState.currentCategoryId,
        brandId: currentState.currentBrandId,
        isActive: currentState.currentIsActive,
        isLowStock: currentState.currentIsLowStock,
      );
    } else {
      await loadArticles();
    }
  }

  /// Réinitialise les filtres
  Future<void> clearFilters() async {
    logger.d('🧹 Réinitialisation des filtres');
    await loadArticles();
  }
}