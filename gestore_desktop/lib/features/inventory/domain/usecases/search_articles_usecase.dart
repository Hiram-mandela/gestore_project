// ========================================
// lib/features/inventory/domain/usecases/search_articles_usecase.dart
// Use case pour rechercher des articles
// ========================================

import '../../../../core/usecases/usecase.dart';
import '../entities/article_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour SearchArticlesUseCase
class SearchArticlesParams {
  final String query;
  final int page;

  const SearchArticlesParams({
    required this.query,
    this.page = 1,
  });

  @override
  String toString() => 'SearchArticlesParams(query: $query, page: $page)';
}

/// Use case pour rechercher des articles
class SearchArticlesUseCase
    implements UseCase<PaginatedResponseEntity<ArticleEntity>, SearchArticlesParams> {
  final InventoryRepository repository;

  SearchArticlesUseCase(this.repository);

  @override
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> call(
      SearchArticlesParams params,
      ) async {
    return await repository.searchArticles(
      query: params.query,
      page: params.page,
    );
  }
}