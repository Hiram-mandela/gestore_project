// ========================================
// lib/features/inventory/presentation/screens/articles_list_screen.dart
//
// MODIFICATIONS APPORTÉES (CORRECTION GRILLE RESPONSIVE) :
// - Remplacement de SliverGridDelegateWithFixedCrossAxisCount par SliverGridDelegateWithMaxCrossAxisExtent.
// - Définition d'une largeur maximale par carte (maxCrossAxisExtent: 180) pour un affichage responsive.
// - Le nombre de colonnes s'ajuste désormais automatiquement à la taille de l'écran, conformément à la demande.
// - Ajustement du childAspectRatio pour un meilleur ratio visuel.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/articles_provider.dart';
import '../providers/categories_brands_providers.dart';
import '../providers/inventory_state.dart';
import '../widgets/article_card.dart';
import '../widgets/article_grid_card.dart';
import '../widgets/article_search_bar.dart';
import '../widgets/articles_filters_sheet.dart';

/// Écran de la liste des articles
class ArticlesListScreen extends ConsumerStatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  ConsumerState<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends ConsumerState<ArticlesListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isGridView = true; // Par défaut en mode grille

  // --- CONSTANTES DE STYLE ---
  static const _pagePadding = EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();
    // Charger les données initiales
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articlesProvider.notifier).loadArticles();
      ref.read(categoriesProvider.notifier).loadCategories(isActive: true);
      ref.read(brandsProvider.notifier).loadBrands(isActive: true);
    });

    // Listener pour la pagination
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Gère le scroll pour la pagination (infinite scroll)
  void _onScroll() {
    if (_isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0; // Charger 200px avant la fin

    if (currentScroll >= maxScroll - delta) {
      final state = ref.read(articlesProvider);
      if (state is InventoryLoaded && state.hasMore) {
        setState(() => _isLoadingMore = true);
        ref.read(articlesProvider.notifier).loadMoreArticles().then((_) {
          if (mounted) {
            setState(() => _isLoadingMore = false);
          }
        });
      }
    }
  }

  /// Affiche la feuille des filtres
  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ArticlesFiltersSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final articlesState = ref.watch(articlesProvider);
    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          _buildHeader(articlesState),
          Expanded(child: _buildBody(articlesState)),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.pushNamed('article-create'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
        tooltip: 'Nouvel article',
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Construit l'en-tête de la page
  Widget _buildHeader(InventoryState state) {
    return Container(
      padding: _pagePadding,
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top), // Safe Area
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Articles',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(state),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton Filtres
              IconButton(
                onPressed: _showFiltersSheet,
                icon: const Icon(Icons.filter_list, color: AppColors.textSecondary),
                tooltip: 'Filtres',
              ),
              // Bouton Grille/Liste
              IconButton(
                onPressed: () {
                  setState(() => _isGridView = !_isGridView);
                },
                icon: Icon(
                  _isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined,
                  color: AppColors.textSecondary,
                ),
                tooltip: _isGridView ? 'Afficher en liste' : 'Afficher en grille',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de recherche
          ArticleSearchBar(
            onSearch: (query) {
              ref.read(articlesProvider.notifier).searchArticles(query);
            },
          ),
        ],
      ),
    );
  }

  /// Construit le sous-titre
  String _buildSubtitle(InventoryState state) {
    if (state is InventoryLoaded) {
      final count = state.totalCount;
      return count > 1 ? '$count articles' : '$count article';
    }
    return 'Gestion des articles';
  }

  /// Construit le corps de la page
  Widget _buildBody(InventoryState state) {
    if (state is InventoryInitial) {
      return const Center(
        child: Text('Prêt à charger...', style: TextStyle(color: AppColors.textTertiary)),
      );
    }
    if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (state is InventoryLoaded || state is InventoryLoadingMore) {
      final articles = (state is InventoryLoaded)
          ? state.articles
          : (state as InventoryLoadingMore).currentArticles;

      if (articles.isEmpty) {
        return _buildEmptyState();
      }
      return _buildArticlesView(articles, state is InventoryLoadingMore);
    }
    if (state is InventoryError) {
      return _buildErrorWidget(state.message);
    }
    return const SizedBox.shrink(); // État inconnu
  }

  /// Construit la vue des articles (grille ou liste)
  Widget _buildArticlesView(List<dynamic> articles, bool isLoadingMore) {
    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(articlesProvider.notifier).refresh();
      },
      child: _isGridView
          ? _buildGridView(articles, isLoadingMore)
          : _buildListView(articles, isLoadingMore),
    );
  }

  /// ✅ MODIFICATION ICI : Remplacement de la grille par une version responsive
  Widget _buildGridView(List<dynamic> articles, bool isLoadingMore) {
    return GridView.builder(
      controller: _scrollController,
      padding: _pagePadding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        // Cette valeur définit la largeur maximale pour chaque carte.
        // Flutter affichera autant de colonnes que possible sans dépasser cette largeur.
        // ex: Sur un écran de 375px, il y aura 2 colonnes (375 / 180 = 2.08).
        // ex: Sur un écran de 600px, il y aura 3 colonnes (600 / 180 = 3.33).
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        // Un ratio de 0.75 signifie que la hauteur sera 75% de la largeur,
        // ce qui donne des cartes plus compactes.
        childAspectRatio: 0.75,
      ),
      itemCount: articles.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final article = articles[index];
        return ArticleGridCard(
          article: article,
          onTap: () => context.pushNamed('article-detail', pathParameters: {'id': article.id}),
        );
      },
    );
  }

  /// Construit la vue en liste
  Widget _buildListView(List<dynamic> articles, bool isLoadingMore) {
    return ListView.separated(
      controller: _scrollController,
      padding: _pagePadding,
      itemCount: articles.length + (isLoadingMore ? 1 : 0),
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return const Padding(
            padding: EdgeInsets.all(16.0),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final article = articles[index];
        return ArticleListCard(
          article: article,
          onTap: () => context.pushNamed('article-detail', pathParameters: {'id': article.id}),
        );
      },
    );
  }

  /// Widget pour l'état vide
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inventory_2_outlined, size: 80, color: AppColors.border),
            const SizedBox(height: 16),
            const Text(
              'Aucun article trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Essayez d\'ajuster vos filtres ou créez un nouvel article.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pushNamed('article-create'),
              icon: const Icon(Icons.add),
              label: const Text('Créer un article'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Widget pour l'état d'erreur
  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 80, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => ref.read(articlesProvider.notifier).refresh(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceLight,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}