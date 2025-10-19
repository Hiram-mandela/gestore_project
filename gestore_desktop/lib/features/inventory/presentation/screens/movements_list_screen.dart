// ========================================
// lib/features/inventory/presentation/pages/movements_list_screen.dart
// Page liste des mouvements de stock
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../providers/stock_movements_provider.dart';
import '../providers/stock_movements_state.dart';
import '../widgets/movement_card.dart';

class MovementsListScreen extends ConsumerStatefulWidget {
  const MovementsListScreen({super.key});

  @override
  ConsumerState<MovementsListScreen> createState() => _MovementsListScreenState();
}

class _MovementsListScreenState extends ConsumerState<MovementsListScreen> {
  final _searchController = TextEditingController();
  String? _filterMovementType;
  String? _filterReason;
  DateTime? _filterDateFrom;
  DateTime? _filterDateTo;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(stockMovementsProvider.notifier).loadMovements();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _applyFilters() {
    ref.read(stockMovementsProvider.notifier).loadMovements(
      page: 1,
      movementType: _filterMovementType,
      reason: _filterReason,
      dateFrom: _filterDateFrom?.toIso8601String().split('T')[0],
      dateTo: _filterDateTo?.toIso8601String().split('T')[0],
      search: _searchController.text.isEmpty ? null : _searchController.text,
    );
  }

  void _resetFilters() {
    setState(() {
      _filterMovementType = null;
      _filterReason = null;
      _filterDateFrom = null;
      _filterDateTo = null;
      _searchController.clear();
    });
    ref.read(stockMovementsProvider.notifier).loadMovements();
  }

