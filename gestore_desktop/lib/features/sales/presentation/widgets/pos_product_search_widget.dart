// ========================================
// lib/features/sales/presentation/widgets/pos_product_search_widget.dart
// Widget de recherche de produits pour POS - VERSION CORRIGÉE
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../inventory/presentation/providers/articles_provider.dart';
import '../../../inventory/presentation/providers/inventory_state.dart';
import '../../../inventory/domain/entities/article_entity.dart';

/// Widget de recherche et sélection de produits
class PosProductSearchWidget extends ConsumerStatefulWidget {
  final TextEditingController searchController;
  final Function(ArticleEntity) onArticleSelected;

  const PosProductSearchWidget({
    super.key,
    required this.searchController,
    required this.onArticleSelected,
  });

  @override
  ConsumerState<PosProductSearchWidget> createState() =>
      _PosProductSearchWidgetState();
}

class _PosProductSearchWidgetState
    extends ConsumerState<PosProductSearchWidget> {
  @override
  void initState() {
    super.initState();
    // Charger les articles au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articlesProvider.notifier).loadArticles();
    });

    // Écouter les changements de recherche
    widget.searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    widget.searchController.removeListener(_onSearchChanged);
    super.dispose();
  }

  void _onSearchChanged() {
    final search = widget.searchController.text.trim();
    if (search.isNotEmpty) {
      ref.read(articlesProvider.notifier).searchArticles(search);
    } else {
      ref.read(articlesProvider.notifier).loadArticles();
    }
  }

  @override
  Widget build(BuildContext context) {
    final articlesState = ref.watch(articlesProvider);

    // ⭐ CORRECTION: Utiliser switch au lieu de .when()
    return switch (articlesState) {
      InventoryInitial() => const Center(
        child: Text(
          'Prêt à rechercher des produits',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      ),
      InventoryLoading() => const Center(
        child: CircularProgressIndicator(),
      ),
      InventoryLoaded(:final articles) when articles.isEmpty => _buildEmptyState(),
      InventoryLoaded(:final articles) => _buildArticlesGrid(articles),
      InventoryLoadingMore(:final currentArticles) => _buildArticlesGrid(currentArticles),
      InventoryError(:final message) => _buildErrorState(message),
      _ => const Center(
        child: Text('État inconnu'),
      ),
    };
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucun produit trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
            ),
          ),
          if (widget.searchController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Essayez une autre recherche',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[400],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Erreur',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.error,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              ref.read(articlesProvider.notifier).loadArticles();
            },
            icon: const Icon(Icons.refresh),
            label: const Text('RÉESSAYER'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Grille d'articles
  Widget _buildArticlesGrid(List<ArticleEntity> articles) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 0.75,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: articles.length,
      itemBuilder: (context, index) {
        return _buildArticleCard(articles[index]);
      },
    );
  }

  /// Carte article
  Widget _buildArticleCard(ArticleEntity article) {
    return InkWell(
      onTap: () => widget.onArticleSelected(article),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(12),
                  ),
                ),
                child: Stack(
                  children: [
                    // Image produit
                    if (article.imageUrl != null)
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                        child: Image.network(
                          article.imageUrl!,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildImagePlaceholder(),
                        ),
                      )
                    else
                      _buildImagePlaceholder(),

                    // Badge stock bas
                    if (article.isLowStock)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.error,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'Stock bas',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),

            // Infos
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nom
                    Text(
                      article.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Code
                    Text(
                      article.code,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey[600],
                      ),
                    ),

                    const Spacer(),

                    // Prix et stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Prix
                        Text(
                          '${article.sellingPrice.toStringAsFixed(0)} F',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),

                        // Stock
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: article.isLowStock
                                ? AppColors.error.withValues(alpha: 0.1)
                                : AppColors.success.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            article.currentStock.toStringAsFixed(0),
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: article.isLowStock
                                  ? AppColors.error
                                  : AppColors.success,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Placeholder image
  Widget _buildImagePlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 48,
        color: Colors.grey[400],
      ),
    );
  }
}