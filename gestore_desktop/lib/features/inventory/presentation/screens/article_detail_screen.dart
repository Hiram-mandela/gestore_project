// ========================================
// lib/features/inventory/presentation/screens/article_detail_screen.dart
//
// MODIFICATIONS APPORTÉES (Refonte Visuelle GESTORE) :
// - Application de la palette GESTORE (AppColors) pour les fonds, textes, icônes, et superpositions.
// - Refonte de l'en-tête (SliverAppBar) pour une meilleure lisibilité et un style plus moderne.
// - Standardisation des cartes d'informations rapides, des onglets, et des boîtes de dialogue (AlertDialog).
// - Uniformisation des notifications (SnackBar) pour les retours de succès et d'erreur.
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

  // --- CONSTANTES DE STYLE ---
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(12));
  static const _pagePadding = EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
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
      backgroundColor: AppColors.backgroundLight,
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
          Text('Chargement du détail...',
              style: TextStyle(color: AppColors.textSecondary)),
        ],
      ),
    );
  }

  // ==================== ÉTAT ERREUR ====================
  Widget _buildErrorState(ArticleDetailError state) {
    return Center(
      child: Padding(
        padding: _pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton(
                  onPressed: () => context.pop(),
                  child: const Text('Retour'),
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
      child: Text('Initialisation...',
          style: TextStyle(color: AppColors.textSecondary)),
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
            backgroundColor: AppColors.surfaceDark,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                article.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Image de fond
                  article.imageUrl != null && article.imageUrl!.isNotEmpty
                      ? Image.network(
                    article.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholderImage();
                    },
                  )
                      : _buildPlaceholderImage(),
                  // Gradient overlay pour la lisibilité
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black54,
                        ],
                        stops: [0.5, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              // Bouton Éditer
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                onPressed: () => context.pushNamed(
                  'article-edit',
                  pathParameters: {'id': article.id},
                ),
                tooltip: 'Modifier',
              ),
              // Bouton Supprimer
              IconButton(
                icon: const Icon(Icons.delete_outline),
                onPressed: () => _confirmDelete(context, article),
                tooltip: 'Supprimer',
              ),
              const SizedBox(width: 8),
            ],
          ),
          // Infos rapides (prix, stock, statut)
          SliverToBoxAdapter(
            child: _buildQuickInfo(article),
          ),
          // Barre d'onglets
          SliverPersistentHeader(
            pinned: true,
            delegate: _SliverTabBarDelegate(
              TabBar(
                controller: _tabController,
                labelColor: AppColors.primary,
                unselectedLabelColor: AppColors.textSecondary,
                indicatorColor: AppColors.primary,
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
          Icons.image_not_supported_outlined,
          size: 80,
          color: AppColors.border,
        ),
      ),
    );
  }

  Widget _buildQuickInfo(article) {
    return Container(
      padding: _pagePadding,
      color: AppColors.surfaceLight,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Prix de vente
          Expanded(
            child: _QuickInfoCard(
              icon: Icons.sell_outlined,
              label: 'Prix de vente',
              value: article.formattedSellingPrice,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 12),
          // Stock
          Expanded(
            child: _QuickInfoCard(
              icon: Icons.inventory_2_outlined,
              label: 'Stock actuel',
              value:
              '${article.currentStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
              color:
              article.isLowStock ? AppColors.warning : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          // Statut
          Expanded(
            child: _QuickInfoCard(
              icon: article.isActive
                  ? Icons.toggle_on_outlined
                  : Icons.toggle_off_outlined,
              label: 'Statut',
              value: article.statusDisplay,
              color: article.isActive
                  ? AppColors.success
                  : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTIONS CRUD ====================
  void _confirmDelete(BuildContext context, article) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
        title: const Text('Supprimer l\'article',
            style: TextStyle(color: AppColors.textPrimary)),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${article.name}" ? Cette action est irréversible.',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Annuler',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _deleteArticle(context, article.id, article.name);
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: AppColors.surfaceLight,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteArticle(
      BuildContext context,
      String articleId,
      String articleName,
      ) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final deleteUseCase = getIt<DeleteArticleUseCase>();
      final params = DeleteArticleParams(articleId: articleId);
      final result = await deleteUseCase(params);

      if (context.mounted) Navigator.of(context).pop(); // Fermer loader

      final error = result.$2;
      if (error != null) {
        if (context.mounted) _showSnackBar(context, '$error', isError: true);
      } else {
        if (context.mounted) {
          _showSnackBar(
              context, 'Article "$articleName" supprimé avec succès.');
          context.go('/inventory');
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.of(context).pop(); // Fermer loader
      if (context.mounted)
        _showSnackBar(context, 'Erreur inattendue: $e', isError: true);
    }
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

// ==================== QUICK INFO CARD ====================
class _QuickInfoCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _QuickInfoCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.textSecondary),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
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
      decoration: const BoxDecoration(
        color: AppColors.surfaceLight,
        border: Border(
          bottom: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}