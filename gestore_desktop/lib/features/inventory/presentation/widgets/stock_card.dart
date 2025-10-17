// ========================================
// lib/features/inventory/presentation/widgets/stock_card.dart
// Widget carte pour afficher un stock
// ========================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_entity.dart';

class StockCard extends StatelessWidget {
  final StockEntity stock;
  final VoidCallback? onTap;
  final VoidCallback? onAdjust;
  final VoidCallback? onTransfer;
  final bool showActions;

  const StockCard({
    super.key,
    required this.stock,
    this.onTap,
    this.onAdjust,
    this.onTransfer,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec article et emplacement
              Row(
                children: [
                  // Icône de stock
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: _getStockStatusColor(colorScheme).withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      _getStockStatusIcon(),
                      color: _getStockStatusColor(colorScheme),
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Informations article et emplacement
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (stock.article != null)
                          Text(
                            stock.article!.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        const SizedBox(height: 4),
                        if (stock.location != null)
                          Row(
                            children: [
                              Icon(
                                Icons.location_on,
                                size: 14,
                                color: colorScheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                stock.location!.name,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),

                  // Badge statut
                  _buildStatusBadge(context),
                ],
              ),

              const SizedBox(height: 16),

              // Quantités
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildQuantityInfo(
                    context,
                    icon: Icons.inventory,
                    label: 'En stock',
                    value: stock.quantityOnHand.toStringAsFixed(2),
                    color: Colors.blue,
                  ),
                  _buildQuantityInfo(
                    context,
                    icon: Icons.check_circle,
                    label: 'Disponible',
                    value: stock.quantityAvailable.toStringAsFixed(2),
                    color: Colors.green,
                  ),
                  _buildQuantityInfo(
                    context,
                    icon: Icons.lock,
                    label: 'Réservé',
                    value: stock.quantityReserved.toStringAsFixed(2),
                    color: Colors.orange,
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 12),

              // Informations complémentaires
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Coût unitaire
                        _buildInfoRow(
                          context,
                          icon: Icons.attach_money,
                          label: 'Coût unitaire',
                          value: currencyFormat.format(stock.unitCost),
                        ),
                        const SizedBox(height: 4),

                        // Valeur du stock
                        _buildInfoRow(
                          context,
                          icon: Icons.account_balance_wallet,
                          label: 'Valeur totale',
                          value: currencyFormat.format(stock.stockValue),
                        ),
                        const SizedBox(height: 4),

                        // Numéro de lot
                        if (stock.hasLotNumber)
                          _buildInfoRow(
                            context,
                            icon: Icons.qr_code,
                            label: 'Lot',
                            value: stock.lotNumber!,
                          ),
                      ],
                    ),
                  ),

                  // Péremption
                  if (stock.hasExpiryDate)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getExpiryColor(colorScheme).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: _getExpiryColor(colorScheme),
                        ),
                      ),
                      child: Column(
                        children: [
                          Icon(
                            _getExpiryIcon(),
                            color: _getExpiryColor(colorScheme),
                            size: 24,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            stock.expiryStatus,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: _getExpiryColor(colorScheme),
                            ),
                          ),
                          if (stock.daysUntilExpiry != null)
                            Text(
                              '${stock.daysUntilExpiry} j',
                              style: TextStyle(
                                fontSize: 12,
                                color: _getExpiryColor(colorScheme),
                              ),
                            ),
                        ],
                      ),
                    ),
                ],
              ),

              // Actions
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onAdjust != null)
                      TextButton.icon(
                        onPressed: onAdjust,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Ajuster'),
                      ),
                    if (onTransfer != null)
                      TextButton.icon(
                        onPressed: onTransfer,
                        icon: const Icon(Icons.swap_horiz, size: 18),
                        label: const Text('Transférer'),
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

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final color = _getStockStatusColor(colorScheme);
    final label = stock.isOutOfStock
        ? 'Épuisé'
        : stock.quantityAvailable < stock.quantityOnHand * 0.2
        ? 'Stock bas'
        : 'Disponible';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }

  Widget _buildQuantityInfo(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 14, color: theme.colorScheme.onSurfaceVariant),
        const SizedBox(width: 4),
        Text(
          '$label: ',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  IconData _getStockStatusIcon() {
    if (stock.isOutOfStock) return Icons.error;
    if (stock.quantityAvailable < stock.quantityOnHand * 0.2) {
      return Icons.warning;
    }
    return Icons.inventory_2;
  }

  Color _getStockStatusColor(ColorScheme colorScheme) {
    if (stock.isOutOfStock) return colorScheme.error;
    if (stock.quantityAvailable < stock.quantityOnHand * 0.2) {
      return Colors.orange;
    }
    return colorScheme.primary;
  }

  IconData _getExpiryIcon() {
    if (stock.isExpired) return Icons.dangerous;
    if (stock.isExpiringSoon) return Icons.warning_amber;
    return Icons.event_available;
  }

  Color _getExpiryColor(ColorScheme colorScheme) {
    if (stock.isExpired) return colorScheme.error;
    if (stock.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }
}