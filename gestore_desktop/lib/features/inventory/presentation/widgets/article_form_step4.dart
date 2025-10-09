// ========================================
// lib/features/inventory/presentation/widgets/article_form_step4.dart
// ÉTAPE 4 : Prix et Fournisseur (3 champs + calculs)
// VERSION 2.0 - CORRIGÉE - Fix dropdown supplier
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep4 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep4({
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

        // Section 1 : Prix
        _buildPricingSection(context),
        const SizedBox(height: 16),

        // Section 2 : Calculs et marges
        _buildMarginSection(context),
        const SizedBox(height: 16),

        // Section 3 : Fournisseur principal
        _buildSupplierSection(context, ref),
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
                Icons.attach_money,
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
                    'Prix et Fournisseur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Définissez les prix et associez un fournisseur',
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

  // ==================== SECTION PRIX ====================

  Widget _buildPricingSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Prix', Icons.payments),
            const SizedBox(height: 16),

            Row(
              children: [
                // Prix d'achat
                Expanded(
                  child: CustomTextField(
                    label: 'Prix d\'achat (HT)',
                    initialValue: formData.purchasePrice.toString(),
                    errorText: errors['purchasePrice'],
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      onFieldChanged('purchasePrice', price);
                    },
                    prefixIcon: Icons.shopping_cart,
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    helperText: 'Coût d\'achat HT',
                  ),
                ),
                const SizedBox(width: 16),

                // Prix de vente
                Expanded(
                  child: CustomTextField(
                    label: 'Prix de vente (TTC)',
                    initialValue: formData.sellingPrice.toString(),
                    errorText: errors['sellingPrice'],
                    onChanged: (value) {
                      final price = double.tryParse(value) ?? 0.0;
                      onFieldChanged('sellingPrice', price);
                    },
                    prefixIcon: Icons.sell,
                    required: true,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    helperText: 'Prix de vente TTC',
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info TVA
            _buildInfoBox(context),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoBox(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade600, size: 18),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Le taux de TVA est défini dans la catégorie de l\'article',
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== SECTION MARGE ====================

  Widget _buildMarginSection(BuildContext context) {
    final margin = formData.marginPercent;
    final profit = formData.sellingPrice - formData.purchasePrice;

    // Couleur selon la marge
    Color marginColor = Colors.grey;
    IconData marginIcon = Icons.trending_flat;
    String marginQuality = 'Pas de marge';

    if (margin > 0) {
      if (margin < 20) {
        marginColor = Colors.orange;
        marginIcon = Icons.trending_down;
        marginQuality = 'Marge faible';
      } else if (margin < 40) {
        marginColor = Colors.blue;
        marginIcon = Icons.trending_up;
        marginQuality = 'Marge correcte';
      } else {
        marginColor = Colors.green;
        marginIcon = Icons.trending_up;
        marginQuality = 'Bonne marge';
      }
    } else if (margin < 0) {
      marginColor = Colors.red;
      marginIcon = Icons.trending_down;
      marginQuality = 'Perte !';
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(context, 'Analyse de marge', Icons.analytics),
            const SizedBox(height: 16),

            // Calculs
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: marginColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: marginColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  // Marge en pourcentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(marginIcon, color: marginColor, size: 32),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Marge',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                '${margin.toStringAsFixed(1)}%',
                                style: TextStyle(
                                  color: marginColor,
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  fontFamily: 'monospace',
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: marginColor,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          marginQuality,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const Divider(height: 24),

                  // Détails
                  _buildCalculationRow('Profit unitaire', '${profit.toStringAsFixed(0)} FCFA', profit >= 0),
                  const SizedBox(height: 8),
                  _buildCalculationRow('Prix achat', '${formData.purchasePrice.toStringAsFixed(0)} FCFA', false),
                  const SizedBox(height: 8),
                  _buildCalculationRow('Prix vente', '${formData.sellingPrice.toStringAsFixed(0)} FCFA', true),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, bool isBold) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[700],
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'monospace',
          ),
        ),
      ],
    );
  }

  // ==================== SECTION FOURNISSEUR ====================

  Widget _buildSupplierSection(BuildContext context, WidgetRef ref) {
    // ⭐ CORRECTION: Ne pas utiliser de dropdown si on n'a pas de fournisseurs
    // Pour éviter l'erreur de valeur dupliquée

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSectionTitle(context, 'Fournisseur principal', Icons.business),
                TextButton.icon(
                  onPressed: () => _showCreateSupplierDialog(context),
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Créer'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // ⭐ CORRECTION: Utiliser un TextField désactivé au lieu d'un dropdown
            // Cela évite le problème de valeur dupliquée
            CustomTextField(
              label: 'Fournisseur principal',
              initialValue: formData.mainSupplierId.isNotEmpty
                  ? 'Fournisseur sélectionné (ID: ${formData.mainSupplierId.substring(0, 8)}...)'
                  : '',
              errorText: errors['mainSupplierId'],
              onChanged: (value) => onFieldChanged('mainSupplierId', value),
              prefixIcon: Icons.local_shipping,
              helperText: 'Module Fournisseurs non encore implémenté',
              enabled: false,
            ),

            const SizedBox(height: 16),

            // Info module
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline, color: Colors.blue.shade700, size: 18),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Le module Fournisseurs sera disponible dans une prochaine version. '
                          'Vous pourrez alors lier vos articles aux fournisseurs et gérer '
                          'les prix d\'achat spécifiques par fournisseur.',
                      style: TextStyle(
                        color: Colors.blue.shade700,
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

  void _showCreateSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Création rapide de fournisseur'),
        content: const Text(
          'Cette fonctionnalité sera disponible avec le module Fournisseurs.\n\n'
              'En attendant, vous pouvez créer l\'article sans fournisseur '
              'et l\'associer plus tard lorsque le module sera disponible.',
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