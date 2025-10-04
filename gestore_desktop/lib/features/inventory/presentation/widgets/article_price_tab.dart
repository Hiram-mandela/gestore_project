// ========================================
// FICHIER 3: lib/features/inventory/presentation/widgets/article_price_tab.dart
// Onglet Prix
// ========================================

import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_detail_entity.dart';

class ArticlePriceTab extends StatelessWidget {
  final ArticleDetailEntity article;

  const ArticlePriceTab({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Prix actuels
        _SectionTitle(title: 'Prix actuels'),
        Row(
          children: [
            Expanded(
              child: _PriceCard(
                label: 'Prix d\'achat',
                value: article.formattedPurchasePrice,
                icon: Icons.shopping_cart,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PriceCard(
                label: 'Prix de vente',
                value: article.formattedSellingPrice,
                icon: Icons.sell,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Marge et profit
        _SectionTitle(title: 'Rentabilité'),
        Row(
          children: [
            Expanded(
              child: _PriceCard(
                label: 'Marge',
                value: article.formattedMargin,
                icon: Icons.trending_up,
                color: _getMarginColor(article.marginPercent),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PriceCard(
                label: 'Profit unitaire',
                value: article.formattedUnitProfit,
                icon: Icons.attach_money,
                color: article.unitProfit >= 0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Historique des prix
        if (article.hasPriceHistory) ...[
          _SectionTitle(
              title: 'Historique des prix (${article.priceHistory.length})'),
          ...article.priceHistory.map((history) => Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Date et raison
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        _formatDate(history.effectiveDate),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Chip(
                        label: Text(
                          _getPriceChangeReason(history.reason),
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Changement prix achat
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prix d\'achat',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${history.oldPurchasePrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward, size: 16),
                                Text(
                                  '${history.newPurchasePrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${history.purchaseChangePercent.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color:
                                    history.purchaseChangePercent >= 0
                                        ? AppColors.error
                                        : AppColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Changement prix vente
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prix de vente',
                              style: TextStyle(fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  '${history.oldSellingPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                    decoration: TextDecoration.lineThrough,
                                  ),
                                ),
                                const Icon(Icons.arrow_forward, size: 16),
                                Text(
                                  '${history.newSellingPrice.toStringAsFixed(0)} FCFA',
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold),
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '(${history.sellingChangePercent.toStringAsFixed(1)}%)',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: history.sellingChangePercent >= 0
                                        ? AppColors.success
                                        : AppColors.error,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  // Notes
                  if (history.notes != null && history.notes!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      history.notes!,
                      style: const TextStyle(
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Créé par
                  Text(
                    'Par ${history.createdBy}',
                    style: const TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          )),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucun historique de prix'),
            ),
          ),
        ],
      ],
    );
  }

  Color _getMarginColor(double margin) {
    if (margin >= 20) return AppColors.success;
    if (margin >= 10) return AppColors.warning;
    return AppColors.error;
  }

  String _getPriceChangeReason(String reason) {
    const reasons = {
      'cost_increase': 'Augmentation coût',
      'cost_decrease': 'Diminution coût',
      'market_adjustment': 'Ajustement marché',
      'promotion': 'Promotion',
      'correction': 'Correction',
      'initial': 'Prix initial',
    };
    return reasons[reason] ?? reason;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class _PriceCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _PriceCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20, color: color),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: color,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ========================================
// WIDGETS COMMUNS
// ========================================

class _SectionTitle extends StatelessWidget {
  final String title;

  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}
