// ========================================
// lib/features/inventory/presentation/pages/stock_detail_page.dart
// Page de détail d'un stock
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_entity.dart';
import '../providers/stocks_provider.dart';
import '../providers/stocks_state.dart';

class StockDetailScreen extends ConsumerStatefulWidget {
  final String stockId;

  const StockDetailScreen({super.key, required this.stockId});

  @override
  ConsumerState<StockDetailScreen> createState() => _StockDetailScreenState();
}

class _StockDetailScreenState extends ConsumerState<StockDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stocksProvider.notifier).loadStockById(widget.stockId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stocksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du stock'),
        actions: [
          if (state is StockDetailLoaded)
            PopupMenuButton<String>(
              onSelected: (value) {
                switch (value) {
                  case 'adjust':
                    _navigateToAdjust(state.stock);
                    break;
                  case 'transfer':
                    _navigateToTransfer(state.stock);
                    break;
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'adjust',
                  child: Row(
                    children: [
                      Icon(Icons.edit, size: 20),
                      SizedBox(width: 12),
                      Text('Ajuster'),
                    ],
                  ),
                ),
                const PopupMenuItem(
                  value: 'transfer',
                  child: Row(
                    children: [
                      Icon(Icons.swap_horiz, size: 20),
                      SizedBox(width: 12),
                      Text('Transférer'),
                    ],
                  ),
                ),
              ],
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(StocksState state, ThemeData theme) {
    if (state is StocksLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StocksError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref
                  .read(stocksProvider.notifier)
                  .loadStockById(widget.stockId),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockDetailLoaded) {
      return _buildStockDetail(state.stock, theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildStockDetail(StockEntity stock, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0);
    final dateFormat = DateFormat('dd/MM/yyyy');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec article
          _buildArticleHeader(stock, theme),

          const SizedBox(height: 24),

          // Badge de statut global
          _buildGlobalStatusBadge(stock, theme),

          const SizedBox(height: 24),

          // Quantités
          _buildSection(
            theme,
            title: 'Quantités',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildQuantityCard(
                      theme,
                      icon: Icons.inventory,
                      label: 'En stock',
                      value: stock.quantityOnHand.toStringAsFixed(2),
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuantityCard(
                      theme,
                      icon: Icons.check_circle,
                      label: 'Disponible',
                      value: stock.quantityAvailable.toStringAsFixed(2),
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: _buildQuantityCard(
                      theme,
                      icon: Icons.lock,
                      label: 'Réservé',
                      value: stock.quantityReserved.toStringAsFixed(2),
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildQuantityCard(
                      theme,
                      icon: Icons.percent,
                      label: '% Disponible',
                      value: '${stock.availablePercentage.toStringAsFixed(1)}%',
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Informations financières
          _buildSection(
            theme,
            title: 'Valorisation',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.attach_money,
                label: 'Coût unitaire',
                value: currencyFormat.format(stock.unitCost),
              ),
              _buildInfoTile(
                theme,
                icon: Icons.account_balance_wallet,
                label: 'Valeur totale du stock',
                value: currencyFormat.format(stock.stockValue),
                valueColor: Colors.green,
                highlight: true,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Emplacement
          _buildSection(
            theme,
            title: 'Emplacement',
            children: [
              if (stock.location != null) ...[
                _buildInfoTile(
                  theme,
                  icon: Icons.location_on,
                  label: 'Emplacement',
                  value: stock.location!.name,
                ),
                if (stock.location!.fullPath.isNotEmpty)
                  _buildInfoTile(
                    theme,
                    icon: Icons.folder_open,
                    label: 'Chemin complet',
                    value: stock.location!.fullPath,
                  ),
              ] else
                _buildInfoTile(
                  theme,
                  icon: Icons.location_off,
                  label: 'Emplacement',
                  value: 'Non défini',
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Traçabilité
          if (stock.hasLotNumber || stock.hasExpiryDate)
            _buildSection(
              theme,
              title: 'Traçabilité',
              children: [
                if (stock.hasLotNumber)
                  _buildInfoTile(
                    theme,
                    icon: Icons.qr_code,
                    label: 'Numéro de lot',
                    value: stock.lotNumber!,
                  ),
                if (stock.hasExpiryDate) ...[
                  _buildInfoTile(
                    theme,
                    icon: Icons.event,
                    label: 'Date de péremption',
                    value: dateFormat.format(stock.expiryDate!),
                    valueColor: _getExpiryColor(stock, theme.colorScheme),
                  ),
                  _buildInfoTile(
                    theme,
                    icon: Icons.calendar_today,
                    label: 'Statut',
                    value: stock.expiryStatus,
                    valueColor: _getExpiryColor(stock, theme.colorScheme),
                  ),
                  if (stock.daysUntilExpiry != null)
                    _buildInfoTile(
                      theme,
                      icon: Icons.hourglass_bottom,
                      label: 'Jours restants',
                      value: '${stock.daysUntilExpiry} jours',
                      valueColor: _getExpiryColor(stock, theme.colorScheme),
                    ),
                ],
              ],
            ),

          const SizedBox(height: 24),

          // Métadonnées
          _buildSection(
            theme,
            title: 'Métadonnées',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.calendar_today,
                label: 'Créé le',
                value: _formatDateTime(stock.createdAt),
              ),
              _buildInfoTile(
                theme,
                icon: Icons.update,
                label: 'Modifié le',
                value: _formatDateTime(stock.updatedAt),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Actions rapides
          _buildQuickActions(stock, theme),
        ],
      ),
    );
  }

  Widget _buildArticleHeader(StockEntity stock, ThemeData theme) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                Icons.inventory_2,
                size: 40,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (stock.article != null) ...[
                    Text(
                      stock.article!.name,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Code: ${stock.article!.code}',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ] else
                    Text(
                      'Article non chargé',
                      style: theme.textTheme.titleLarge,
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGlobalStatusBadge(StockEntity stock, ThemeData theme) {
    String statusText;
    Color statusColor;
    IconData statusIcon;

    if (stock.isOutOfStock) {
      statusText = 'Stock épuisé';
      statusColor = theme.colorScheme.error;
      statusIcon = Icons.error;
    } else if (stock.quantityAvailable < stock.quantityOnHand * 0.2) {
      statusText = 'Stock bas';
      statusColor = Colors.orange;
      statusIcon = Icons.warning;
    } else {
      statusText = 'Stock disponible';
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor, width: 2),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 12),
          Text(
            statusText,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: statusColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
      ThemeData theme, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityCard(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
      }) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoTile(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
        bool highlight = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: highlight ? FontWeight.w600 : null,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: highlight ? FontWeight.bold : FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(StockEntity stock, ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: () => _navigateToAdjust(stock),
            icon: const Icon(Icons.edit),
            label: const Text('Ajuster'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _navigateToTransfer(stock),
            icon: const Icon(Icons.swap_horiz),
            label: const Text('Transférer'),
          ),
        ),
      ],
    );
  }

  Color _getExpiryColor(StockEntity stock, ColorScheme colorScheme) {
    if (stock.isExpired) return colorScheme.error;
    if (stock.isExpiringSoon) return Colors.orange;
    return Colors.green;
  }

  String _formatDateTime(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _navigateToAdjust(StockEntity stock) {
    context.push(
      '/inventory/stocks/adjustment',
      extra: {'stock': stock},
    );
  }

  void _navigateToTransfer(StockEntity stock) {
    context.push(
      '/inventory/stocks/transfer',
      extra: {'stock': stock},
    );
  }
}