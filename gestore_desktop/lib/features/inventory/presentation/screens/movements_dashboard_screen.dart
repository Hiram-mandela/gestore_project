// ========================================
// lib/features/inventory/presentation/pages/movements_dashboard_screen.dart
// Dashboard des mouvements de stock avec statistiques
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/usecases/stock_movement_usecases.dart';
import '../providers/stock_movements_provider.dart';
import '../providers/stock_movements_state.dart';

class MovementsDashboardScreen extends ConsumerStatefulWidget {
  const MovementsDashboardScreen({super.key});

  @override
  ConsumerState<MovementsDashboardScreen> createState() =>
      _MovementsDashboardScreenState();
}

class _MovementsDashboardScreenState
    extends ConsumerState<MovementsDashboardScreen> {
  DateTime? _dateFrom;
  DateTime? _dateTo;

  @override
  void initState() {
    super.initState();
    // Par défaut : 30 derniers jours
    _dateTo = DateTime.now();
    _dateFrom = _dateTo!.subtract(const Duration(days: 30));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSummary();
    });
  }

  void _loadSummary() {
    ref.read(stockMovementsProvider.notifier).loadSummary(
      dateFrom: _dateFrom?.toIso8601String().split('T')[0],
      dateTo: _dateTo?.toIso8601String().split('T')[0],
    );
  }

  Future<void> _selectDateFrom() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateFrom ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateFrom = date);
      _loadSummary();
    }
  }

  Future<void> _selectDateTo() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _dateTo ?? DateTime.now(),
      firstDate: _dateFrom ?? DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (date != null) {
      setState(() => _dateTo = date);
      _loadSummary();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockMovementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Mouvements'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadSummary,
            tooltip: 'Actualiser',
          ),
        ],
      ),
      body: Column(
        children: [
          // Sélecteur de période
          _buildPeriodSelector(),

          // Contenu
          Expanded(
            child: _buildBody(state),
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
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
      child: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: _selectDateFrom,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Du',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _dateFrom != null
                                ? '${_dateFrom!.day}/${_dateFrom!.month}/${_dateFrom!.year}'
                                : 'Sélectionner',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: InkWell(
              onTap: _selectDateTo,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: AppColors.border),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, size: 20, color: AppColors.primary),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Au',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          Text(
                            _dateTo != null
                                ? '${_dateTo!.day}/${_dateTo!.month}/${_dateTo!.year}'
                                : 'Sélectionner',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody(StockMovementsState state) {
    if (state is MovementsSummaryLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is MovementsSummaryError) {
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
              onPressed: _loadSummary,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is MovementsSummaryLoaded) {
      return _buildDashboard(state.summary);
    }

    return const SizedBox.shrink();
  }

  Widget _buildDashboard(MovementsSummary summary) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Statistiques globales
          _buildGlobalStats(summary),
          const SizedBox(height: 24),

          // Graphique quotidien
          if (summary.dailySummary.isNotEmpty) ...[
            const Text(
              'Évolution quotidienne',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            _buildDailyChart(summary.dailySummary),
          ],
        ],
      ),
    );
  }

  Widget _buildGlobalStats(MovementsSummary summary) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Statistiques globales',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Total',
                value: summary.totalMovements.toString(),
                icon: Icons.inventory,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Entrées',
                value: summary.totalIn.toString(),
                icon: Icons.arrow_downward,
                color: AppColors.success,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildStatCard(
                title: 'Sorties',
                value: summary.totalOut.toString(),
                icon: Icons.arrow_upward,
                color: AppColors.error,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCard(
                title: 'Ajustements',
                value: summary.totalAdjustments.toString(),
                icon: Icons.tune,
                color: AppColors.warning,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        // Net
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: summary.totalMovements >= 0
                  ? [AppColors.success.withValues(alpha: 0.1), AppColors.success.withValues(alpha: 0.05)]
                  : [AppColors.error.withValues(alpha: 0.1), AppColors.error.withValues(alpha: 0.05)],
            ),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: summary.totalMovements >= 0
                  ? AppColors.success.withValues(alpha: 0.3)
                  : AppColors.error.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    summary.totalMovements >= 0 ? Icons.trending_up : Icons.trending_down,
                    color: summary.totalMovements >= 0 ? AppColors.success : AppColors.error,
                    size: 32,
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Solde net',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              Text(
                '${summary.totalMovements >= 0 ? '+' : ''}${summary.totalMovements}',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: summary.totalMovements >= 0 ? AppColors.success : AppColors.error,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: 12),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: color.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyChart(List<DailySummary> dailySummary) {
    // Graphique simple avec barres
    final maxValue = dailySummary
        .map((d) => d.totalMovements)
        .reduce((a, b) => a > b ? a : b)
        .toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border, width: 1),
      ),
      child: Column(
        children: [
          // Légende
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLegendItem('Entrées', AppColors.success),
              const SizedBox(width: 16),
              _buildLegendItem('Sorties', AppColors.error),
            ],
          ),
          const SizedBox(height: 20),

          // Graphique
          SizedBox(
            height: 200,
            child: dailySummary.length > 10
                ? ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: dailySummary.length,
              itemBuilder: (context, index) {
                return _buildDayBar(dailySummary[index], maxValue);
              },
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: dailySummary
                  .map((day) => _buildDayBar(day, maxValue))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildDayBar(DailySummary day, double maxValue) {
    final inHeight = maxValue > 0 ? (day.totalIn / maxValue) * 150 : 0.0;
    final outHeight = maxValue > 0 ? (day.totalOut / maxValue) * 150 : 0.0;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Tooltip avec détails
          Text(
            '${day.totalIn}/${day.totalOut}',
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 4),

          // Barres
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                width: 20,
                height: inHeight,
                decoration: BoxDecoration(
                  color: AppColors.success,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
              const SizedBox(width: 2),
              Container(
                width: 20,
                height: outHeight,
                decoration: BoxDecoration(
                  color: AppColors.error,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Date
          Text(
            day.date.split('/')[0],
            style: const TextStyle(
              fontSize: 10,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}