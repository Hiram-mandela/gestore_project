// ========================================
// lib/features/inventory/presentation/widgets/article_form_step5.dart
// ÉTAPE 5 : Métadonnées Avancées
// Dimensions, Images, Codes-barres, Variantes, Statut
// VERSION 2.0 - Formulaire Complet
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
        _buildDimensionsSection(context),
        const SizedBox(height: 16),

        // Section 2 : Images multiples
        _buildImagesSection(context),
        const SizedBox(height: 16),

        // Section 3 : Codes-barres additionnels
        _buildBarcodesSection(context),
        const SizedBox(height: 16),

        // Section 4 : Variantes (si applicable)
        if (formData.articleType != 'variant')
          _buildVariantsSection(context),

        if (formData.articleType == 'variant')
          _buildVariantInfoSection(context),

        const SizedBox(height: 16),

        // Section 5 : Statut
        _buildStatusSection(context),
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
                Icons.auto_awesome,
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
                    'Métadonnées avancées',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Informations complémentaires pour une gestion optimale',
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

  // ==================== DIMENSIONS ====================

  Widget _buildDimensionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Dimensions et poids', Icons.straighten),
            const SizedBox(height: 16),

            // Poids
            CustomNumberField(
              label: 'Poids',
              initialValue: formData.weight,
              errorText: errors['weight'],
              onChanged: (value) => onFieldChanged('weight', value),
              prefixIcon: Icons.monitor_weight,
              suffix: 'kg',
              decimals: 2,
              minValue: 0,
              helperText: 'Poids unitaire de l\'article',
            ),

            const SizedBox(height: 16),

            // Dimensions (L x l x h)
            Row(
              children: [
                Expanded(
                  child: CustomNumberField(
                    label: 'Longueur',
                    initialValue: formData.length,
                    errorText: errors['length'],
                    onChanged: (value) => onFieldChanged('length', value),
                    prefixIcon: Icons.straighten,
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
                    prefixIcon: Icons.width_normal,
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
                    prefixIcon: Icons.height,
                    suffix: 'cm',
                    decimals: 1,
                    minValue: 0,
                  ),
                ),
              ],
            ),

            if (formData.weight > 0 || formData.length > 0)
              _buildDimensionsSummary(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDimensionsSummary(BuildContext context) {
    final volume = formData.length * formData.width * formData.height;

    return Container(
      margin: const EdgeInsets.only(top: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          if (formData.weight > 0)
            _buildInfoRow(
              'Poids total',
              '${formData.weight.toStringAsFixed(2)} kg',
            ),
          if (volume > 0) ...[
            const Divider(height: 12),
            _buildInfoRow(
              'Volume',
              '${(volume / 1000).toStringAsFixed(2)} litres',
            ),
          ],
        ],
      ),
    );
  }

  // ==================== IMAGES ====================

  Widget _buildImagesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: MultiImageManager(
          images: formData.images,
          onImagesChanged: (images) => onFieldChanged('images', images),
        ),
      ),
    );
  }

  // ==================== CODES-BARRES ====================

  Widget _buildBarcodesSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AdditionalBarcodesManager(
          barcodes: formData.additionalBarcodes,
          onBarcodesChanged: (barcodes) => onFieldChanged('additionalBarcodes', barcodes),
        ),
      ),
    );
  }

  // ==================== VARIANTES ====================

  Widget _buildVariantsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Variantes', Icons.dashboard_customize),
            const SizedBox(height: 16),

            // Info sur les variantes
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Gestion des variantes',
                          style: TextStyle(
                            color: Colors.blue.shade900,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Les variantes permettent de créer des déclinaisons d\'un '
                        'produit (tailles, couleurs, etc.). Créez d\'abord l\'article '
                        'parent, puis créez les variantes depuis l\'écran de détail.',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Bouton de gestion (placeholder)
            OutlinedButton.icon(
              onPressed: () => _showVariantsInfo(context),
              icon: const Icon(Icons.dashboard_customize),
              label: const Text('En savoir plus sur les variantes'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.all(16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVariantInfoSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Information variante', Icons.link),
            const SizedBox(height: 16),

            // Article parent (si c'est une variante)
            if (formData.parentArticleId != null && formData.parentArticleId!.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.purple.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.link, color: Colors.purple.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Article parent',
                            style: TextStyle(
                              color: Colors.purple.shade900,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'ID: ${formData.parentArticleId}',
                            style: TextStyle(
                              color: Colors.purple.shade700,
                              fontSize: 11,
                              fontFamily: 'monospace',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              )
            else
              _buildNoParentInfo(context),

            const SizedBox(height: 16),

            // Attributs de variante
            CustomTextField(
              label: 'Attributs de variante',
              initialValue: formData.variantAttributes,
              errorText: errors['variantAttributes'],
              onChanged: (value) => onFieldChanged('variantAttributes', value),
              prefixIcon: Icons.list,
              maxLines: 3,
              helperText: 'Ex: {"couleur": "Rouge", "taille": "L"}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoParentInfo(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.warning_amber, color: Colors.orange.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Cet article est marqué comme variante mais n\'a pas d\'article parent. '
                  'Veuillez sélectionner un article parent ou changer le type.',
              style: TextStyle(
                color: Colors.orange.shade900,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STATUT ====================

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Statut de l\'article', Icons.toggle_on),
            const SizedBox(height: 16),

            CustomSwitchTile(
              title: 'Article actif',
              subtitle: formData.isActive
                  ? 'Visible et utilisable dans toute l\'application'
                  : 'Masqué et non disponible',
              value: formData.isActive,
              icon: formData.isActive ? Icons.visibility : Icons.visibility_off,
              onChanged: (value) => onFieldChanged('isActive', value),
            ),

            const SizedBox(height: 16),

            // Info sur la désactivation
            if (!formData.isActive)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange.shade700, size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Un article inactif ne peut pas être vendu ni acheté. '
                            'Il reste visible dans les historiques et rapports.',
                        style: TextStyle(
                          color: Colors.orange.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
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

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 12,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  void _showVariantsInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Gestion des variantes'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Les variantes permettent de gérer des déclinaisons d\'un même produit.',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text('Exemples :'),
              const SizedBox(height: 8),
              _buildExampleItem('T-shirt → Tailles (S, M, L, XL)'),
              _buildExampleItem('Chaussure → Pointures (38, 39, 40...)'),
              _buildExampleItem('Peinture → Couleurs (Rouge, Bleu...)'),
              const SizedBox(height: 16),
              const Text(
                'Comment créer des variantes ?',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              _buildStepItem('1. Créez l\'article parent (ex: "T-shirt")'),
              _buildStepItem('2. Définissez les attributs variables'),
              _buildStepItem('3. Créez les variantes depuis le détail'),
              _buildStepItem('4. Chaque variante hérite du parent'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Compris'),
          ),
        ],
      ),
    );
  }

  Widget _buildExampleItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.arrow_right, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
        ],
      ),
    );
  }

  Widget _buildStepItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Text(text, style: const TextStyle(fontSize: 13)),
    );
  }
}