// ========================================
// lib/features/inventory/presentation/widgets/location_selector_dialog.dart
// Dialog de sélection d'emplacement
// Utile pour les phases ultérieures (stocks, transferts, etc.)
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/location_entity.dart';
import '../providers/locations_provider.dart';
import '../providers/locations_state.dart';

class LocationSelectorDialog extends ConsumerStatefulWidget {
  final String? excludeId; // Pour exclure un emplacement (utile pour transferts)
  final bool onlyActive; // Afficher uniquement les emplacements actifs

  const LocationSelectorDialog({
    super.key,
    this.excludeId,
    this.onlyActive = true,
  });

  @override
  ConsumerState<LocationSelectorDialog> createState() =>
      _LocationSelectorDialogState();
}

class _LocationSelectorDialogState
    extends ConsumerState<LocationSelectorDialog> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationsProvider.notifier).loadLocations(
        isActive: widget.onlyActive ? true : null,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    return Dialog(
      child: SizedBox(
        width: MediaQuery.of(context).size.width * 0.8,
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Sélectionner un emplacement',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: theme.colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ],
              ),
            ),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Rechercher un emplacement...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) {
                  setState(() => _searchQuery = value.toLowerCase());
                },
              ),
            ),

            // Liste des emplacements
            Expanded(
              child: _buildLocationsList(state, theme),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationsList(LocationsState state, ThemeData theme) {
    if (state is LocationsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is LocationsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: theme.colorScheme.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: theme.textTheme.titleMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is LocationsLoaded) {
      // Filtrer les emplacements
      var locations = state.locations;

      // Exclure l'emplacement spécifié
      if (widget.excludeId != null) {
        locations = locations
            .where((loc) => loc.id != widget.excludeId)
            .toList();
      }

      // Filtrer par recherche
      if (_searchQuery.isNotEmpty) {
        locations = locations.where((loc) {
          return loc.name.toLowerCase().contains(_searchQuery) ||
              loc.code.toLowerCase().contains(_searchQuery) ||
              loc.fullPath.toLowerCase().contains(_searchQuery);
        }).toList();
      }

      if (locations.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.location_off,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Aucun emplacement trouvé',
                style: theme.textTheme.titleMedium,
              ),
            ],
          ),
        );
      }

      return ListView.builder(
        itemCount: locations.length,
        itemBuilder: (context, index) {
          final location = locations[index];
          return _buildLocationTile(location, theme);
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildLocationTile(LocationEntity location, ThemeData theme) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          location.locationType.icon,
          style: const TextStyle(fontSize: 20),
        ),
      ),
      title: Text(
        location.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Code: ${location.code}'),
          if (location.fullPath.isNotEmpty)
            Text(
              location.fullPath,
              style: TextStyle(
                fontSize: 12,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (location.hasStocks)
            Chip(
              label: Text('${location.stocksCount}'),
              avatar: const Icon(Icons.inventory_2, size: 16),
              visualDensity: VisualDensity.compact,
            ),
          const SizedBox(width: 8),
          Icon(
            Icons.chevron_right,
            color: theme.colorScheme.primary,
          ),
        ],
      ),
      onTap: () => Navigator.pop(context, location),
    );
  }

  /// Méthode statique pour afficher le dialog facilement
  static Future<LocationEntity?> show(
      BuildContext context, {
        String? excludeId,
        bool onlyActive = true,
      }) {
    return showDialog<LocationEntity>(
      context: context,
      builder: (context) => LocationSelectorDialog(
        excludeId: excludeId,
        onlyActive: onlyActive,
      ),
    );
  }
}