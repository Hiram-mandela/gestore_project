// ========================================
// lib/features/inventory/presentation/screens/article_detail_screen.dart
// VERSION COMPLÈTE AVEC CRUD
// Écran de détail complet d'un article avec onglets et actions (Éditer, Supprimer)
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/dependencies.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../providers/article_detail_provider.dart';
import '../providers/article_detail_state.dart';
import '../widgets/article_info_tab.dart';
import '../widgets/article_stock_tab.dart';
import '../widgets/article_price_tab.dart';
import '../widgets/article_history_tab.dart';
import '../widgets/stock_badge.dart';

class ArticleDetailScreen extends ConsumerStatefulWidget {
  final String articleId;

  const ArticleDetailScreen({
    super.key,
    required this.articleId,
  });

  @override
  ConsumerState<ArticleDetailScreen> createState() =>
      _ArticleDetailScreenState();
}

class _ArticleDetailScreenState extends ConsumerState<ArticleDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);

    // Écouter les changements de tab
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref
            .read(articleDetailProvider(widget.articleId).notifier)
            .changeTab(_tabController.index);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleDetailProvider(widget.articleId));

    return Scaffold(
      body: state is ArticleDetailLoading
          ? _buildLoadingState()
          : state is ArticleDetailError
          ? _buildErrorState(state)
          : state is ArticleDetailLoaded
          ? _buildLoadedState(state)
          : _buildInitialState(),
    );
  }

  // ==================== ÉTAT CHARGEMENT ====================

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement du détail...'),
        ],
      ),
    );
  }

  // ==================== ÉTAT ERREUR ====================

  Widget _buildErrorState(ArticleDetailError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(articleDetailProvider(widget.articleId).notifier)
                      .retry(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ÉTAT INITIAL ====================

  Widget _buildInitialState() {
    return const Center(
      child: Text('Initialisation...'),
    );
  }

  // ==================== ÉTAT CHARGÉ ====================

  Widget _buildLoadedState(ArticleDetailLoaded state) {
    final article = state.article;

    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          // AppBar avec image de fond
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3,
                      color: Colors.black45,
                    ),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de fond
                  article.imageUrl != null
                      ? Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                      : _buildPlaceholderImage(),
                  // Gradient overlay
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Badge actif/inactif
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(
                    article.statusDisplay,
                    style: const TextStyle(fontSize: 12),
                  ),
                  backgroundColor: article.isActive
                      ? AppColors.success.withValues(alpha: 0.2)
                      : AppColors.error.withValues(alpha: 0.2),
                ),
              ),

              // ⭐ NOUVEAU : Bouton Éditer
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => context.pushNamed(
                  'article-edit',
                  pathParameters: {'id': article.id},
                ),
                tooltip: 'Modifier',
              ),

              // ⭐ NOUVEAU : Bouton Supprimer
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, article),
                tooltip: 'Supprimer',
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Infos rapides (prix, stock, marge)
          SliverToBoxAdapter(
            child: _buildQuickInfo(article),
          ),

          // Barre d'onglets
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).colorScheme.primary,
                unselectedLabelColor: Theme.of(context).hintColor,
                indicatorColor: Theme.of(context).colorScheme.primary,
                tabs: const [
                  Tab(icon: Icon(Icons.info_outline), text: 'Info'),
                  Tab(icon: Icon(Icons.inventory_2_outlined), text: 'Stock'),
                  Tab(icon: Icon(Icons.attach_money), text: 'Prix'),
                  Tab(icon: Icon(Icons.history), text: 'Historique'),
                ],
              ),
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          ArticleInfoTab(article: article),
          ArticleStockTab(article: article),
          ArticlePriceTab(article: article),
          ArticleHistoryTab(article: article),
        ],
      ),
    );
  }

  // ==================== WIDGETS HELPER ====================

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.surfaceDark,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 80,
          color: Colors.white54,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(article) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Prix de vente
          Expanded(
            child: _QuickInfoCard(
              icon: Icons.sell,
              label: 'Prix de vente',
              value: article.formattedSellingPrice,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Stock
          Expanded(
            child: _QuickInfoCard(
              icon: Icons.inventory,
              label: 'Stock',
              value: '${article.currentStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
              color: article.isLowStock ? AppColors.warning : AppColors.success,
              badge: StockBadge(
                stock: article.currentStock,
                isLowStock: article.isLowStock,
                unit: article.unitOfMeasure?.symbol ?? '',
              ),
            ),
          ),
          const SizedBox(width: 12),
          // Marge
          Expanded(
            child: _QuickInfoCard(
              icon: Icons.trending_up,
              label: 'Marge',
              value: article.formattedMargin,
              color: article.marginPercent >= 20
                  ? AppColors.success
                  : article.marginPercent >= 10
                  ? AppColors.warning
                  : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS CRUD ====================

  /// ⭐ NOUVELLE MÉTHODE : Confirmation de suppression
  void _confirmDelete(BuildContext context, article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer l\'article'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${article.name}" ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteArticle(context, article.id, article.name);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  /// ⭐ NOUVELLE MÉTHODE : Suppression de l'article
  Future<void> _deleteArticle(
      BuildContext context,
      String articleId,
      String articleName,
      ) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );

    try {
      // Appeler le use case
      final deleteUseCase = getIt<DeleteArticleUseCase>();
      final params = DeleteArticleParams(articleId: articleId);
      final result = await deleteUseCase(params);

      // Fermer le loader
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      final error = result.$2;

      if (error != null) {
        // Erreur
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.error, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(child: Text('Erreur: $error')),
                ],
              ),
              backgroundColor: AppColors.error,
              duration: const Duration(seconds: 4),
            ),
          );
        }
      } else {
        // Succès
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  const Icon(Icons.check_circle, color: Colors.white),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text('Article "$articleName" supprimé avec succès'),
                  ),
                ],
              ),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 3),
            ),
          );

          // Retourner à la liste après un court délai
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              context.go('/inventory');
            }
          });
        }
      }
    } catch (e) {
      // Fermer le loader en cas d'exception
      if (context.mounted) {
        Navigator.of(context).pop();
      }

      // Afficher l'erreur
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(child: Text('Erreur inattendue: $e')),
              ],
            ),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }
}

// ==================== QUICK INFO CARD ====================

class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final Widget? badge;

  const _QuickInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          badge ??
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
        ],
      ),
    );
  }
}

// ==================== SLIVER TAB BAR DELEGATE ====================

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar _tabBar;

  _SliverTabBarDelegate(this._tabBar);

  @override
  double get minExtent => _tabBar.preferredSize.height;

  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}