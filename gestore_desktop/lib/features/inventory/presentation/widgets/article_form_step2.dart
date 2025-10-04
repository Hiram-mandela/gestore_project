// ========================================
// FICHIER 2: lib/features/inventory/presentation/widgets/article_form_step2.dart
// Étape 2: Prix et Stock
// ========================================

import 'package:flutter/material.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep2 extends StatelessWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep2({
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
          'Prix et gestion du stock',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 8),
        Text(
          'Définissez les prix et les paramètres de stock',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 24),

        // Prix
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Prix d\'achat (FCFA) *',
                initialValue: formData.purchasePrice.toString(),
                errorText: errors['purchasePrice'],
                onChanged: (value) => onFieldChanged(
                  'purchasePrice',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.shopping_cart,
                keyboardType: TextInputType.number,
                required: true,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                label: 'Prix de vente (FCFA) *',
                initialValue: formData.sellingPrice.toString(),
                errorText: errors['sellingPrice'],
                onChanged: (value) => onFieldChanged(
                  'sellingPrice',
                  double.tryParse(value) ?? 0.0,
                ),
                prefixIcon: Icons.sell,
                keyboardType: TextInputType.number,
                required: true,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Marge calculée
        _buildMarginCard(context),
        const SizedBox(height: 24),

        // Gestion du stock
        CustomSwitchTile(
          title: 'Gérer le stock',
          subtitle: 'Activer le suivi des quantités en stock',
          value: formData.manageStock,
          onChanged: (value) => onFieldChanged('manageStock', value),
        ),
        const SizedBox(height: 16),

        // Stock minimum et maximum (si gestion activée)
        if (formData.manageStock) ...[
          Row(
            children: [
              Expanded(
                child: CustomTextField(
                  label: 'Stock minimum',
                  initialValue: formData.minStockLevel.toString(),
                  errorText: errors['minStockLevel'],
                  onChanged: (value) => onFieldChanged(
                    'minStockLevel',
                    int.tryParse(value) ?? 0,
                  ),
                  prefixIcon: Icons.warning_amber,
                  keyboardType: TextInputType.number,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomTextField(
                  label: 'Stock maximum',
                  initialValue: formData.maxStockLevel.toString(),
                  errorText: errors['maxStockLevel'],
                  onChanged: (value) => onFieldChanged(
                    'maxStockLevel',
                    int.tryParse(value) ?? 0,
                  ),
                  prefixIcon: Icons.inventory,
                  keyboardType: TextInputType.number,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
        ],

        // Options de vente
        CustomSwitchTile(
          title: 'Vendable',
          subtitle: 'Cet article peut être vendu',
          value: formData.isSellable,
          onChanged: (value) => onFieldChanged('isSellable', value),
        ),
        const SizedBox(height: 8),

        CustomSwitchTile(
          title: 'Achetable',
          subtitle: 'Cet article peut être acheté auprès de fournisseurs',
          value: formData.isPurchasable,
          onChanged: (value) => onFieldChanged('isPurchasable', value),
        ),
      ],
    );
  }

  Widget _buildMarginCard(BuildContext context) {
    final margin = formData.sellingPrice - formData.purchasePrice;
    final marginPercent = formData.purchasePrice > 0
        ? (margin / formData.purchasePrice * 100)
        : 0.0;

    Color color;
    if (marginPercent >= 20) {
      color = Colors.green;
    } else if (marginPercent >= 10) {
      color = Colors.orange;
    } else {
      color = Colors.red;
    }

    return Card(
      color: color.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Marge unitaire',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${margin.toStringAsFixed(0)} FCFA',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  'Pourcentage',
                  style: TextStyle(
                    fontSize: 12,
                    color: color,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${marginPercent.toStringAsFixed(1)}%',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
