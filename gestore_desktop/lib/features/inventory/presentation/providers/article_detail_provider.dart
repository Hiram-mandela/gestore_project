// ========================================
// lib/features/inventory/presentation/providers/article_detail_provider.dart
// Provider Riverpod pour le détail d'un article
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/get_article_detail_usecase.dart';
import 'article_detail_state.dart';

/// Provider pour le détail d'un article
final articleDetailProvider =
StateNotifierProvider.family<ArticleDetailNotifier, ArticleDetailState, String>(
      (ref, articleId) {
    return ArticleDetailNotifier(
      articleId: articleId,
      getArticleDetailUseCase: getIt<GetArticleDetailUseCase>(),
      logger: getIt<Logger>(),
    );
  },
);

/// Notifier pour gérer l'état du détail article
class ArticleDetailNotifier extends StateNotifier<ArticleDetailState> {
  final String articleId;
  final GetArticleDetailUseCase getArticleDetailUseCase;
  final Logger logger;

  ArticleDetailNotifier({
    required this.articleId,
    required this.getArticleDetailUseCase,
    required this.logger,
  }) : super(const ArticleDetailInitial()) {
    // Charger automatiquement le détail à l'initialisation
    loadArticleDetail();
  }

  /// Charge le détail de l'article
  Future<void> loadArticleDetail() async {
    try {
      logger.d('🔄 Chargement détail article: $articleId');
      state = ArticleDetailLoading(articleId: articleId);

      final params = GetArticleDetailParams(articleId: articleId);
      final result = await getArticleDetailUseCase(params);

      final error = result.$2;
      final article = result.$1;

      if (error != null) {
        logger.e('❌ Erreur chargement détail: $error');
        state = ArticleDetailError(
          message: error,
          articleId: articleId,
        );
        return;
      }

      if (article == null) {
        logger.e('❌ Article null retourné');
        state = const ArticleDetailError(
          message: 'Article non trouvé',
        );
        return;
      }

      logger.i('✅ Détail article chargé: ${article.name}');
      logger.d('   - Stock: ${article.currentStock} ${article.unitOfMeasure?.symbol ?? ""}');
      logger.d('   - Prix: ${article.formattedSellingPrice}');
      logger.d('   - Marge: ${article.formattedMargin}');

      state = ArticleDetailLoaded(article: article);
    } catch (e) {
      logger.e('❌ Exception chargement détail: $e');
      state = ArticleDetailError(
        message: 'Erreur inattendue: $e',
        articleId: articleId,
      );
    }
  }

  /// Rafraîchit le détail de l'article
  Future<void> refresh() async {
    logger.d('🔄 Rafraîchissement détail article');
    await loadArticleDetail();
  }

  /// Change l'onglet actif
  void changeTab(int tabIndex) {
    final currentState = state;
    if (currentState is ArticleDetailLoaded) {
      logger.d('📑 Changement onglet: $tabIndex');
      state = currentState.copyWithTabIndex(tabIndex);
    }
  }

  /// Réessaye de charger après une erreur
  Future<void> retry() async {
    logger.d('🔄 Nouvelle tentative de chargement');
    await loadArticleDetail();
  }
}