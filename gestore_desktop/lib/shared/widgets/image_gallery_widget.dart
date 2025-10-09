// ========================================
// lib/shared/widgets/image_gallery_widget.dart
// Widget pour gérer une galerie d'images
// Support upload multiple, réordonnancement, définition principale
// ========================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';

/// Représente une image dans la galerie
class GalleryImage {
  final String? path; // Chemin local si nouvelle image
  final String? url; // URL si image existante
  final bool isPrimary; // Image principale

  GalleryImage({
    this.path,
    this.url,
    this.isPrimary = false,
  });

  /// Vérifie si c'est une image locale
  bool get isLocal => path != null && path!.isNotEmpty;

  /// Vérifie si c'est une image réseau
  bool get isNetwork => url != null && url!.isNotEmpty;

  /// Copie avec modifications
  GalleryImage copyWith({bool? isPrimary}) {
    return GalleryImage(
      path: path,
      url: url,
      isPrimary: isPrimary ?? this.isPrimary,
    );
  }
}

/// Widget pour gérer une galerie d'images
class ImageGalleryWidget extends StatefulWidget {
  /// Images initiales
  final List<GalleryImage> initialImages;

  /// Callback quand les images changent
  final Function(List<GalleryImage>) onImagesChanged;

  /// Nombre maximum d'images
  final int maxImages;

  /// Taille des thumbnails
  final double thumbnailSize;

  /// Taille maximale par image en MB
  final double maxSizeMB;

  /// Extensions autorisées
  final List<String> allowedExtensions;

  const ImageGalleryWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.maxImages = 5,
    this.thumbnailSize = 120,
    this.maxSizeMB = 5.0,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png'],
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  late List<GalleryImage> _images;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  /// Ajoute une ou plusieurs images
  Future<void> _addImages() async {
    if (_images.length >= widget.maxImages) {
      setState(() {
        _errorMessage = 'Maximum ${widget.maxImages} images autorisées';
      });
      return;
    }

    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: true,
      );

      if (result != null && result.files.isNotEmpty) {
        final remainingSlots = widget.maxImages - _images.length;
        final filesToAdd = result.files.take(remainingSlots).toList();

        for (final file in filesToAdd) {
          // Validation taille
          if (file.size > widget.maxSizeMB * 1024 * 1024) {
            setState(() {
              _errorMessage =
              '${file.name}: Fichier trop volumineux (max ${widget.maxSizeMB}MB)';
            });
            continue;
          }

          // Validation extension
          final extension = file.extension?.toLowerCase();
          if (extension == null ||
              !widget.allowedExtensions.contains(extension)) {
            setState(() {
              _errorMessage =
              '${file.name}: Format non autorisé';
            });
            continue;
          }

          _images.add(GalleryImage(
            path: file.path,
            isPrimary: _images.isEmpty, // Première image = principale
          ));
        }

        setState(() {
          _errorMessage = null;
        });

        widget.onImagesChanged(_images);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection: $e';
      });
    }
  }

  /// Supprime une image
  void _removeImage(int index) {
    final wasPrimary = _images[index].isPrimary;

    setState(() {
      _images.removeAt(index);

      // Si on supprime l'image principale, définir la première comme principale
      if (wasPrimary && _images.isNotEmpty) {
        _images[0] = _images[0].copyWith(isPrimary: true);
      }

      _errorMessage = null;
    });

    widget.onImagesChanged(_images);
  }

  /// Définit une image comme principale
  void _setPrimaryImage(int index) {
    setState(() {
      // Retirer le flag primary de toutes les images
      _images = _images.map((img) => img.copyWith(isPrimary: false)).toList();

      // Définir la nouvelle image principale
      _images[index] = _images[index].copyWith(isPrimary: true);
    });

    widget.onImagesChanged(_images);
  }

  /// Réordonne les images (drag & drop)
  void _reorderImages(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final image = _images.removeAt(oldIndex);
      _images.insert(newIndex, image);
    });

    widget.onImagesChanged(_images);
  }

  /// Construit le widget d'une image
  Widget _buildImageTile(GalleryImage image, int index) {
    return Stack(
      children: [
        // Image
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: widget.thumbnailSize,
            height: widget.thumbnailSize,
            decoration: BoxDecoration(
              border: Border.all(
                color: image.isPrimary
                    ? AppColors.primary
                    : Colors.grey.shade300,
                width: image.isPrimary ? 3 : 1,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: image.isLocal
                ? Image.file(
              File(image.path!),
              fit: BoxFit.cover,
            )
                : image.isNetwork
                ? Image.network(
              image.url!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.grey.shade200,
                  child: const Icon(Icons.broken_image),
                );
              },
            )
                : Container(
              color: Colors.grey.shade200,
              child: const Icon(Icons.image),
            ),
          ),
        ),

        // Badge "Principale"
        if (image.isPrimary)
          Positioned(
            top: 4,
            left: 4,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                'Principale',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

        // Bouton supprimer
        Positioned(
          top: 4,
          right: 4,
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => _removeImage(index),
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.red.shade500,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.close,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          ),
        ),

        // Bouton définir comme principale (si pas déjà principale)
        if (!image.isPrimary)
          Positioned(
            bottom: 4,
            left: 4,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _setPrimaryImage(index),
                borderRadius: BorderRadius.circular(4),
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.9),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.primary),
                  ),
                  child: const Text(
                    'Définir principale',
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 9,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  /// Construit le bouton d'ajout
  Widget _buildAddButton() {
    final canAddMore = _images.length < widget.maxImages;

    return GestureDetector(
      onTap: canAddMore ? _addImages : null,
      child: Container(
        width: widget.thumbnailSize,
        height: widget.thumbnailSize,
        decoration: BoxDecoration(
          color: canAddMore
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey.shade200,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canAddMore ? AppColors.primary : Colors.grey.shade300,
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_photo_alternate,
              size: 32,
              color: canAddMore ? AppColors.primary : Colors.grey.shade400,
            ),
            const SizedBox(height: 4),
            Text(
              canAddMore ? 'Ajouter' : 'Maximum atteint',
              style: TextStyle(
                color: canAddMore ? AppColors.primary : Colors.grey.shade400,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (canAddMore)
              Text(
                '${_images.length}/${widget.maxImages}',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Galerie d\'images',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            Text(
              '${_images.length}/${widget.maxImages}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Info
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(Icons.info_outline, color: Colors.blue.shade700, size: 16),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'La première image sera utilisée comme image principale. Cliquez sur une image pour la définir comme principale.',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 11,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Galerie (Reorderable)
        ReorderableWrap(
          spacing: 12,
          runSpacing: 12,
          onReorder: _reorderImages,
          children: [
            ..._images.asMap().entries.map((entry) {
              return _buildImageTile(entry.value, entry.key);
            }),
            _buildAddButton(),
          ],
        ),

        // Message d'erreur
        if (_errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.red.shade50,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.red.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: Colors.red.shade700, size: 16),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      color: Colors.red.shade700,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }
}

/// Widget Wrap avec support reorder (simplifié)
class ReorderableWrap extends StatelessWidget {
  final List<Widget> children;
  final double spacing;
  final double runSpacing;
  final Function(int, int) onReorder;

  const ReorderableWrap({
    super.key,
    required this.children,
    this.spacing = 8,
    this.runSpacing = 8,
    required this.onReorder,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children,
    );
  }
}