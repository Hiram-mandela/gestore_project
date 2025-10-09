// ========================================
// lib/features/inventory/presentation/widgets/advanced_form_widgets.dart
// Widgets avancés pour le formulaire article
// Images multiples, Codes-barres additionnels, Variantes
// VERSION COMPLÈTE
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_state.dart';

// ==================== MULTI-IMAGES MANAGER ====================

class MultiImageManager extends StatelessWidget {
  final List<ArticleImageData> images;
  final Function(List<ArticleImageData>) onImagesChanged;
  final bool enabled;

  const MultiImageManager({
    super.key,
    required this.images,
    required this.onImagesChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête avec bouton d'ajout
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.photo_library,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Images (${images.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: enabled ? () => _addImage(context) : null,
              icon: const Icon(Icons.add_photo_alternate, size: 20),
              label: const Text('Ajouter'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste des images
        if (images.isEmpty)
          _buildEmptyState(context)
        else
          _buildImagesList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucune image',
              style: TextStyle(color: Colors.grey[600], fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajoutez des images pour illustrer votre article',
              style: TextStyle(color: Colors.grey[500], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList(BuildContext context) {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: images.length,
      onReorder: enabled ? (oldIndex, newIndex) => _reorderImages(oldIndex, newIndex) : (_, __) {},
      itemBuilder: (context, index) {
        final image = images[index];
        return _buildImageCard(context, image, index);
      },
    );
  }

  Widget _buildImageCard(BuildContext context, ArticleImageData image, int index) {
    return Card(
      key: ValueKey(image.imagePath + index.toString()),
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Handle de drag
            if (enabled)
              Icon(Icons.drag_handle, color: Colors.grey[400]),
            const SizedBox(width: 12),

            // Prévisualisation
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Container(
                width: 80,
                height: 80,
                color: Colors.grey[200],
                child: image.imagePath.startsWith('http')
                    ? Image.network(
                  image.imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.broken_image,
                    color: Colors.grey[400],
                  ),
                )
                    : Icon(Icons.image, color: Colors.grey[400], size: 40),
              ),
            ),
            const SizedBox(width: 12),

            // Informations
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          image.caption.isEmpty ? 'Image ${index + 1}' : image.caption,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (image.isPrimary)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRINCIPALE',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                    ],
                  ),
                  if (image.altText.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      image.altText,
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ],
              ),
            ),

            // Actions
            if (enabled) ...[
              IconButton(
                icon: Icon(
                  image.isPrimary ? Icons.star : Icons.star_border,
                  color: image.isPrimary ? Colors.amber : Colors.grey,
                ),
                onPressed: () => _setPrimaryImage(index),
                tooltip: 'Définir comme principale',
              ),
              IconButton(
                icon: const Icon(Icons.edit, size: 20),
                onPressed: () => _editImage(context, index),
                tooltip: 'Modifier',
              ),
              IconButton(
                icon: Icon(Icons.delete, size: 20, color: AppColors.error),
                onPressed: () => _deleteImage(index),
                tooltip: 'Supprimer',
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _addImage(BuildContext context) {
    // TODO: Intégrer file_picker
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Ajouter une image'),
        content: const Text(
          'La fonctionnalité d\'upload sera disponible après intégration du package file_picker.\n\n'
              'Pour l\'instant, vous pouvez tester avec une URL d\'image.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              _addTestImage();
            },
            child: const Text('Ajouter une image test'),
          ),
        ],
      ),
    );
  }

  void _addTestImage() {
    final newImage = ArticleImageData(
      imagePath: 'https://via.placeholder.com/400',
      caption: 'Image ${images.length + 1}',
      altText: 'Image de test',
      order: images.length,
      isPrimary: images.isEmpty, // Première image = principale
    );

    final updatedImages = List<ArticleImageData>.from(images)..add(newImage);
    onImagesChanged(updatedImages);
  }

  void _editImage(BuildContext context, int index) {
    final image = images[index];
    final captionController = TextEditingController(text: image.caption);
    final altTextController = TextEditingController(text: image.altText);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Modifier l\'image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: captionController,
              decoration: const InputDecoration(
                labelText: 'Légende',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.title),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: altTextController,
              decoration: const InputDecoration(
                labelText: 'Texte alternatif (SEO)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.alt_route),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () {
              final updatedImages = List<ArticleImageData>.from(images);
              updatedImages[index] = image.copyWith(
                caption: captionController.text,
                altText: altTextController.text,
              );
              onImagesChanged(updatedImages);
              Navigator.pop(context);
            },
            child: const Text('Enregistrer'),
          ),
        ],
      ),
    );
  }

  void _deleteImage(int index) {
    final updatedImages = List<ArticleImageData>.from(images);
    updatedImages.removeAt(index);

    // Si on supprime l'image principale, mettre la première comme principale
    if (updatedImages.isNotEmpty && !updatedImages.any((img) => img.isPrimary)) {
      updatedImages[0] = updatedImages[0].copyWith(isPrimary: true);
    }

    onImagesChanged(updatedImages);
  }

  void _setPrimaryImage(int index) {
    final updatedImages = List<ArticleImageData>.from(images);

    // Retirer le statut principal de toutes les images
    for (int i = 0; i < updatedImages.length; i++) {
      updatedImages[i] = updatedImages[i].copyWith(isPrimary: i == index);
    }

    onImagesChanged(updatedImages);
  }

  void _reorderImages(int oldIndex, int newIndex) {
    final updatedImages = List<ArticleImageData>.from(images);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    final item = updatedImages.removeAt(oldIndex);
    updatedImages.insert(newIndex, item);

    // Mettre à jour les order
    for (int i = 0; i < updatedImages.length; i++) {
      updatedImages[i] = updatedImages[i].copyWith(order: i);
    }

    onImagesChanged(updatedImages);
  }
}

