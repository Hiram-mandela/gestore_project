// ========================================
// lib/features/inventory/presentation/screens/category_form_screen.dart
//
// MODIFICATIONS APPORTÉES (Refonte Visuelle GESTORE) :
// - Application de la palette GESTORE (AppColors) pour les fonds, textes, icônes, et éléments de formulaire.
// - Standardisation des styles de boutons (Filled, Outlined) et des boîtes de dialogue (AlertDialog).
// - Refonte de la barre d'actions inférieure et de l'AppBar pour une apparence plus propre et intégrée.
// - NOTE : La correction de la visibilité du texte dans les champs et les switchs sera faite dans le fichier form_field_widgets.dart.
// ========================================

import 'package:flutter/material.dart';
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
  // --- CONSTANTES DE STYLE ---
  static const _cardBorderRadius = BorderRadius.all(Radius.circular(12));
  static const _pagePadding = EdgeInsets.all(16.0);
  static const _formPadding = EdgeInsets.symmetric(horizontal: 16, vertical: 24);
  static const _buttonPadding =
  EdgeInsets.symmetric(horizontal: 24, vertical: 16);

  // Couleurs prédéfinies basées sur la palette GESTORE
  final List<String> _predefinedColors = [
    '#1E3A8A', // primary
    '#10B981', // success
    '#F59E0B', // warning
    '#EF4444', // error
    '#7C3AED', // secondary
    '#06B6D4', // accent
    '#3B82F6', // info
    '#64748B', // settings (grey)
    '#8B5CF6', // inventory
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
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          widget.mode == CategoryFormMode.create
              ? 'Nouvelle catégorie'
              : 'Modifier la catégorie',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textPrimary,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: AppColors.border,
            height: 1.0,
          ),
        ),
        actions: [
          if (widget.mode == CategoryFormMode.edit)
            IconButton(
              onPressed: () => _showDeleteConfirmation(),
              icon: const Icon(Icons.delete_outline, color: AppColors.error),
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
        child: Padding(
          padding: _pagePadding,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline,
                  size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              const Text(
                'Erreur',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.message,
                style: const TextStyle(color: AppColors.textSecondary),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Retour'),
                style: OutlinedButton.styleFrom(
                    padding: _buttonPadding,
                    foregroundColor: AppColors.textSecondary,
                    side: const BorderSide(color: AppColors.border),
                    shape: const RoundedRectangleBorder(
                        borderRadius: _cardBorderRadius)),
              ),
            ],
          ),
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
            Text(
              'Enregistrement en cours...',
              style: TextStyle(color: AppColors.textSecondary),
            ),
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
            padding: _formPadding,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Informations de base
                _buildSectionTitle('Informations générales'),
                const SizedBox(height: 16),
                // Nom *
                CustomTextField(
                  label: 'Nom de la catégorie',
                  initialValue: formData.name,
                  errorText: errors['name'],
                  onChanged: (value) => _updateField('name', value),
                  prefixIcon: Icons.category_outlined,
                  required: true,
                ),
                const SizedBox(height: 16),
                // Code *
                CustomTextField(
                  label: 'Code',
                  initialValue: formData.code,
                  errorText: errors['code'],
                  onChanged: (value) =>
                      _updateField('code', value.toUpperCase()),
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
                  prefixIcon: Icons.description_outlined,
                  maxLines: 3,
                ),
                const SizedBox(height: 24),
                // Configuration
                _buildSectionTitle('Configuration'),
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
                const SizedBox(height: 24),
                // Couleur
                _buildColorPicker(formData),
                const SizedBox(height: 24),
                // Options spéciales
                _buildSectionTitle('Options spéciales'),
                const SizedBox(height: 8),
                // Switches
                CustomSwitchTile(
                  title: 'Prescription requise',
                  subtitle: 'Articles nécessitant une prescription médicale',
                  value: formData.requiresPrescription,
                  onChanged: (value) =>
                      _updateField('requiresPrescription', value),
                ),
                CustomSwitchTile(
                  title: 'Traçabilité par lot',
                  subtitle: 'Suivi des numéros de lot',
                  value: formData.requiresLotTracking,
                  onChanged: (value) =>
                      _updateField('requiresLotTracking', value),
                ),
                CustomSwitchTile(
                  title: 'Date d\'expiration',
                  subtitle: 'Gestion des dates de péremption',
                  value: formData.requiresExpiryDate,
                  onChanged: (value) =>
                      _updateField('requiresExpiryDate', value),
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
        _buildBottomActionBar(state),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textPrimary,
      ),
    );
  }

  Widget _buildBottomActionBar(CategoryFormReady state) {
    return Container(
      padding: _pagePadding,
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        border: const Border(
          top: BorderSide(color: AppColors.border),
        ),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _showCancelConfirmation(),
              style: OutlinedButton.styleFrom(
                padding: _buttonPadding,
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                shape: const RoundedRectangleBorder(
                  borderRadius: _cardBorderRadius,
                ),
              ),
              child: const Text('Annuler'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: FilledButton(
              onPressed: state.isValid ? _submit : null,
              style: FilledButton.styleFrom(
                padding: _buttonPadding,
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.surfaceLight,
                shape: const RoundedRectangleBorder(
                  borderRadius: _cardBorderRadius,
                ),
                disabledBackgroundColor: AppColors.border,
              ),
              child: Text(
                widget.mode == CategoryFormMode.create
                    ? 'Créer la catégorie'
                    : 'Enregistrer',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
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
          child: Text('Aucune (racine)',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              )),
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
          child: Text('Aucune (racine)',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: AppColors.textSecondary,
              )),
        ),
      ],
      onChanged: (value) => _updateField('parentId', value),
      prefixIcon: Icons.folder_open_outlined,
    );
  }

  /// Sélecteur de couleur
  Widget _buildColorPicker(CategoryFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Couleur d\'identification',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
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
                  borderRadius: const BorderRadius.all(Radius.circular(22)),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.border,
                    width: isSelected ? 3 : 1.5,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, color: AppColors.surfaceLight)
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
    ref
        .read(categoryFormProvider((widget.mode, widget.categoryId)).notifier)
        .updateField(field, value);
  }

  /// Soumet le formulaire
  void _submit() {
    ref.read(categoryFormProvider((widget.mode, widget.categoryId)).notifier).submit();
  }

  /// Affiche le succès et navigue
  void _showSuccessAndNavigate(CategoryFormSuccess state) {
    if (!mounted) return;
    final message = widget.mode == CategoryFormMode.create
        ? 'Catégorie "${state.category.name}" créée avec succès'
        : 'Catégorie mise à jour avec succès';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
    // Recharger la liste
    ref.read(categoriesListProvider.notifier).refresh();
    // Retour
    context.pop();
  }

  /// Affiche une erreur
  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  /// Boîte de dialogue stylisée GESTORE
  Future<bool?> _showGestoreDialog({
    required String title,
    required String content,
    required String confirmText,
    bool isDestructive = false,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: const RoundedRectangleBorder(borderRadius: _cardBorderRadius),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(content, style: const TextStyle(color: AppColors.textSecondary)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: isDestructive ? AppColors.error : AppColors.primary,
              foregroundColor: AppColors.surfaceLight,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  /// Confirmation annulation
  Future<void> _showCancelConfirmation() async {
    final confirm = await _showGestoreDialog(
      title: 'Annuler les modifications ?',
      content: 'Les changements non enregistrés seront perdus.',
      confirmText: 'Quitter',
    );
    if (confirm == true && mounted) {
      context.pop();
    }
  }

  /// Confirmation suppression
  Future<void> _showDeleteConfirmation() async {
    final confirm = await _showGestoreDialog(
      title: 'Supprimer la catégorie ?',
      content: 'Cette action est irréversible et supprimera la catégorie définitivement.',
      confirmText: 'Supprimer',
      isDestructive: true,
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