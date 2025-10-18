// ========================================
// lib/features/inventory/presentation/widgets/alert_level_indicator.dart
// Widget indicateur de niveau d'alerte
// ========================================

import 'package:flutter/material.dart';
import '../../domain/entities/stock_alert_entity.dart';

class AlertLevelIndicator extends StatelessWidget {
  final AlertLevel level;
  final int count;
  final bool showLabel;
  final bool isCompact;

  const AlertLevelIndicator({
    super.key,
    required this.level,
    required this.count,
    this.showLabel = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getColor();
    final icon = _getIcon();

    if (isCompact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              count.toString(),
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color, width: 2),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 32, color: color),
          const SizedBox(height: 8),
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(height: 4),
            Text(
              level.label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getColor() {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }

  IconData _getIcon() {
    switch (level) {
      case AlertLevel.critical:
        return Icons.error;
      case AlertLevel.warning:
        return Icons.warning;
      case AlertLevel.info:
        return Icons.info;
    }
  }
}