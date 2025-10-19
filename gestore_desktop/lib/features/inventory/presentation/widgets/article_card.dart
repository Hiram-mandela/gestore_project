// ========================================
// lib/features/inventory/presentation/widgets/article_card.dart
// VERSION PHASE 2 - Support des opérations en masse
//
// NOUVEAUTÉS :
// - Support de la sélection multiple avec checkbox
// - Menu d'actions contextuelles (dupliquer, modifier, supprimer)
// - Indication visuelle de la sélection (bordure colorée)
// - Mode désactivé en mode sélection
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_entity.dart';
import 'stock_badge.dart';

/// Carte pour afficher un article dans une liste (vue détaillée)
class ArticleListCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;

  // NOUVEAUX PARAMÈTRES Phase 2
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;
  final List<PopupMenuEntry<String>>? actions;

  const ArticleListCard({
    super.key,
    required this.article,
    this.onTap,
    this.isSelected = false,
    this.onSelected,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    // Désactiver le tap si en mode sélection
    final effectiveOnTap = onSelected != null ? null : onTap;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        // Bordure colorée si sélectionné
        border: Border.all(
          color: isSelected ? AppColors.primary : AppColors.border,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: [
          if (isSelected)
            BoxShadow(
              color: AppColors.primary.withValues(alpha: 0.2),
              blurRadius: 8,
              offset: const Offset(0, 2),
            )
          else
            AppColors.subtleShadow(),
        ],
      ),
      child: InkWell(
        onTap: effectiveOnTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // NOUVEAU: Checkbox de sélection
              if (onSelected != null)
                Padding(
                  padding: const EdgeInsets.only(right: 12),
                  child: Checkbox(
                    value: isSelected,
                    onChanged: onSelected,
                    activeColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                  ),
                ),

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

              // Indicateurs à droite + Menu actions
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // FIX: Utiliser min au lieu de max
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    // Menu d'actions contextuelles (3 points)
                    if (actions != null && actions!.isNotEmpty && onSelected == null)
                      PopupMenuButton<String>(
                        icon: const Icon(
                          Icons.more_vert,
                          size: 20,
                          color: AppColors.textSecondary,
                        ),
                        tooltip: 'Actions',
                        itemBuilder: (context) => actions!,
                        offset: const Offset(0, 40),
                      )
                    else if (onSelected == null)
                      const SizedBox(width: 20, height: 48), // Hauteur fixe pour alignement

                    // Badge de marge
                    _buildMarginBadge(),

                    // Badge inactif
                    if (!article.isActive) ...[
                      const SizedBox(height: 8),
                      _buildInactiveBadge(),
                    ],
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
            return const Center(
              child: CircularProgressIndicator(strokeWidth: 2),
            );
          },
        )
            : _buildPlaceholderImage(),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return const Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: AppColors.border,
      ),
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