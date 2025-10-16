// ========================================
// lib/features/inventory/presentation/widgets/article_form_step5.dart
// ÉTAPE 5 : Métadonnées Avancées avec ImageGalleryWidget
// VERSION 3.0 - AMÉLIORATIONS COMPLÈTES
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/constants/app_colors.dart';
import '../../../../shared/widgets/image_gallery_widget.dart';
import '../../../../shared/widgets/barcode_input_field.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep5 extends ConsumerStatefulWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep5({
    super.key,
    required this.formData,
    required this.errors,
    required this.onFieldChanged,
  });

  @override
  ConsumerState<ArticleFormStep5> createState() => _ArticleFormStep5State();
}

class _ArticleFormStep5State extends ConsumerState<ArticleFormStep5> {
  // Liste temporaire des codes-barres pour gestion locale
  List<AdditionalBarcodeData> _tempBarcodes = [];
  final TextEditingController _newBarcodeController = TextEditingController();
  String _selectedBarcodeType = 'ean13';

  @override
  void initState() {
    super.initState();
    _tempBarcodes = List.from(widget.formData.additionalBarcodes);
  }

  @override
  void dispose() {
    _newBarcodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 24),

        // Section 1 : Images
        _buildSectionContainer(
          context: context,
          title: 'Images de l\'article',
          icon: Icons.photo_library_outlined,
          child: _buildImagesSection(),
        ),
        const SizedBox(height: 24),

        // Section 2 : Codes-barres additionnels
        _buildSectionContainer(
          context: context,
          title: 'Codes-barres additionnels',
          icon: Icons.qr_code_2_outlined,
          child: _buildAdditionalBarcodesSection(),
        ),
        const SizedBox(height: 24),

        // Section 3 : Dimensions physiques
        _buildSectionContainer(
          context: context,
          title: 'Dimensions et poids',
          icon: Icons.straighten_outlined,
          child: _buildDimensionsSection(),
        ),
        const SizedBox(height: 24),

        // Section 4 : Variantes et statut
        _buildSectionContainer(
          context: context,
          title: 'Variantes et statut',
          icon: Icons.tune_outlined,
          child: _buildVariantsSection(),
        ),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.tune_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Métadonnées avancées',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Images, codes-barres additionnels, dimensions et variantes.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== CONTAINER DE SECTION ====================
  Widget _buildSectionContainer({
    required BuildContext context,
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
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
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  // ==================== SECTION IMAGES ==================== 
  Widget _buildImagesSection() {
    // Convertir ArticleImageData en GalleryImage pour ImageGalleryWidget
    final galleryImages = widget.formData.images
        .map((img) => GalleryImage(
      path: img.imagePath.startsWith('http') ? null : img.imagePath,
      url: img.imagePath.startsWith('http') ? img.imagePath : null,
      isPrimary: img.isPrimary,
    ))
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Ajoutez jusqu\'à 5 images. La première sera l\'image principale. Les images seront automatiquement compressées avant l\'envoi.',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // ImageGalleryWidget - Widget réutilisable existant ✨
        ImageGalleryWidget(
          initialImages: galleryImages,
          onImagesChanged: (updatedImages) {
            // Convertir GalleryImage en ArticleImageData
            final articleImages = updatedImages
                .asMap()
                .entries
                .map((entry) => ArticleImageData(
              imagePath: entry.value.path ?? entry.value.url ?? '',
              caption: '',
              altText: '',
              order: entry.key,
              isPrimary: entry.value.isPrimary,
            ))
                .toList();

            widget.onFieldChanged('images', articleImages);
          },
          maxImages: 5,
          thumbnailSize: 120,
          maxSizeMB: 5.0,
          allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
        ),
      ],
    );
  }

