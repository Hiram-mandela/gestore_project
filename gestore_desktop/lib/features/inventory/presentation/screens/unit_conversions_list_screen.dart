// ========================================
// lib/features/inventory/presentation/pages/unit_conversions_list_screen.dart
// Page liste des conversions d'unités avec calculateur
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/unit_conversion_entity.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../providers/categories_brands_providers.dart';
import '../providers/unit_conversions_provider.dart';
import '../providers/unit_conversions_state.dart';
import '../widgets/unit_conversion_card.dart';
import '../widgets/conversion_calculator_widget.dart';

class UnitConversionsListScreen extends ConsumerStatefulWidget {
  const UnitConversionsListScreen({super.key});

  @override
  ConsumerState<UnitConversionsListScreen> createState() =>
      _UnitConversionsListScreenState();
}

class _UnitConversionsListScreenState
    extends ConsumerState<UnitConversionsListScreen> {
  String? _filterFromUnitId;
  String? _filterToUnitId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unitConversionsProvider.notifier).loadConversions();
      ref.read(unitsProvider.notifier).loadUnits();
    });
  }

  void _showDeleteConfirmation(UnitConversionEntity conversion) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmer la suppression'),
        content: Text(
          'Voulez-vous vraiment supprimer la conversion "${conversion.conversionDisplay}" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final success = await ref
                  .read(unitConversionsProvider.notifier)
                  .deleteConversion(conversion.id);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Conversion supprimée avec succès'),
                    backgroundColor: AppColors.success,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConversionsProvider);
    final unitsState = ref.watch(unitsProvider);

    // Récupère les unités pour le filtre et le calculateur
    final units = unitsState is UnitsLoaded ? unitsState.units : <UnitOfMeasureEntity>[];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Conversions d\'unités'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Bouton refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(unitConversionsProvider.notifier).refresh();
            },
            tooltip: 'Actualiser',
          ),
          // Bouton ajouter
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.push('/inventory/unit-conversions/create');
            },
            tooltip: 'Nouvelle conversion',
          ),
        ],
      ),
      body: Column(
        children: [
          // Calculateur de conversion (en haut)
          if (units.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: ConversionCalculatorWidget(units: units),
            ),

          // Filtres
          if (units.isNotEmpty)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _filterFromUnitId,
                      decoration: InputDecoration(
                        labelText: 'Filtrer par unité source',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Toutes'),
                        ),
                        ...units.map((unit) => DropdownMenuItem(
                          value: unit.id,
                          child: Text('${unit.symbol} (${unit.name})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _filterFromUnitId = value);
                        ref.read(unitConversionsProvider.notifier).loadConversions(
                          fromUnitId: value,
                          toUnitId: _filterToUnitId,
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      initialValue: _filterToUnitId,
                      decoration: InputDecoration(
                        labelText: 'Filtrer par unité cible',
                        isDense: true,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Toutes'),
                        ),
                        ...units.map((unit) => DropdownMenuItem(
                          value: unit.id,
                          child: Text('${unit.symbol} (${unit.name})'),
                        )),
                      ],
                      onChanged: (value) {
                        setState(() => _filterToUnitId = value);
                        ref.read(unitConversionsProvider.notifier).loadConversions(
                          fromUnitId: _filterFromUnitId,
                          toUnitId: value,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

          // Liste des conversions
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(UnitConversionsState state) {
    if (state is UnitConversionsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is UnitConversionsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur: ${state.message}',
              style: const TextStyle(
                fontSize: 16,
                color: AppColors.error,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                ref.read(unitConversionsProvider.notifier).loadConversions();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is UnitConversionsLoaded) {
      if (state.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.swap_horiz,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                state.hasFilters
                    ? 'Aucune conversion trouvée avec ces filtres'
                    : 'Aucune conversion configurée',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  context.push('/inventory/unit-conversions/create');
                },
                icon: const Icon(Icons.add),
                label: const Text('Créer une conversion'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.conversions.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final conversion = state.conversions[index];
          return UnitConversionCard(
            conversion: conversion,
            onTap: () {
              context.push('/inventory/unit-conversions/${conversion.id}');
            },
            onEdit: () {
              context.push('/inventory/unit-conversions/${conversion.id}/edit');
            },
            onDelete: () {
              _showDeleteConfirmation(conversion);
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }
}