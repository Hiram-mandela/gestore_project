// ========================================
// lib/features/inventory/presentation/widgets/article_grid_card.dart
// VERSION PHASE 2 - Support des opérations en masse (mode grille)
//
// Widget pour l'affichage en grille des articles
// - Design vertical et compact, optimisé pour une grille à 2 colonnes
// - Met l'accent sur l'image de l'article
// - Support de la sélection multiple (optionnel)
// - Applique le style GESTORE
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_entity.dart';
import 'stock_badge.dart';

/// Carte pour afficher un article dans une grille (vue compacte)
class ArticleGridCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback? onTap;

  // PHASE 2: Support sélection (optionnel en mode grille)
  final bool isSelected;
  final ValueChanged<bool?>? onSelected;

  const ArticleGridCard({
    super.key,
    required this.article,
    this.onTap,
    this.isSelected = false,
    this.onSelected,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image avec overlay sélection si nécessaire
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildArticleImage(),

                  // Overlay inactif
                  if (!article.isActive) _buildInactiveOverlay(),

                  // PHASE 2: Checkbox de sélection en overlay
                  if (onSelected != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: Checkbox(
                          value: isSelected,
                          onChanged: onSelected,
                          activeColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nom de l'article
                  Text(
                    article.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Code
                  Text(
                    article.code,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Prix et Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Prix
                      Expanded(
                        child: Text(
                          article.formattedSellingPrice,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.success,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      // Stock
                      StockBadge(
                        stock: article.currentStock,
                        isLowStock: article.isLowStock,
                        unit: article.unitSymbol,
                        isCompact: true, // Mode compact pour la grille
                      ),
                    ],
                  ),

                  const SizedBox(height: 6),

                  // Catégorie
                  _buildCategoryChip(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildArticleImage() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      child: article.hasImage
          ? Image.network(
        article.imageUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholderImage(),
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Center(
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: loadingProgress.expectedTotalBytes != null
                  ? loadingProgress.cumulativeBytesLoaded /
                  loadingProgress.expectedTotalBytes!
                  : null,
            ),
          );
        },
      )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.backgroundLight,
      child: const Center(
        child: Icon(
          Icons.inventory_2_outlined,
          size: 48,
          color: AppColors.border,
        ),
      ),
    );
  }

  Widget _buildInactiveOverlay() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight.withValues(alpha: 0.6),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.border),
          ),
          child: const Text(
            'Inactif',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontWeight: FontWeight.w500,
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip() {
    final color = _parseColor(article.categoryColor);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              article.categoryName,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: color.withValues(alpha: 0.9),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
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