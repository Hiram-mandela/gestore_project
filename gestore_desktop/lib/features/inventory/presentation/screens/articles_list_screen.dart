// ========================================
// lib/features/inventory/presentation/screens/articles_list_screen.dart
// VERSION COMPLÈTE MISE À JOUR - Écran principal de la liste des articles
// Intégration navigation CRUD (Création, Détail, Édition)
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/articles_provider.dart';
import '../providers/categories_brands_providers.dart';
import '../providers/inventory_state.dart';
import '../widgets/article_card.dart';
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

  @override
  void initState() {
    super.initState();

    // Charger les articles au démarrage
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
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header avec titre et actions
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Titre et boutons d'action
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
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _buildSubtitle(articlesState),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bouton Filtres
                    IconButton(
                      onPressed: _showFiltersSheet,
                      icon: const Icon(Icons.filter_list),
                      tooltip: 'Filtres',
                    ),

                    // Bouton Rafraîchir
                    IconButton(
                      onPressed: () {
                        ref.read(articlesProvider.notifier).refresh();
                      },
                      icon: const Icon(Icons.refresh),
                      tooltip: 'Actualiser',
                    ),

                    // ⭐ NOUVEAU : Bouton Nouvel Article
                    IconButton(
                      onPressed: () {
                        // Navigation vers le formulaire de création
                        context.pushNamed('article-create');
                      },
                      icon: const Icon(Icons.add_circle_outline),
                      tooltip: 'Nouvel article',
                      color: Theme.of(context).primaryColor,
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
          ),

          // Corps principal
          Expanded(
            child: _buildBody(articlesState),
          ),
        ],
      ),
    );
  }

  /// Construit le sous-titre en fonction de l'état
  String _buildSubtitle(InventoryState state) {
    if (state is InventoryLoaded) {
      final count = state.totalCount;
      return count > 1 ? '$count articles' : '$count article';
    }
    return 'Gestion des articles';
  }

  /// Construit le corps de l'écran en fonction de l'état
  Widget _buildBody(InventoryState state) {
    if (state is InventoryInitial) {
      return const Center(
        child: Text(
          'Prêt à charger les articles',
          style: TextStyle(color: Colors.grey),
        ),
      );
    } else if (state is InventoryLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is InventoryLoaded) {
      return _buildArticlesList(state);
    } else if (state is InventoryLoadingMore) {
      return _buildArticlesList(
        InventoryLoaded(
          response: state.currentArticles as dynamic,
          currentPage: 1,
        ),
        isLoadingMore: true,
      );
    } else if (state is InventoryError) {
      return _buildErrorWidget(state.message);
    }

    // Cas par défaut (ne devrait jamais arriver)
    return const Center(
      child: Text(
        'État inconnu',
        style: TextStyle(color: Colors.grey),
      ),
    );
  }

  /// Construit la liste des articles
  Widget _buildArticlesList(
      InventoryLoaded state, {
        bool isLoadingMore = false,
      }) {
    final articles = state.articles;

    if (articles.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(articlesProvider.notifier).refresh();
      },
      child: ListView.separated(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: articles.length + (isLoadingMore ? 1 : 0),
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == articles.length) {
            // Indicateur de chargement pour la pagination
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final article = articles[index];
          return ArticleCard(
            article: article,
            onTap: () {
              // ⭐ NOUVEAU : Navigation vers le détail de l'article
              context.pushNamed(
                'article-detail',
                pathParameters: {'id': article.id},
              );
            },
          );
        },
      ),
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
            Icon(
              Icons.inventory_2_outlined,
              size: 80,
              color: Colors.grey[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Aucun article trouvé',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Essayez d\'ajuster vos filtres ou créez un nouvel article',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),

            // ⭐ NOUVEAU : Bouton pour créer le premier article
            FilledButton.icon(
              onPressed: () {
                context.pushNamed('article-create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Créer un article'),
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
            Icon(
              Icons.error_outline,
              size: 80,
              color: Colors.red[300],
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(articlesProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }
}