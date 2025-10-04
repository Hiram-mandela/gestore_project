// ========================================
// lib/features/inventory/domain/usecases/get_article_detail_usecase.dart
// Use Case pour récupérer le détail complet d'un article
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/article_detail_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour GetArticleDetailUseCase
class GetArticleDetailParams {
  final String articleId;

  const GetArticleDetailParams({required this.articleId});
}

/// Use Case pour récupérer le détail complet d'un article
/// Retourne un tuple (ArticleDetailEntity?, String? error)
@lazySingleton
class GetArticleDetailUseCase
    implements UseCase<ArticleDetailEntity, GetArticleDetailParams> {
  final InventoryRepository repository;

  GetArticleDetailUseCase({required this.repository});

  @override
  Future<(ArticleDetailEntity?, String?)> call(
      GetArticleDetailParams params,
      ) async {
    return await repository.getArticleDetailById(params.articleId);
  }
}