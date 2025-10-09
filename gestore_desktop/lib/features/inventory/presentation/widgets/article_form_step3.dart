// ========================================
// lib/features/inventory/presentation/widgets/article_form_step3.dart
// ÉTAPE 3 : Gestion de Stock (8 champs)
// VERSION 2.0 - Formulaire Complet
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep3 extends ConsumerWidget {
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
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 24),

        // Section 1 : Configuration du stock
        _buildStockConfigSection(context),
        const SizedBox(height: 16),

        // Section 2 : Niveaux de stock (visible si manageStock = true)
        if (formData.manageStock) ...[
          _buildStockLevelsSection(context),
          const SizedBox(height: 16),
        ],

        // Section 3 : Options avancées
        _buildAdvancedOptionsSection(context),
        const SizedBox(height: 16),

        // Section 4 : Disponibilité
        _buildAvailabilitySection(context),
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
                Icons.inventory,
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
                    'Gestion de stock',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Configurez la gestion des stocks et les alertes',
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

  // ==================== CONFIGURATION DU STOCK ====================

  Widget _buildStockConfigSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Configuration', Icons.settings),
            const SizedBox(height: 16),

            // Gérer le stock
            CustomSwitchTile(
              title: 'Gérer le stock',
              subtitle: formData.manageStock
                  ? 'Les mouvements de stock seront suivis'
                  : 'Aucun suivi de stock pour cet article',
              value: formData.manageStock,
              icon: Icons.inventory_2,
              onChanged: (value) => onFieldChanged('manageStock', value),
            ),

            if (formData.manageStock) ...[
              const SizedBox(height: 12),

              // Stock négatif autorisé
              CustomSwitchTile(
                title: 'Autoriser stock négatif',
                subtitle: formData.allowNegativeStock
                    ? 'Ventes possibles même sans stock'
                    : 'Ventes bloquées si stock insuffisant',
                value: formData.allowNegativeStock,
                icon: Icons.remove_circle_outline,
                onChanged: (value) => onFieldChanged('allowNegativeStock', value),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== NIVEAUX DE STOCK ====================

  Widget _buildStockLevelsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Niveaux de stock', Icons.stacked_line_chart),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: CustomNumberField(
                    label: 'Stock minimum',
                    initialValue: formData.minStockLevel.toDouble(),
                    errorText: errors['minStockLevel'],
                    onChanged: (value) => onFieldChanged('minStockLevel', value.toInt()),
                    prefixIcon: Icons.arrow_downward,
                    decimals: 0,
                    minValue: 0,
                    helperText: 'Alerte si en dessous',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: CustomNumberField(
                    label: 'Stock maximum',
                    initialValue: formData.maxStockLevel.toDouble(),
                    errorText: errors['maxStockLevel'],
                    onChanged: (value) => onFieldChanged('maxStockLevel', value.toInt()),
                    prefixIcon: Icons.arrow_upward,
                    decimals: 0,
                    minValue: 0,
                    helperText: 'Stock idéal',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Indicateur visuel
            _buildStockLevelIndicator(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStockLevelIndicator(BuildContext context) {
    if (formData.minStockLevel == 0 && formData.maxStockLevel == 0) {
      return const SizedBox();
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              formData.maxStockLevel > 0
                  ? 'Alertes actives : Stock bas < ${formData.minStockLevel}, '
                  'Stock idéal = ${formData.maxStockLevel}'
                  : 'Alerte stock bas activée à ${formData.minStockLevel} unités',
              style: TextStyle(
                color: Colors.blue.shade700,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== OPTIONS AVANCÉES ====================

  Widget _buildAdvancedOptionsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Traçabilité', Icons.track_changes),
            const SizedBox(height: 16),

            // Suivi par lot
            CustomSwitchTile(
              title: 'Suivi par lot',
              subtitle: formData.requiresLotTracking
                  ? 'Numéro de lot obligatoire à chaque mouvement'
                  : 'Pas de suivi des lots',
              value: formData.requiresLotTracking,
              icon: Icons.format_list_numbered,
              onChanged: (value) => onFieldChanged('requiresLotTracking', value),
            ),

            const SizedBox(height: 12),

            // Date d'expiration
            CustomSwitchTile(
              title: 'Date d\'expiration',
              subtitle: formData.requiresExpiryDate
                  ? 'Date d\'expiration obligatoire'
                  : 'Pas de gestion des dates d\'expiration',
              value: formData.requiresExpiryDate,
              icon: Icons.calendar_today,
              onChanged: (value) => onFieldChanged('requiresExpiryDate', value),
            ),

            if (formData.requiresLotTracking || formData.requiresExpiryDate) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.amber.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber, color: Colors.amber.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'La traçabilité avancée nécessite des informations '
                            'supplémentaires lors des entrées et sorties de stock.',
                        style: TextStyle(
                          color: Colors.amber.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ==================== DISPONIBILITÉ ====================

  Widget _buildAvailabilitySection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Disponibilité commerciale', Icons.shopping_cart),
            const SizedBox(height: 16),

            // Vendable
            CustomSwitchTile(
              title: 'Article vendable',
              subtitle: formData.isSellable
                  ? 'Peut être vendu aux clients'
                  : 'Non disponible à la vente',
              value: formData.isSellable,
              icon: Icons.point_of_sale,
              onChanged: (value) => onFieldChanged('isSellable', value),
            ),

            const SizedBox(height: 12),

            // Achetable
            CustomSwitchTile(
              title: 'Article achetable',
              subtitle: formData.isPurchasable
                  ? 'Peut être commandé aux fournisseurs'
                  : 'Pas d\'achat auprès des fournisseurs',
              value: formData.isPurchasable,
              icon: Icons.shopping_bag,
              onChanged: (value) => onFieldChanged('isPurchasable', value),
            ),

            if (!formData.isSellable && !formData.isPurchasable) ...[
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(Icons.block, color: Colors.red.shade700, size: 20),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Attention : Cet article ne peut ni être vendu ni acheté. '
                            'Activez au moins une option.',
                        style: TextStyle(
                          color: Colors.red.shade900,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
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