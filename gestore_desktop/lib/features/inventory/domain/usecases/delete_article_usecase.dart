// ========================================
// lib/features/inventory/domain/usecases/delete_article_usecase.dart
// Use Case pour supprimer un article
// ========================================

import 'package:injectable/injectable.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour la suppression d'un article
class DeleteArticleParams {
  final String articleId;

  const DeleteArticleParams({required this.articleId});
}

/// Use Case pour supprimer un article
@lazySingleton
class DeleteArticleUseCase implements UseCase<void, DeleteArticleParams> {
  final InventoryRepository repository;

  DeleteArticleUseCase({required this.repository});

  @override
  Future<(void, String?)> call(DeleteArticleParams params) async {
    if (params.articleId.trim().isEmpty) {
      return (null, 'ID de l\'article requis');
    }

    return await repository.deleteArticle(params.articleId);
  }
}