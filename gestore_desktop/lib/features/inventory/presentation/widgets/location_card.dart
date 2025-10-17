// ========================================
// lib/features/inventory/presentation/widgets/location_card.dart
// Widget carte pour afficher un emplacement
// ========================================

import 'package:flutter/material.dart';
import '../../domain/entities/location_entity.dart';

class LocationCard extends StatelessWidget {
  final LocationEntity location;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;
  final bool showActions;

  const LocationCard({
    super.key,
    required this.location,
    this.onTap,
    this.onEdit,
    this.onDelete,
    this.showActions = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec type et statut
              Row(
                children: [
                  // Icône du type
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.primaryContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      location.locationType.icon,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                  const SizedBox(width: 12),

                  // Nom et code
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          location.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Code: ${location.code}',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Badge statut
                  _buildStatusBadge(context),
                ],
              ),

              const SizedBox(height: 12),

              // Type d'emplacement
              _buildInfoChip(
                context,
                icon: Icons.category,
                label: location.locationType.label,
                color: colorScheme.secondary,
              ),

              const SizedBox(height: 8),

              // Chemin complet
              if (location.fullPath.isNotEmpty)
                _buildInfoRow(
                  context,
                  icon: Icons.folder_open,
                  label: 'Chemin',
                  value: location.fullPath,
                ),

              // Parent
              if (location.parentName != null)
                _buildInfoRow(
                  context,
                  icon: Icons.folder,
                  label: 'Parent',
                  value: location.parentName!,
                ),

              // Code-barres
              if (location.barcode != null)
                _buildInfoRow(
                  context,
                  icon: Icons.qr_code,
                  label: 'Code-barres',
                  value: location.barcode!,
                ),

              const SizedBox(height: 12),

              // Statistiques
              Row(
                children: [
                  _buildStatChip(
                    context,
                    icon: Icons.inventory_2,
                    label: '${location.stocksCount} stocks',
                    color: Colors.blue,
                  ),
                  const SizedBox(width: 8),
                  _buildStatChip(
                    context,
                    icon: Icons.folder_copy,
                    label: '${location.childrenCount} enfants',
                    color: Colors.orange,
                  ),
                ],
              ),

              // Actions
              if (showActions) ...[
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onEdit != null)
                      TextButton.icon(
                        onPressed: onEdit,
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Modifier'),
                      ),
                    if (onDelete != null)
                      TextButton.icon(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Supprimer'),
                        style: TextButton.styleFrom(
                          foregroundColor: colorScheme.error,
                        ),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: location.isActive
            ? colorScheme.primaryContainer
            : colorScheme.errorContainer,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        location.statusDisplay,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: location.isActive
              ? colorScheme.onPrimaryContainer
              : colorScheme.onErrorContainer,
        ),
      ),
    );
  }

  Widget _buildInfoChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Chip(
      avatar: Icon(icon, size: 18, color: color),
      label: Text(label),
      backgroundColor: color.withValues(alpha: 0.1),
      labelStyle: TextStyle(color: color),
    );
  }

  Widget _buildInfoRow(
      BuildContext context, {
        required IconData icon,
        required String label,
        required String value,
      }) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 8),
          Text(
            '$label: ',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(
      BuildContext context, {
        required IconData icon,
        required String label,
        required Color color,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}