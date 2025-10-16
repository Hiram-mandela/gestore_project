// ========================================
// lib/features/inventory/presentation/widgets/stock_badge.dart
// Widget badge pour afficher le statut du stock
// ========================================

import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';

/// Badge pour afficher le niveau de stock
class StockBadge extends StatelessWidget {
  final double stock;
  final bool isLowStock;
  final String? unit;
  final bool isCompact; // NOUVEAU: paramètre pour une vue compacte

  const StockBadge({
    super.key,
    required this.stock,
    required this.isLowStock,
    this.unit,
    this.isCompact = false, // Par défaut, la vue n'est pas compacte
  });

  @override
  Widget build(BuildContext context) {
    final color = isLowStock ? AppColors.warning : AppColors.textSecondary;
    final stockText = stock.toStringAsFixed(0);
    final unitText = unit != null && unit!.isNotEmpty ? ' $unit' : '';

    return Container(
      padding: isCompact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isLowStock ? Icons.warning_amber_rounded : Icons.inventory_2_outlined,
            size: isCompact ? 14 : 16,
            color: color,
          ),
          const SizedBox(width: 6),
          // NOUVEAU: Logique conditionnelle pour le texte
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: isCompact ? 12 : 13,
                color: AppColors.textPrimary,
              ),
              children: [
                if (!isCompact)
                  const TextSpan(
                    text: 'Stock: ',
                    style: TextStyle(color: AppColors.textSecondary),
                  ),
                TextSpan(
                  text: stockText,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                if (unitText.isNotEmpty)
                  TextSpan(
                    text: unitText,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
/// Classe pour représenter le statut du stock
class StockStatus {
  final String label;
  final Color color;
  final IconData icon;

  StockStatus({
    required this.label,
    required this.color,
    required this.icon,
  });
}