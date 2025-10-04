// ========================================
// FICHIER 3: lib/features/inventory/presentation/widgets/article_form_step3.dart
// Étape 3: Options avancées
// ========================================

import 'package:flutter/material.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep3 extends StatelessWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep3({
    super.key,
    required this.formData,
    required this.errors,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        Text(
          'Options avancées',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Paramètres supplémentaires et options avancées',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Traçabilité
        Text(
          'Traçabilité',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        CustomSwitchTile(
          title: 'Traçabilité par lot',
          subtitle: 'Suivre les numéros de lot',
          value: formData.requiresLotTracking,
          onChanged: (value) => onFieldChanged('requiresLotTracking', value),
        ),
        const SizedBox(height: 8),
        CustomSwitchTile(
          title: 'Date de péremption',
          subtitle: 'Gérer les dates de péremption (DLC/DLUO)',
          value: formData.requiresExpiryDate,
          onChanged: (value) => onFieldChanged('requiresExpiryDate', value),
        ),
        const SizedBox(height: 8),
        CustomSwitchTile(
          title: 'Autoriser stock négatif',
          subtitle: 'Permettre les ventes même sans stock disponible',
          value: formData.allowNegativeStock,
          onChanged: (value) => onFieldChanged('allowNegativeStock', value),
        ),
        const SizedBox(height: 24),

        // Dimensions
        Text(
          'Dimensions',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Poids (kg)',
                initialValue: formData.weight > 0 ? formData.weight.toString() : '',
                onChanged: (value) => onFieldChanged(
                  'weight',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.scale,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Longueur (m)',
                initialValue: formData.length > 0 ? formData.length.toString() : '',
                onChanged: (value) => onFieldChanged(
                  'length',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.straighten,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Largeur (m)',
                initialValue: formData.width > 0 ? formData.width.toString() : '',
                onChanged: (value) => onFieldChanged(
                  'width',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.width_normal,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Hauteur (m)',
                initialValue: formData.height > 0 ? formData.height.toString() : '',
                onChanged: (value) => onFieldChanged(
                  'height',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.height,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Tags
        CustomTextField(
          label: 'Tags',
          initialValue: formData.tags,
          onChanged: (value) => onFieldChanged('tags', value),
          prefixIcon: Icons.label,
          helperText: 'Séparés par des virgules',
        ),
        const SizedBox(height: 16),

        // Notes
        CustomTextField(
          label: 'Notes',
          initialValue: formData.notes,
          onChanged: (value) => onFieldChanged('notes', value),
          prefixIcon: Icons.note,
          maxLines: 4,
        ),
        const SizedBox(height: 24),

        // Statut
        CustomSwitchTile(
          title: 'Article actif',
          subtitle: 'Désactiver pour masquer l\'article sans le supprimer',
          value: formData.isActive,
          onChanged: (value) => onFieldChanged('isActive', value),
        ),
      ],
    );
  }
}