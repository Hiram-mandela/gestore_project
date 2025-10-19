// ========================================
// lib/features/inventory/presentation/widgets/conversion_calculator_widget.dart
// Widget pour calculer des conversions à la volée
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../providers/unit_conversions_provider.dart';
import '../providers/unit_conversions_state.dart';

class ConversionCalculatorWidget extends ConsumerStatefulWidget {
  final List<UnitOfMeasureEntity> units;

  const ConversionCalculatorWidget({
    super.key,
    required this.units,
  });

  @override
  ConsumerState<ConversionCalculatorWidget> createState() =>
      _ConversionCalculatorWidgetState();
}

class _ConversionCalculatorWidgetState
    extends ConsumerState<ConversionCalculatorWidget> {
  final _quantityController = TextEditingController();
  UnitOfMeasureEntity? _fromUnit;
  UnitOfMeasureEntity? _toUnit;

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  void _calculate() {
    if (_fromUnit == null || _toUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les deux unités'),
          backgroundColor: AppColors.warning,
        ),
      );
      return;
    }

    final quantity = double.tryParse(_quantityController.text);
    if (quantity == null || quantity <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez entrer une quantité valide'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    ref.read(unitConversionsProvider.notifier).calculate(
      fromUnitId: _fromUnit!.id,
      toUnitId: _toUnit!.id,
      quantity: quantity,
    );
  }

  void _swapUnits() {
    setState(() {
      final temp = _fromUnit;
      _fromUnit = _toUnit;
      _toUnit = temp;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConversionsProvider);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: AppColors.border, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titre
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.calculate,
                    color: AppColors.primary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Calculateur de conversion',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Champ quantité
            TextField(
              controller: _quantityController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                labelText: 'Quantité',
                hintText: 'Entrez la quantité à convertir',
                prefixIcon: const Icon(Icons.numbers, color: AppColors.primary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Sélection unités
            Row(
              children: [
                // Unité source
                Expanded(
                  child: DropdownButtonFormField<UnitOfMeasureEntity>(
                    initialValue: _fromUnit,
                    decoration: InputDecoration(
                      labelText: 'De',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: widget.units
                        .where((u) => u.isActive)
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text('${unit.symbol} (${unit.name})'),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _fromUnit = value);
                    },
                  ),
                ),
                const SizedBox(width: 12),

                // Bouton swap
                IconButton(
                  onPressed: _swapUnits,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.swap_horiz,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Unité cible
                Expanded(
                  child: DropdownButtonFormField<UnitOfMeasureEntity>(
                    initialValue: _toUnit,
                    decoration: InputDecoration(
                      labelText: 'Vers',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: const BorderSide(color: AppColors.primary, width: 2),
                      ),
                    ),
                    items: widget.units
                        .where((u) => u.isActive)
                        .map((unit) => DropdownMenuItem(
                      value: unit,
                      child: Text('${unit.symbol} (${unit.name})'),
                    ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _toUnit = value);
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Bouton calculer
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: state is ConversionCalculating ? null : _calculate,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: state is ConversionCalculating
                    ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                )
                    : const Text(
                  'Calculer',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),

            // Résultat
            if (state is ConversionCalculated) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.success.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: AppColors.success,
                          size: 24,
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          'Résultat',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: AppColors.success,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.result.displayText,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Facteur: ${state.result.conversionFactor}',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Erreur
            if (state is ConversionCalculationError) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.error.withValues(alpha: 0.3),
                    width: 2,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: AppColors.error,
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        state.message,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.error,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}