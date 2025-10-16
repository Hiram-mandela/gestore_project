// ========================================
// lib/features/inventory/presentation/widgets/article_form_step5.dart
// ÉTAPE 5 : Métadonnées Avancées
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Remplacement de toutes les Card par des conteneurs de section stylisés (fond, bordure, ombre).
// - Application de la palette GESTORE (AppColors) pour une cohérence totale des couleurs.
// - Refonte des bannières d'information (variantes, statut) avec les couleurs de statut GESTORE.
// - Amélioration de l'en-tête et des boîtes de dialogue pour correspondre au design GESTORE.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';
import 'advanced_form_widgets.dart';

class ArticleFormStep5 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep5({
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

        // Section 1 : Dimensions physiques
        _buildDimensionsSection(),
        const SizedBox(height: 24),

        // Section 2 : Images multiples
        _buildImagesSection(),
        const SizedBox(height: 24),

        // Section 3 : Codes-barres additionnels
        _buildBarcodesSection(),
        const SizedBox(height: 24),

        // Section 4 : Variantes (si applicable)
        if (formData.articleType != 'variant') _buildVariantsSection(context),
        if (formData.articleType == 'variant') _buildVariantInfoSection(),
        const SizedBox(height: 24),

        // Section 5 : Statut
        _buildStatusSection(),
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
            Icons.auto_awesome_outlined,
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
                'Métadonnées avancées',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Informations complémentaires pour une gestion optimale.',
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

  // ==================== SECTIONS ====================

  Widget _buildDimensionsSection() {
    return _buildSectionContainer(
      title: 'Dimensions et poids',
      icon: Icons.straighten_outlined,
      child: Column(
        children: [
          // Poids
          CustomNumberField(
            label: 'Poids',
            initialValue: formData.weight,
            errorText: errors['weight'],
            onChanged: (value) => onFieldChanged('weight', value),
            prefixIcon: Icons.monitor_weight_outlined,
            suffix: 'kg',
            decimals: 2,
            minValue: 0,
            helperText: 'Poids unitaire de l\'article',
          ),
          const SizedBox(height: 16),
          // Dimensions (L x l x h)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomNumberField(
                  label: 'Longueur',
                  initialValue: formData.length,
                  errorText: errors['length'],
                  onChanged: (value) => onFieldChanged('length', value),
                  prefixIcon: Icons.straighten_outlined,
                  suffix: 'cm',
                  decimals: 1,
                  minValue: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomNumberField(
                  label: 'Largeur',
                  initialValue: formData.width,
                  errorText: errors['width'],
                  onChanged: (value) => onFieldChanged('width', value),
                  prefixIcon: Icons.width_normal_outlined,
                  suffix: 'cm',
                  decimals: 1,
                  minValue: 0,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: CustomNumberField(
                  label: 'Hauteur',
                  initialValue: formData.height,
                  errorText: errors['height'],
                  onChanged: (value) => onFieldChanged('height', value),
                  prefixIcon: Icons.height_outlined,
                  suffix: 'cm',
                  decimals: 1,
                  minValue: 0,
                ),
              ),
            ],
          ),
          if (formData.weight > 0 || formData.length > 0)
            _buildDimensionsSummary(),
        ],
      ),
    );
  }

  Widget _buildImagesSection() {
    return _buildSectionContainer(
      title: 'Images',
      icon: Icons.image_outlined,
      child: MultiImageManager(
        images: formData.images,
        onImagesChanged: (images) => onFieldChanged('images', images),
      ),
    );
  }

  Widget _buildBarcodesSection() {
    return _buildSectionContainer(
      title: 'Codes-barres additionnels',
      icon: Icons.qr_code_2_outlined,
      child: AdditionalBarcodesManager(
        barcodes: formData.additionalBarcodes,
        onBarcodesChanged: (barcodes) =>
            onFieldChanged('additionalBarcodes', barcodes),
      ),
    );
  }

  Widget _buildVariantsSection(BuildContext context) {
    return _buildSectionContainer(
      title: 'Variantes',
      icon: Icons.dashboard_customize_outlined,
      child: Column(
        children: [
          _buildInfoBanner(
            message:
            'Créez des déclinaisons (tailles, couleurs, etc.) d\'un produit. Créez d\'abord l\'article parent, puis les variantes depuis son écran de détail.',
            color: AppColors.info,
            icon: Icons.info_outline_rounded,
            title: 'Gestion des variantes',
          ),
          const SizedBox(height: 16),
          // Bouton de gestion (placeholder)
          OutlinedButton.icon(
            onPressed: () => _showVariantsInfo(context),
            icon: const Icon(Icons.help_outline),
            label: const Text('Comment créer des variantes ?'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVariantInfoSection() {
    return _buildSectionContainer(
      title: 'Information variante',
      icon: Icons.link_outlined,
      child: Column(
        children: [
          // Article parent (si c'est une variante)
          if (formData.parentArticleId != null &&
              formData.parentArticleId!.isNotEmpty)
            _buildInfoBanner(
                message: 'ID: ${formData.parentArticleId}',
                color: AppColors.secondary,
                icon: Icons.link,
                title: 'Article Parent')
          else
            _buildInfoBanner(
              message:
              'Cet article est marqué comme variante mais n\'a pas d\'article parent. Veuillez le lier à un parent ou changer son type.',
              color: AppColors.warning,
              icon: Icons.warning_amber_rounded,
            ),
          const SizedBox(height: 16),
          // Attributs de variante
          CustomTextField(
            label: 'Attributs de variante (JSON)',
            initialValue: formData.variantAttributes,
            errorText: errors['variantAttributes'],
            onChanged: (value) => onFieldChanged('variantAttributes', value),
            prefixIcon: Icons.data_object_outlined,
            maxLines: 3,
            helperText: 'Ex: {"couleur": "Rouge", "taille": "L"}',
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSection() {
    return _buildSectionContainer(
      title: 'Statut',
      icon: Icons.toggle_on_outlined,
      child: Column(
        children: [
          CustomSwitchTile(
            title: 'Article actif',
            subtitle: formData.isActive
                ? 'Visible et utilisable dans toute l\'application'
                : 'Masqué et non disponible',
            value: formData.isActive,
            icon: formData.isActive
                ? Icons.visibility_outlined
                : Icons.visibility_off_outlined,
            onChanged: (value) => onFieldChanged('isActive', value),
          ),
          if (!formData.isActive) ...[
            const SizedBox(height: 16),
            _buildInfoBanner(
              message:
              'Un article inactif ne peut pas être vendu ni acheté. Il reste visible dans les historiques et rapports.',
              color: AppColors.warning,
              icon: Icons.info_outline_rounded,
            ),
          ]
        ],
      ),
    );
  }

  // ==================== WIDGETS RÉUTILISABLES ====================

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
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
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildDimensionsSummary() {
    final volume = formData.length * formData.width * formData.height;
    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          if (formData.weight > 0)
            _buildInfoRow(
              'Poids total',
              '${formData.weight.toStringAsFixed(2)} kg',
            ),
          if (volume > 0 && formData.weight > 0)
            const Divider(height: 12, color: AppColors.border),
          if (volume > 0) ...[
            _buildInfoRow(
              'Volume',
              '${(volume / 1000).toStringAsFixed(2)} litres',
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required Color color,
    required IconData icon,
    String? title,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null)
                  Text(
                    title,
                    style: TextStyle(
                        color: color,
                        fontWeight: FontWeight.bold,
                        fontSize: 14),
                  ),
                if (title != null) const SizedBox(height: 4),
                Text(
                  message,
                  style:
                  TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showVariantsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Gestion des variantes',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              const Text(
                'Les variantes permettent de gérer des déclinaisons d\'un même produit.',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              const Text('Exemples :', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _buildExampleItem('T-shirt → Tailles (S, M, L)'),
              _buildExampleItem('Peinture → Couleurs (Rouge, Bleu)'),
              const SizedBox(height: 16),
              const Text('Comment faire ?', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
              const SizedBox(height: 8),
              _buildStepItem('1. Créez et enregistrez l\'article "parent".'),
              _buildStepItem('2. Depuis l\'écran de détail de cet article, utilisez l\'option pour générer des variantes.'),
            ],
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.pop(context),
            style: FilledButton.styleFrom(backgroundColor: AppColors.primary),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.arrow_right, size: 16, color: AppColors.textTertiary),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      ]),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(children: [
        const Icon(Icons.check_circle_outline, size: 14, color: AppColors.success),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary))),
      ]),
    );
  }
}