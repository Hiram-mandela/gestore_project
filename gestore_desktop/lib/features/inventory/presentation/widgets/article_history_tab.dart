// ========================================
// FICHIER 4: lib/features/inventory/presentation/widgets/article_history_tab.dart
// Onglet Historique
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history, size: 64, color: AppColors.textTertiaryDark),
          const SizedBox(height: 16),
          const Text('Historique des mouvements'),
          const SizedBox(height: 8),
          const Text(
            'Cette fonctionnalité sera disponible prochainement',
            style: TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }
}

