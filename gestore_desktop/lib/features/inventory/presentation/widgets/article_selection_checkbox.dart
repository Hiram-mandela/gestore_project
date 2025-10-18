// ========================================
// lib/features/inventory/presentation/widgets/article_selection_checkbox.dart
// Checkbox pour la sélection d'articles dans ArticleCard
// ========================================

import 'package:flutter/material.dart';

class ArticleSelectionCheckbox extends StatelessWidget {
  final bool isSelected;
  final ValueChanged<bool?>? onChanged;
  final Color? activeColor;

  const ArticleSelectionCheckbox({
    super.key,
    required this.isSelected,
    this.onChanged,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isSelected
            ? (activeColor ?? Theme.of(context).primaryColor).withValues(alpha: 0.1)
            : Colors.transparent,
      ),
      child: Checkbox(
        value: isSelected,
        onChanged: onChanged,
        activeColor: activeColor ?? Theme.of(context).primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}