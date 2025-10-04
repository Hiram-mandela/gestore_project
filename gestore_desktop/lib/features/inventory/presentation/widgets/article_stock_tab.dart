// ========================================
// FICHIER 2: lib/features/inventory/presentation/widgets/article_stock_tab.dart
// Onglet Stock
// ========================================

import 'package:flutter/material.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_detail_entity.dart';

class ArticleStockTab extends StatelessWidget {
  final ArticleDetailEntity article;

  const ArticleStockTab({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Résumé du stock
        _SectionTitle(title: 'Résumé du stock'),
        Row(
          children: [
            Expanded(
              child: _StockCard(
                label: 'Stock actuel',
                value:
                '${article.currentStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.inventory,
                color: article.isLowStock ? AppColors.error : AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StockCard(
                label: 'Disponible',
                value:
                '${article.availableStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.check_circle,
                color: AppColors.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _StockCard(
                label: 'Réservé',
                value:
                '${article.reservedStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.bookmark,
                color: AppColors.warning,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StockCard(
                label: 'Niveau',
                value: '${article.stockPercentage.toStringAsFixed(0)}%',
                icon: Icons.trending_up,
                color: _getStockLevelColor(article.stockPercentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Limites de stock
        _SectionTitle(title: 'Limites de stock'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow(
                'Stock minimum',
                '${article.minStockLevel} ${article.unitOfMeasure?.symbol ?? ""}',
              ),
              _InfoRow(
                'Stock maximum',
                '${article.maxStockLevel} ${article.unitOfMeasure?.symbol ?? ""}',
              ),
              if (article.isLowStock)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.error),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.warning_amber, color: AppColors.error),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Stock bas ! Réapprovisionnement nécessaire.',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Gestion du stock
        _SectionTitle(title: 'Paramètres'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow(
                  'Gestion du stock', article.manageStock ? 'Activée' : 'Désactivée'),
              _InfoRow(
                  'Stock négatif', article.allowNegativeStock ? 'Autorisé' : 'Interdit'),
              _InfoRow('Traçabilité lot',
                  article.requiresLotTracking ? 'Requise' : 'Non requise'),
              _InfoRow('Date péremption',
                  article.requiresExpiryDate ? 'Requise' : 'Non requise'),
            ],
          ),
        ),
      ],
    );
  }

  Color _getStockLevelColor(double percentage) {
    if (percentage >= 70) return AppColors.success;
    if (percentage >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

class _StockCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StockCard({
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

class _InfoCard extends StatelessWidget {
  final Widget child;

  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 1,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: child,
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow(this.label, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w500),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}