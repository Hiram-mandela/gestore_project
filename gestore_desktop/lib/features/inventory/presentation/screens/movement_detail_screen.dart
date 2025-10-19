// ========================================
// lib/features/inventory/presentation/pages/movement_detail_screen.dart
// Page détail d'un mouvement de stock
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/stock_movement_entity.dart';
import '../providers/stock_movements_provider.dart';
import '../providers/stock_movements_state.dart';

class MovementDetailScreen extends ConsumerStatefulWidget {
  final String movementId;

  const MovementDetailScreen({
    super.key,
    required this.movementId,
  });

  @override
  ConsumerState<MovementDetailScreen> createState() =>
      _MovementDetailScreenState();
}

class _MovementDetailScreenState extends ConsumerState<MovementDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(stockMovementsProvider.notifier)
          .loadMovementDetail(widget.movementId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockMovementsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail du mouvement'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(StockMovementsState state) {
    if (state is StockMovementDetailLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is StockMovementDetailError) {
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
          ],
        ),
      );
    }

    if (state is StockMovementDetailLoaded) {
      return _buildContent(state.movement);
    }

    return const SizedBox.shrink();
  }

  Widget _buildContent(StockMovementEntity movement) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête avec type
          _buildHeader(movement),
          const SizedBox(height: 24),

          // Informations principales
          _buildSection(
            title: 'Informations principales',
            icon: Icons.info_outline,
            children: [
              _buildInfoRow('Type', movement.movementType.label),
              _buildInfoRow('Raison', movement.reason.label),
              _buildInfoRow('Quantité', movement.quantity.toStringAsFixed(2)),
              _buildInfoRow('Date', movement.formattedDate),
              if (movement.createdBy != null)
                _buildInfoRow('Créé par', movement.createdBy!),
            ],
          ),
          const SizedBox(height: 20),

          // Article
          _buildSection(
            title: 'Article',
            icon: Icons.inventory_2,
            children: [
              _buildInfoRow('Nom', movement.article.name),
              _buildInfoRow('Code', movement.article.code),
              _buildInfoRow('Catégorie', movement.article.categoryName),
            ],
          ),
          const SizedBox(height: 20),

          // Emplacement
          _buildSection(
            title: 'Emplacement',
            icon: Icons.location_on,
            children: [
              _buildInfoRow('Nom', movement.stock.location!.name),
              _buildInfoRow('Code', movement.stock.location!.code),
            ],
          ),
          const SizedBox(height: 20),

          // Variation de stock
          _buildStockVariation(movement),
          const SizedBox(height: 20),

          // Valeur (si disponible)
          if (movement.hasValue) ...[
            _buildSection(
              title: 'Valeur',
              icon: Icons.attach_money,
              children: [
                _buildInfoRow(
                  'Coût unitaire',
                  '${movement.unitCost!.toStringAsFixed(2)} FCFA',
                ),
                _buildInfoRow(
                  'Valeur totale',
                  '${movement.movementValue.toStringAsFixed(2)} FCFA',
                  valueColor: AppColors.success,
                  valueBold: true,
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Document de référence (si disponible)
          if (movement.referenceDocument != null &&
              movement.referenceDocument!.isNotEmpty) ...[
            _buildSection(
              title: 'Document de référence',
              icon: Icons.description,
              children: [
                _buildInfoRow('Référence', movement.referenceDocument!),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // Notes (si disponibles)
          if (movement.notes != null && movement.notes!.isNotEmpty) ...[
            _buildSection(
              title: 'Notes',
              icon: Icons.note,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceLight,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: Text(
                    movement.notes!,
                    style: const TextStyle(
                      fontSize: 14,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader(StockMovementEntity movement) {
    Color typeColor;
    IconData typeIcon;

    switch (movement.movementType) {
      case MovementType.inMovement:
        typeColor = AppColors.success;
        typeIcon = Icons.arrow_downward;
        break;
      case MovementType.out:
        typeColor = AppColors.error;
        typeIcon = Icons.arrow_upward;
        break;
      case MovementType.adjustment:
        typeColor = AppColors.warning;
        typeIcon = Icons.tune;
        break;
      case MovementType.transfer:
        typeColor = AppColors.info;
        typeIcon = Icons.swap_horiz;
        break;
      case MovementType.returnMovement:
        typeColor = AppColors.warning;
        typeIcon = Icons.undo;
        break;
      case MovementType.loss:
        typeColor = AppColors.error;
        typeIcon = Icons.remove_circle;
        break;
      case MovementType.found:
        typeColor = AppColors.success;
        typeIcon = Icons.add_circle;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: typeColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: typeColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(typeIcon, color: typeColor, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  movement.movementType.label,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: typeColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'ID: ${movement.id}',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 20, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border, width: 1),
          ),
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(
      String label,
      String value, {
        Color? valueColor,
        bool valueBold = false,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: valueBold ? FontWeight.w600 : FontWeight.normal,
                color: valueColor ?? AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockVariation(StockMovementEntity movement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.info.withValues(alpha: 0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.trending_up, size: 20, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text(
                'Variation de stock',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStockValue('Avant', movement.stockBefore),
              Icon(Icons.arrow_forward, size: 32, color: AppColors.primary),
              _buildStockValue('Après', movement.stockAfter),
            ],
          ),
          const SizedBox(height: 12),
          Center(
            child: Text(
              'Variation: ${movement.stockVariation >= 0 ? '+' : ''}${movement.stockVariation.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: movement.stockVariation >= 0
                    ? AppColors.success
                    : AppColors.error,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStockValue(String label, double value) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value.toStringAsFixed(2),
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}