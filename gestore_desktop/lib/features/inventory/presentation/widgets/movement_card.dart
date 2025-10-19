// ========================================
// lib/features/inventory/presentation/widgets/movement_card.dart
// Carte pour afficher un mouvement de stock
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/stock_movement_entity.dart';

class MovementCard extends StatelessWidget {
  final StockMovementEntity movement;
  final VoidCallback? onTap;

  const MovementCard({
    super.key,
    required this.movement,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête: Type et date
              Row(
                children: [
                  _buildTypeIcon(),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          movement.movementType.label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: _getTypeColor(),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          movement.formattedDate,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildQuantityBadge(),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 12),

              // Article
              Row(
                children: [
                  const Icon(
                    Icons.inventory_2,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      movement.article.name,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Emplacement
              Row(
                children: [
                  const Icon(
                    Icons.location_on,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      movement.stock.location!.name,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Raison
              _buildReasonChip(),

              // Stock avant/après
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildStockInfo('Avant', movement.stockBefore),
                    Icon(Icons.arrow_forward, size: 20, color: AppColors.textSecondary),
                    _buildStockInfo('Après', movement.stockAfter),
                  ],
                ),
              ),

              // Valeur (si disponible)
              if (movement.hasValue) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.attach_money,
                      size: 16,
                      color: AppColors.success,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${movement.movementValue.toStringAsFixed(2)} FCFA',
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ],
                ),
              ],

              // Document de référence (si disponible)
              if (movement.referenceDocument != null &&
                  movement.referenceDocument!.isNotEmpty) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.description,
                      size: 16,
                      color: AppColors.info,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Réf: ${movement.referenceDocument}',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.info,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Icône du type de mouvement
  Widget _buildTypeIcon() {
    IconData icon;
    Color color = _getTypeColor();

    switch (movement.movementType) {
      case MovementType.inMovement:
        icon = Icons.arrow_downward;
        break;
      case MovementType.out:
        icon = Icons.arrow_upward;
        break;
      case MovementType.adjustment:
        icon = Icons.tune;
        break;
      case MovementType.transfer:
        icon = Icons.swap_horiz;
        break;
      case MovementType.returnMovement:
        icon = Icons.undo;
        break;
      case MovementType.loss:
        icon = Icons.remove_circle;
        break;
      case MovementType.found:
        icon = Icons.add_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Icon(icon, color: color, size: 24),
    );
  }

  /// Badge de quantité
  Widget _buildQuantityBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _getTypeColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getTypeColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        '${movement.isOutbound ? '-' : '+'}${movement.quantity.toStringAsFixed(2)}',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
          color: _getTypeColor(),
        ),
      ),
    );
  }

  /// Chip de raison
  Widget _buildReasonChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.info.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Text(
        movement.reason.label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w500,
          color: AppColors.info,
        ),
      ),
    );
  }

  /// Info de stock (avant/après)
  Widget _buildStockInfo(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }

  /// Couleur selon le type de mouvement
  Color _getTypeColor() {
    switch (movement.movementType) {
      case MovementType.inMovement:
        return AppColors.success;
      case MovementType.out:
        return AppColors.error;
      case MovementType.adjustment:
        return AppColors.warning;
      case MovementType.transfer:
        return AppColors.info;
      case MovementType.returnMovement:
        return AppColors.warning;
      case MovementType.loss:
        return AppColors.error;
      case MovementType.found:
        return AppColors.success;
    }
  }
}