  Future<void> _selectDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filterDateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _filterDateFrom = date);
    }
  }

  Future<void> _selectDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _filterDateTo ?? DateTime.now(),
      firstDate: _filterDateFrom ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _filterDateTo = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockMovementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mouvements de stock'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          // Bouton résumé/dashboard
          IconButton(
            icon: const Icon(Icons.dashboard),
            onPressed: () {
              context.push('/inventory/movements/dashboard');
            },
            tooltip: 'Dashboard',
          ),
          // Bouton refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              ref.read(stockMovementsProvider.notifier).refresh();
            },
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Barre de recherche et filtres
          _buildSearchAndFilters(),

          // Compteur de résultats
          if (state is StockMovementsLoaded)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.surfaceLight,
                border: Border(
                  bottom: BorderSide(color: AppColors.border, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${state.totalCount} mouvement(s)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  if (state.hasFilters)
                    TextButton.icon(
                      onPressed: _resetFilters,
                      icon: const Icon(Icons.clear, size: 16),
                      label: const Text('Réinitialiser'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.error,
                      ),
                    ),
                ],
              ),
            ),

          // Liste des mouvements
          Expanded(
            child: _buildBody(state),
          ),

          // Pagination
          if (state is StockMovementsLoaded &&
              (state.hasNextPage || state.hasPreviousPage))
            _buildPagination(state),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Recherche
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Rechercher un mouvement...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchController.clear();
                  _applyFilters();
                },
              )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onSubmitted: (_) => _applyFilters(),
          ),
          const SizedBox(height: 12),

          // Filtres rapides
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                // Filtre type
                _buildFilterChip(
                  label: _filterMovementType != null
                      ? MovementType.fromString(_filterMovementType!).label
                      : 'Type',
                  icon: Icons.category,
                  onTap: () => _showMovementTypeFilter(),
                  isActive: _filterMovementType != null,
                ),
                const SizedBox(width: 8),

                // Filtre raison
                _buildFilterChip(
                  label: _filterReason != null
                      ? MovementReason.fromString(_filterReason!).label
                      : 'Raison',
                  icon: Icons.info,
                  onTap: () => _showReasonFilter(),
                  isActive: _filterReason != null,
                ),
                const SizedBox(width: 8),

                // Filtre date début
                _buildFilterChip(
                  label: _filterDateFrom != null
                      ? 'Du ${_filterDateFrom!.day}/${_filterDateFrom!.month}'
                      : 'Date début',
                  icon: Icons.calendar_today,
                  onTap: _selectDateFrom,
                  isActive: _filterDateFrom != null,
                ),
                const SizedBox(width: 8),

                // Filtre date fin
                _buildFilterChip(
                  label: _filterDateTo != null
                      ? 'Au ${_filterDateTo!.day}/${_filterDateTo!.month}'
                      : 'Date fin',
                  icon: Icons.calendar_today,
                  onTap: _selectDateTo,
                  isActive: _filterDateTo != null,
                ),
                const SizedBox(width: 8),

                // Bouton appliquer
                ElevatedButton.icon(
                  onPressed: _applyFilters,
                  icon: const Icon(Icons.filter_list, size: 18),
                  label: const Text('Filtrer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required IconData icon,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isActive
              ? AppColors.primary.withValues(alpha: 0.1)
              : AppColors.surfaceLight,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isActive ? AppColors.primary : AppColors.border,
            width: isActive ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 16,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                color: isActive ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showMovementTypeFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Type de mouvement'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                setState(() => _filterMovementType = null);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _filterMovementType == null
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _filterMovementType == null
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    const Text('Tous'),
                  ],
                ),
              ),
            ),
            ...MovementType.values.map((type) => InkWell(
              onTap: () {
                setState(() => _filterMovementType = type.value);
                Navigator.pop(context);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                child: Row(
                  children: [
                    Icon(
                      _filterMovementType == type.value
                          ? Icons.radio_button_checked
                          : Icons.radio_button_unchecked,
                      color: _filterMovementType == type.value
                          ? AppColors.primary
                          : AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(type.label),
                  ],
                ),
              ),
            )),
          ],
        ),
      ),
    );
  }

  void _showReasonFilter() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Raison du mouvement'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: () {
                  setState(() => _filterReason = null);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        _filterReason == null
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _filterReason == null
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      const Text('Toutes'),
                    ],
                  ),
                ),
              ),
              ...MovementReason.values.map((reason) => InkWell(
                onTap: () {
                  setState(() => _filterReason = reason.value);
                  Navigator.pop(context);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: Row(
                    children: [
                      Icon(
                        _filterReason == reason.value
                            ? Icons.radio_button_checked
                            : Icons.radio_button_unchecked,
                        color: _filterReason == reason.value
                            ? AppColors.primary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Text(reason.label),
                    ],
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBody(StockMovementsState state) {
    if (state is StockMovementsLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is StockMovementsError) {
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
                ref.read(stockMovementsProvider.notifier).loadMovements();
              },
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockMovementsLoaded) {
      if (state.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.inventory_2,
                size: 64,
                color: AppColors.textSecondary.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                state.hasFilters
                    ? 'Aucun mouvement trouvé avec ces filtres'
                    : 'Aucun mouvement de stock enregistré',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        );
      }

      return ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: state.response.results.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final movement = state.response.results[index];
          return MovementCard(
            movement: movement,
            onTap: () {
              context.push('/inventory/movements/${movement.id}');
            },
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildPagination(StockMovementsLoaded state) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton précédent
          ElevatedButton.icon(
            onPressed: state.hasPreviousPage
                ? () {
              ref.read(stockMovementsProvider.notifier).loadPreviousPage();
            }
                : null,
            icon: const Icon(Icons.chevron_left),
            label: const Text('Précédent'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.surfaceLight,
              foregroundColor: AppColors.textPrimary,
            ),
          ),

          // Numéro de page
          Text(
            'Page ${state.currentPage}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),

          // Bouton suivant
          ElevatedButton.icon(
            onPressed: state.hasNextPage
                ? () {
              ref.read(stockMovementsProvider.notifier).loadNextPage();
            }
                : null,
            icon: const Icon(Icons.chevron_right),
            label: const Text('Suivant'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}