  // ==================== SECTION CODES-BARRES ADDITIONNELS ====================
  Widget _buildAdditionalBarcodesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.info.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: AppColors.info, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Codes-barres supplémentaires pour cet article (différents formats ou emballages).',
                  style: TextStyle(
                    color: AppColors.info,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Formulaire d'ajout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              flex: 3,
              child: BarcodeInputField(
                label: 'Nouveau code-barres',
                onChanged: (value) {
                  _newBarcodeController.text = value;
                },
                helperText: 'Scanner ou saisir',
                prefixIcon: Icons.qr_code_scanner,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: CustomDropdown<String>(
                label: 'Type',
                value: _selectedBarcodeType,
                items: const [
                  DropdownMenuItem(value: 'ean13', child: Text('EAN-13')),
                  DropdownMenuItem(value: 'ean8', child: Text('EAN-8')),
                  DropdownMenuItem(value: 'upc', child: Text('UPC')),
                  DropdownMenuItem(value: 'code128', child: Text('Code 128')),
                  DropdownMenuItem(value: 'qr', child: Text('QR Code')),
                  DropdownMenuItem(value: 'other', child: Text('Autre')),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedBarcodeType = value ?? 'ean13';
                  });
                },
                prefixIcon: Icons.category,
              ),
            ),
            const SizedBox(width: 12),
            Container(
              margin: const EdgeInsets.only(top: 24),
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: _addBarcode,
                  borderRadius: BorderRadius.circular(12),
                  child: const Icon(Icons.add, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Liste des codes-barres
        if (_tempBarcodes.isNotEmpty) ...[
          const Divider(),
          const SizedBox(height: 12),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _tempBarcodes.length,
            separatorBuilder: (context, index) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final barcode = _tempBarcodes[index];
              return _buildBarcodeCard(barcode, index);
            },
          ),
        ] else
          Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  Icon(Icons.qr_code_2_outlined, size: 48, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text(
                    'Aucun code-barres additionnel',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildBarcodeCard(AdditionalBarcodeData barcode, int index) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.qr_code_2,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  barcode.barcode,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  barcode.barcodeType.toUpperCase(),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => _removeBarcode(index),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            iconSize: 20,
          ),
        ],
      ),
    );
  }

  void _addBarcode() {
    if (_newBarcodeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('⚠️ Veuillez saisir un code-barres'),
          backgroundColor: AppColors.warning,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _tempBarcodes.add(AdditionalBarcodeData(
        barcode: _newBarcodeController.text.trim(),
        barcodeType: _selectedBarcodeType,
        isPrimary: false, // ✅ Corriger: isPrimary au lieu de isActive
      ));
      _newBarcodeController.clear();
    });

    widget.onFieldChanged('additionalBarcodes', _tempBarcodes);
  }

  void _removeBarcode(int index) {
    setState(() {
      _tempBarcodes.removeAt(index);
    });
    widget.onFieldChanged('additionalBarcodes', _tempBarcodes);
  }

  // ==================== SECTION DIMENSIONS ====================
  Widget _buildDimensionsSection() {
    return Column(
      children: [
        // Poids
        CustomTextField(
          label: 'Poids',
          initialValue: widget.formData.weight > 0 ? widget.formData.weight.toString() : '',
          errorText: widget.errors['weight'],
          onChanged: (value) {
            final weight = double.tryParse(value) ?? 0.0;
            widget.onFieldChanged('weight', weight);
          },
          prefixIcon: Icons.scale_outlined,
          suffixText: 'kg',
          keyboardType: TextInputType.numberWithOptions(decimal: true),
          helperText: 'Poids de l\'article en kilogrammes',
        ),
        const SizedBox(height: 16),

        // Dimensions (Longueur, Largeur, Hauteur)
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                label: 'Longueur',
                initialValue: widget.formData.length > 0 ? widget.formData.length.toString() : '',
                errorText: widget.errors['length'],
                onChanged: (value) {
                  final length = double.tryParse(value) ?? 0.0;
                  widget.onFieldChanged('length', length);
                },
                suffixText: 'cm',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Largeur',
                initialValue: widget.formData.width > 0 ? widget.formData.width.toString() : '',
                errorText: widget.errors['width'],
                onChanged: (value) {
                  final width = double.tryParse(value) ?? 0.0;
                  widget.onFieldChanged('width', width);
                },
                suffixText: 'cm',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: CustomTextField(
                label: 'Hauteur',
                initialValue: widget.formData.height > 0 ? widget.formData.height.toString() : '',
                errorText: widget.errors['height'],
                onChanged: (value) {
                  final height = double.tryParse(value) ?? 0.0;
                  widget.onFieldChanged('height', height);
                },
                suffixText: 'cm',
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ==================== SECTION VARIANTES ====================
  Widget _buildVariantsSection() {
    return Column(
      children: [
        // Attributs de variante
        CustomTextField(
          label: 'Attributs de variante',
          initialValue: widget.formData.variantAttributes,
          errorText: widget.errors['variantAttributes'],
          onChanged: (value) => widget.onFieldChanged('variantAttributes', value),
          prefixIcon: Icons.tune_outlined,
          helperText: 'Ex: Couleur=Rouge, Taille=L (format JSON pour variantes)',
          maxLines: 2,
        ),
        const SizedBox(height: 16),

        // Statut actif
        CustomSwitchTile(
          title: 'Article actif',
          subtitle: 'L\'article est visible et disponible à la vente',
          value: widget.formData.isActive,
          onChanged: (value) => widget.onFieldChanged('isActive', value),
          icon: Icons.toggle_on_outlined,
        ),
      ],
    );
  }
}