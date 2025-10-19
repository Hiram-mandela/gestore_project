// ========================================
// lib/features/inventory/presentation/pages/unit_conversion_form_screen.dart
// Formulaire de création/modification de conversion
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/entities/unit_conversion_entity.dart';
import '../providers/categories_brands_providers.dart';
import '../providers/unit_conversions_provider.dart';
import '../providers/unit_conversions_state.dart';

class UnitConversionFormScreen extends ConsumerStatefulWidget {
  final String? conversionId;

  const UnitConversionFormScreen({
    super.key,
    this.conversionId,
  });

  @override
  ConsumerState<UnitConversionFormScreen> createState() =>
      _UnitConversionFormScreenState();
}

class _UnitConversionFormScreenState
    extends ConsumerState<UnitConversionFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _conversionFactorController = TextEditingController();

  UnitOfMeasureEntity? _fromUnit;
  UnitOfMeasureEntity? _toUnit;
  bool _isLoading = false;

  bool get isEditMode => widget.conversionId != null;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(unitsProvider.notifier).loadUnits();
      if (isEditMode) {
        ref
            .read(unitConversionsProvider.notifier)
            .loadConversionDetail(widget.conversionId!);
      }
    });
  }

  @override
  void dispose() {
    _conversionFactorController.dispose();
    super.dispose();
  }

  void _populateForm(UnitConversionEntity conversion) {
    setState(() {
      _fromUnit = conversion.fromUnit;
      _toUnit = conversion.toUnit;
      _conversionFactorController.text = conversion.conversionFactor.toString();
    });
  }

  Future<void> _saveConversion() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_fromUnit == null || _toUnit == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner les deux unités'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    if (_fromUnit!.id == _toUnit!.id) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les unités source et cible doivent être différentes'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final conversionFactor = double.parse(_conversionFactorController.text);

    bool success;
    if (isEditMode) {
      success = await ref
          .read(unitConversionsProvider.notifier)
          .updateExistingConversion(
        id: widget.conversionId!,
        fromUnitId: _fromUnit!.id,
        toUnitId: _toUnit!.id,
        conversionFactor: conversionFactor,
      );
    } else {
      success = await ref
          .read(unitConversionsProvider.notifier)
          .createNewConversion(
        fromUnitId: _fromUnit!.id,
        toUnitId: _toUnit!.id,
        conversionFactor: conversionFactor,
      );
    }

    setState(() => _isLoading = false);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            isEditMode
                ? 'Conversion modifiée avec succès'
                : 'Conversion créée avec succès',
          ),
          backgroundColor: AppColors.success,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitConversionsProvider);
    final unitsState = ref.watch(unitsProvider);

    // Charger les données en mode édition
    if (isEditMode && state is UnitConversionDetailLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _populateForm(state.conversion);
      });
    }

    final units = unitsState is UnitsLoaded
        ? unitsState.units.where((u) => u.isActive).toList()
        : <UnitOfMeasureEntity>[];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isEditMode ? 'Modifier conversion' : 'Nouvelle conversion',
        ),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: _buildBody(state, units),
    );
  }

  Widget _buildBody(UnitConversionsState state, List<UnitOfMeasureEntity> units) {
    if (isEditMode && state is UnitConversionDetailLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (state is UnitConversionDetailError) {
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
              onPressed: () => context.pop(),
              child: const Text('Retour'),
            ),
          ],
        ),
      );
    }

    if (state is UnitConversionsError) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: AppColors.error,
          ),
        );
      });
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.primary.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.swap_horiz,
                    color: AppColors.primary,
                    size: 32,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isEditMode
                              ? 'Modification de conversion'
                              : 'Nouvelle conversion',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Définissez le facteur de conversion entre deux unités',
                          style: TextStyle(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Unité source
            const Text(
              'Unité source',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UnitOfMeasureEntity>(
              initialValue: _fromUnit,
              decoration: InputDecoration(
                hintText: 'Sélectionnez l\'unité source',
                prefixIcon: const Icon(Icons.straighten, color: AppColors.info),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: units
                  .map((unit) => DropdownMenuItem(
                value: unit,
                child: Text('${unit.symbol} - ${unit.name}'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => _fromUnit = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une unité source';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Unité cible
            const Text(
              'Unité cible',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<UnitOfMeasureEntity>(
              initialValue: _toUnit,
              decoration: InputDecoration(
                hintText: 'Sélectionnez l\'unité cible',
                prefixIcon: const Icon(Icons.straighten, color: AppColors.success),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              items: units
                  .map((unit) => DropdownMenuItem(
                value: unit,
                child: Text('${unit.symbol} - ${unit.name}'),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() => _toUnit = value);
              },
              validator: (value) {
                if (value == null) {
                  return 'Veuillez sélectionner une unité cible';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),

            // Facteur de conversion
            const Text(
              'Facteur de conversion',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _conversionFactorController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
              ],
              decoration: InputDecoration(
                hintText: 'Ex: 1000 (pour 1 kg = 1000 g)',
                prefixIcon: const Icon(Icons.calculate, color: AppColors.primary),
                suffixText: _fromUnit != null && _toUnit != null
                    ? '${_toUnit!.symbol}/${_fromUnit!.symbol}'
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer un facteur de conversion';
                }
                final factor = double.tryParse(value);
                if (factor == null || factor <= 0) {
                  return 'Le facteur doit être un nombre positif';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),

            // Info helper
            if (_fromUnit != null &&
                _toUnit != null &&
                _conversionFactorController.text.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.info.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppColors.info.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.info,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        '1 ${_fromUnit!.symbol} = ${_conversionFactorController.text} ${_toUnit!.symbol}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 32),

            // Boutons d'action
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isLoading ? null : () => context.pop(),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      side: const BorderSide(color: AppColors.border),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Annuler',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _saveConversion,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : Text(
                      isEditMode ? 'Modifier' : 'Créer',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}