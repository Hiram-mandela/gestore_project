// ========================================
// lib/features/inventory/presentation/screens/articles_list_screen.dart
// VERSION PHASE 2 - Support complet des opérations en masse
//
// NOUVEAUTÉS :
// - Mode sélection multiple
// - Barre d'actions flottante pour opérations en masse
// - Import/Export CSV
// - Duplication d'articles
// - Menu contextuel par article
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../../../config/dependencies.dart';
import '../providers/articles_provider.dart';
import '../providers/categories_brands_providers.dart';
import '../providers/inventory_state.dart';
import '../widgets/article_card.dart';
import '../widgets/article_grid_card.dart';
import '../widgets/article_search_bar.dart';
import '../widgets/articles_filters_sheet.dart';
import '../widgets/bulk_action_bar.dart';
import '../widgets/csv_import_export_dialogs.dart';
import '../../domain/usecases/article_bulk_operations_usecases.dart';

/// Écran de la liste des articles avec opérations en masse
class ArticlesListScreen extends ConsumerStatefulWidget {
  const ArticlesListScreen({super.key});

  @override
  ConsumerState<ArticlesListScreen> createState() => _ArticlesListScreenState();
}

class _ArticlesListScreenState extends ConsumerState<ArticlesListScreen> {
  final ScrollController _scrollController = ScrollController();
  bool _isLoadingMore = false;
  bool _isGridView = true;

  // PHASE 2: Variables pour opérations en masse
  bool _selectionMode = false;
  final Set<String> _selectedArticles = {};

  // Use cases Phase 2
  late final BulkUpdateArticlesUseCase _bulkUpdateUseCase;
  late final DuplicateArticleUseCase _duplicateUseCase;
  late final ImportArticlesCSVUseCase _importCSVUseCase;
  late final ExportArticlesCSVUseCase _exportCSVUseCase;

  static const _pagePadding = EdgeInsets.all(16.0);