// ==================== ADDITIONAL BARCODES MANAGER ====================

class AdditionalBarcodesManager extends StatelessWidget {
  final List<AdditionalBarcodeData> barcodes;
  final Function(List<AdditionalBarcodeData>) onBarcodesChanged;
  final bool enabled;

  const AdditionalBarcodesManager({
    super.key,
    required this.barcodes,
    required this.onBarcodesChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(
                  Icons.qr_code_2,
                  size: 20,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Text(
                  'Codes-barres additionnels (${barcodes.length})',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: enabled ? () => _addBarcode(context) : null,
              icon: const Icon(Icons.add, size: 20),
              label: const Text('Ajouter'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Liste des codes-barres
        if (barcodes.isEmpty)
          _buildEmptyState(context)
        else
          _buildBarcodesList(context),
      ],
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[50],
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.qr_code_2, size: 48, color: Colors.grey[400]),
            const SizedBox(height: 12),
            Text(
              'Aucun code-barres additionnel',
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBarcodesList(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: barcodes.length,
      itemBuilder: (context, index) {
        final barcode = barcodes[index];
        return _buildBarcodeCard(context, barcode, index);
      },
    );
  }

  Widget _buildBarcodeCard(BuildContext context, AdditionalBarcodeData barcode, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.qr_code_scanner,
          color: barcode.isPrimary ? AppColors.primary : Colors.grey,
        ),
        title: Text(
          barcode.barcode,
          style: const TextStyle(
            fontFamily: 'monospace',
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Row(
          children: [
            Text(barcode.barcodeType),
            if (barcode.isPrimary) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'PRINCIPAL',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ],
        ),
        trailing: enabled
            ? Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(
                barcode.isPrimary ? Icons.star : Icons.star_border,
                color: barcode.isPrimary ? Colors.amber : Colors.grey,
                size: 20,
              ),
              onPressed: () => _setPrimaryBarcode(index),
              tooltip: 'Définir comme principal',
            ),
            IconButton(
              icon: const Icon(Icons.edit, size: 20),
              onPressed: () => _editBarcode(context, index),
              tooltip: 'Modifier',
            ),
            IconButton(
              icon: Icon(Icons.delete, size: 20, color: AppColors.error),
              onPressed: () => _deleteBarcode(index),
              tooltip: 'Supprimer',
            ),
          ],
        )
            : null,
      ),
    );
  }

  void _addBarcode(BuildContext context) {
    final barcodeController = TextEditingController();
    String selectedType = 'EAN13';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Ajouter un code-barres'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Code-barres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de code-barres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'EAN13', child: Text('EAN-13')),
                  DropdownMenuItem(value: 'EAN8', child: Text('EAN-8')),
                  DropdownMenuItem(value: 'UPC', child: Text('UPC')),
                  DropdownMenuItem(value: 'CODE128', child: Text('Code 128')),
                  DropdownMenuItem(value: 'CODE39', child: Text('Code 39')),
                  DropdownMenuItem(value: 'QR_CODE', child: Text('QR Code')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (barcodeController.text.trim().isNotEmpty) {
                  final newBarcode = AdditionalBarcodeData(
                    barcode: barcodeController.text.trim(),
                    barcodeType: selectedType,
                    isPrimary: barcodes.isEmpty,
                  );
                  final updatedBarcodes = List<AdditionalBarcodeData>.from(barcodes)
                    ..add(newBarcode);
                  onBarcodesChanged(updatedBarcodes);
                  Navigator.pop(context);
                }
              },
              child: const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  void _editBarcode(BuildContext context, int index) {
    final barcode = barcodes[index];
    final barcodeController = TextEditingController(text: barcode.barcode);
    String selectedType = barcode.barcodeType;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Modifier le code-barres'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: barcodeController,
                decoration: const InputDecoration(
                  labelText: 'Code-barres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.qr_code),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                initialValue: selectedType,
                decoration: const InputDecoration(
                  labelText: 'Type de code-barres',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.category),
                ),
                items: const [
                  DropdownMenuItem(value: 'EAN13', child: Text('EAN-13')),
                  DropdownMenuItem(value: 'EAN8', child: Text('EAN-8')),
                  DropdownMenuItem(value: 'UPC', child: Text('UPC')),
                  DropdownMenuItem(value: 'CODE128', child: Text('Code 128')),
                  DropdownMenuItem(value: 'CODE39', child: Text('Code 39')),
                  DropdownMenuItem(value: 'QR_CODE', child: Text('QR Code')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() => selectedType = value);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () {
                if (barcodeController.text.trim().isNotEmpty) {
                  final updatedBarcodes = List<AdditionalBarcodeData>.from(barcodes);
                  updatedBarcodes[index] = barcode.copyWith(
                    barcode: barcodeController.text.trim(),
                    barcodeType: selectedType,
                  );
                  onBarcodesChanged(updatedBarcodes);
                  Navigator.pop(context);
                }
              },
              child: const Text('Enregistrer'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteBarcode(int index) {
    final updatedBarcodes = List<AdditionalBarcodeData>.from(barcodes);
    updatedBarcodes.removeAt(index);

    // Si on supprime le principal, mettre le premier comme principal
    if (updatedBarcodes.isNotEmpty && !updatedBarcodes.any((b) => b.isPrimary)) {
      updatedBarcodes[0] = updatedBarcodes[0].copyWith(isPrimary: true);
    }

    onBarcodesChanged(updatedBarcodes);
  }

  void _setPrimaryBarcode(int index) {
    final updatedBarcodes = List<AdditionalBarcodeData>.from(barcodes);

    // Retirer le statut principal de tous les codes-barres
    for (int i = 0; i < updatedBarcodes.length; i++) {
      updatedBarcodes[i] = updatedBarcodes[i].copyWith(isPrimary: i == index);
    }

    onBarcodesChanged(updatedBarcodes);
  }
}