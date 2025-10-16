// ========================================
// lib/features/inventory/presentation/screens/units_list_screen.dart
// Écran de la liste des unités de mesure
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Application de la palette GESTORE (AppColors) pour une UI cohérente.
// - Remplacement des Card par des Container stylisés (bordures, ombres subtiles).
// - Amélioration de l'en-tête, de la barre de recherche et de l'état vide.
// - Refonte des badges de statut ("Décimal", "Inactif") avec les couleurs GESTORE.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/units_crud_provider.dart';
import '../providers/unit_state.dart';
import '../../domain/entities/unit_of_measure_entity.dart';

/// Écran de la liste des unités de mesure
class UnitsListScreen extends ConsumerStatefulWidget {
  const UnitsListScreen({super.key});

  @override
  ConsumerState<UnitsListScreen> createState() => _UnitsListScreenState();
}

class _UnitsListScreenState extends ConsumerState<UnitsListScreen> {
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    // Charger les unités au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unitsListProvider.notifier).loadUnits(isActive: true);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitsListProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      body: Column(
        children: [
          // Header
          _buildHeader(context, state),
          // Corps
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
      // Bouton flottant pour créer
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/inventory/units/new'),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Nouvelle unité', style: TextStyle(color: Colors.white)),
        backgroundColor: AppColors.primary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  /// Construit l'en-tête
  Widget _buildHeader(BuildContext context, UnitState state) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
      ),
      padding: const EdgeInsets.all(24).copyWith(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: MediaQuery.of(context).padding.top),
          // Titre
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Unités de mesure',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _buildSubtitle(state),
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Bouton refresh
              IconButton(
                onPressed: () {
                  ref.read(unitsListProvider.notifier).refresh();
                },
                icon: const Icon(Icons.refresh, color: AppColors.primary),
                tooltip: 'Actualiser',
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Barre de recherche
          TextField(
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: 'Rechercher une unité...',
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary),
              filled: true,
              fillColor: AppColors.backgroundLight,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
            onChanged: (value) {
              setState(() {
                _searchQuery = value.toLowerCase();
              });
            },
          ),
        ],
      ),
    );
  }

  /// Construit le sous-titre
  String _buildSubtitle(UnitState state) {
    if (state is UnitLoaded) {
      return '${state.units.length} unités enregistrées';
    }
    return 'Gestion des unités de mesure';
  }

  /// Construit le corps
  Widget _buildBody(UnitState state) {
    if (state is UnitLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is UnitError) {
      return _buildErrorState(state.message);
    }
    if (state is UnitLoaded) {
      // Filtrer par recherche
      final filteredUnits = _searchQuery.isEmpty
          ? state.units
          : state.units.where((unit) {
        return unit.name.toLowerCase().contains(_searchQuery) ||
            unit.symbol.toLowerCase().contains(_searchQuery) ||
            (unit.description?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();

      if (filteredUnits.isEmpty) {
        return _buildEmptyState();
      }
      return RefreshIndicator(
        onRefresh: () async {
          await ref.read(unitsListProvider.notifier).refresh();
        },
        color: AppColors.primary,
        child: ListView.separated(
          padding: const EdgeInsets.all(24),
          itemCount: filteredUnits.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            return _buildUnitCard(context, filteredUnits[index]);
          },
        ),
      );
    }
    return const SizedBox.shrink();
  }

  /// Construit une carte unité
  Widget _buildUnitCard(BuildContext context, UnitOfMeasureEntity unit) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: InkWell(
        onTap: () {
          context.push('/inventory/units/${unit.id}/edit');
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Icône
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.straighten_outlined,
                  color: AppColors.primary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Infos
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            unit.name,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        // Badge décimale
                        if (unit.isDecimal)
                          _buildBadge('Décimal', AppColors.info),
                        const SizedBox(width: 8),
                        // Badge statut
                        if (!unit.isActive)
                          _buildBadge('Inactif', AppColors.warning),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.backgroundLight,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: Text(
                            unit.symbol,
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        if (unit.description != null &&
                            unit.description!.isNotEmpty) ...[
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              unit.description!,
                              style: const TextStyle(
                                fontSize: 13,
                                color: AppColors.textSecondary,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Chevron
              const Icon(
                Icons.chevron_right,
                color: AppColors.border,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Construit un badge
  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.straighten_outlined,
            size: 80,
            color: AppColors.border,
          ),
          const SizedBox(height: 16),
          Text(
            _searchQuery.isEmpty ? 'Aucune unité' : 'Aucun résultat',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _searchQuery.isEmpty
                ? 'Créez votre première unité pour commencer'
                : 'Essayez avec un autre mot-clé',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.push('/inventory/units/new'),
              icon: const Icon(Icons.add),
              label: const Text('Créer une unité'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// État d'erreur
  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            const Text(
              'Une erreur est survenue',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: const TextStyle(color: AppColors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () {
                ref.read(unitsListProvider.notifier).refresh();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}