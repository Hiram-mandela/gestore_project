// ========================================
// lib/features/inventory/presentation/widgets/article_form_step2.dart
// ÉTAPE 2 : Classification (3 champs)
// VERSION 2.2 - Correction du layout (Unbounded Width)
// --
// Changement :
// - Ajout de `mainAxisSize: MainAxisSize.min` aux Row dans les DropdownMenuItem
//   pour corriger l'erreur de contrainte de largeur infinie.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_state.dart';
import '../providers/categories_brands_providers.dart';
import 'form_field_widgets.dart';

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
        _buildCategorySection(context, categoriesState, ref),
        const SizedBox(height: 24),

        // Marque
        _buildBrandSection(context, brandsState, ref),
        const SizedBox(height: 24),

        // Unité de mesure
        _buildUnitSection(context, unitsState, ref),
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
  Widget _buildCategorySection(
      BuildContext context,
      CategoriesState state,
      WidgetRef ref,
      ) {
    Widget content;
    if (state is CategoriesLoading) {
      content = const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is CategoriesError) {
      content = _buildErrorState(state.message);
    } else if (state is CategoriesLoaded) {
      content = _buildCategoryDropdown(context, state);
    } else {
      content = const SizedBox.shrink();
    }

    return _buildSectionContainer(
      title: 'Catégorie',
      icon: Icons.folder_outlined,
      action: TextButton.icon(
        onPressed: () => _showCreateCategoryDialog(context, ref),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Créer'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: content,
    );
  }

  Widget _buildCategoryDropdown(BuildContext context, CategoriesLoaded state) {
    final categories = state.categories;
    return CustomDropdown<String>(
      label: 'Sélectionner une catégorie',
      value: formData.categoryId.isEmpty ? null : formData.categoryId,
      items: categories.map((category) {
        return DropdownMenuItem<String>(
          value: category.id,
          child: Row(
            // ✨ CORRECTION ICI
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(category.color),
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border, width: 1.5),
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  category.fullPath,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onFieldChanged('categoryId', value ?? ''),
      prefixIcon: Icons.category_outlined,
      errorText: errors['categoryId'],
      helperText: categories.isEmpty
          ? 'Aucune catégorie disponible'
          : '${categories.length} catégorie(s) disponible(s)',
    );
  }

  // ==================== MARQUE ====================
  Widget _buildBrandSection(
      BuildContext context,
      BrandsState state,
      WidgetRef ref,
      ) {
    Widget content;
    if (state is BrandsLoading) {
      content = const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is BrandsError) {
      content = _buildErrorState(state.message);
    } else if (state is BrandsLoaded) {
      content = _buildBrandDropdown(context, state);
    } else {
      content = const SizedBox.shrink();
    }

    return _buildSectionContainer(
      title: 'Marque',
      icon: Icons.branding_watermark_outlined,
      action: TextButton.icon(
        onPressed: () => _showCreateBrandDialog(context, ref),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Créer'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: content,
    );
  }

  Widget _buildBrandDropdown(BuildContext context, BrandsLoaded state) {
    final brands = state.brands;
    return CustomDropdown<String>(
      label: 'Sélectionner une marque (optionnel)',
      value: formData.brandId.isEmpty ? null : formData.brandId,
      items: brands.map((brand) {
        return DropdownMenuItem<String>(
          value: brand.id,
          child: Row(
            // ✨ CORRECTION ICI
            mainAxisSize: MainAxisSize.min,
            children: [
              if (brand.logoUrl != null && brand.logoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    brand.logoUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                    const Icon(Icons.image_outlined, size: 24, color: AppColors.border),
                  ),
                )
              else
                const Icon(Icons.branding_watermark_outlined,
                    size: 24, color: AppColors.textTertiary),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  brand.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onFieldChanged('brandId', value ?? ''),
      prefixIcon: Icons.label_outline,
      errorText: errors['brandId'],
      helperText: brands.isEmpty
          ? 'Aucune marque disponible'
          : '${brands.length} marque(s) disponible(s)',
    );
  }

  // ==================== UNITÉ DE MESURE ====================
  Widget _buildUnitSection(
      BuildContext context,
      UnitsState state,
      WidgetRef ref,
      ) {
    Widget content;
    if (state is UnitsLoading) {
      content = const Center(
          child: CircularProgressIndicator(color: AppColors.primary));
    } else if (state is UnitsError) {
      content = _buildErrorState(state.message);
    } else if (state is UnitsLoaded) {
      content = _buildUnitDropdown(context, state);
    } else {
      content = const SizedBox.shrink();
    }

    return _buildSectionContainer(
      title: 'Unité de mesure',
      icon: Icons.straighten_outlined,
      action: TextButton.icon(
        onPressed: () => _showCreateUnitDialog(context, ref),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Créer'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: content,
    );
  }

  Widget _buildUnitDropdown(BuildContext context, UnitsLoaded state) {
    final units = state.units;
    return CustomDropdown<String>(
      label: 'Sélectionner une unité',
      value: formData.unitOfMeasureId.isEmpty ? null : formData.unitOfMeasureId,
      items: units.map((unit) {
        return DropdownMenuItem<String>(
          value: unit.id,
          child: Row(
            // ✨ CORRECTION ICI
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                unit.symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  unit.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isDecimal) ...[
                const SizedBox(width: 8),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.info.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'DÉCIMAL',
                    style: TextStyle(
                        fontSize: 10,
                        color: AppColors.info,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onFieldChanged('unitOfMeasureId', value ?? ''),
      prefixIcon: Icons.straighten_outlined,
      errorText: errors['unitOfMeasureId'],
      helperText: units.isEmpty
          ? 'Aucune unité disponible'
          : '${units.length} unité(s) disponible(s)',
    );
  }

  // ==================== WIDGETS RÉUTILISABLES ====================

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(icon, size: 22, color: AppColors.primary),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.error.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.error.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.error_outline, color: AppColors.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  Color _parseColor(String colorHex) {
    try {
      return Color(int.parse(colorHex.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary; // Couleur par défaut GESTORE
    }
  }

  // ==================== DIALOGS CRÉATION RAPIDE ====================

  void _showStyledDialog({
    required BuildContext context,
    required String title,
    required String content,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary)),
        content:
        Text(content, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }

  void _showCreateCategoryDialog(BuildContext context, WidgetRef ref) {
    _showStyledDialog(
      context: context,
      title: 'Création rapide de catégorie',
      content:
      'Cette fonctionnalité sera bientôt disponible. Pour l\'instant, veuillez utiliser l\'écran dédié de gestion des catégories.',
    );
  }

  void _showCreateBrandDialog(BuildContext context, WidgetRef ref) {
    _showStyledDialog(
      context: context,
      title: 'Création rapide de marque',
      content:
      'Cette fonctionnalité sera bientôt disponible. Pour l\'instant, veuillez utiliser l\'écran dédié de gestion des marques.',
    );
  }

  void _showCreateUnitDialog(BuildContext context, WidgetRef ref) {
    _showStyledDialog(
      context: context,
      title: 'Création rapide d\'unité',
      content:
      'Cette fonctionnalité sera bientôt disponible. Pour l\'instant, veuillez utiliser l\'écran dédié de gestion des unités.',
    );
  }
}