// ========================================
// lib/features/inventory/presentation/pages/location_detail_screen.dart
// Page de détail d'un emplacement
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/location_entity.dart';
import '../providers/locations_provider.dart';
import '../providers/locations_state.dart';

class LocationDetailScreen extends ConsumerStatefulWidget {
  final String locationId;

  const LocationDetailScreen({super.key, required this.locationId});

  @override
  ConsumerState<LocationDetailScreen> createState() => _LocationDetailScreenState();
}

class _LocationDetailScreenState extends ConsumerState<LocationDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(locationsProvider.notifier).loadLocationById(widget.locationId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(locationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de l\'emplacement'),
        actions: [
          if (state is LocationDetailLoaded)
            IconButton(
              icon: const Icon(Icons.edit),
              tooltip: 'Modifier',
              onPressed: () => context.push(
                '/inventory/locations/${widget.locationId}/edit',
              ),
            ),
        ],
      ),
      body: _buildBody(state, theme),
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
              onPressed: () => ref
                  .read(locationsProvider.notifier)
                  .loadLocationById(widget.locationId),
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is LocationDetailLoaded) {
      return _buildLocationDetail(state.location, theme);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLocationDetail(LocationEntity location, ThemeData theme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec icône et nom
          _buildHeader(location, theme),

          const SizedBox(height: 24),

          // Informations générales
          _buildSection(
            theme,
            title: 'Informations générales',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.tag,
                label: 'Code',
                value: location.code,
              ),
              _buildInfoTile(
                theme,
                icon: Icons.category,
                label: 'Type',
                value: location.locationType.label,
              ),
              _buildInfoTile(
                theme,
                icon: Icons.toggle_on,
                label: 'Statut',
                value: location.statusDisplay,
                valueColor: location.isActive ? Colors.green : Colors.red,
              ),
              if (location.barcode != null)
                _buildInfoTile(
                  theme,
                  icon: Icons.qr_code,
                  label: 'Code-barres',
                  value: location.barcode!,
                ),
              if (location.description != null)
                _buildInfoTile(
                  theme,
                  icon: Icons.description,
                  label: 'Description',
                  value: location.description!,
                ),
            ],
          ),

          const SizedBox(height: 24),

          // Hiérarchie
          _buildSection(
            theme,
            title: 'Hiérarchie',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.folder_open,
                label: 'Chemin complet',
                value: location.fullPath,
              ),
              if (location.parentName != null)
                _buildInfoTile(
                  theme,
                  icon: Icons.folder,
                  label: 'Parent',
                  value: location.parentName!,
                ),
              _buildInfoTile(
                theme,
                icon: Icons.layers,
                label: 'Niveau',
                value: '${location.level}',
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Statistiques
          _buildSection(
            theme,
            title: 'Statistiques',
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      icon: Icons.inventory_2,
                      label: 'Stocks',
                      value: '${location.stocksCount}',
                      color: Colors.blue,
                      onTap: location.hasStocks
                          ? () => _viewStocks(location)
                          : null,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      theme,
                      icon: Icons.folder_copy,
                      label: 'Sous-emplacements',
                      value: '${location.childrenCount}',
                      color: Colors.orange,
                      onTap: location.hasChildren
                          ? () => _viewChildren(location)
                          : null,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Métadonnées
          _buildSection(
            theme,
            title: 'Métadonnées',
            children: [
              _buildInfoTile(
                theme,
                icon: Icons.calendar_today,
                label: 'Créé le',
                value: _formatDate(location.createdAt),
              ),
              _buildInfoTile(
                theme,
                icon: Icons.update,
                label: 'Modifié le',
                value: _formatDate(location.updatedAt),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(LocationEntity location, ThemeData theme) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                location.locationType.icon,
                style: const TextStyle(fontSize: 48),
              ),
            ),
            const SizedBox(width: 24),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    location.name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    location.locationType.label,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(
      ThemeData theme, {
        required String title,
        required List<Widget> children,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: children,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoTile(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        Color? valueColor,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                color: valueColor,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
      ThemeData theme, {
        required IconData icon,
        required String label,
        required String value,
        required Color color,
        VoidCallback? onTap,
      }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Icon(icon, size: 32, color: color),
              const SizedBox(height: 8),
              Text(
                value,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.bodySmall,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year} ${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  void _viewStocks(LocationEntity location) {
    // TODO: Naviguer vers la page des stocks de cet emplacement
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Affichage des stocks (Phase 4)'),
      ),
    );
  }

  void _viewChildren(LocationEntity location) {
    // Naviguer vers la liste filtrée par parent
    context.push('/inventory/locations?parent=${location.id}');
  }
}