// ========================================
// lib/features/inventory/presentation/screens/brand_form_screen.dart
// Formulaire de création/édition marque
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Application complète de la palette GESTORE (AppColors).
// - Refonte de l'AppBar, du fond et de la barre d'actions.
// - Amélioration de la section d'upload du logo avec un design moderne.
// - Standardisation des boutons, des boîtes de dialogue et des notifications.
// ========================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
// import 'package:file_picker/file_picker.dart'; // TODO: Ajouter au pubspec
import '../../../../shared/constants/app_colors.dart';
import '../providers/brands_crud_provider.dart';
import '../providers/brand_state.dart';
import '../widgets/form_field_widgets.dart';

/// Écran du formulaire marque
class BrandFormScreen extends ConsumerStatefulWidget {
  final BrandFormMode mode;
  final String? brandId;

  const BrandFormScreen({
    super.key,
    required this.mode,
    this.brandId,
  });

  @override
  ConsumerState<BrandFormScreen> createState() => _BrandFormScreenState();
}

class _BrandFormScreenState extends ConsumerState<BrandFormScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(brandFormProvider((widget.mode, widget.brandId)));

    // Écouter les changements d'état
    ref.listen<BrandFormState>(
      brandFormProvider((widget.mode, widget.brandId)),
          (previous, next) {
        if (next is BrandFormSuccess) {
          _showSuccessAndNavigate(next);
        } else if (next is BrandFormError) {
          _showError(next.message);
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        widget.mode == BrandFormMode.create
            ? 'Nouvelle marque'
            : 'Modifier la marque',
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
        if (widget.mode == BrandFormMode.edit)
          IconButton(
            onPressed: () => _showDeleteConfirmation(),
            icon: const Icon(Icons.delete_outline, color: AppColors.error),
            tooltip: 'Supprimer',
          ),
      ],
    );
  }

  Widget _buildBody(BrandFormState state) {
    if (state is BrandFormLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    if (state is BrandFormError) {
      return _buildErrorState(state.message);
    }
    if (state is BrandFormReady) {
      return _buildForm(state);
    }
    if (state is BrandFormSubmitting) {
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
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm(BrandFormReady state) {
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
                // Section Logo
                _buildSectionContainer(
                  title: 'Logo de la marque',
                  icon: Icons.image_outlined,
                  child: _buildLogoSection(formData),
                ),
                const SizedBox(height: 24),
                // Section Informations
                _buildSectionContainer(
                  title: 'Informations générales',
                  icon: Icons.info_outline,
                  child: _buildInfoSection(formData, errors),
                ),
                const SizedBox(height: 24),
                // Section Statut
                _buildSectionContainer(
                  title: 'Statut',
                  icon: Icons.toggle_on_outlined,
                  child:  CustomSwitchTile(
                    title: 'Marque active',
                    subtitle: formData.isActive ? 'Visible dans l\'application' : 'Masquée dans l\'application',
                    value: formData.isActive,
                    icon: formData.isActive ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                    onChanged: (value) => _updateField('isActive', value),
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

  /// Section upload logo
  Widget _buildLogoSection(BrandFormData formData) {
    return Column(
      children: [
        // Preview du logo
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: AppColors.backgroundLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.border,
              width: 1.5,
            ),
          ),
          child: _buildLogoPreview(formData),
        ),
        const SizedBox(height: 16),
        // Boutons
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FilledButton.icon(
              onPressed: _pickLogo,
              icon: const Icon(Icons.upload_file),
              label: Text(
                formData.logoPath != null || formData.logoUrl != null
                    ? 'Changer'
                    : 'Choisir un logo',
              ),
              style: _getFilledButtonStyle(),
            ),
            if (formData.logoPath != null || formData.logoUrl != null) ...[
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: () {
                  _updateField('logoUrl', null); // clear url
                  _updateField('logoPath', null); // clear path
                },
                icon: const Icon(Icons.delete_outline),
                label: const Text('Supprimer'),
                style: _getOutlinedButtonStyle(color: AppColors.error),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Formats acceptés: PNG, JPG • Max 5 Mo',
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(BrandFormData formData, Map<String, String> errors) {
    return Column(
      children: [
        // Nom *
        CustomTextField(
          label: 'Nom de la marque',
          initialValue: formData.name,
          errorText: errors['name'],
          onChanged: (value) => _updateField('name', value),
          prefixIcon: Icons.branding_watermark_outlined,
          required: true,
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
        const SizedBox(height: 16),
        // Site web
        CustomTextField(
          label: 'Site web',
          initialValue: formData.website,
          errorText: errors['website'],
          onChanged: (value) => _updateField('website', value),
          prefixIcon: Icons.language_outlined,
          keyboardType: TextInputType.url,
          helperText: 'Ex: https://example.com',
        ),
      ],
    );
  }

  /// Preview du logo
  Widget _buildLogoPreview(BrandFormData formData) {
    // Logo local sélectionné
    if (formData.logoPath != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.file(
          File(formData.logoPath!),
          fit: BoxFit.contain,
        ),
      );
    }
    // Logo existant (URL)
    if (formData.logoUrl != null && formData.logoUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: Image.network(
          formData.logoUrl!,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return const Center(child: CircularProgressIndicator(color: AppColors.primary));
          },
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }
    // Placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return const Icon(
      Icons.branding_watermark_outlined,
      size: 64,
      color: AppColors.border,
    );
  }

  Widget _buildBottomBar(BrandFormReady state) {
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
              onPressed: () => _showCancelConfirmation(),
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
                widget.mode == BrandFormMode.create
                    ? 'Créer la marque'
                    : 'Enregistrer',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STYLES ====================
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

  /// Sélectionner un logo
  Future<void> _pickLogo() async {
    //  TODO: Implémenter avec file_picker
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   allowMultiple: false,
    // );
    // if (result != null && result.files.single.path != null) {
    //   _updateField('logoPath', result.files.single.path);
    // }
    // Placeholder: Afficher un message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Upload de logo à implémenter avec file_picker'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.info,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  /// Met à jour un champ
  void _updateField(String field, dynamic value) {
    ref.read(brandFormProvider((widget.mode, widget.brandId)).notifier).updateField(field, value);
  }

  /// Soumet le formulaire
  void _submit() {
    ref.read(brandFormProvider((widget.mode, widget.brandId)).notifier).submit();
  }

  /// Affiche le succès et navigue
  void _showSuccessAndNavigate(BrandFormSuccess state) {
    final message = widget.mode == BrandFormMode.create
        ? 'Marque "${state.brand.name}" créée avec succès'
        : 'Marque mise à jour avec succès';
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
    ref.read(brandsListProvider.notifier).refresh();
    // Retour
    context.pop();
  }

  /// Affiche une erreur
  void _showError(String message) {
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
          Center(child: child),
        ],
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
            style: _getFilledButtonStyle(color: AppColors.primary),
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
        title: const Text('Supprimer la marque ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Cette action est irréversible et supprimera définitivement la marque.',
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
      ref.read(brandFormProvider((widget.mode, widget.brandId)).notifier).delete();
    }
  }
}