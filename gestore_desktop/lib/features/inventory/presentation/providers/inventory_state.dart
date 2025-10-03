// ========================================
// lib/features/inventory/presentation/providers/inventory_state.dart
// États pour la gestion de l'inventaire
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/paginated_response_entity.dart';

/// État de base pour l'inventaire
abstract class InventoryState extends Equatable {
  const InventoryState();

  @override
  List<Object?> get props => [];
}

/// État initial
class InventoryInitial extends InventoryState {
  const InventoryInitial();
}

/// État de chargement
class InventoryLoading extends InventoryState {
  const InventoryLoading();
}

/// État de chargement supplémentaire (pagination)
class InventoryLoadingMore extends InventoryState {
  final List<ArticleEntity> currentArticles;

  const InventoryLoadingMore({required this.currentArticles});

  @override
  List<Object?> get props => [currentArticles];
}

/// État avec articles chargés
class InventoryLoaded extends InventoryState {
  final PaginatedResponseEntity<ArticleEntity> response;
  final int currentPage;
  final String? currentSearch;
  final String? currentCategoryId;
  final String? currentBrandId;
  final bool? currentIsActive;
  final bool? currentIsLowStock;

  const InventoryLoaded({
    required this.response,
    this.currentPage = 1,
    this.currentSearch,
    this.currentCategoryId,
    this.currentBrandId,
    this.currentIsActive,
    this.currentIsLowStock,
  });

  /// Retourne la liste des articles
  List<ArticleEntity> get articles => response.results;

  /// Vérifie s'il y a plus de pages
  bool get hasMore => response.hasNext;

  /// Nombre total d'articles
  int get totalCount => response.count;

  /// Vérifie si des filtres sont appliqués
  bool get hasFilters =>
      currentSearch != null ||
          currentCategoryId != null ||
          currentBrandId != null ||
          currentIsActive != null ||
          currentIsLowStock != null;

  /// Copie l'état avec de nouvelles valeurs
  InventoryLoaded copyWith({
    PaginatedResponseEntity<ArticleEntity>? response,
    int? currentPage,
    String? currentSearch,
    String? currentCategoryId,
    String? currentBrandId,
    bool? currentIsActive,
    bool? currentIsLowStock,
  }) {
    return InventoryLoaded(
      response: response ?? this.response,
      currentPage: currentPage ?? this.currentPage,
      currentSearch: currentSearch ?? this.currentSearch,
      currentCategoryId: currentCategoryId ?? this.currentCategoryId,
      currentBrandId: currentBrandId ?? this.currentBrandId,
      currentIsActive: currentIsActive ?? this.currentIsActive,
      currentIsLowStock: currentIsLowStock ?? this.currentIsLowStock,
    );
  }

  /// Copie l'état en ajoutant des articles (pagination)
  InventoryLoaded copyWithMoreArticles({
    required List<ArticleEntity> newArticles,
    required int newPage,
    required bool hasNext,
  }) {
    final allArticles = [...articles, ...newArticles];

    final updatedResponse = PaginatedResponseEntity<ArticleEntity>(
      count: response.count,
      next: hasNext ? 'next_page' : null,
      previous: response.previous,
      results: allArticles,
    );

    return InventoryLoaded(
      response: updatedResponse,
      currentPage: newPage,
      currentSearch: currentSearch,
      currentCategoryId: currentCategoryId,
      currentBrandId: currentBrandId,
      currentIsActive: currentIsActive,
      currentIsLowStock: currentIsLowStock,
    );
  }

  @override
  List<Object?> get props => [
    response,
    currentPage,
    currentSearch,
    currentCategoryId,
    currentBrandId,
    currentIsActive,
    currentIsLowStock,
  ];
}

/// État d'erreur
class InventoryError extends InventoryState {
  final String message;

  const InventoryError({required this.message});

  @override
  List<Object?> get props => [message];
}