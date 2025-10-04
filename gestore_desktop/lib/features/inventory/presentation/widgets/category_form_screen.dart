// ========================================
// lib/features/inventory/presentation/screens/category_form_screen.dart
// Formulaire de création/édition catégorie
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/categories_crud_provider.dart';
import '../providers/category_state.dart';
import '../widgets/form_field_widgets.dart';

/// Écran du formulaire catégorie
class CategoryFormScreen extends ConsumerStatefulWidget {
  final CategoryFormMode mode;
  final String? categoryId;

  const CategoryFormScreen({
    super.key,
    required this.mode,
    this.categoryId,
  });

  @override
  ConsumerState<CategoryFormScreen> createState() => _CategoryFormScreenState();
}

class _CategoryFormScreenState extends ConsumerState<CategoryFormScreen> {
  // Couleurs prédéfinies
  final List<String> _predefinedColors = [
    '#007bff', // Bleu
    '#28a745', // Vert
    '#dc3545', // Rouge
    '#ffc107', // Jaune
    '#17a2b8', // Cyan
    '#6f42c1', // Violet
    '#e83e8c', // Rose
    '#fd7e14', // Orange
    '#20c997', // Teal
    '#6c757d', // Gris
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(categoryFormProvider((widget.mode, widget.categoryId)));

    // Écouter les changements d'état
    ref.listen<CategoryFormState>(
      categoryFormProvider((widget.mode, widget.categoryId)),
          (previous, next) {
        if (next is CategoryFormSuccess) {
          _showSuccessAndNavigate(next);
        } else if (next is CategoryFormError) {
          _showError(next.message);
        }
      },
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.mode == CategoryFormMode.create
              ? 'Nouvelle catégorie'
              : 'Modifier la catégorie',
        ),
        actions: [
          if (widget.mode == CategoryFormMode.edit)
            IconButton(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(Icons.delete),
              tooltip: 'Supprimer',
            ),
        ],
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(CategoryFormState state) {
    if (state is CategoryFormLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is CategoryFormError) {
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

    if (state is CategoryFormReady) {
      return _buildForm(state);
    }

    if (state is CategoryFormSubmitting) {
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

  Widget _buildForm(CategoryFormReady state) {
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
                  label: 'Nom de la catégorie *',
                  initialValue: formData.name,
                  errorText: errors['name'],
                  onChanged: (value) => _updateField('name', value),
                  prefixIcon: Icons.category,
                  required: true,
                ),
                const SizedBox(height: 16),

                // Code *
                CustomTextField(
                  label: 'Code *',
                  initialValue: formData.code,
                  errorText: errors['code'],
                  onChanged: (value) => _updateField('code', value.toUpperCase()),
                  prefixIcon: Icons.tag,
                  required: true,
                  textCapitalization: TextCapitalization.characters,
                ),
                const SizedBox(height: 16),

                // Description
                CustomTextField(
                  label: 'Description',
                  initialValue: formData.description,
                  onChanged: (value) => _updateField('description', value),
                  prefixIcon: Icons.description,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),

                // Configuration
                Text(
                  'Configuration',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Parent (dropdown)
                _buildParentDropdown(formData),
                const SizedBox(height: 16),

                // Taux de TVA
                CustomTextField(
                  label: 'Taux de TVA (%)',
                  initialValue: formData.taxRate.toString(),
                  errorText: errors['taxRate'],
                  onChanged: (value) {
                    final rate = double.tryParse(value) ?? 0.0;
                    _updateField('taxRate', rate);
                  },
                  prefixIcon: Icons.percent,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Couleur
                _buildColorPicker(formData),
                const SizedBox(height: 16),

                // Stock minimum par défaut
                CustomTextField(
                  label: 'Stock minimum par défaut',
                  initialValue: formData.defaultMinStock.toString(),
                  errorText: errors['defaultMinStock'],
                  onChanged: (value) {
                    final stock = int.tryParse(value) ?? 5;
                    _updateField('defaultMinStock', stock);
                  },
                  prefixIcon: Icons.inventory,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 16),

                // Ordre d'affichage
                CustomTextField(
                  label: 'Ordre d\'affichage',
                  initialValue: formData.order.toString(),
                  onChanged: (value) {
                    final order = int.tryParse(value) ?? 0;
                    _updateField('order', order);
                  },
                  prefixIcon: Icons.sort,
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 24),

                // Options spéciales
                Text(
                  'Options spéciales',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Switches
                CustomSwitchTile(
                  title: 'Prescription requise',
                  subtitle: 'Articles nécessitant une prescription médicale',
                  value: formData.requiresPrescription,
                  onChanged: (value) => _updateField('requiresPrescription', value),
                ),
                CustomSwitchTile(
                  title: 'Traçabilité par lot',
                  subtitle: 'Suivi des numéros de lot',
                  value: formData.requiresLotTracking,
                  onChanged: (value) => _updateField('requiresLotTracking', value),
                ),
                CustomSwitchTile(
                  title: 'Date d\'expiration',
                  subtitle: 'Gestion des dates de péremption',
                  value: formData.requiresExpiryDate,
                  onChanged: (value) => _updateField('requiresExpiryDate', value),
                ),
                CustomSwitchTile(
                  title: 'Catégorie active',
                  subtitle: 'Visible dans l\'application',
                  value: formData.isActive,
                  onChanged: (value) => _updateField('isActive', value),
                ),

                const SizedBox(height: 100), // Espace pour le bouton flottant
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
                  onPressed: () => _showCancelConfirmation(),
                  child: const Text('Annuler'),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 2,
                child: ElevatedButton(
                  onPressed: state.isValid ? _submit : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    widget.mode == CategoryFormMode.create
                        ? 'Créer'
                        : 'Enregistrer',
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

  /// Dropdown parent
  Widget _buildParentDropdown(CategoryFormData formData) {
    final categoriesState = ref.watch(categoriesListProvider);

    return CustomDropdown<String>(
      label: 'Catégorie parent',
      value: formData.parentId,
      items: categoriesState is CategoryLoaded
          ? [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Aucune (racine)'),
        ),
        ...categoriesState.categories
            .where((cat) => cat.id != widget.categoryId) // Pas soi-même
            .map(
              (cat) => DropdownMenuItem<String>(
            value: cat.id,
            child: Text(cat.name),
          ),
        ),
      ]
          : [
        const DropdownMenuItem<String>(
          value: null,
          child: Text('Aucune (racine)'),
        ),
      ],
      onChanged: (value) => _updateField('parentId', value),
      prefixIcon: Icons.folder,
    );
  }

  /// Sélecteur de couleur
  Widget _buildColorPicker(CategoryFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Couleur',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[700],
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: _predefinedColors.map((color) {
            final isSelected = formData.color == color;
            return GestureDetector(
              onTap: () => _updateField('color', color),
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _parseColor(color),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? Colors.black : Colors.grey.shade300,
                    width: isSelected ? 3 : 1,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: Colors.white)
                    : null,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Met à jour un champ
  void _updateField(String field, dynamic value) {
    ref.read(categoryFormProvider((widget.mode, widget.categoryId)).notifier).updateField(field, value);
  }

  /// Soumet le formulaire
  void _submit() {
    ref.read(categoryFormProvider((widget.mode, widget.categoryId)).notifier).submit();
  }

  /// Affiche le succès et navigue
  void _showSuccessAndNavigate(CategoryFormSuccess state) {
    final message = widget.mode == CategoryFormMode.create
        ? 'Catégorie "${state.category.name}" créée avec succès'
        : 'Catégorie mise à jour avec succès';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );

    // Recharger la liste
    ref.read(categoriesListProvider.notifier).refresh();

    // Retour
    context.pop();
  }

  /// Affiche une erreur
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Confirmation annulation
  Future<void> _showCancelConfirmation() async {
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

    if (confirm == true && mounted) {
      context.pop();
    }
  }

  /// Confirmation suppression
  Future<void> _showDeleteConfirmation() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer ?'),
        content: const Text(
          'Êtes-vous sûr de vouloir supprimer cette catégorie ? '
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
      ref.read(categoryFormProvider((widget.mode, widget.categoryId)).notifier).delete();
    }
  }

  /// Parse une couleur hex
  Color _parseColor(String hexColor) {
    try {
      return Color(int.parse(hexColor.replaceFirst('#', '0xFF')));
    } catch (e) {
      return AppColors.primary;
    }
  }
}