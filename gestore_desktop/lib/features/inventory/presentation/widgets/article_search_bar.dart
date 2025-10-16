// ========================================
// lib/features/inventory/presentation/widgets/article_search_bar.dart
//
// MODIFICATIONS APPORTÉES (CORRECTION) :
// - Utilisation de `filled: true` et `fillColor` dans InputDecoration pour garantir un fond blanc.
// - Changement de la couleur du hintStyle pour `AppColors.textSecondary` pour un meilleur contraste, comme demandé.
// - Le style GESTORE (bordures, icônes) est maintenant appliqué de manière plus robuste.
// ========================================

import 'dart:async';
import 'package:flutter/material.dart';
import '../../../../shared/constants/app_colors.dart';

class ArticleSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  final Duration debounceDuration;

  const ArticleSearchBar({
    super.key,
    required this.onSearch,
    this.debounceDuration = const Duration(milliseconds: 500),
  });

  @override
  State<ArticleSearchBar> createState() => _ArticleSearchBarState();
}

class _ArticleSearchBarState extends State<ArticleSearchBar> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _controller.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    _debounce?.cancel();
    _debounce = Timer(widget.debounceDuration, () {
      if (mounted) {
        widget.onSearch(query);
      }
    });
  }

  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      onChanged: _onSearchChanged,
      style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        // ✅ CORRECTION : Application robuste du style GESTORE
        filled: true,
        fillColor: AppColors.surfaceLight,
        hintText: 'Rechercher un article (nom, code, code-barres)...',
        hintStyle: const TextStyle(color: AppColors.textSecondary, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
        suffixIcon: _controller.text.isNotEmpty
            ? IconButton(
          icon: const Icon(Icons.clear, color: AppColors.textSecondary),
          onPressed: _clearSearch,
        )
            : null,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        // Bordures
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
      ),
    );
  }
}