// ========================================
// lib/features/inventory/presentation/screens/unit_form_screen.dart
// Formulaire de création/édition unité de mesure
// VERSION 2.2 - Correction des erreurs et finalisation GESTORE
// --
// Changements :
// - Conversion en ConsumerStatefulWidget pour corriger l'erreur 'Undefined name ref'.
// - Remplacement de l'icône invalide 'decimal_increase' par 'calculate_outlined'.
// - Remplacement des appels dépréciés par des équivalents corrects.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/units_crud_provider.dart';
import '../providers/unit_state.dart';
import '../widgets/form_field_widgets.dart';

/// Écran du formulaire unité de mesure
class UnitFormScreen extends ConsumerStatefulWidget {
  final UnitFormMode mode;
  final String? unitId;

  const UnitFormScreen({
    super.key,
    required this.mode,
    this.unitId,
  });

  @override
  ConsumerState<UnitFormScreen> createState() => _UnitFormScreenState();
}

class _UnitFormScreenState extends ConsumerState<UnitFormScreen> {
  @override
  void initState() {
    super.initState();
    // Écouter les changements d'état pour la navigation et les snackbars
    ref.listenManual<UnitFormState>(
      unitFormProvider((widget.mode, widget.unitId)),
          (previous, next) {
        if (next is UnitFormSuccess) {
          _showSuccessAndNavigate(next);
        } else if (next is UnitFormError) {
          _showError(next.message);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(unitFormProvider((widget.mode, widget.unitId)));

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.mode == UnitFormMode.create
            ? 'Nouvelle unité de mesure'
            : 'Modifier l\'unité',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      surfaceTintColor: Colors.transparent,
      actions: [
        if (widget.mode == UnitFormMode.edit)
          IconButton(
            onPressed: _showDeleteConfirmation,
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  Widget _buildBody(UnitFormState state) {
    if (state is UnitFormLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is UnitFormError) {
      return _buildErrorState(state.message);
    }
    if (state is UnitFormReady) {
      return _buildForm(state);
    }
    if (state is UnitFormSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text('Enregistrement en cours...', style: TextStyle(color: AppColors.textSecondary)),
          ],
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildForm(UnitFormReady state) {
    final formData = state.formData;
    final errors = state.errors;

    return Column(
      children: [
        // Corps du formulaire
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoBanner(),
                const SizedBox(height: 24),
                // Informations de base
                _buildSectionContainer(
                    title: 'Informations générales',
                    icon: Icons.info_outline,
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Nom de l\'unité',
                          initialValue: formData.name,
                          errorText: errors['name'],
                          onChanged: (value) => _updateField('name', value),
                          prefixIcon: Icons.straighten_outlined,
                          required: true,
                          helperText: 'Ex: Kilogramme, Litre, Pièce...',
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Symbole',
                          initialValue: formData.symbol,
                          errorText: errors['symbol'],
                          onChanged: (value) => _updateField('symbol', value),
                          prefixIcon: Icons.tag,
                          required: true,
                          helperText: 'Ex: kg, L, pcs...',
                          textCapitalization: TextCapitalization.none,
                        ),
                        const SizedBox(height: 16),
                        CustomTextField(
                          label: 'Description',
                          initialValue: formData.description,
                          onChanged: (value) => _updateField('description', value),
                          prefixIcon: Icons.description_outlined,
                          maxLines: 2,
                          helperText: 'Description optionnelle de l\'unité',
                        ),
                      ],
                    )
                ),
                const SizedBox(height: 24),
                // Options
                _buildSectionContainer(
                  title: 'Options',
                  icon: Icons.tune_outlined,
                  child: Column(
                    children: [
                      CustomSwitchTile(
                        title: 'Quantités décimales',
                        subtitle: 'Autorise les quantités avec virgule (ex: 1.5 kg)',
                        value: formData.isDecimal,
                        icon: Icons.calculate_outlined, // ✨ CORRECTION
                        onChanged: (value) => _updateField('isDecimal', value),
                      ),
                      const SizedBox(height: 12),
                      CustomSwitchTile(
                        title: 'Unité active',
                        subtitle: 'Visible et utilisable dans l\'application',
                        value: formData.isActive,
                        icon: formData.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                        onChanged: (value) => _updateField('isActive', value),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
        // Barre de boutons
        _buildBottomBar(state),
      ],
    );
  }

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.info.withValues(alpha: 0.1), // ✨ CORRECTION
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.info.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline_rounded, color: AppColors.info, size: 20),
          const SizedBox(width: 12),
          const Expanded(
            child: Text(
              'Les unités sont utilisées pour quantifier les articles (ex: kg, L, pcs)',
              style: TextStyle(color: AppColors.info, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(UnitFormReady state) {
    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _showCancelConfirmation,
              style: _getOutlinedButtonStyle(),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: state.isValid ? _submit : null,
              style: _getFilledButtonStyle(),
              child: Text(
                widget.mode == UnitFormMode.create ? 'Créer l\'unité' : 'Enregistrer',
              ),
            ),
          ),
        ],
      ),
    );
  }

  ButtonStyle _getFilledButtonStyle({Color? color}) {
    return FilledButton.styleFrom(
      backgroundColor: color ?? AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

  ButtonStyle _getOutlinedButtonStyle({Color? color}) {
    return OutlinedButton.styleFrom(
      foregroundColor: color ?? AppColors.textSecondary,
      side: BorderSide(color: color ?? AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
    );
  }

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
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour'),
              style: _getFilledButtonStyle(),
            ),
          ],
        ),
      ),
    );
  }

  /// Met à jour un champ
  void _updateField(String field, dynamic value) {
    ref.read(unitFormProvider((widget.mode, widget.unitId)).notifier).updateField(field, value);
  }

  /// Soumet le formulaire
  void _submit() {
    ref.read(unitFormProvider((widget.mode, widget.unitId)).notifier).submit();
  }

  /// Affiche le succès et navigue
  void _showSuccessAndNavigate(UnitFormSuccess state) {
    final message = widget.mode == UnitFormMode.create
        ? 'Unité "${state.unit.name}" créée avec succès'
        : 'Unité mise à jour avec succès';
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.check_circle, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
    // Recharger la liste
    ref.read(unitsListProvider.notifier).refresh();
    // Retour
    context.pop();
  }

  /// Affiche une erreur
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(children: [const Icon(Icons.error, color: Colors.white), const SizedBox(width: 12), Expanded(child: Text(message))]),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Confirmation annulation
  Future<void> _showCancelConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Annuler les modifications ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text('Les modifications non enregistrées seront perdues.', style: TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Rester', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: _getFilledButtonStyle(),
            child: const Text('Confirmer'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      context.pop();
    }
  }

  /// Confirmation suppression
  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Supprimer l\'unité ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Cette action est irréversible. L\'unité ne pourra plus être utilisée pour de nouveaux articles.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: _getFilledButtonStyle(color: AppColors.error),
            child: const Text('Oui, supprimer'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      ref.read(unitFormProvider((widget.mode, widget.unitId)).notifier).delete();
    }
  }
}