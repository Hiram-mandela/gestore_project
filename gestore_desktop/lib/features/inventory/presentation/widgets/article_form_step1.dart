// ========================================
// lib/features/inventory/presentation/widgets/article_form_step1.dart
// ÉTAPE 1 : Informations de Base avec validation inline et scanner de codes-barres
// VERSION 3.0 - AMÉLIORATIONS COMPLÈTES
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/barcode_input_field.dart';
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
        _buildSectionContainer(
          context: context,
          title: 'Identification',
          icon: Icons.tag,
          child: _buildIdentificationFields(),
        ),
        const SizedBox(height: 24),

        // Section 2 : Descriptions
        _buildSectionContainer(
          context: context,
          title: 'Descriptions',
          icon: Icons.description_outlined,
          child: _buildDescriptionsFields(),
        ),
        const SizedBox(height: 24),

        // Section 3 : Références et Métadonnées
        _buildSectionContainer(
          context: context,
          title: 'Références et Métadonnées',
          icon: Icons.bookmark_border,
          child: _buildReferencesFields(),
        ),
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
            Icons.info_outline,
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
                'Informations de base',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Renseignez les informations principales de l\'article.',
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

  // ==================== CONTAINER DE SECTION ====================
  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
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
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ==================== SECTIONS DE FORMULAIRE ====================

  Widget _buildIdentificationFields() {
    return Column(
      children: [
        // Nom * (Requis) - AVEC VALIDATION INLINE
        CustomTextField(
          label: 'Nom de l\'article',
          initialValue: formData.name,
          errorText: errors['name'],
          onChanged: (value) => onFieldChanged('name', value),
          prefixIcon: Icons.inventory_2_outlined,
          required: true,
          helperText: 'Nom commercial de l\'article',
          autovalidateMode: AutovalidateMode.onUserInteraction, // ✨ VALIDATION INLINE
        ),
        const SizedBox(height: 16),

        // Code * (Requis) - AVEC VALIDATION INLINE
        CustomTextField(
          label: 'Code article',
          initialValue: formData.code,
          errorText: errors['code'],
          onChanged: (value) => onFieldChanged('code', value.toUpperCase()),
          prefixIcon: Icons.qr_code_2,
          required: true,
          textCapitalization: TextCapitalization.characters,
          helperText: 'Code unique pour identifier l\'article (SKU)',
          autovalidateMode: AutovalidateMode.onUserInteraction, // ✨ VALIDATION INLINE
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
          prefixIcon: Icons.category_outlined,
          helperText: 'Nature de l\'article',
        ),
        const SizedBox(height: 16),

        // Code-barres principal - AVEC SCANNER ✨
        BarcodeInputField(
          label: 'Code-barres principal',
          initialValue: formData.barcode,
          onChanged: (value) => onFieldChanged('barcode', value),
          errorText: errors['barcode'],
          helperText: 'EAN13, UPC ou autre (codes additionnels en étape 5)',
          prefixIcon: Icons.qr_code_scanner,
        ),
      ],
    );
  }

  Widget _buildDescriptionsFields() {
    return Column(
      children: [
        // Description courte - AVEC VALIDATION INLINE
        CustomTextField(
          label: 'Description courte',
          initialValue: formData.shortDescription,
          errorText: errors['shortDescription'],
          onChanged: (value) => onFieldChanged('shortDescription', value),
          prefixIcon: Icons.short_text,
          maxLines: 2,
          helperText: 'Résumé pour les listes et recherches (150 caractères max)',
          autovalidateMode: AutovalidateMode.onUserInteraction, // ✨ VALIDATION INLINE
        ),
        const SizedBox(height: 16),

        // Description complète
        CustomTextField(
          label: 'Description complète',
          initialValue: formData.description,
          errorText: errors['description'],
          onChanged: (value) => onFieldChanged('description', value),
          prefixIcon: Icons.notes_outlined,
          maxLines: 4,
          helperText: 'Description détaillée pour la fiche produit',
        ),
      ],
    );
  }

  Widget _buildReferencesFields() {
    return Column(
      children: [
        // Référence interne
        CustomTextField(
          label: 'Référence interne',
          initialValue: formData.internalReference,
          errorText: errors['internalReference'],
          onChanged: (value) => onFieldChanged('internalReference', value),
          prefixIcon: Icons.tag,
          helperText: 'Référence pour usage interne (optionnel)',
        ),
        const SizedBox(height: 16),

        // Référence fournisseur
        CustomTextField(
          label: 'Référence fournisseur',
          initialValue: formData.supplierReference,
          errorText: errors['supplierReference'],
          onChanged: (value) => onFieldChanged('supplierReference', value),
          prefixIcon: Icons.factory_outlined,
          helperText: 'Référence du fournisseur principal (optionnel)',
        ),
        const SizedBox(height: 16),

        // Tags
        CustomTextField(
          label: 'Tags',
          initialValue: formData.tags,
          errorText: errors['tags'],
          onChanged: (value) => onFieldChanged('tags', value),
          prefixIcon: Icons.label_outlined,
          helperText: 'Mots-clés séparés par des virgules (ex: bio, promo, nouveau)',
        ),
        const SizedBox(height: 16),

        // Notes
        CustomTextField(
          label: 'Notes internes',
          initialValue: formData.notes,
          errorText: errors['notes'],
          onChanged: (value) => onFieldChanged('notes', value),
          prefixIcon: Icons.note_outlined,
          maxLines: 3,
          helperText: 'Informations complémentaires (non visibles publiquement)',
        ),
      ],
    );
  }
}