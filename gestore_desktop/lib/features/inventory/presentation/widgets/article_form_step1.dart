// ========================================
// FICHIER 1: lib/features/inventory/presentation/widgets/article_form_step1.dart
// Étape 1: Informations de base
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/article_entity.dart';
import '../providers/article_form_state.dart';
import '../providers/categories_brands_providers.dart';
import 'form_field_widgets.dart';

class ArticleFormStep1 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep1({
    super.key,
    required this.formData,
    required this.errors,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesState = ref.watch(categoriesProvider);
    final brandsState = ref.watch(brandsProvider);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        Text(
          'Informations de base',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Renseignez les informations principales de l\'article',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Nom *
        CustomTextField(
          label: 'Nom de l\'article *',
          initialValue: formData.name,
          errorText: errors['name'],
          onChanged: (value) => onFieldChanged('name', value),
          prefixIcon: Icons.inventory_2,
          required: true,
        ),
        const SizedBox(height: 16),

        // Code *
        CustomTextField(
          label: 'Code article *',
          initialValue: formData.code,
          errorText: errors['code'],
          onChanged: (value) => onFieldChanged('code', value.toUpperCase()),
          prefixIcon: Icons.tag,
          required: true,
          textCapitalization: TextCapitalization.characters,
        ),
        const SizedBox(height: 16),

        // Description
        CustomTextField(
          label: 'Description',
          initialValue: formData.description,
          onChanged: (value) => onFieldChanged('description', value),
          prefixIcon: Icons.description,
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        // Type d'article *
        CustomDropdown<String>(
          label: 'Type d\'article *',
          value: formData.articleType,
          items: ArticleType.values
              .map((type) => DropdownMenuItem(
            value: type.value,
            child: Text(type.label),
          ))
              .toList(),
          onChanged: (value) => onFieldChanged('articleType', value),
          prefixIcon: Icons.category,
          required: true,
        ),
        const SizedBox(height: 16),

        // Catégorie * (Dropdown avec chargement)
        _buildCategoryDropdown(categoriesState, context),
        const SizedBox(height: 16),

        // Marque (Dropdown avec chargement)
        _buildBrandDropdown(brandsState, context),
        const SizedBox(height: 16),

        // Code-barres
        CustomTextField(
          label: 'Code-barres',
          initialValue: formData.barcode,
          onChanged: (value) => onFieldChanged('barcode', value),
          prefixIcon: Icons.qr_code,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: 16),

        // Références
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Réf. interne',
                initialValue: formData.internalReference,
                onChanged: (value) => onFieldChanged('internalReference', value),
                prefixIcon: Icons.numbers,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Réf. fournisseur',
                initialValue: formData.supplierReference,
                onChanged: (value) => onFieldChanged('supplierReference', value),
                prefixIcon: Icons.receipt_long,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDropdown(CategoriesState state, BuildContext context) {
    if (state is CategoriesLoading) {
      return const LinearProgressIndicator();
    } else if (state is CategoriesLoaded) {
      return CustomDropdown<String>(
        label: 'Catégorie *',
        value: formData.categoryId.isEmpty ? null : formData.categoryId,
        errorText: errors['categoryId'],
        items: state.categories
            .map((category) => DropdownMenuItem(
          value: category.id,
          child: Text(category.fullPath),
        ))
            .toList(),
        onChanged: (value) => onFieldChanged('categoryId', value ?? ''),
        prefixIcon: Icons.folder,
        required: true,
      );
    } else if (state is CategoriesError) {
      return Text('Erreur: ${state.message}');
    }
    return const SizedBox();
  }

  Widget _buildBrandDropdown(BrandsState state, BuildContext context) {
    if (state is BrandsLoading) {
      return const LinearProgressIndicator();
    } else if (state is BrandsLoaded) {
      return CustomDropdown<String>(
        label: 'Marque',
        value: formData.brandId.isEmpty ? null : formData.brandId,
        items: [
          const DropdownMenuItem(value: '', child: Text('Aucune')),
          ...state.brands
              .map((brand) => DropdownMenuItem(
            value: brand.id,
            child: Text(brand.name),
          ))
              .toList(),
        ],
        onChanged: (value) => onFieldChanged('brandId', value ?? ''),
        prefixIcon: Icons.branding_watermark,
      );
    }
    return const SizedBox();
  }
}