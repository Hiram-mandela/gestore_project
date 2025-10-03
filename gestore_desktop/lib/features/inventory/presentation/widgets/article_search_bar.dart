// ========================================
// lib/features/inventory/presentation/widgets/article_search_bar.dart
// Widget barre de recherche pour les articles
// ========================================

import 'package:flutter/material.dart';
import 'dart:async';

/// Barre de recherche avec debounce pour les articles
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

  /// Gère le changement de texte avec debounce
  void _onSearchChanged(String query) {
    // Annuler le timer précédent
    _debounce?.cancel();

    // Créer un nouveau timer
    _debounce = Timer(widget.debounceDuration, () {
      widget.onSearch(query);
    });
  }

  /// Efface la recherche
  void _clearSearch() {
    _controller.clear();
    widget.onSearch('');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: TextField(
        controller: _controller,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Rechercher un article (nom, code, code-barres)...',
          hintStyle: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: Colors.grey[600],
          ),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(
              Icons.clear,
              color: Colors.grey[600],
            ),
            onPressed: _clearSearch,
          )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 14,
          ),
        ),
        style: const TextStyle(fontSize: 14),
      ),
    );
  }
}