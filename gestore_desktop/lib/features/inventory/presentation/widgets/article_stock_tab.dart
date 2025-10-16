// ========================================
// lib/features/inventory/presentation/widgets/article_stock_tab.dart
//
// MODIFICATIONS APPORTÉES (CORRECTION) :
// - Réintégration des widgets communs (_SectionTitle, _InfoCard, _InfoRow) pour rendre le fichier autonome et compilable.
// - Maintien du style GESTORE pour tous les éléments visuels.
// - La logique et la structure originales sont respectées.
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
        const _SectionTitle(title: 'Résumé du stock'),
        Row(
          children: [
            Expanded(
              child: _StockCard(
                label: 'Stock actuel',
                value:
                '${article.currentStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.inventory_2_outlined,
                color: article.isLowStock ? AppColors.warning : AppColors.success,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StockCard(
                label: 'Disponible',
                value:
                '${article.availableStock.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.check_circle_outline,
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
                '${article.reservedStock} ${article.unitOfMeasure?.symbol ?? ""}',
                icon: Icons.bookmark_border,
                color: AppColors.info,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StockCard(
                label: 'Niveau',
                value: '${article.stockPercentage.toStringAsFixed(0)}%',
                icon: Icons.pie_chart_outline,
                color: _getStockLevelColor(article.stockPercentage),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Limites de stock
        const _SectionTitle(title: 'Limites de stock'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow(
                'Stock minimum',
                '${article.minStockLevel.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
              ),
              _InfoRow(
                'Stock maximum',
                '${article.maxStockLevel.toStringAsFixed(0)} ${article.unitOfMeasure?.symbol ?? ""}',
              ),
              if (article.isLowStock)
                Padding(
                  padding: const EdgeInsets.only(top: 12),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.warning.withValues(alpha: 0.5)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.warning_amber_rounded,
                            color: AppColors.warning),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Stock bas ! Réapprovisionnement nécessaire.',
                            style: TextStyle(
                              fontWeight: FontWeight.w500,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Gestion du stock
        const _SectionTitle(title: 'Paramètres'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow(
                  'Gestion du stock', article.manageStock ? 'Activée' : 'Désactivée'),
              _InfoRow('Stock négatif',
                  article.allowNegativeStock ? 'Autorisé' : 'Interdit'),
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

class _InfoCard extends StatelessWidget {
  final Widget child;
  const _InfoCard({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: child,
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
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}