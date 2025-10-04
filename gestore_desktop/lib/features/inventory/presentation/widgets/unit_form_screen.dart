// ========================================
// lib/features/inventory/presentation/screens/unit_form_screen.dart
// Formulaire de création/édition unité de mesure
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/units_crud_provider.dart';
import '../providers/unit_state.dart';
import '../widgets/form_field_widgets.dart';

/// Écran du formulaire unité de mesure
class UnitFormScreen extends ConsumerWidget {
  final UnitFormMode mode;
  final String? unitId;

  const UnitFormScreen({
    super.key,
    required this.mode,
    this.unitId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(unitFormProvider((mode, unitId)));

    // Écouter les changements d'état
    ref.listen<UnitFormState>(
      unitFormProvider((mode, unitId)),
          (previous, next) {
        if (next is UnitFormSuccess) {
          _showSuccessAndNavigate(context, ref, next);
        } else if (next is UnitFormError) {
          _showError(context, next.message);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          mode == UnitFormMode.create
              ? 'Nouvelle unité de mesure'
              : 'Modifier l\'unité',
        ),
        actions: [
          if (mode == UnitFormMode.edit)
            IconButton(
              onPressed: () => _showDeleteConfirmation(context, ref),
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer',
            ),
        ],
      ),
      body: _buildBody(context, ref, state),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref, UnitFormState state) {
    if (state is UnitFormLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is UnitFormError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red[300]),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: TextStyle(color: Colors.grey[600]),
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

    if (state is UnitFormReady) {
      return _buildForm(context, ref, state);
    }

    if (state is UnitFormSubmitting) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Enregistrement en cours...'),
          ],
        ),
      );
    }

    return const SizedBox();
  }

  Widget _buildForm(BuildContext context, WidgetRef ref, UnitFormReady state) {
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
                // Info banner
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.blue[200]!,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Les unités sont utilisées pour quantifier les articles (ex: kg, L, pcs)',
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.blue[900],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Informations de base
                Text(
                  'Informations générales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Nom *
                CustomTextField(
                  label: 'Nom de l\'unité *',
                  initialValue: formData.name,
                  errorText: errors['name'],
                  onChanged: (value) => _updateField(ref, 'name', value),
                  prefixIcon: Icons.straighten,
                  required: true,
                  //placeholder: 'Kilogramme, Litre, Pièce...',
                ),
                const SizedBox(height: 16),

                // Symbole *
                CustomTextField(
                  label: 'Symbole *',
                  initialValue: formData.symbol,
                  errorText: errors['symbol'],
                  onChanged: (value) => _updateField(ref, 'symbol', value),
                  prefixIcon: Icons.tag,
                  required: true,
                  //placeholder: 'kg, L, pcs...',
                  textCapitalization: TextCapitalization.none,
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  label: 'Description',
                  initialValue: formData.description,
                  onChanged: (value) => _updateField(ref, 'description', value),
                  prefixIcon: Icons.description,
                  maxLines: 2,
                  //placeholder: 'Description optionnelle de l\'unité',
                ),
                const SizedBox(height: 24),

                // Options
                Text(
                  'Options',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Décimale autorisée
                CustomSwitchTile(
                  title: 'Quantités décimales',
                  subtitle: 'Autorise les quantités avec virgule (ex: 1.5 kg)',
                  value: formData.isDecimal,
                  onChanged: (value) => _updateField(ref, 'isDecimal', value),
                ),

                // Statut actif
                CustomSwitchTile(
                  title: 'Unité active',
                  subtitle: 'Visible dans l\'application',
                  value: formData.isActive,
                  onChanged: (value) => _updateField(ref, 'isActive', value),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),

        // Barre de boutons
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showCancelConfirmation(context),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.isValid ? () => _submit(ref) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    mode == UnitFormMode.create ? 'Créer' : 'Enregistrer',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Met à jour un champ
  void _updateField(WidgetRef ref, String field, dynamic value) {
    ref.read(unitFormProvider((mode, unitId)).notifier).updateField(field, value);
  }

  /// Soumet le formulaire
  void _submit(WidgetRef ref) {
    ref.read(unitFormProvider((mode, unitId)).notifier).submit();
  }

  /// Affiche le succès et navigue
  void _showSuccessAndNavigate(BuildContext context, WidgetRef ref, UnitFormSuccess state) {
    final message = mode == UnitFormMode.create
        ? 'Unité "${state.unit.name}" créée avec succès'
        : 'Unité mise à jour avec succès';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    // Recharger la liste
    ref.read(unitsListProvider.notifier).refresh();

    // Retour
    context.pop();
  }

  /// Affiche une erreur
  void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Confirmation annulation
  Future<void> _showCancelConfirmation(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Annuler ?'),
        content: const Text('Les modifications non enregistrées seront perdues.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Continuer'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Annuler'),
          ),
        ],
      ),
    );

    if (confirm == true && context.mounted) {
      context.pop();
    }
  }

  /// Confirmation suppression
  Future<void> _showDeleteConfirmation(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette unité ? '
              'Cette action est irréversible.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      ref.read(unitFormProvider((mode, unitId)).notifier).delete();
    }
  }
}