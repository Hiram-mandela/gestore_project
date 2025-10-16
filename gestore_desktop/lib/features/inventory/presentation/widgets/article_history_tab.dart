// ========================================
// lib/features/inventory/presentation/widgets/article_history_tab.dart
//
// MODIFICATIONS APPORTÉES (Refonte Visuelle GESTORE) :
// - Amélioration du message de "fonctionnalité à venir" pour qu'il soit plus propre et aligné sur le design GESTORE.
// - Utilisation des couleurs AppColors pour le texte et les icônes.
// - Standardisation de la typographie pour une meilleure cohérence.
// ========================================

import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/article_detail_entity.dart';

class ArticleHistoryTab extends StatelessWidget {
  final ArticleDetailEntity article;
  const ArticleHistoryTab({super.key, required this.article});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.history_toggle_off_outlined,
                size: 64, color: AppColors.border),
            const SizedBox(height: 24),
            const Text(
              'Historique des mouvements',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Cette fonctionnalité sera disponible dans une prochaine mise à jour.',
              textAlign: TextAlign.center,
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}