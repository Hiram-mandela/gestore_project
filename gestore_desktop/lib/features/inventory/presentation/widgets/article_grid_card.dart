// ========================================
// lib/features/inventory/presentation/widgets/article_grid_card.dart
//
// NOUVEAU WIDGET pour l'affichage en grille.
// - Design vertical et compact, optimisé pour une grille à 2 colonnes.
// - Met l'accent sur l'image de l'article.
// - Affiche les informations essentielles (nom, prix, stock) de manière concise.
// - Applique rigoureusement le style GESTORE (fonds, bordures, ombres, typographie).
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_entity.dart';
import 'stock_badge.dart';

/// Carte pour afficher un article dans une grille (vue compacte)
class ArticleGridCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const ArticleGridCard({
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _buildArticleImage(),
                  if (!article.isActive) _buildInactiveOverlay(),
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
                  const SizedBox(height: 8),
                  // Prix et Stock
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Prix
                      Text(
                        article.formattedSellingPrice,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.success,
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
      )
          : _buildPlaceholderImage(),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.backgroundLight,
      child: const Center(
        child: Icon(Icons.inventory_2_outlined, size: 48, color: AppColors.border),
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
            ),
          ),
        ),
      ),
    );
  }
}