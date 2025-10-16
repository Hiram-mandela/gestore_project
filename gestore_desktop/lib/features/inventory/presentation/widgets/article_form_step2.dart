// ========================================
// lib/features/inventory/presentation/widgets/article_form_step2.dart
// ÉTAPE 2 : Classification avec sélecteurs intelligents et création rapide
// VERSION 3.0 - AMÉLIORATIONS COMPLÈTES
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/smart_selector_widget.dart';
import '../providers/article_form_state.dart';
import '../providers/categories_brands_providers.dart';

class ArticleFormStep2 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep2({
    super.key,
    required this.formData,
    required this.errors,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final brandsState = ref.watch(brandsProvider);
    final unitsState = ref.watch(unitsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 24),

        // Catégorie
        _buildCategorySection(context, ref, categoriesState),
        const SizedBox(height: 24),

        // Marque
        _buildBrandSection(context, ref, brandsState),
        const SizedBox(height: 24),

        // Unité de mesure
        _buildUnitSection(context, ref, unitsState),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.category_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Classification',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Organisez l\'article dans votre catalogue.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== CATÉGORIE ====================
  Widget _buildCategorySection(BuildContext context, WidgetRef ref, CategoriesState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.folder_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Catégorie',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // État de chargement
          if (state is CategoriesLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          // État d'erreur
          else if (state is CategoriesError)
            _buildErrorWidget(state.message, () {
              ref.read(categoriesProvider.notifier).refresh();
            })
          // Sélecteur intelligent
          else if (state is CategoriesLoaded)
              SmartSelectorWidget<String>(
                label: 'Catégorie',
                required: true,
                prefixIcon: Icons.category,
                selectedValue: formData.categoryId.isEmpty ? null : formData.categoryId,
                items: state.categories
                    .map((category) => SelectableItem<String>(
                  value: category.id,
                  label: category.name,
                  subtitle: category.fullPath,
                  searchText: category.fullPath, // Pour recherche hiérarchique
                  icon: Icons.folder,
                ))
                    .toList(),
                onSelected: (value) => onFieldChanged('categoryId', value ?? ''),
                errorText: errors['categoryId'],
                helperText: 'Choisissez la catégorie de l\'article',
                emptyMessage: 'Aucune catégorie disponible',
                searchHint: 'Rechercher une catégorie...',
                // Bouton de création rapide
                trailing: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _quickCreateCategory(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Créer une nouvelle catégorie'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ==================== MARQUE ====================
  Widget _buildBrandSection(BuildContext context, WidgetRef ref, BrandsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.local_offer_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Marque',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (state is BrandsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state is BrandsError)
            _buildErrorWidget(state.message, () {
              ref.read(brandsProvider.notifier).refresh();
            })
          else if (state is BrandsLoaded)
              SmartSelectorWidget<String>(
                label: 'Marque',
                prefixIcon: Icons.local_offer,
                selectedValue: formData.brandId.isEmpty ? null : formData.brandId,
                items: state.brands
                    .map((brand) => SelectableItem<String>(
                  value: brand.id,
                  label: brand.name,
                  subtitle: brand.description!.isNotEmpty ? brand.description : null,
                  icon: Icons.branding_watermark,
                ))
                    .toList(),
                onSelected: (value) => onFieldChanged('brandId', value ?? ''),
                errorText: errors['brandId'],
                helperText: 'Marque du produit (optionnel)',
                emptyMessage: 'Aucune marque disponible',
                searchHint: 'Rechercher une marque...',
                trailing: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _quickCreateBrand(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Créer une nouvelle marque'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ==================== UNITÉ DE MESURE ====================
  Widget _buildUnitSection(BuildContext context, WidgetRef ref, UnitsState state) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.straighten_outlined, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              const Text(
                'Unité de mesure',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          if (state is UnitsLoading)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(),
              ),
            )
          else if (state is UnitsError)
            _buildErrorWidget(state.message, () {
              ref.read(unitsProvider.notifier).refresh();
            })
          else if (state is UnitsLoaded)
              SmartSelectorWidget<String>(
                label: 'Unité de mesure',
                required: true,
                prefixIcon: Icons.straighten,
                selectedValue: formData.unitOfMeasureId.isEmpty ? null : formData.unitOfMeasureId,
                items: state.units
                    .map((unit) => SelectableItem<String>(
                  value: unit.id,
                  label: unit.name,
                  subtitle: '${unit.symbol} - ${unit.description}',
                  searchText: '${unit.name} ${unit.symbol}',
                  icon: Icons.balance,
                ))
                    .toList(),
                onSelected: (value) => onFieldChanged('unitOfMeasureId', value ?? ''),
                errorText: errors['unitOfMeasureId'],
                helperText: 'Unité pour quantifier l\'article',
                emptyMessage: 'Aucune unité disponible',
                searchHint: 'Rechercher une unité...',
                trailing: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => _quickCreateUnit(context, ref),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Créer une nouvelle unité'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.primary,
                      side: const BorderSide(color: AppColors.primary),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }

  // ==================== WIDGETS UTILITAIRES ====================

  Widget _buildErrorWidget(String message, VoidCallback onRetry) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.error_outline, color: AppColors.error, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: AppColors.error,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text('Réessayer'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.error,
                side: BorderSide(color: AppColors.error),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CRÉATION RAPIDE ====================

  Future<void> _quickCreateCategory(BuildContext context, WidgetRef ref) async {
    // Navigation vers le formulaire de création de catégorie
    final result = await context.pushNamed(
      'category-create',
    );

    if (result != null && context.mounted) {
      // Rafraîchir la liste des catégories
      ref.invalidate(categoriesProvider);

      // Afficher un message de succès
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Catégorie créée avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _quickCreateBrand(BuildContext context, WidgetRef ref) async {
    // Navigation vers le formulaire de création de marque
    final result = await context.pushNamed(
      'brand-create',
    );

    if (result != null && context.mounted) {
      // Rafraîchir la liste des marques
      ref.invalidate(brandsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Marque créée avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _quickCreateUnit(BuildContext context, WidgetRef ref) async {
    // Navigation vers le formulaire de création d'unité
    final result = await context.pushNamed(
      'unit-create',
    );

    if (result != null && context.mounted) {
      // Rafraîchir la liste des unités
      ref.invalidate(unitsProvider);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Unité créée avec succès'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}