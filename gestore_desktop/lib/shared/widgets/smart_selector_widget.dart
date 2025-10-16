// ========================================
// lib/shared/widgets/smart_selector_widget.dart
// Widget de sélection intelligente avec recherche
// Remplace les CustomDropdown classiques pour une meilleure UX
// ========================================

import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Item sélectionnable générique
class SelectableItem<T> {
  final T value;
  final String label;
  final String? subtitle;
  final IconData? icon;
  final String? searchText; // Texte additionnel pour la recherche

  SelectableItem({
    required this.value,
    required this.label,
    this.subtitle,
    this.icon,
    this.searchText,
  });

  /// Vérifie si l'item correspond à la recherche
  bool matchesSearch(String query) {
    if (query.isEmpty) return true;

    final lowerQuery = query.toLowerCase();
    final lowerLabel = label.toLowerCase();
    final lowerSubtitle = subtitle?.toLowerCase() ?? '';
    final lowerSearchText = searchText?.toLowerCase() ?? '';

    return lowerLabel.contains(lowerQuery) ||
        lowerSubtitle.contains(lowerQuery) ||
        lowerSearchText.contains(lowerQuery);
  }
}

/// Widget de sélection intelligente avec recherche
class SmartSelectorWidget<T> extends StatelessWidget {
  final String label;
  final T? selectedValue;
  final List<SelectableItem<T>> items;
  final Function(T?) onSelected;
  final IconData? prefixIcon;
  final String? errorText;
  final String? helperText;
  final bool required;
  final bool enabled;
  final String emptyMessage;
  final String searchHint;
  final Widget? trailing; // Pour ajouter un bouton "Créer"

  const SmartSelectorWidget({
    super.key,
    required this.label,
    this.selectedValue,
    required this.items,
    required this.onSelected,
    this.prefixIcon,
    this.errorText,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.emptyMessage = 'Aucun élément disponible',
    this.searchHint = 'Rechercher...',
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    // Trouver l'item sélectionné
    final selectedItem = items.cast<SelectableItem<T>?>().firstWhere(
          (item) => item?.value == selectedValue,
      orElse: () => null,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label avec astérisque si requis
        if (label.isNotEmpty) ...[
          Text(
            required ? '$label *' : label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Champ cliquable
        InkWell(
          onTap: enabled ? () => _showSelectionSheet(context) : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: enabled ? AppColors.surfaceLight : AppColors.surfaceLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: errorText != null
                    ? AppColors.error
                    : AppColors.border,
                width: 1,
              ),
            ),
            child: Row(
              children: [
                if (prefixIcon != null) ...[
                  Icon(
                    prefixIcon,
                    color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                ],
                Expanded(
                  child: Text(
                    selectedItem?.label ?? 'Sélectionner',
                    style: TextStyle(
                      color: selectedItem != null
                          ? AppColors.textPrimary
                          : AppColors.textTertiary,
                      fontSize: 15,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
                ),
              ],
            ),
          ),
        ),

        // Message d'aide ou d'erreur
        if (errorText != null) ...[
          const SizedBox(height: 6),
          Text(
            errorText!,
            style: const TextStyle(
              color: AppColors.error,
              fontSize: 12,
            ),
          ),
        ] else if (helperText != null) ...[
          const SizedBox(height: 6),
          Text(
            helperText!,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ],
    );
  }

  /// Affiche le sheet de sélection avec recherche
  Future<void> _showSelectionSheet(BuildContext context) async {
    final result = await showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _SelectionSheet<T>(
        title: label,
        items: items,
        selectedValue: selectedValue,
        emptyMessage: emptyMessage,
        searchHint: searchHint,
        trailing: trailing,
      ),
    );

    if (result != null) {
      onSelected(result);
    }
  }
}

/// Sheet de sélection avec recherche
class _SelectionSheet<T> extends StatefulWidget {
  final String title;
  final List<SelectableItem<T>> items;
  final T? selectedValue;
  final String emptyMessage;
  final String searchHint;
  final Widget? trailing;

  const _SelectionSheet({
    required this.title,
    required this.items,
    this.selectedValue,
    required this.emptyMessage,
    required this.searchHint,
    this.trailing,
  });

  @override
  State<_SelectionSheet<T>> createState() => _SelectionSheetState<T>();
}

class _SelectionSheetState<T> extends State<_SelectionSheet<T>> {
  final TextEditingController _searchController = TextEditingController();
  List<SelectableItem<T>> _filteredItems = [];

  @override
  void initState() {
    super.initState();
    _filteredItems = widget.items;
    _searchController.addListener(_filterItems);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _filterItems() {
    final query = _searchController.text;
    setState(() {
      _filteredItems = widget.items
          .where((item) => item.matchesSearch(query))
          .toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height * 0.75;

    return Container(
      height: height,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    widget.title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),

          // Barre de recherche
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: InputDecoration(
                hintText: widget.searchHint,
                prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                  },
                )
                    : null,
                filled: true,
                fillColor: AppColors.backgroundLight,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
          ),

          // Bouton d'action (ex: Créer)
          if (widget.trailing != null) ...[
            const SizedBox(height: 12),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: widget.trailing!,
            ),
          ],

          const SizedBox(height: 12),
          const Divider(height: 1),

          // Liste des items
          Expanded(
            child: _filteredItems.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.search_off,
                      size: 64,
                      color: Colors.grey.shade300,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      _searchController.text.isEmpty
                          ? widget.emptyMessage
                          : 'Aucun résultat trouvé',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            )
                : ListView.separated(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _filteredItems.length,
              separatorBuilder: (context, index) => const Divider(height: 1, indent: 16, endIndent: 16),
              itemBuilder: (context, index) {
                final item = _filteredItems[index];
                final isSelected = item.value == widget.selectedValue;

                return ListTile(
                  leading: item.icon != null
                      ? Icon(
                    item.icon,
                    color: isSelected ? AppColors.primary : AppColors.textSecondary,
                  )
                      : null,
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: isSelected ? AppColors.primary : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  subtitle: item.subtitle != null
                      ? Text(
                    item.subtitle!,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                  )
                      : null,
                  trailing: isSelected
                      ? const Icon(
                    Icons.check_circle,
                    color: AppColors.primary,
                  )
                      : null,
                  onTap: () => Navigator.pop(context, item.value),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}