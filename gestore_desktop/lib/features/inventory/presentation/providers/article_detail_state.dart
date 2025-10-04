// ========================================
// lib/features/inventory/presentation/providers/article_detail_state.dart
// États pour le détail d'un article
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/article_detail_entity.dart';

/// État de base pour le détail article
abstract class ArticleDetailState extends Equatable {
  const ArticleDetailState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ArticleDetailInitial extends ArticleDetailState {
  const ArticleDetailInitial();
}

/// État de chargement
class ArticleDetailLoading extends ArticleDetailState {
  final String articleId;

  const ArticleDetailLoading({required this.articleId});

  @override
  List<Object?> get props => [articleId];
}

/// État avec article chargé
class ArticleDetailLoaded extends ArticleDetailState {
  final ArticleDetailEntity article;
  final int currentTabIndex;

  const ArticleDetailLoaded({
    required this.article,
    this.currentTabIndex = 0,
  });

  /// Copie l'état avec un nouvel index de tab
  ArticleDetailLoaded copyWithTabIndex(int tabIndex) {
    return ArticleDetailLoaded(
      article: article,
      currentTabIndex: tabIndex,
    );
  }

  @override
  List<Object?> get props => [article, currentTabIndex];
}

/// État d'erreur
class ArticleDetailError extends ArticleDetailState {
  final String message;
  final String? articleId;

  const ArticleDetailError({
    required this.message,
    this.articleId,
  });

  @override
  List<Object?> get props => [message, articleId];
}