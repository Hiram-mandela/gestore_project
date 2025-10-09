// ========================================
// lib/features/inventory/presentation/widgets/article_form_step1.dart
// ÉTAPE 1 : Informations de Base (10 champs)
// VERSION 2.0 - Formulaire Complet
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_form_state.dart';
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
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 24),

        // Section 1 : Identification
        _buildIdentificationSection(context),
        const SizedBox(height: 24),

        // Section 2 : Descriptions
        _buildDescriptionsSection(context),
        const SizedBox(height: 24),

        // Section 3 : Références et Métadonnées
        _buildReferencesSection(context),
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
                Icons.info_outline,
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
                    'Informations de base',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Renseignez les informations principales de l\'article',
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

  // ==================== SECTION IDENTIFICATION ====================

  Widget _buildIdentificationSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Identification', Icons.tag),
            const SizedBox(height: 16),

            // Nom * (Requis)
            CustomTextField(
              label: 'Nom de l\'article',
              initialValue: formData.name,
              errorText: errors['name'],
              onChanged: (value) => onFieldChanged('name', value),
              prefixIcon: Icons.inventory_2,
              required: true,
              helperText: 'Nom commercial de l\'article',
            ),
            const SizedBox(height: 16),

            // Code * (Requis)
            CustomTextField(
              label: 'Code article',
              initialValue: formData.code,
              errorText: errors['code'],
              onChanged: (value) => onFieldChanged('code', value.toUpperCase()),
              prefixIcon: Icons.qr_code,
              required: true,
              textCapitalization: TextCapitalization.characters,
              helperText: 'Code unique pour identifier l\'article (SKU)',
            ),
            const SizedBox(height: 16),

            // Type d'article
            CustomDropdown<String>(
              label: 'Type d\'article',
              value: formData.articleType.isEmpty ? null : formData.articleType,
              items: const [
                DropdownMenuItem(value: 'product', child: Text('Produit')),
                DropdownMenuItem(value: 'service', child: Text('Service')),
                DropdownMenuItem(value: 'bundle', child: Text('Pack/Bundle')),
                DropdownMenuItem(value: 'variant', child: Text('Variante')),
              ],
              onChanged: (value) => onFieldChanged('articleType', value ?? 'product'),
              prefixIcon: Icons.category,
              helperText: 'Nature de l\'article',
            ),
            const SizedBox(height: 16),

            // Code-barres principal
            CustomTextField(
              label: 'Code-barres principal',
              initialValue: formData.barcode,
              errorText: errors['barcode'],
              onChanged: (value) => onFieldChanged('barcode', value),
              prefixIcon: Icons.qr_code_scanner,
              helperText: 'EAN13, UPC ou autre (codes additionnels en étape 5)',
              keyboardType: TextInputType.number,
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION DESCRIPTIONS ====================

  Widget _buildDescriptionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Descriptions', Icons.description),
            const SizedBox(height: 16),

            // Description courte (NOUVEAU)
            CustomTextField(
              label: 'Description courte',
              initialValue: formData.shortDescription,
              errorText: errors['shortDescription'],
              onChanged: (value) => onFieldChanged('shortDescription', value),
              prefixIcon: Icons.short_text,
              maxLines: 2,
              helperText: 'Résumé pour les listes et recherches (150 caractères max)',
            ),
            const SizedBox(height: 16),

            // Description complète
            CustomTextField(
              label: 'Description complète',
              initialValue: formData.description,
              errorText: errors['description'],
              onChanged: (value) => onFieldChanged('description', value),
              prefixIcon: Icons.notes,
              maxLines: 4,
              helperText: 'Description détaillée de l\'article',
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION RÉFÉRENCES ====================

  Widget _buildReferencesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Références et Métadonnées', Icons.bookmark),
            const SizedBox(height: 16),

            // Référence interne
            CustomTextField(
              label: 'Référence interne',
              initialValue: formData.internalReference,
              errorText: errors['internalReference'],
              onChanged: (value) => onFieldChanged('internalReference', value),
              prefixIcon: Icons.pin,
              helperText: 'Référence utilisée en interne',
            ),
            const SizedBox(height: 16),

            // Référence fournisseur
            CustomTextField(
              label: 'Référence fournisseur',
              initialValue: formData.supplierReference,
              errorText: errors['supplierReference'],
              onChanged: (value) => onFieldChanged('supplierReference', value),
              prefixIcon: Icons.business,
              helperText: 'Référence du fournisseur principal',
            ),
            const SizedBox(height: 16),

            // Tags
            CustomTextField(
              label: 'Tags',
              initialValue: formData.tags,
              errorText: errors['tags'],
              onChanged: (value) => onFieldChanged('tags', value),
              prefixIcon: Icons.label,
              helperText: 'Mots-clés séparés par des virgules (ex: bio, promo, nouveau)',
            ),
            const SizedBox(height: 16),

            // Notes
            CustomTextField(
              label: 'Notes internes',
              initialValue: formData.notes,
              errorText: errors['notes'],
              onChanged: (value) => onFieldChanged('notes', value),
              prefixIcon: Icons.sticky_note_2,
              maxLines: 3,
              helperText: 'Notes visibles uniquement en interne',
            ),
          ],
        ),
      ),
    );
  }

  // ==================== HELPERS ====================

  Widget _buildSectionTitle(BuildContext context, String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 8),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}