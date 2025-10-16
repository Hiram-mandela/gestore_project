// ========================================
// lib/features/inventory/presentation/widgets/article_price_tab.dart
//
// MODIFICATIONS APPORTÉES (CORRECTION) :
// - Réintégration du widget commun _SectionTitle pour rendre le fichier autonome.
// - Les autres widgets (_PriceCard, _PriceChangeRow) étaient déjà définis localement.
// - Maintien du style GESTORE pour tous les éléments.
// ========================================

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_detail_entity.dart';

class ArticlePriceTab extends StatelessWidget {
  final ArticleDetailEntity article;
  const ArticlePriceTab({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    final currencyFormat =
    NumberFormat.currency(locale: 'fr_FR', symbol: 'FCFA', decimalDigits: 0);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Prix actuels
        const _SectionTitle(title: 'Prix actuels'),
        Row(
          children: [
            Expanded(
              child: _PriceCard(
                label: 'Prix d\'achat',
                value: article.formattedPurchasePrice,
                icon: Icons.shopping_cart_outlined,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _PriceCard(
                label: 'Prix de vente',
                value: article.formattedSellingPrice,
                icon: Icons.sell_outlined,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Marge et profit
        const _SectionTitle(title: 'Rentabilité'),
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
        const SizedBox(height: 24),

        // Historique des prix
        if (article.hasPriceHistory) ...[
          _SectionTitle(
              title: 'Historique des prix (${article.priceHistory.length})'),
          ...article.priceHistory.map((history) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date et raison
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _formatDate(history.effectiveDate),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary),
                    ),
                    Chip(
                      label: Text(_getPriceChangeReason(history.reason)),
                      labelStyle: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.textSecondary),
                      backgroundColor: AppColors.backgroundLight,
                      side: const BorderSide(color: AppColors.border),
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                  ],
                ),
                const Divider(height: 24),

                // Changements de prix
                _PriceChangeRow(
                  label: 'Prix d\'achat',
                  oldValue: currencyFormat.format(history.oldPurchasePrice),
                  newValue: currencyFormat.format(history.newPurchasePrice),
                  percentChange: history.purchaseChangePercent,
                  color: history.purchaseChangePercent >= 0
                      ? AppColors.error
                      : AppColors.success,
                ),
                const SizedBox(height: 12),
                _PriceChangeRow(
                  label: 'Prix de vente',
                  oldValue: currencyFormat.format(history.oldSellingPrice),
                  newValue: currencyFormat.format(history.newSellingPrice),
                  percentChange: history.sellingChangePercent,
                  color: history.sellingChangePercent >= 0
                      ? AppColors.success
                      : AppColors.error,
                ),

                if (history.notes != null && history.notes!.isNotEmpty) ...[
                  const Divider(height: 24),
                  Text(
                    history.notes!,
                    style: const TextStyle(
                      fontSize: 13,
                      fontStyle: FontStyle.italic,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
                const Divider(height: 24),
                Text(
                  'Par ${history.createdBy}',
                  style: const TextStyle(
                      fontSize: 12, color: AppColors.textTertiary),
                ),
              ],
            ),
          )),
        ] else ...[
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32.0),
              child: Text('Aucun historique de prix disponible.',
                  style: TextStyle(color: AppColors.textSecondary)),
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
    return DateFormat('dd/MM/yyyy', 'fr_FR').format(date);
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 13,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _PriceChangeRow extends StatelessWidget {
  final String label;
  final String oldValue;
  final String newValue;
  final double percentChange;
  final Color color;

  const _PriceChangeRow({
    required this.label,
    required this.oldValue,
    required this.newValue,
    required this.percentChange,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: AppColors.textSecondary)),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              oldValue,
              style: const TextStyle(
                decoration: TextDecoration.lineThrough,
                color: AppColors.textTertiary,
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 6),
              child: Icon(Icons.arrow_forward,
                  size: 16, color: AppColors.textTertiary),
            ),
            Text(
              newValue,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: AppColors.textPrimary),
            ),
            const SizedBox(width: 8),
            Text(
              '(${percentChange >= 0 ? '+' : ''}${percentChange.toStringAsFixed(1)}%)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: color,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

// ========================================
// WIDGETS COMMUNS (STYLE GESTORE) - RÉINTÉGRÉS
// ========================================

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.bold,
          color: AppColors.textSecondary,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}