// ========================================
// lib/features/sales/presentation/widgets/pos_cart_widget.dart
// Widget panier du POS
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/pos_state.dart';

/// Widget affichant le panier avec les articles
class PosCartWidget extends StatelessWidget {
  final List<CartItem> cartItems;
  final Function(String articleId, double quantity) onUpdateQuantity;
  final Function(String articleId) onRemoveItem;
  final Function(String articleId, double discount) onApplyDiscount;

  const PosCartWidget({
    super.key,
    required this.cartItems,
    required this.onUpdateQuantity,
    required this.onRemoveItem,
    required this.onApplyDiscount,
  });

  @override
  Widget build(BuildContext context) {
    if (cartItems.isEmpty) {
      return _buildEmptyCart();
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: cartItems.length,
      itemBuilder: (context, index) {
        return _buildCartItem(context, cartItems[index], index);
      },
    );
  }

  /// Panier vide
  Widget _buildEmptyCart() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.shopping_cart_outlined,
            size: 80,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'Panier vide',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[500],
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Scannez ou recherchez un produit',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[400],
            ),
          ),
        ],
      ),
    );
  }

  /// Article dans le panier
  Widget _buildCartItem(BuildContext context, CartItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Ligne principale
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image produit
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: item.article.imageUrl != null
                      ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.network(
                      item.article.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildProductPlaceholder(),
                    ),
                  )
                      : _buildProductPlaceholder(),
                ),

                const SizedBox(width: 12),

                // Infos produit
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Nom
                      Text(
                        item.article.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Code
                      Text(
                        item.article.code,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Prix unitaire
                      Row(
                        children: [
                          Text(
                            '${item.unitPrice.toStringAsFixed(0)} FCFA',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                          ),
                          if (item.discountPercentage > 0) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '-${item.discountPercentage.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 8),

                // Bouton supprimer
                IconButton(
                  onPressed: () => onRemoveItem(item.article.id),
                  icon: const Icon(Icons.close, size: 20),
                  color: AppColors.error,
                  tooltip: 'Retirer',
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.error.withValues(alpha: 0.1),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Divider
          Divider(height: 1, color: Colors.grey[200]),

          // Quantité et total
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Contrôle quantité
                Row(
                  children: [
                    // Bouton -
                    _buildQuantityButton(
                      icon: Icons.remove,
                      onPressed: () {
                        final newQty = item.quantity - 1;
                        if (newQty > 0) {
                          onUpdateQuantity(item.article.id, newQty);
                        }
                      },
                    ),

                    // Quantité éditable
                    Container(
                      width: 60,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      child: TextField(
                        controller: TextEditingController(
                          text: item.quantity.toStringAsFixed(
                            item.quantity % 1 == 0 ? 0 : 2,
                          ),
                        ),
                        textAlign: TextAlign.center,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                            RegExp(r'^\d+\.?\d{0,2}'),
                          ),
                        ],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(color: Colors.grey[300]!),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: const BorderSide(color: AppColors.primary),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 8,
                          ),
                        ),
                        onSubmitted: (value) {
                          final newQty = double.tryParse(value) ?? item.quantity;
                          if (newQty > 0) {
                            onUpdateQuantity(item.article.id, newQty);
                          }
                        },
                      ),
                    ),

                    // Bouton +
                    _buildQuantityButton(
                      icon: Icons.add,
                      onPressed: () {
                        onUpdateQuantity(item.article.id, item.quantity + 1);
                      },
                    ),
                  ],
                ),

                const Spacer(),

                // Total ligne
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (item.discountAmount > 0) ...[
                      Text(
                        '${item.subtotal.toStringAsFixed(0)} FCFA',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[500],
                          decoration: TextDecoration.lineThrough,
                        ),
                      ),
                      const SizedBox(height: 2),
                    ],
                    Text(
                      '${item.total.toStringAsFixed(0)} FCFA',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Actions supplémentaires (remise)
          if (item.discountPercentage == 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                border: Border(
                  top: BorderSide(color: Colors.grey[200]!),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton.icon(
                    onPressed: () => _showDiscountDialog(context, item),
                    icon: const Icon(Icons.discount, size: 16),
                    label: const Text('Appliquer remise'),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.success,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// Bouton quantité
  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(6),
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.primary.withValues(alpha: 0.3)),
        ),
        child: Icon(
          icon,
          size: 18,
          color: AppColors.primary,
        ),
      ),
    );
  }

  /// Placeholder image produit
  Widget _buildProductPlaceholder() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 28,
        color: Colors.grey[400],
      ),
    );
  }

  /// Dialogue remise
  Future<void> _showDiscountDialog(BuildContext context, CartItem item) async {
    final controller = TextEditingController();

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remise'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Article: ${item.article.name}'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: const InputDecoration(
                labelText: 'Pourcentage de remise',
                suffixText: '%',
                border: OutlineInputBorder(),
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ANNULER'),
          ),
          FilledButton(
            onPressed: () {
              final discount = double.tryParse(controller.text) ?? 0;
              if (discount >= 0 && discount <= 100) {
                Navigator.of(context).pop(discount);
              }
            },
            child: const Text('APPLIQUER'),
          ),
        ],
      ),
    );

    if (result != null) {
      onApplyDiscount(item.article.id, result);
    }
  }
}