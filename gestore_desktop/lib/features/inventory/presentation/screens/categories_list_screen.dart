// ========================================
// lib/features/inventory/presentation/screens/categories_list_screen.dart
//
// MODIFICATIONS APPORTÉES (Refonte Visuelle GESTORE) :
// - Application de la palette de couleurs GESTORE (AppColors) pour les fonds, textes, et icônes.
// - Standardisation de la typographie pour un contraste et une lisibilité accrus.
// - Refonte des cartes (Cards) en utilisant des conteneurs stylisés avec bordures et ombres subtiles.
// - Uniformisation du style des champs de saisie et des boutons pour une meilleure cohérence visuelle.
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
  ConsumerState<CategoriesListScreen> createState() =>
      _CategoriesListScreenState();
}

class _CategoriesListScreenState extends ConsumerState<CategoriesListScreen> {
  // --- CONSTANTES DE STYLE ---
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(12));
  static const _pagePadding = EdgeInsets.all(16.0);
  static const _buttonPadding =
  EdgeInsets.symmetric(horizontal: 24, vertical: 16);

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
      backgroundColor: AppColors.backgroundLight,
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
        icon: const Icon(Icons.add, color: AppColors.surfaceLight),
        label: const Text('Nouvelle catégorie'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(
          borderRadius: _cardBorderRadius,
        ),
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader(BuildContext context, CategoryState state) {
    return Container(
      color: AppColors.surfaceLight,
      padding: _pagePadding,
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
              // Bouton refresh
              IconButton(
                onPressed: () {
                  ref.read(categoriesListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh, color: AppColors.textSecondary),
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de recherche
          TextField(
            decoration: _inputDecoration('Rechercher une catégorie...'),
            onChanged: (value) {
              // TODO: Implémenter recherche locale
            },
          ),
        ],
      ),
    );
  }

  /// Décoration standardisée pour les champs de texte
  InputDecoration _inputDecoration(String hintText) {
    return InputDecoration(
      hintText: hintText,
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.backgroundLight,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: _cardBorderRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: _cardBorderRadius,
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: _cardBorderRadius,
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
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
        child: Padding(
          padding: _pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Erreur',
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
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () {
                  ref.read(categoriesListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.surfaceLight,
                  padding: _buttonPadding,
                  shape: const RoundedRectangleBorder(
                    borderRadius: _cardBorderRadius,
                  ),
                ),
              ),
            ],
          ),
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
          padding: _pagePadding,
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
  Widget _buildCategoryItem(BuildContext context, CategoryEntity category,
      CategoryLoaded state,
      {required int level}) {
    final hasChildren = state.hasChildren(category.id);
    final children = state.getChildren(category.id);
    final isExpanded = true; // TODO: Gérer l'expansion/collapse

    final categoryColor = _parseColor(category.color);

    return Column(
      children: [
        // Carte de la catégorie
        Container(
          margin: EdgeInsets.only(
            left: level * 24.0,
            bottom: 8,
          ),
          decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: _cardBorderRadius,
              border: Border.all(color: AppColors.border),
              boxShadow: [AppColors.subtleShadow()]),
          child: InkWell(
            onTap: () {
              context.push('/inventory/categories/${category.id}');
            },
            borderRadius: _cardBorderRadius,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  // Icône et couleur
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: categoryColor.withValues(alpha: 0.1),
                      borderRadius:
                      const BorderRadius.all(Radius.circular(8)),
                    ),
                    child: Icon(
                      hasChildren ? Icons.folder_open_outlined : Icons.label_outline,
                      color: categoryColor,
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
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.textPrimary,
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
                                  color: AppColors.backgroundLight,
                                  borderRadius:
                                  const BorderRadius.all(Radius.circular(6)),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: const Text(
                                  'Inactif',
                                  style: TextStyle(
                                    fontSize: 11,
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          category.code,
                          style: const TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (category.description.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Text(
                            category.description,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textTertiary,
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
                  if (hasChildren)
                    Text(
                      '${children.length}',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  // Chevron
                  const Icon(
                    Icons.chevron_right,
                    color: AppColors.textTertiary,
                  ),
                ],
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
      child: Padding(
        padding: _pagePadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.category_outlined,
              size: 80,
              color: AppColors.border,
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucune catégorie',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Créez votre première catégorie pour commencer',
              style: TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/inventory/categories/new'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une catégorie'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceLight,
                padding: _buttonPadding,
                shape: const RoundedRectangleBorder(
                  borderRadius: _cardBorderRadius,
                ),
              ),
            ),
          ],
        ),
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