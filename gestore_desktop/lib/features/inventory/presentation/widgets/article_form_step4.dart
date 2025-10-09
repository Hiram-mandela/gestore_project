// ========================================
// lib/features/inventory/presentation/widgets/article_form_step4.dart
// ÉTAPE 4 : Prix et Fournisseur (3 champs + calculs)
// VERSION 2.0 - Formulaire Complet
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
                    'Prix et fournisseur',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Définissez les prix et le fournisseur principal',
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
            _buildSectionTitle(context, 'Tarification', Icons.price_change),
            const SizedBox(height: 16),

            Row(
              children: [
                // Prix d'achat
                Expanded(
                  child: CustomNumberField(
                    label: 'Prix d\'achat HT',
                    initialValue: formData.purchasePrice,
                    errorText: errors['purchasePrice'],
                    onChanged: (value) => onFieldChanged('purchasePrice', value),
                    prefixIcon: Icons.shopping_cart,
                    suffix: 'FCFA',
                    decimals: 2,
                    minValue: 0,
                    helperText: 'Coût d\'achat unitaire',
                    required: true,
                  ),
                ),
                const SizedBox(width: 16),
                // Prix de vente
                Expanded(
                  child: CustomNumberField(
                    label: 'Prix de vente TTC',
                    initialValue: formData.sellingPrice,
                    errorText: errors['sellingPrice'],
                    onChanged: (value) => onFieldChanged('sellingPrice', value),
                    prefixIcon: Icons.point_of_sale,
                    suffix: 'FCFA',
                    decimals: 2,
                    minValue: 0,
                    helperText: 'Prix de vente au client',
                    required: true,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Info fiscale
            _buildTaxInfo(context),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxInfo(BuildContext context) {
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
            _buildSectionTitle(context, 'Calculs automatiques', Icons.calculate),
            const SizedBox(height: 16),

            // Carte marge
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    marginColor.withValues(alpha: 0.1),
                    marginColor.withValues(alpha: 0.05),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: marginColor.withValues(alpha: 0.3)),
              ),
              child: Column(
                children: [
                  // Marge en pourcentage
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(marginIcon, color: marginColor, size: 32),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${margin.toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.bold,
                              color: marginColor,
                            ),
                          ),
                          Text(
                            marginQuality,
                            style: TextStyle(
                              fontSize: 14,
                              color: marginColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Divider(),
                  const SizedBox(height: 16),
                  // Bénéfice
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Bénéfice unitaire',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '${profit.toStringAsFixed(2)} FCFA',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: profit >= 0 ? Colors.green : Colors.red,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Détails des calculs
            _buildCalculationDetails(context),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationDetails(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          _buildCalculationRow(
            'Prix d\'achat HT',
            '${formData.purchasePrice.toStringAsFixed(2)} FCFA',
          ),
          const Divider(height: 16),
          _buildCalculationRow(
            'Prix de vente TTC',
            '${formData.sellingPrice.toStringAsFixed(2)} FCFA',
          ),
          const Divider(height: 16),
          _buildCalculationRow(
            'Bénéfice',
            '${(formData.sellingPrice - formData.purchasePrice).toStringAsFixed(2)} FCFA',
            isBold: true,
          ),
          const Divider(height: 16),
          _buildCalculationRow(
            'Marge',
            '${formData.marginPercent.toStringAsFixed(2)}%',
            isBold: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, {bool isBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade700,
            fontSize: 13,
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
    // TODO: Charger la liste des fournisseurs depuis le provider
    // Pour l'instant, c'est un placeholder

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

            // Dropdown fournisseur (placeholder)
            CustomDropdown<String>(
              label: 'Sélectionner un fournisseur',
              value: formData.mainSupplierId.isEmpty ? null : formData.mainSupplierId,
              items: const [
                DropdownMenuItem(
                  value: 'placeholder',
                  child: Text('Module Fournisseurs à implémenter'),
                ),
              ],
              onChanged: (value) => onFieldChanged('mainSupplierId', value ?? ''),
              prefixIcon: Icons.local_shipping,
              helperText: 'Fournisseur principal pour cet article (optionnel)',
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
                          'Vous pourrez alors lier vos articles aux fournisseurs.',
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
              'et l\'associer plus tard.',
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