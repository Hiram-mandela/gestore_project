// ========================================
// lib/features/inventory/presentation/pages/locations_list_screen.dart
// Page de liste des emplacements
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/location_entity.dart';
import '../providers/locations_provider.dart';
import '../providers/locations_state.dart';
import '../widgets/location_card.dart';

class LocationsListScreen extends ConsumerStatefulWidget {
  const LocationsListScreen({super.key});

  @override
  ConsumerState<LocationsListScreen> createState() => _LocationsListScreenState();
}

class _LocationsListScreenState extends ConsumerState<LocationsListScreen> {
  String? _selectedType;
  bool? _filterActive;

  @override
  void initState() {
    super.initState();
    // Charger les emplacements au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationsProvider.notifier).loadLocations();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emplacements'),
        actions: [
          // Filtre par type
          PopupMenuButton<String?>(
            icon: const Icon(Icons.filter_list),
            tooltip: 'Filtrer par type',
            onSelected: (value) {
              setState(() => _selectedType = value);
              _applyFilters();
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: null,
                child: Text('Tous les types'),
              ),
              ...LocationType.values.map((type) => PopupMenuItem(
                value: type.value,
                child: Row(
                  children: [
                    Text(type.icon),
                    const SizedBox(width: 8),
                    Text(type.label),
                  ],
                ),
              )),
            ],
          ),

          // Filtre actif/inactif
          IconButton(
            icon: Icon(
              _filterActive == true
                  ? Icons.toggle_on
                  : _filterActive == false
                  ? Icons.toggle_off
                  : Icons.filter_alt_outlined,
            ),
            tooltip: 'Filtrer actifs',
            onPressed: () {
              setState(() {
                if (_filterActive == null) {
                  _filterActive = true;
                } else if (_filterActive == true) {
                  _filterActive = false;
                } else {
                  _filterActive = null;
                }
              });
              _applyFilters();
            },
          ),
        ],
      ),
      body: _buildBody(state, theme),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/locations/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nouvel emplacement'),
      ),
    );
  }

  Widget _buildBody(LocationsState state, ThemeData theme) {
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
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => ref.read(locationsProvider.notifier).loadLocations(),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is LocationsLoaded) {
      if (state.locations.isEmpty) {
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
                'Aucun emplacement',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Créez votre premier emplacement',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        );
      }

      return Column(
        children: [
          // Statistiques en en-tête
          _buildStatsHeader(state, theme),

          // Liste des emplacements
          Expanded(
            child: RefreshIndicator(
              onRefresh: () async {
                await ref.read(locationsProvider.notifier).loadLocations();
              },
              child: ListView.builder(
                itemCount: state.locations.length,
                itemBuilder: (context, index) {
                  final location = state.locations[index];
                  return LocationCard(
                    location: location,
                    onTap: () => _navigateToDetail(location.id),
                    onEdit: () => _navigateToEdit(location.id),
                    onDelete: () => _confirmDelete(location),
                  );
                },
              ),
            ),
          ),
        ],
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildStatsHeader(LocationsLoaded state, ThemeData theme) {
    final activeCount = state.activeLocations.length;
    final rootCount = state.rootLocations.length;

    return Container(
      padding: const EdgeInsets.all(16),
      color: theme.colorScheme.surfaceContainerHighest,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            theme,
            icon: Icons.location_on,
            label: 'Total',
            value: '${state.count}',
          ),
          _buildStatItem(
            theme,
            icon: Icons.check_circle,
            label: 'Actifs',
            value: '$activeCount',
            color: Colors.green,
          ),
          _buildStatItem(
            theme,
            icon: Icons.folder,
            label: 'Racines',
            value: '$rootCount',
            color: Colors.blue,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        Color? color,
      }) {
    final displayColor = color ?? theme.colorScheme.primary;

    return Column(
      children: [
        Icon(icon, color: displayColor),
        const SizedBox(height: 4),
        Text(
          value,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: displayColor,
          ),
        ),
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  void _applyFilters() {
    ref.read(locationsProvider.notifier).loadLocations(
      locationType: _selectedType,
      isActive: _filterActive,
    );
  }

  void _navigateToDetail(String id) {
    context.push('/inventory/locations/$id');
  }

  void _navigateToEdit(String id) {
    context.push('/inventory/locations/$id/edit');
  }

  Future<void> _confirmDelete(LocationEntity location) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'emplacement'),
        content: Text(
          'Êtes-vous sûr de vouloir supprimer "${location.name}" ?\n\n'
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final success = await ref.read(locationsProvider.notifier).deleteLocation(location.id);

      if (success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emplacement supprimé')),
        );
      }
    }
  }
}