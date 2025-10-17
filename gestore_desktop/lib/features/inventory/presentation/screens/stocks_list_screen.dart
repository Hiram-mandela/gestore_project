// ========================================
// lib/features/inventory/presentation/pages/stocks_list_screen.dart
// Page de liste des stocks
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_entity.dart';
import '../providers/stocks_provider.dart';
import '../providers/stocks_state.dart';
import '../widgets/stock_card.dart';

class StocksListScreen extends ConsumerStatefulWidget {
  const StocksListScreen({super.key});

  @override
  ConsumerState<StocksListScreen> createState() => _StocksListScreenState();
}

class _StocksListScreenState extends ConsumerState<StocksListScreen> {
  String? _filterArticleId;
  String? _filterLocationId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stocksProvider.notifier).loadStocks();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stocksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des stocks'),
        actions: [
          // Filtres
          IconButton(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtres',
            onPressed: _showFiltersDialog,
          ),

          // Valorisation
          IconButton(
            icon: const Icon(Icons.assessment),
            tooltip: 'Valorisation',
            onPressed: () => context.push('/inventory/stocks/valuation'),
          ),
        ],
      ),
      body: _buildBody(state, theme),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'adjust',
            onPressed: () => context.push('/inventory/stocks/adjustment'),
            tooltip: 'Ajustement',
            child: const Icon(Icons.edit),
          ),
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: 'transfer',
            onPressed: () => context.push('/inventory/stocks/transfer'),
            tooltip: 'Transfert',
            child: const Icon(Icons.swap_horiz),
          ),
        ],
      ),
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
              onPressed: () => ref.read(stocksProvider.notifier).loadStocks(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StocksLoaded) {
      if (state.stocks.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun stock',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Les stocks apparaîtront ici',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Statistiques en en-tête
          _buildStatsHeader(state, theme),

          // Alertes (stocks périmés et péremption proche)
          if (state.expiredStocks.isNotEmpty || state.expiringSoonStocks.isNotEmpty)
            _buildAlertsSection(state, theme),

          // Liste des stocks
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(stocksProvider.notifier).loadStocks();
              },
              child: ListView.builder(
                itemCount: state.stocks.length,
                itemBuilder: (context, index) {
                  final stock = state.stocks[index];
                  return StockCard(
                    stock: stock,
                    onTap: () => _navigateToDetail(stock.id),
                    onAdjust: () => _navigateToAdjust(stock),
                    onTransfer: () => _navigateToTransfer(stock),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatsHeader(StocksLoaded state, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0);

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            icon: Icons.inventory_2,
            label: 'Articles',
            value: '${state.count}',
          ),
          _buildStatItem(
            theme,
            icon: Icons.account_balance_wallet,
            label: 'Valeur',
            value: currencyFormat.format(state.totalValue),
            color: Colors.green,
          ),
          _buildStatItem(
            theme,
            icon: Icons.check_circle,
            label: 'Disponible',
            value: state.totalAvailable.toStringAsFixed(0),
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        Color? color,
      }) {
    final displayColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: displayColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: displayColor,
          ),
          overflow: TextOverflow.ellipsis,
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

  Widget _buildAlertsSection(StocksLoaded state, ThemeData theme) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700),
              const SizedBox(width: 8),
              Text(
                'Alertes',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (state.expiredStocks.isNotEmpty)
            Text(
              '${state.expiredStocks.length} stock(s) périmé(s)',
              style: theme.textTheme.bodySmall,
            ),
          if (state.expiringSoonStocks.isNotEmpty)
            Text(
              '${state.expiringSoonStocks.length} stock(s) péremption proche',
              style: theme.textTheme.bodySmall,
            ),
        ],
      ),
    );
  }

  void _showFiltersDialog() {
    // TODO: Implémenter le dialog de filtres
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Filtres (à implémenter)')),
    );
  }

  void _navigateToDetail(String id) {
    context.push('/inventory/stocks/$id');
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