// ========================================
// lib/features/inventory/presentation/pages/stock_valuation_page.dart
// Page de valorisation du stock
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/stocks_provider.dart';
import '../providers/stocks_state.dart';

class StockValuationScreen extends ConsumerStatefulWidget {
  const StockValuationScreen({super.key});

  @override
  ConsumerState<StockValuationScreen> createState() =>
      _StockValuationScreenState();
}

class _StockValuationScreenState extends ConsumerState<StockValuationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stocksProvider.notifier).loadStockValuation();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stocksProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Valorisation du stock'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Actualiser',
            onPressed: () {
              ref.read(stocksProvider.notifier).loadStockValuation();
            },
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
              onPressed: () {
                ref.read(stocksProvider.notifier).loadStockValuation();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockValuationLoaded) {
      return _buildValuationContent(state, theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildValuationContent(StockValuationLoaded state, ThemeData theme) {
    final currencyFormat = NumberFormat.currency(symbol: 'FCFA', decimalDigits: 0);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Carte de résumé global
          Card(
            elevation: 4,
            color: theme.colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(
                    Icons.account_balance_wallet,
                    size: 64,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Valeur totale du stock',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    currencyFormat.format(state.totalValue),
                    style: theme.textTheme.displaySmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Chip(
                    avatar: const Icon(Icons.inventory_2, size: 18),
                    label: Text('${state.totalArticles} articles en stock'),
                    backgroundColor: theme.colorScheme.surface,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // Titre section par catégorie
          Text(
            'Valorisation par catégorie',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 16),

          // Liste des catégories
          if (state.byCategory.isEmpty)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Center(
                  child: Column(
                    children: [
                      Icon(
                        Icons.category,
                        size: 48,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Aucune catégorie',
                        style: theme.textTheme.titleMedium,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            ...state.byCategory.entries.map((entry) {
              final categoryName = entry.key;
              final categoryData = entry.value as Map<String, dynamic>;
              final articlesCount = categoryData['articles_count'] as int? ?? 0;
              final totalQuantity = (categoryData['total_quantity'] as num?)?.toDouble() ?? 0.0;
              final totalValue = (categoryData['total_value'] as num?)?.toDouble() ?? 0.0;

              // Calculer le pourcentage de la valeur totale
              final percentage = state.totalValue > 0
                  ? (totalValue / state.totalValue * 100)
                  : 0.0;

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // En-tête de la catégorie
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              categoryName,
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.secondaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: theme.colorScheme.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      // Barre de progression
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percentage / 100,
                          minHeight: 8,
                          backgroundColor: theme.colorScheme.surfaceContainerHighest,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            theme.colorScheme.primary,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Statistiques
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildStatColumn(
                            context,
                            icon: Icons.inventory_2,
                            label: 'Articles',
                            value: '$articlesCount',
                          ),
                          _buildStatColumn(
                            context,
                            icon: Icons.widgets,
                            label: 'Quantité',
                            value: totalQuantity.toStringAsFixed(0),
                          ),
                          _buildStatColumn(
                            context,
                            icon: Icons.attach_money,
                            label: 'Valeur',
                            value: currencyFormat.format(totalValue),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildStatColumn(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Icon(icon, size: 20, color: theme.colorScheme.primary),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
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
}