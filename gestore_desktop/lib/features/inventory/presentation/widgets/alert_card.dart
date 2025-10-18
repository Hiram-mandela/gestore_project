// ========================================
// lib/features/inventory/presentation/widgets/alert_card.dart
// Widget carte pour afficher une alerte de stock
// ========================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_alert_entity.dart';

class AlertCard extends StatelessWidget {
  final StockAlertEntity alert;
  final VoidCallback? onTap;
  final VoidCallback? onAcknowledge;
  final bool showActions;
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;

  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.onAcknowledge,
    this.showActions = true,
    this.isSelected = false,
    this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelColor = _getLevelColor();
    final typeIcon = _getTypeIcon();

    return Card(
      elevation: alert.isAcknowledged ? 0 : 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: alert.isAcknowledged
              ? Colors.grey.shade300
              : levelColor.withOpacity(0.5),
          width: alert.isAcknowledged ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec checkbox, badge niveau et actions
              Row(
                children: [
                  // Checkbox de sélection (optionnel)
                  if (onSelected != null && !alert.isAcknowledged) ...[
                    Checkbox(
                      value: isSelected,
                      onChanged: onSelected,
                      activeColor: levelColor,
                    ),
                    const SizedBox(width: 8),
                  ],

                  // Badge niveau
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: levelColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: levelColor),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getLevelIcon(),
                          size: 16,
                          color: levelColor,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          alert.alertLevel.label.toUpperCase(),
                          style: TextStyle(
                            color: levelColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(width: 12),

                  // Badge type
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(typeIcon, size: 14, color: Colors.grey.shade700),
                        const SizedBox(width: 6),
                        Text(
                          alert.alertType.label,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Badge "Acquittée"
                  if (alert.isAcknowledged)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.shade100,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.green.shade700,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Acquittée',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Bouton d'action
                  if (showActions && !alert.isAcknowledged)
                    IconButton(
                      icon: const Icon(Icons.check_circle_outline),
                      color: Colors.green,
                      tooltip: 'Acquitter',
                      onPressed: onAcknowledge,
                    ),
                ],
              ),

              const SizedBox(height: 12),

              // Article concerné
              if (alert.article != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.inventory_2_outlined,
                      size: 18,
                      color: Colors.grey.shade600,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        alert.article!.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],

              // Message de l'alerte
              Text(
                alert.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.grey.shade700,
                ),
              ),

              const SizedBox(height: 12),

              // Footer avec date et infos supplémentaires
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: Colors.grey.shade500,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatDate(alert.createdAt),
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),

                  if (alert.isRecent) ...[
                    const SizedBox(width: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade100,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'NOUVEAU',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange.shade700,
                        ),
                      ),
                    ),
                  ],

                  const Spacer(),

                  // Emplacement si disponible
                  if (alert.stock?.location != null) ...[
                    Icon(
                      Icons.location_on_outlined,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      alert.stock!.location!.name,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ],
              ),

              // Info acquittement
              if (alert.isAcknowledged && alert.acknowledgedBy != null) ...[
                const SizedBox(height: 8),
                const Divider(),
                Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 14,
                      color: Colors.grey.shade500,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Acquittée par ${alert.acknowledgedBy}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    if (alert.acknowledgedAt != null) ...[
                      const SizedBox(width: 8),
                      Text(
                        'le ${_formatDate(alert.acknowledgedAt!)}',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade500,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getLevelColor() {
    switch (alert.alertLevel) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon() {
    switch (alert.alertLevel) {
      case AlertLevel.critical:
        return Icons.error;
      case AlertLevel.warning:
        return Icons.warning;
      case AlertLevel.info:
        return Icons.info;
    }
  }

  IconData _getTypeIcon() {
    switch (alert.alertType) {
      case AlertType.lowStock:
        return Icons.trending_down;
      case AlertType.outOfStock:
        return Icons.remove_shopping_cart;
      case AlertType.expirySoon:
        return Icons.schedule;
      case AlertType.expired:
        return Icons.dangerous;
      case AlertType.overstock:
        return Icons.trending_up;
    }
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 60) {
      return 'Il y a ${difference.inMinutes} min';
    } else if (difference.inHours < 24) {
      return 'Il y a ${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return 'Il y a ${difference.inDays}j';
    } else {
      return DateFormat('dd/MM/yyyy HH:mm').format(date);
    }
  }
}