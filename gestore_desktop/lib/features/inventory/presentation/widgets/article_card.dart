// ========================================
// lib/features/inventory/presentation/widgets/article_card.dart
//
// MODIFICATIONS APPORTÉES (Refonte GESTORE - Vue Liste) :
// - Renommage de ArticleCard en ArticleListCard pour plus de clarté.
// - Remplacement de Card par un Container stylisé avec les couleurs et bordures GESTORE.
// - Application de la palette AppColors pour les textes, badges et icônes.
// - Uniformisation des "chips" (catégorie, marque) et badges (marge) pour un design épuré.
// - Amélioration de la lisibilité et de la hiérarchie de l'information.
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_entity.dart';
import 'stock_badge.dart';

/// Carte pour afficher un article dans une liste (vue détaillée)
class ArticleListCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const ArticleListCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image de l'article
              _buildArticleImage(),
              const SizedBox(width: 12),
              // Informations de l'article
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      article.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.code,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Catégorie et marque
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        _buildCategoryChip(),
                        if (article.hasBrand) _buildBrandChip(),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Prix et stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Prix
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Prix de vente',
                              style: TextStyle(
                                fontSize: 11,
                                color: AppColors.textTertiary,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              article.formattedSellingPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.success,
                              ),
                            ),
                          ],
                        ),
                        // Stock
                        StockBadge(
                          stock: article.currentStock,
                          isLowStock: article.isLowStock,
                          unit: article.unitSymbol,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Indicateurs à droite (Marge, Inactif)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    _buildMarginBadge(),
                    if (!article.isActive) ...[
                      const SizedBox(height: 8),
                      _buildInactiveBadge(),
                    ]
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        height: 80,
        color: AppColors.backgroundLight,
        child: article.hasImage
            ? Image.network(
          article.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(strokeWidth: 2));
          },
        )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(Icons.inventory_2_outlined, size: 40, color: AppColors.border),
    );
  }

  Widget _buildCategoryChip() {
    final color = _parseColor(article.categoryColor);
    return _InfoChip(
      label: article.categoryName,
      backgroundColor: color.withValues(alpha: 0.1),
      borderColor: color.withValues(alpha: 0.3),
      textColor: color.withValues(alpha: 0.9),
      leading: Container(
        width: 8,
        height: 8,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  Widget _buildBrandChip() {
    return _InfoChip(
      label: article.brandName!,
      backgroundColor: AppColors.info.withValues(alpha: 0.1),
      borderColor: AppColors.info.withValues(alpha: 0.3),
      textColor: AppColors.info.withValues(alpha: 0.9),
    );
  }

  Widget _buildMarginBadge() {
    final marginColor = article.marginPercent >= 20
        ? AppColors.success
        : article.marginPercent >= 10
        ? AppColors.warning
        : AppColors.error;
    return _InfoChip(
      label: article.formattedMargin,
      backgroundColor: marginColor.withValues(alpha: 0.1),
      borderColor: marginColor.withValues(alpha: 0.3),
      textColor: marginColor,
      isBold: true,
    );
  }

  Widget _buildInactiveBadge() {
    return _InfoChip(
      label: 'Inactif',
      backgroundColor: AppColors.backgroundLight,
      borderColor: AppColors.border,
      textColor: AppColors.textSecondary,
    );
  }

  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.textTertiary;
    }
  }
}

/// Widget générique pour les "chips" d'information
class _InfoChip extends StatelessWidget {
  final String label;
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Widget? leading;
  final bool isBold;

  const _InfoChip({
    required this.label,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    this.leading,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 6)],
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}