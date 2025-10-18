// ========================================
// lib/features/inventory/presentation/widgets/bulk_action_bar.dart
// Barre d'actions flottante pour les opérations en masse
// ========================================

import 'package:flutter/material.dart';

class BulkActionBar extends StatelessWidget {
  final int selectedCount;
  final VoidCallback onActivate;
  final VoidCallback onDeactivate;
  final VoidCallback onDelete;
  final VoidCallback onChangeCategory;
  final VoidCallback onChangeSupplier;
  final VoidCallback onCancel;

  const BulkActionBar({
    super.key,
    required this.selectedCount,
    required this.onActivate,
    required this.onDeactivate,
    required this.onDelete,
    required this.onChangeCategory,
    required this.onChangeSupplier,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Compteur
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade100,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '$selectedCount sélectionné(s)',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
            ),
          ),

          const SizedBox(width: 16),
          const VerticalDivider(width: 1),
          const SizedBox(width: 8),

          // Actions
          _buildActionButton(
            icon: Icons.check_circle,
            label: 'Activer',
            color: Colors.green,
            onTap: onActivate,
          ),

          _buildActionButton(
            icon: Icons.block,
            label: 'Désactiver',
            color: Colors.orange,
            onTap: onDeactivate,
          ),

          _buildActionButton(
            icon: Icons.folder,
            label: 'Catégorie',
            color: Colors.blue,
            onTap: onChangeCategory,
          ),

          _buildActionButton(
            icon: Icons.business,
            label: 'Fournisseur',
            color: Colors.purple,
            onTap: onChangeSupplier,
          ),

          _buildActionButton(
            icon: Icons.delete,
            label: 'Supprimer',
            color: Colors.red,
            onTap: onDelete,
          ),

          const SizedBox(width: 8),
          const VerticalDivider(width: 1),
          const SizedBox(width: 8),

          // Bouton annuler
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: onCancel,
            tooltip: 'Annuler la sélection',
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: color.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, size: 18, color: color),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}