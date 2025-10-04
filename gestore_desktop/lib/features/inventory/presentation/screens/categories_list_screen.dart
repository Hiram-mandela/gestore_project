// ========================================
// lib/features/inventory/presentation/screens/categories_list_screen.dart
// Écran de la liste des catégories avec hiérarchie
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/categories_crud_provider.dart';
import '../providers/category_state.dart';
import '../../domain/entities/category_entity.dart';

/// Écran de la liste des catégories
class CategoriesListScreen extends ConsumerStatefulWidget {
  const CategoriesListScreen({super.key});

  @override
  ConsumerState<CategoriesListScreen> createState() => _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
// Pour filtrer par parent

  @override
  void initState() {
    super.initState();
    // Charger les catégories au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoriesListProvider.notifier).loadCategories(isActive: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoriesListProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Header
          _buildHeader(context, state),

          // Corps
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),

      // Bouton flottant pour créer
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/categories/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvelle catégorie'),
        backgroundColor: AppColors.primary,
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader(BuildContext context, CategoryState state) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Catégories',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(state),
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton refresh
              IconButton(
                onPressed: () {
                  ref.read(categoriesListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                tooltip: 'Actualiser',
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Barre de recherche
          TextField(
            decoration: InputDecoration(
              hintText: 'Rechercher une catégorie...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              filled: true,
              fillColor: Colors.grey[100],
            ),
            onChanged: (value) {
              // TODO: Implémenter recherche locale
            },
          ),
        ],
      ),
    );
  }

  /// Construit le sous-titre
  String _buildSubtitle(CategoryState state) {
    if (state is CategoryLoaded) {
      return '${state.categories.length} catégories • ${state.rootCategories.length} racines';
    }
    return 'Gestion des catégories d\'articles';
  }

  /// Construit le corps
  Widget _buildBody(CategoryState state) {
    if (state is CategoryLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is CategoryError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(categoriesListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is CategoryLoaded) {
      if (state.categories.isEmpty) {
        return _buildEmptyState();
      }

      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(categoriesListProvider.notifier).refresh();
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Afficher les catégories racines avec leurs enfants
            ...state.rootCategories.map((category) {
              return _buildCategoryItem(
                context,
                category,
                state,
                level: 0,
              );
            }),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  /// Construit un élément catégorie avec hiérarchie
  Widget _buildCategoryItem(
      BuildContext context,
      CategoryEntity category,
      CategoryLoaded state, {
        required int level,
      }) {
    final hasChildren = state.hasChildren(category.id);
    final children = state.getChildren(category.id);
    final isExpanded = true; // TODO: Gérer l'expansion/collapse

    return Column(
      children: [
        // Carte de la catégorie
        Container(
          margin: EdgeInsets.only(
            left: level * 24.0,
            bottom: 8,
          ),
          child: Card(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
              side: BorderSide(
                color: Colors.grey.shade200,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: () {
                context.push('/inventory/categories/${category.id}');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Indicateur hiérarchie
                    if (level > 0)
                      Container(
                        width: 3,
                        height: 40,
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          color: _parseColor(category.color).withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),

                    // Icône et couleur
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: _parseColor(category.color).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(
                        hasChildren ? Icons.folder : Icons.label,
                        color: _parseColor(category.color),
                      ),
                    ),

                    const SizedBox(width: 16),

                    // Infos
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  category.name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              if (!category.isActive)
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.grey[300],
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: const Text(
                                    'Inactif',
                                    style: TextStyle(fontSize: 11),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            category.code,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (category.description!.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              category.description!,
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.grey[500],
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(width: 8),

                    // Stats
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        if (hasChildren)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.folder_open,
                                  size: 14,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${children.length}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        if (category.taxRate > 0) ...[
                          const SizedBox(height: 4),
                          Text(
                            'TVA ${category.taxRate.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ],
                    ),

                    // Chevron
                    Icon(
                      Icons.chevron_right,
                      color: Colors.grey[400],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),

        // Enfants (récursif)
        if (isExpanded && hasChildren)
          ...children.map((child) {
            return _buildCategoryItem(
              context,
              child,
              state,
              level: level + 1,
            );
          }),
      ],
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.category_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune catégorie',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Créez votre première catégorie pour commencer',
            style: TextStyle(color: Colors.grey[500]),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => context.push('/inventory/categories/new'),
            icon: const Icon(Icons.add),
            label: const Text('Créer une catégorie'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  /// Parse une couleur hex
  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}