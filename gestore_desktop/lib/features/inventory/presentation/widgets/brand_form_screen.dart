// ========================================
// lib/features/inventory/presentation/screens/brand_form_screen.dart
// Formulaire de création/édition marque
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
      appBar: AppBar(
        title: Text(
          widget.mode == BrandFormMode.create
              ? 'Nouvelle marque'
              : 'Modifier la marque',
        ),
        actions: [
          if (widget.mode == BrandFormMode.edit)
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

  Widget _buildBody(BrandFormState state) {
    if (state is BrandFormLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is BrandFormError) {
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

    if (state is BrandFormReady) {
      return _buildForm(state);
    }

    if (state is BrandFormSubmitting) {
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
                // Upload logo
                _buildLogoSection(formData),
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
                  label: 'Nom de la marque *',
                  initialValue: formData.name,
                  errorText: errors['name'],
                  onChanged: (value) => _updateField('name', value),
                  prefixIcon: Icons.branding_watermark,
                  required: true,
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
                const SizedBox(height: 16),

                // Site web
                CustomTextField(
                  label: 'Site web',
                  initialValue: formData.website,
                  errorText: errors['website'],
                  onChanged: (value) => _updateField('website', value),
                  prefixIcon: Icons.language,
                  keyboardType: TextInputType.url,
                  //placeholder: 'https://example.com',
                ),
                const SizedBox(height: 24),

                // Statut
                CustomSwitchTile(
                  title: 'Marque active',
                  subtitle: 'Visible dans l\'application',
                  value: formData.isActive,
                  onChanged: (value) => _updateField('isActive', value),
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
                    widget.mode == BrandFormMode.create
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

  /// Section upload logo
  Widget _buildLogoSection(BrandFormData formData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Logo de la marque',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        Center(
          child: Column(
            children: [
              // Preview du logo
              Container(
                width: 150,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.grey[300]!,
                    width: 2,
                  ),
                ),
                child: _buildLogoPreview(formData),
              ),

              const SizedBox(height: 16),

              // Boutons
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickLogo,
                    icon: const Icon(Icons.upload_file),
                    label: Text(
                      formData.logoPath != null || formData.logoUrl != null
                          ? 'Changer'
                          : 'Choisir un logo',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                    ),
                  ),
                  if (formData.logoPath != null || formData.logoUrl != null) ...[
                    const SizedBox(width: 12),
                    OutlinedButton.icon(
                      onPressed: () => _updateField('logoPath', null),
                      icon: const Icon(Icons.delete_outline),
                      label: const Text('Supprimer'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 8),
              Text(
                'Formats acceptés: PNG, JPG • Max 5 Mo',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
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
            return const Center(child: CircularProgressIndicator());
          },
          errorBuilder: (_, __, ___) => _buildPlaceholder(),
        ),
      );
    }

    // Placeholder
    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Icon(
      Icons.branding_watermark,
      size: 64,
      color: Colors.grey[400],
    );
  }

  /// Sélectionner un logo
  Future<void> _pickLogo() async {
    // TODO: Implémenter avec file_picker
    // final result = await FilePicker.platform.pickFiles(
    //   type: FileType.image,
    //   allowMultiple: false,
    // );
    //
    // if (result != null && result.files.single.path != null) {
    //   _updateField('logoPath', result.files.single.path);
    // }

    // Placeholder: Afficher un message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Upload de logo à implémenter avec file_picker'),
        duration: Duration(seconds: 2),
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
        content: Text(message),
        backgroundColor: Colors.green,
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
          'Êtes-vous sûr de vouloir supprimer cette marque ? '
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
      ref.read(brandFormProvider((widget.mode, widget.brandId)).notifier).delete();
    }
  }
}