// ========================================
// lib/features/inventory/presentation/widgets/articles_filters_sheet.dart
// Feuille de filtres pour les articles
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/articles_provider.dart';
import '../providers/categories_brands_providers.dart';

/// Feuille de filtres pour les articles
class ArticlesFiltersSheet extends ConsumerStatefulWidget {
  const ArticlesFiltersSheet({super.key});

  @override
  ConsumerState<ArticlesFiltersSheet> createState() =>
      _ArticlesFiltersSheetState();
}

class _ArticlesFiltersSheetState extends ConsumerState<ArticlesFiltersSheet> {
  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool _showLowStockOnly = false;
  bool _showActiveOnly = true;

  @override
  Widget build(BuildContext context) {
    final categoriesState = ref.watch(categoriesProvider);
    final brandsState = ref.watch(brandsProvider);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Text(
                  'Filtres',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _resetFilters,
                  child: const Text('Réinitialiser'),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Corps des filtres
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Filtre par catégorie
                  const Text(
                    'Catégorie',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildCategoryFilter(categoriesState),
                  const SizedBox(height: 24),

                  // Filtre par marque
                  const Text(
                    'Marque',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildBrandFilter(brandsState),
                  const SizedBox(height: 24),

                  // Autres filtres
                  const Text(
                    'Options',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildOptionsFilters(),
                  const SizedBox(height: 24),

                  // Bouton Appliquer
                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Appliquer les filtres',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le filtre de catégories
  Widget _buildCategoryFilter(CategoriesState state) {
    return switch (state) {
      CategoriesLoaded() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            label: 'Toutes',
            isSelected: _selectedCategoryId == null,
            onSelected: () {
              setState(() => _selectedCategoryId = null);
            },
          ),
          ...state.categories.map((category) {
            return _buildFilterChip(
              label: category.name,
              isSelected: _selectedCategoryId == category.id,
              onSelected: () {
                setState(() => _selectedCategoryId = category.id);
              },
              color: _parseColor(category.color),
            );
          }),
        ],
      ),
      CategoriesLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      CategoriesError() => Text(
        'Erreur: ${state.message}',
        style: const TextStyle(color: Colors.red),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  /// Construit le filtre de marques
  Widget _buildBrandFilter(BrandsState state) {
    return switch (state) {
      BrandsLoaded() => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _buildFilterChip(
            label: 'Toutes',
            isSelected: _selectedBrandId == null,
            onSelected: () {
              setState(() => _selectedBrandId = null);
            },
          ),
          ...state.brands.map((brand) {
            return _buildFilterChip(
              label: brand.name,
              isSelected: _selectedBrandId == brand.id,
              onSelected: () {
                setState(() => _selectedBrandId = brand.id);
              },
            );
          }),
        ],
      ),
      BrandsLoading() => const Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: CircularProgressIndicator(),
        ),
      ),
      BrandsError() => Text(
        'Erreur: ${state.message}',
        style: const TextStyle(color: Colors.red),
      ),
      _ => const SizedBox.shrink(),
    };
  }

  /// Construit les options de filtres
  Widget _buildOptionsFilters() {
    return Column(
      children: [
        SwitchListTile(
          title: const Text('Stock bas uniquement'),
          subtitle: const Text('Afficher les articles en stock critique'),
          value: _showLowStockOnly,
          onChanged: (value) {
            setState(() => _showLowStockOnly = value);
          },
          contentPadding: EdgeInsets.zero,
        ),
        SwitchListTile(
          title: const Text('Articles actifs uniquement'),
          subtitle: const Text('Masquer les articles inactifs'),
          value: _showActiveOnly,
          onChanged: (value) {
            setState(() => _showActiveOnly = value);
          },
          contentPadding: EdgeInsets.zero,
        ),
      ],
    );
  }

  /// Construit un chip de filtre
  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onSelected,
    Color? color,
  }) {
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => onSelected(),
      backgroundColor: color?.withValues(alpha: 0.1),
      selectedColor: color ?? Theme.of(context).primaryColor,
      labelStyle: TextStyle(
        color: isSelected
            ? Colors.white
            : (color ?? Theme.of(context).primaryColor),
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      checkmarkColor: Colors.white,
      side: BorderSide(
        color: isSelected
            ? (color ?? Theme.of(context).primaryColor)
            : Colors.grey[300]!,
      ),
    );
  }

  /// Applique les filtres
  void _applyFilters() {
    ref.read(articlesProvider.notifier).loadArticles(
      categoryId: _selectedCategoryId,
      brandId: _selectedBrandId,
      isLowStock: _showLowStockOnly ? true : null,
      isActive: _showActiveOnly ? true : null,
    );
    Navigator.of(context).pop();
  }

  /// Réinitialise les filtres
  void _resetFilters() {
    setState(() {
      _selectedCategoryId = null;
      _selectedBrandId = null;
      _showLowStockOnly = false;
      _showActiveOnly = true;
    });
  }

  /// Parse une couleur depuis une chaîne hexadécimale
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}