  @override
  void initState() {
    super.initState();

    // Initialiser les use cases
    _bulkUpdateUseCase = getIt<BulkUpdateArticlesUseCase>();
    _duplicateUseCase = getIt<DuplicateArticleUseCase>();
    _importCSVUseCase = getIt<ImportArticlesCSVUseCase>();
    _exportCSVUseCase = getIt<ExportArticlesCSVUseCase>();

    // Charger les données
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(articlesProvider.notifier).loadArticles();
      ref.read(categoriesProvider.notifier).loadCategories(isActive: true);
      ref.read(brandsProvider.notifier).loadBrands(isActive: true);
    });

    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  /// Gestion du scroll pour pagination
  void _onScroll() {
    if (_isLoadingMore) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    final delta = 200.0;

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
      floatingActionButton: _buildFloatingActionButton(),
      floatingActionButtonLocation: _selectionMode
          ? FloatingActionButtonLocation.centerFloat
          : FloatingActionButtonLocation.endFloat,
    );
  }

  /// Construction du floating action button
  Widget _buildFloatingActionButton() {
    if (_selectionMode && _selectedArticles.isNotEmpty) {
      return BulkActionBar(
        selectedCount: _selectedArticles.length,
        onActivate: _bulkActivate,
        onDeactivate: _bulkDeactivate,
        onDelete: _bulkDelete,
        onChangeCategory: _bulkChangeCategory,
        onChangeSupplier: _bulkChangeSupplier,
        onCancel: () {
          setState(() {
            _selectionMode = false;
            _selectedArticles.clear();
          });
        },
      );
    }

    return FloatingActionButton(
      onPressed: () => context.pushNamed('article-create'),
      backgroundColor: AppColors.primary,
      foregroundColor: AppColors.surfaceLight,
      tooltip: 'Nouvel article',
      child: const Icon(Icons.add),
    );
  }

  /// Construction de l'en-tête
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
          SizedBox(height: MediaQuery.of(context).padding.top),
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

              // PHASE 2: Bouton Import/Export
              PopupMenuButton<String>(
                icon: const Icon(Icons.import_export, color: AppColors.textSecondary),
                tooltip: 'Import/Export',
                onSelected: (value) {
                  if (value == 'import') {
                    _showImportDialog();
                  } else if (value == 'export') {
                    _showExportDialog();
                  }
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'import',
                    child: Row(
                      children: [
                        Icon(Icons.upload_file, size: 20),
                        SizedBox(width: 8),
                        Text('Importer CSV'),
                      ],
                    ),
                  ),
                  const PopupMenuItem(
                    value: 'export',
                    child: Row(
                      children: [
                        Icon(Icons.download, size: 20),
                        SizedBox(width: 8),
                        Text('Exporter CSV'),
                      ],
                    ),
                  ),
                ],
              ),

              // PHASE 2: Bouton mode sélection
              if (!_selectionMode)
                IconButton(
                  icon: const Icon(Icons.checklist, color: AppColors.textSecondary),
                  tooltip: 'Mode sélection',
                  onPressed: () {
                    setState(() {
                      _selectionMode = true;
                      _selectedArticles.clear();
                    });
                  },
                ),

              // Bouton annuler sélection
              if (_selectionMode)
                IconButton(
                  icon: const Icon(Icons.close, color: AppColors.error),
                  tooltip: 'Annuler',
                  onPressed: () {
                    setState(() {
                      _selectionMode = false;
                      _selectedArticles.clear();
                    });
                  },
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

  String _buildSubtitle(InventoryState state) {
    if (_selectionMode && _selectedArticles.isNotEmpty) {
      return '${_selectedArticles.length} sélectionné(s)';
    }
    if (state is InventoryLoaded) {
      final count = state.totalCount;
      return count > 1 ? '$count articles' : '$count article';
    }
    return 'Gestion des articles';
  }

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
    return const SizedBox.shrink();
  }

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

  Widget _buildGridView(List<dynamic> articles, bool isLoadingMore) {
    return GridView.builder(
      controller: _scrollController,
      padding: _pagePadding,
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 280,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),
      itemCount: articles.length + (isLoadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == articles.length) {
          return const Center(child: CircularProgressIndicator());
        }
        final article = articles[index];

        // En mode grille, pas de sélection multiple pour simplifier
        return ArticleGridCard(
          article: article,
          onTap: _selectionMode
              ? null
              : () => context.pushNamed('article-detail', pathParameters: {'id': article.id}),
        );
      },
    );
  }

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
        final isSelected = _selectedArticles.contains(article.id);

        return ArticleListCard(
          article: article,
          isSelected: isSelected,
          // Mode sélection : activer le checkbox
          onSelected: _selectionMode
              ? (selected) {
            setState(() {
              if (selected == true) {
                _selectedArticles.add(article.id);
              } else {
                _selectedArticles.remove(article.id);
              }
            });
          }
              : null,
          // Navigation : désactiver en mode sélection
          onTap: _selectionMode
              ? null
              : () => context.pushNamed('article-detail', pathParameters: {'id': article.id}),
          // Menu d'actions contextuelles
          actions: _selectionMode
              ? null
              : _buildArticleActions(article.id),
        );
      },
    );
  }

  /// Construction du menu d'actions pour un article
  List<PopupMenuEntry<String>> _buildArticleActions(String articleId) {
    return [
      PopupMenuItem(
        value: 'duplicate',
        child: const Row(
          children: [
            Icon(Icons.copy, size: 20),
            SizedBox(width: 8),
            Text('Dupliquer'),
          ],
        ),
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
                () => _duplicateArticle(articleId),
          );
        },
      ),
      PopupMenuItem(
        value: 'edit',
        child: const Row(
          children: [
            Icon(Icons.edit, size: 20),
            SizedBox(width: 8),
            Text('Modifier'),
          ],
        ),
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
                () => context.pushNamed('article-edit', pathParameters: {'id': articleId}),
          );
        },
      ),
      const PopupMenuDivider(),
      PopupMenuItem(
        value: 'delete',
        child: Row(
          children: [
            Icon(Icons.delete, size: 20, color: Colors.red.shade700),
            const SizedBox(width: 8),
            Text(
              'Supprimer',
              style: TextStyle(color: Colors.red.shade700),
            ),
          ],
        ),
        onTap: () {
          Future.delayed(
            const Duration(milliseconds: 100),
                () => _confirmDeleteArticle(articleId),
          );
        },
      ),
    ];
  }

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
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.pushNamed('article-create'),
              icon: const Icon(Icons.add),
              label: const Text('Créer un article'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(articlesProvider.notifier).loadArticles();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      ),
    );
  }

  void _showFiltersSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const ArticlesFiltersSheet(),
    );
  }

  // ========================================
  // PHASE 2: MÉTHODES D'OPÉRATIONS EN MASSE
  // ========================================

  Future<void> _bulkActivate() async {
    final params = BulkUpdateArticlesParams(
      articleIds: _selectedArticles.toList(),
      action: 'activate',
    );

    await _executeBulkOperation(params, 'Articles activés');
  }

  Future<void> _bulkDeactivate() async {
    final params = BulkUpdateArticlesParams(
      articleIds: _selectedArticles.toList(),
      action: 'deactivate',
    );

    await _executeBulkOperation(params, 'Articles désactivés');
  }

  Future<void> _bulkDelete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer ${_selectedArticles.length} article(s) ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final params = BulkUpdateArticlesParams(
      articleIds: _selectedArticles.toList(),
      action: 'delete',
    );

    await _executeBulkOperation(params, 'Articles supprimés');
  }

  Future<void> _bulkChangeCategory() async {
    // TODO: Afficher dialog de sélection de catégorie
    // puis appeler _executeBulkOperation avec action: 'update_category'
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité en cours de développement'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  Future<void> _bulkChangeSupplier() async {
    // TODO: Afficher dialog de sélection de fournisseur
    // puis appeler _executeBulkOperation avec action: 'update_supplier'
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fonctionnalité en cours de développement'),
          backgroundColor: AppColors.info,
        ),
      );
    }
  }

  Future<void> _executeBulkOperation(
      BulkUpdateArticlesParams params,
      String successMessage,
      ) async {
    final (result, error) = await _bulkUpdateUseCase(params);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result?['message'] ?? successMessage),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        _selectionMode = false;
        _selectedArticles.clear();
      });

      // Recharger la liste
      ref.read(articlesProvider.notifier).loadArticles();
    }
  }

  Future<void> _duplicateArticle(String articleId) async {
    final params = DuplicateArticleParams(
      articleId: articleId,
      copyImages: true,
      copyBarcodes: false,
    );

    final (result, error) = await _duplicateUseCase(params);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Article dupliqué avec succès'),
          backgroundColor: Colors.green,
        ),
      );

      // Recharger la liste
      ref.read(articlesProvider.notifier).loadArticles();
    }
  }

  Future<void> _confirmDeleteArticle(String articleId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cet article ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      // Utiliser bulk delete pour un seul article
      await _bulkDelete();
    }
  }

  void _showImportDialog() {
    showDialog(
      context: context,
      builder: (context) => CSVImportDialog(
        onImport: (filePath) async {
          Navigator.pop(context);
          await _importCSV(filePath);
        },
      ),
    );
  }

  Future<void> _importCSV(String filePath) async {
    final params = ImportArticlesCSVParams(filePath: filePath);
    final (result, error) = await _importCSVUseCase(params);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted && result != null) {
      final created = result['created_count'] ?? 0;
      final updated = result['updated_count'] ?? 0;
      final errors = (result['errors'] as List?)?.length ?? 0;

      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.check_circle, color: Colors.green),
              SizedBox(width: 12),
              Text('Import terminé'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✅ Articles créés : $created'),
              Text('🔄 Articles mis à jour : $updated'),
              if (errors > 0)
                Text('❌ Erreurs : $errors', style: const TextStyle(color: Colors.red)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      // Recharger la liste
      ref.read(articlesProvider.notifier).loadArticles();
    }
  }

  void _showExportDialog() {
    showDialog(
      context: context,
      builder: (context) => CSVExportDialog(
        onExport: ({categoryId, brandId, isActive, isLowStock}) async {
          Navigator.pop(context);
          await _exportCSV(
            categoryId: categoryId,
            brandId: brandId,
            isActive: isActive,
            isLowStock: isLowStock,
          );
        },
      ),
    );
  }

  Future<void> _exportCSV({
    String? categoryId,
    String? brandId,
    bool? isActive,
    bool? isLowStock,
  }) async {
    final params = ExportArticlesCSVParams(
      categoryId: categoryId,
      brandId: brandId,
      isActive: isActive,
      isLowStock: isLowStock,
    );

    final (fileName, error) = await _exportCSVUseCase(params);

    if (error != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (mounted && fileName != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export réussi : $fileName'),
          backgroundColor: Colors.green,
          action: SnackBarAction(
            label: 'Ouvrir',
            onPressed: () {
              // TODO: Ouvrir le fichier avec l'application par défaut
            },
          ),
        ),
      );
    }
  }
}