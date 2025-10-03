// ========================================
// lib/features/inventory/presentation/widgets/stock_badge.dart
// Widget badge pour afficher le statut du stock
// ========================================

import 'package:flutter/material.dart';

/// Badge pour afficher le niveau de stock
class StockBadge extends StatelessWidget {
  final double stock;
  final bool isLowStock;
  final String unit;

  const StockBadge({
    super.key,
    required this.stock,
    required this.isLowStock,
    required this.unit,
  });

  @override
  Widget build(BuildContext context) {
    final stockStatus = _getStockStatus();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: stockStatus.color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: stockStatus.color.withValues(alpha: 0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            stockStatus.icon,
            size: 16,
            color: stockStatus.color,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                stockStatus.label,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: stockStatus.color,
                ),
              ),
              Text(
                '${stock.toStringAsFixed(0)} $unit',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: stockStatus.color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Détermine le statut du stock
  StockStatus _getStockStatus() {
    if (stock <= 0) {
      return StockStatus(
        label: 'Rupture',
        color: Colors.red,
        icon: Icons.cancel,
      );
    } else if (isLowStock) {
      return StockStatus(
        label: 'Stock bas',
        color: Colors.orange,
        icon: Icons.warning_amber,
      );
    } else {
      return StockStatus(
        label: 'En stock',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    }
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