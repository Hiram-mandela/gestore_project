// ========================================
// lib/features/inventory/domain/usecases/get_articles_usecase.dart
// Use case pour récupérer la liste des articles
// ========================================

import '../../../../core/usecases/usecase.dart';
import '../entities/article_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour GetArticlesUseCase
class GetArticlesParams {
  final int page;
  final int pageSize;
  final String? search;
  final String? categoryId;
  final String? brandId;
  final bool? isActive;
  final bool? isLowStock;
  final String? ordering;

  const GetArticlesParams({
    this.page = 1,
    this.pageSize = 20,
    this.search,
    this.categoryId,
    this.brandId,
    this.isActive,
    this.isLowStock,
    this.ordering,
  });

  @override
  String toString() => 'GetArticlesParams(page: $page, pageSize: $pageSize, search: $search)';
}

/// Use case pour récupérer la liste paginée des articles
class GetArticlesUseCase
    implements UseCase<PaginatedResponseEntity<ArticleEntity>, GetArticlesParams> {
  final InventoryRepository repository;

  GetArticlesUseCase(this.repository);

  @override
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> call(
      GetArticlesParams params,
      ) async {
    return await repository.getArticles(
      page: params.page,
      pageSize: params.pageSize,
      search: params.search,
      categoryId: params.categoryId,
      brandId: params.brandId,
      isActive: params.isActive,
      isLowStock: params.isLowStock,
      ordering: params.ordering,
    );
  }
}