// ========================================
// lib/features/inventory/presentation/widgets/article_form_step2.dart
// ÉTAPE 2 : Classification (3 champs)
// VERSION 2.0 - CORRIGÉE - Fix layout constraints
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        const SizedBox(height: 16),

        // Marque
        _buildBrandSection(context, brandsState, ref),
        const SizedBox(height: 16),

        // Unité de mesure
        _buildUnitSection(context, unitsState, ref),
      ],
    );
  }

  // ==================== HEADER ====================

  Widget _buildHeader(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.category,
                color: Theme.of(context).colorScheme.primary,
                size: 28,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Classification',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Organisez l\'article dans votre catalogue',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.folder,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Catégorie',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Bouton création rapide
                TextButton.icon(
                  onPressed: () => _showCreateCategoryDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state is CategoriesLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is CategoriesError)
              _buildErrorState(state.message)
            else if (state is CategoriesLoaded)
                _buildCategoryDropdown(context, state)
              else
                const SizedBox(),
          ],
        ),
      ),
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
            mainAxisSize: MainAxisSize.min, // ⭐ FIX: Shrink-wrap
            children: [
              // Couleur de la catégorie
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: _parseColor(category.color),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 12),
              // ⭐ FIX: Utiliser Flexible au lieu de Expanded
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
      prefixIcon: Icons.category,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.branding_watermark,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Marque',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Bouton création rapide
                TextButton.icon(
                  onPressed: () => _showCreateBrandDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state is BrandsLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is BrandsError)
              _buildErrorState(state.message)
            else if (state is BrandsLoaded)
                _buildBrandDropdown(context, state)
              else
                const SizedBox(),
          ],
        ),
      ),
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
            mainAxisSize: MainAxisSize.min, // ⭐ FIX: Shrink-wrap
            children: [
              // Logo de la marque (si disponible)
              if (brand.logoUrl != null && brand.logoUrl!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: Image.network(
                    brand.logoUrl!,
                    width: 24,
                    height: 24,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => const Icon(Icons.image, size: 24),
                  ),
                )
              else
                const Icon(Icons.branding_watermark, size: 24),
              const SizedBox(width: 12),
              // ⭐ FIX: Utiliser Flexible au lieu de Expanded
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
      prefixIcon: Icons.label,
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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.straighten,
                      size: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Unité de mesure',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),
                // Bouton création rapide
                TextButton.icon(
                  onPressed: () => _showCreateUnitDialog(context, ref),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            if (state is UnitsLoading)
              const Center(child: CircularProgressIndicator())
            else if (state is UnitsError)
              _buildErrorState(state.message)
            else if (state is UnitsLoaded)
                _buildUnitDropdown(context, state)
              else
                const SizedBox(),
          ],
        ),
      ),
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
            mainAxisSize: MainAxisSize.min, // ⭐ FIX: Shrink-wrap
            children: [
              Text(
                unit.symbol,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: 'monospace',
                ),
              ),
              const SizedBox(width: 12),
              // ⭐ FIX: Utiliser Flexible au lieu de Expanded
              Flexible(
                child: Text(
                  unit.name,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit.isDecimal) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'Décimal',
                    style: TextStyle(fontSize: 10, color: Colors.blue),
                  ),
                ),
              ],
            ],
          ),
        );
      }).toList(),
      onChanged: (value) => onFieldChanged('unitOfMeasureId', value ?? ''),
      prefixIcon: Icons.straighten,
      errorText: errors['unitOfMeasureId'],
      helperText: units.isEmpty
          ? 'Aucune unité disponible'
          : '${units.length} unité(s) disponible(s)',
    );
  }

  // ==================== HELPERS ====================

  Widget _buildErrorState(String message) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.red.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.error_outline, color: Colors.red.shade700),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Colors.red.shade700),
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
      return Colors.blue;
    }
  }

  // ==================== DIALOGS CRÉATION RAPIDE ====================

  void _showCreateCategoryDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Création rapide de catégorie'),
        content: const Text(
          'Cette fonctionnalité ouvrira un formulaire de création rapide.\n\n'
              'Pour l\'instant, utilisez l\'écran dédié de gestion des catégories.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreateBrandDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Création rapide de marque'),
        content: const Text(
          'Cette fonctionnalité ouvrira un formulaire de création rapide.\n\n'
              'Pour l\'instant, utilisez l\'écran dédié de gestion des marques.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showCreateUnitDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Création rapide d\'unité'),
        content: const Text(
          'Cette fonctionnalité ouvrira un formulaire de création rapide.\n\n'
              'Pour l\'instant, utilisez l\'écran dédié de gestion des unités.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}