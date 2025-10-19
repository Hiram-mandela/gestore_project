// ========================================
// lib/features/inventory/presentation/screens/article_detail_screen.dart
// VERSION PHASE 2 - Support duplication d'article
//
// NOUVEAUTÉS :
// - Bouton "Dupliquer" dans le menu d'actions
// - Dialog de confirmation avec options de duplication
// - Intégration du DuplicateArticleUseCase
// - Feedback utilisateur amélioré
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../config/dependencies.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/usecases/delete_article_usecase.dart';
import '../../domain/usecases/article_bulk_operations_usecases.dart';
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

  // PHASE 2: Use case pour la duplication
  late final DuplicateArticleUseCase _duplicateUseCase;

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

    // PHASE 2: Initialiser le use case
    _duplicateUseCase = getIt<DuplicateArticleUseCase>();
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
          : const Center(
        child: Text('Initialisation...',
            style: TextStyle(color: AppColors.textSecondary)),
      ),
    );
  }

  // ==================== ÉTATS ====================

  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildErrorState(ArticleDetailError state) {
    return Center(
      child: Padding(
        padding: _pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(articleDetailProvider(widget.articleId).notifier).retry();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

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
                  // Gradient overlay
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
              // PHASE 2: Menu d'actions (Modifier, Dupliquer, Supprimer)
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Actions',
                onSelected: (value) {
                  switch (value) {
                    case 'edit':
                      context.pushNamed(
                        'article-edit',
                        pathParameters: {'id': article.id},
                      );
                      break;
                    case 'duplicate':
                      _showDuplicateDialog(context, article.id);
                      break;
                    case 'delete':
                      _confirmDelete(context, article);
                      break;
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'edit',
                    child: Row(
                      children: [
                        Icon(Icons.edit, size: 20),
                        SizedBox(width: 12),
                        Text('Modifier'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'duplicate',
                    child: Row(
                      children: [
                        Icon(Icons.copy, size: 20),
                        SizedBox(width: 12),
                        Text('Dupliquer'),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(Icons.delete, size: 20, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Text(
                          'Supprimer',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                ],
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
              color: article.isLowStock ? AppColors.warning : AppColors.success,
            ),
          ),
          const SizedBox(width: 12),
          // Statut
          Expanded(
            child: _QuickInfoCard(
              icon: article.isActive
                  ? Icons.check_circle_outline
                  : Icons.cancel_outlined,
              label: 'Statut',
              value: article.isActive ? 'Actif' : 'Inactif',
              color: article.isActive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== PHASE 2: DIALOG DE DUPLICATION ====================

  Future<void> _showDuplicateDialog(BuildContext context, String articleId) async {
    bool copyImages = true;
    bool copyBarcodes = false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.copy, color: AppColors.primary),
              SizedBox(width: 12),
              Text('Dupliquer l\'article'),
            ],
          ),
          content: SizedBox(
            width: 400,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Un nouvel article sera créé avec les mêmes caractéristiques.\n'
                      'Le code et le nom seront modifiés automatiquement.',
                  style: TextStyle(fontSize: 14),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Options de duplication :',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 12),
                CheckboxListTile(
                  title: const Text('Copier les images'),
                  subtitle: const Text(
                    'Les images de l\'article seront dupliquées',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: copyImages,
                  onChanged: (value) {
                    setState(() => copyImages = value ?? true);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
                CheckboxListTile(
                  title: const Text('Copier les codes-barres'),
                  subtitle: const Text(
                    'Les codes-barres additionnels seront copiés',
                    style: TextStyle(fontSize: 12),
                  ),
                  value: copyBarcodes,
                  onChanged: (value) {
                    setState(() => copyBarcodes = value ?? false);
                  },
                  controlAffinity: ListTileControlAffinity.leading,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(dialogContext, true),
              icon: const Icon(Icons.copy),
              label: const Text('Dupliquer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );

    if (confirmed == true && mounted) {
      await _duplicateArticle(articleId, copyImages, copyBarcodes);
    }
  }

  Future<void> _duplicateArticle(
      String articleId,
      bool copyImages,
      bool copyBarcodes,
      ) async {
    // Afficher un loader
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: Card(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Duplication en cours...'),
              ],
            ),
          ),
        ),
      ),
    );

    final params = DuplicateArticleParams(
      articleId: articleId,
      copyImages: copyImages,
      copyBarcodes: copyBarcodes,
    );

    final (result, error) = await _duplicateUseCase(params);

    if (mounted) {
      Navigator.pop(context); // Fermer le loader

      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      if (result != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Article dupliqué avec succès'),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );

        // Naviguer vers le nouvel article si on a son ID
        if (result['article'] != null && result['article']['id'] != null) {
          final newArticleId = result['article']['id'] as String;
          context.pushReplacementNamed(
            'article-detail',
            pathParameters: {'id': newArticleId},
          );
        }
      }
    }
  }

  // ==================== SUPPRESSION ====================

  Future<void> _confirmDelete(BuildContext context, article) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppColors.error),
            SizedBox(width: 12),
            Text('Confirmer la suppression'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Êtes-vous sûr de vouloir supprimer cet article ?',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.red.shade700, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cette action est irréversible',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await _deleteArticle(article.id);
    }
  }

  Future<void> _deleteArticle(String articleId) async {
    final deleteUseCase = getIt<DeleteArticleUseCase>();
    final (_, error) = await deleteUseCase(DeleteArticleParams(articleId: articleId));

    if (mounted) {
      if (error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article supprimé avec succès'),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Retour à la liste
      context.go('/inventory/articles');
    }
  }
}

// ==================== WIDGETS AUXILIAIRES ====================

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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _SliverTabBarDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  _SliverTabBarDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context,
      double shrinkOffset,
      bool overlapsContent,
      ) {
    return Container(
      color: AppColors.surfaceLight,
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverTabBarDelegate oldDelegate) {
    return false;
  }
}