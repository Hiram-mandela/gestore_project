// ========================================
// lib/features/inventory/presentation/widgets/article_card.dart
// Widget carte pour afficher un article
// ========================================

import 'package:flutter/material.dart';
import '../../domain/entities/article_entity.dart';
import 'stock_badge.dart';

/// Carte pour afficher un article dans la liste
class ArticleCard extends StatelessWidget {
  final ArticleEntity article;
  final VoidCallback onTap;

  const ArticleCard({
    super.key,
    required this.article,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
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
                    // Nom et code
                    Text(
                      article.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      article.code,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
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
                    const SizedBox(height: 8),

                    // Prix et stock
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // Prix
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Prix de vente',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey[600],
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              article.formattedSellingPrice,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.green,
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

              // Indicateurs à droite
              Column(
                children: [
                  // Badge marge
                  _buildMarginBadge(),
                  const SizedBox(height: 8),
                  // Statut actif/inactif
                  if (!article.isActive)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Text(
                        'Inactif',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: Colors.black54,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit l'image de l'article
  Widget _buildArticleImage() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: article.hasImage
          ? ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          article.imageUrl!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholderImage();
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
        ),
      )
          : _buildPlaceholderImage(),
    );
  }

  /// Image placeholder
  Widget _buildPlaceholderImage() {
    return Center(
      child: Icon(
        Icons.inventory_2_outlined,
        size: 40,
        color: Colors.grey[400],
      ),
    );
  }

  /// Construit le chip de catégorie
  Widget _buildCategoryChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _parseColor(article.categoryColor).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _parseColor(article.categoryColor).withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _parseColor(article.categoryColor),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            article.categoryName,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: _parseColor(article.categoryColor).withOpacity(0.8),
            ),
          ),
        ],
      ),
    );
  }

  /// Construit le chip de marque
  Widget _buildBrandChip() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Text(
        article.brandName!,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Colors.blue[700],
        ),
      ),
    );
  }

  /// Construit le badge de marge
  Widget _buildMarginBadge() {
    final marginColor = article.marginPercent >= 20
        ? Colors.green
        : article.marginPercent >= 10
        ? Colors.orange
        : Colors.red;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: marginColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: marginColor.withOpacity(0.3)),
      ),
      child: Text(
        article.formattedMargin,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: marginColor,
        ),
      ),
    );
  }

  /// Parse une couleur depuis une chaîne hexadécimale
  Color _parseColor(String hexColor) {
    try {
      final hex = hexColor.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (e) {
      return Colors.grey;
    }
  }
}