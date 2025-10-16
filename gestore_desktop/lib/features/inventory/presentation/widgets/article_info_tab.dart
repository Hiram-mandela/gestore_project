// ========================================
// lib/features/inventory/presentation/widgets/article_info_tab.dart
//
// MODIFICATIONS APPORTÉES (Refonte Visuelle GESTORE) :
// - Remplacement des Card avec élévation par des Container stylisés (bordure, pas d'ombre).
// - Standardisation de la typographie (_InfoRow) avec AppColors.textSecondary pour les labels et AppColors.textPrimary pour les valeurs.
// - Amélioration du style des titres de section (_SectionTitle) pour une meilleure hiérarchie visuelle.
// - Harmonisation de l'affichage des variantes et des images avec le style GESTORE.
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_detail_entity.dart';

class ArticleInfoTab extends StatelessWidget {
  final ArticleDetailEntity article;
  const ArticleInfoTab({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    // Note: Le RefreshIndicator est géré par l'écran parent
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Description
        if (article.description!.isNotEmpty) ...[
          const _SectionTitle(title: 'Description'),
          _InfoCard(
            child: Text(
              article.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Informations de base
        const _SectionTitle(title: 'Informations de base'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow('Code', article.code),
              if (article.barcode != null)
                _InfoRow('Code-barres', article.barcode!),
              if (article.internalReference != null)
                _InfoRow('Réf. interne', article.internalReference!),
              if (article.supplierReference != null)
                _InfoRow('Réf. fournisseur', article.supplierReference!),
              _InfoRow('Type', article.articleType.label),
              _InfoRow('Statut', article.statusDisplay),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Catégorisation
        const _SectionTitle(title: 'Catégorisation'),
        _InfoCard(
          child: Column(
            children: [
              if (article.category != null)
                _InfoRow('Catégorie', article.category!.fullPath),
              if (article.brand != null) _InfoRow('Marque', article.brand!.name),
              if (article.unitOfMeasure != null)
                _InfoRow('Unité', article.unitOfMeasure!.name),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Fournisseur
        if (article.mainSupplier != null) ...[
          const _SectionTitle(title: 'Fournisseur principal'),
          _InfoCard(
            child: Column(
              children: [
                _InfoRow('Nom', article.mainSupplier!.name),
                if (article.mainSupplier!.contactPerson != null)
                  _InfoRow('Contact', article.mainSupplier!.contactPerson!),
                if (article.mainSupplier!.phone != null)
                  _InfoRow('Téléphone', article.mainSupplier!.phone!),
                if (article.mainSupplier!.email != null)
                  _InfoRow('Email', article.mainSupplier!.email!),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Dimensions
        if (article.weight != null ||
            article.length != null ||
            article.width != null ||
            article.height != null) ...[
          const _SectionTitle(title: 'Dimensions'),
          _InfoCard(
            child: Column(
              children: [
                if (article.weight != null)
                  _InfoRow('Poids', '${article.weight!.toStringAsFixed(2)} kg'),
                if (article.length != null)
                  _InfoRow('Longueur', '${article.length!.toStringAsFixed(2)} m'),
                if (article.width != null)
                  _InfoRow('Largeur', '${article.width!.toStringAsFixed(2)} m'),
                if (article.height != null)
                  _InfoRow('Hauteur', '${article.height!.toStringAsFixed(2)} m'),
              ],
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Options
        const _SectionTitle(title: 'Options'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow('Gérer le stock', article.manageStock ? 'Oui' : 'Non'),
              _InfoRow('Vendable', article.isSellable ? 'Oui' : 'Non'),
              _InfoRow('Achetable', article.isPurchasable ? 'Oui' : 'Non'),
              _InfoRow('Stock négatif',
                  article.allowNegativeStock ? 'Autorisé' : 'Interdit'),
              _InfoRow(
                  'Traçabilité lot', article.requiresLotTracking ? 'Oui' : 'Non'),
              _InfoRow('Date péremption',
                  article.requiresExpiryDate ? 'Oui' : 'Non'),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Notes
        if (article.notes != null && article.notes!.isNotEmpty) ...[
          const _SectionTitle(title: 'Notes'),
          _InfoCard(
            child: Text(
              article.notes!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Images additionnelles
        if (article.images.isNotEmpty) ...[
          _SectionTitle(title: 'Images (${article.images.length})'),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: article.images.length,
              itemBuilder: (context, index) {
                final img = article.images[index];
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      img.imageUrl,
                      width: 120,
                      height: 120,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          width: 120,
                          height: 120,
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: const Icon(
                            Icons.image_not_supported_outlined,
                            color: AppColors.textTertiary,
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 24),
        ],

        // Variantes
        if (article.hasVariants) ...[
          _SectionTitle(title: 'Variantes (${article.variantsCount})'),
          ...article.variants.map((variant) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding:
            const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.surfaceLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.border),
            ),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: variant.imageUrl != null
                  ? ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  variant.imageUrl!,
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                ),
              )
                  : Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AppColors.backgroundLight,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.inventory_2_outlined,
                    color: AppColors.textTertiary),
              ),
              title: Text(variant.name,
                  style:
                  const TextStyle(color: AppColors.textPrimary)),
              subtitle: Text(variant.code,
                  style:
                  const TextStyle(color: AppColors.textSecondary)),
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '${variant.sellingPrice.toStringAsFixed(0)} FCFA',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary),
                  ),
                  Text(
                    'Stock: ${variant.currentStock.toStringAsFixed(0)}',
                    style: const TextStyle(
                        fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          )),
        ],

        // Métadonnées
        const SizedBox(height: 16),
        const _SectionTitle(title: 'Métadonnées'),
        _InfoCard(
          child: Column(
            children: [
              _InfoRow('Créé par', article.createdBy ?? 'N/A'),
              _InfoRow('Créé le', _formatDate(article.createdAt)),
              if (article.updatedBy != null)
                _InfoRow('Modifié par', article.updatedBy ?? ''),
              _InfoRow('Modifié le', _formatDate(article.updatedAt)),
            ],
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} à ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}

// ========================================
// WIDGETS COMMUNS (STYLE GESTORE)
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