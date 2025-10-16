// ========================================
// lib/shared/widgets/image_gallery_widget.dart
// Widget pour gérer une galerie d'images avec compression automatique
// VERSION 2.0 - AMÉLIORATIONS: Compression auto avant envoi
// ========================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';
import '../../core/utils/image_compression_helper.dart';

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

/// Widget pour gérer une galerie d'images avec compression automatique
class ImageGalleryWidget extends StatefulWidget {
  /// Images initiales
  final List<GalleryImage> initialImages;

  /// Callback quand les images changent
  final Function(List<GalleryImage>) onImagesChanged;

  /// Nombre maximum d'images
  final int maxImages;

  /// Taille des thumbnails
  final double thumbnailSize;

  /// Taille maximale par image en MB (avant compression)
  final double maxSizeMB;

  /// Extensions autorisées
  final List<String> allowedExtensions;

  /// Activer la compression automatique
  final bool enableAutoCompression;

  /// Paramètres de compression
  final int compressionMaxWidth;
  final int compressionMaxHeight;
  final int compressionQuality;

  const ImageGalleryWidget({
    super.key,
    this.initialImages = const [],
    required this.onImagesChanged,
    this.maxImages = 5,
    this.thumbnailSize = 120,
    this.maxSizeMB = 5.0,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png', 'webp'],
    this.enableAutoCompression = true, // ✨ PAR DÉFAUT: activé
    this.compressionMaxWidth = 1280,
    this.compressionMaxHeight = 1280,
    this.compressionQuality = 85,
  });

  @override
  State<ImageGalleryWidget> createState() => _ImageGalleryWidgetState();
}

class _ImageGalleryWidgetState extends State<ImageGalleryWidget> {
  late List<GalleryImage> _images;
  String? _errorMessage;
  bool _isCompressing = false;

  @override
  void initState() {
    super.initState();
    _images = List.from(widget.initialImages);
  }

  /// Ajoute une ou plusieurs images avec compression automatique ✨
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
        setState(() {
          _isCompressing = true;
          _errorMessage = null;
        });

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
              _errorMessage = '${file.name}: Format non autorisé';
            });
            continue;
          }

          String finalPath = file.path!;

          // ✨ COMPRESSION AUTOMATIQUE
          if (widget.enableAutoCompression) {
            final shouldCompress = await ImageCompressionHelper.shouldCompress(
              imagePath: file.path!,
              maxSizeMB: 2.0, // Seuil: compresser si > 2MB
            );

            if (shouldCompress) {
              final compressedPath = await ImageCompressionHelper.compressImage(
                imagePath: file.path!,
                maxWidth: widget.compressionMaxWidth,
                maxHeight: widget.compressionMaxHeight,
                quality: widget.compressionQuality,
              );

              if (compressedPath != null) {
                // Calculer le gain de compression
                final ratio = await ImageCompressionHelper.getCompressionRatio(
                  originalPath: file.path!,
                  compressedPath: compressedPath,
                );

                if (ratio != null && ratio > 10) {
                  // Si compression > 10%, utiliser l'image compressée
                  finalPath = compressedPath;

                  // Afficher un message de succès
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          '✅ Image compressée: ${ratio.toStringAsFixed(0)}% de réduction',
                        ),
                        backgroundColor: AppColors.success,
                        behavior: SnackBarBehavior.floating,
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  }
                }
              }
            }
          }

          _images.add(GalleryImage(
            path: finalPath,
            isPrimary: _images.isEmpty, // Première image = principale
          ));
        }

        setState(() {
          _isCompressing = false;
          _errorMessage = null;
        });

        widget.onImagesChanged(_images);
      }
    } catch (e) {
      setState(() {
        _isCompressing = false;
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
                Icon(Icons.photo_library, size: 20, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Images (${_images.length}/${widget.maxImages})',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: _isCompressing || _images.length >= widget.maxImages
                  ? null
                  : _addImages,
              icon: _isCompressing
                  ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : const Icon(Icons.add_photo_alternate, size: 18),
              label: Text(_isCompressing ? 'Compression...' : 'Ajouter'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.primary,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Message d'erreur
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.error.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.error.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(Icons.error_outline, color: AppColors.error, size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
                IconButton(
                  onPressed: () => setState(() => _errorMessage = null),
                  icon: const Icon(Icons.close, size: 18),
                  color: AppColors.error,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Liste des images
        if (_images.isEmpty)
          _buildEmptyState()
        else
          _buildImagesList(),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.border, style: BorderStyle.solid),
        borderRadius: BorderRadius.circular(12),
        color: AppColors.backgroundLight,
      ),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.photo_library_outlined, size: 48, color: Colors.grey.shade400),
            const SizedBox(height: 12),
            Text(
              'Aucune image',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
            ),
            const SizedBox(height: 4),
            Text(
              'Ajoutez des images pour illustrer votre article',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImagesList() {
    return ReorderableListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _images.length,
      onReorder: _reorderImages,
      itemBuilder: (context, index) {
        final image = _images[index];
        return _buildImageTile(image, index);
      },
    );
  }

  Widget _buildImageTile(GalleryImage image, int index) {
    return Container(
      key: ValueKey('${image.path}${image.url}$index'),
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: image.isPrimary ? AppColors.primary : AppColors.border,
          width: image.isPrimary ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          // Handle de drag
          Icon(Icons.drag_handle, color: Colors.grey.shade400),
          const SizedBox(width: 12),

          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: widget.thumbnailSize,
              height: widget.thumbnailSize,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.border),
              ),
              child: image.isLocal
                  ? Image.file(
                File(image.path!),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Icon(Icons.broken_image),
                  );
                },
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
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (image.isPrimary)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Image principale',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                else
                  Text(
                    'Image ${index + 1}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textPrimary,
                    ),
                  ),
                const SizedBox(height: 4),
                FutureBuilder<double?>(
                  future: ImageCompressionHelper.getImageSizeInMB(
                    image.path ?? image.url ?? '',
                  ),
                  builder: (context, snapshot) {
                    if (snapshot.hasData && snapshot.data != null) {
                      return Text(
                        '${snapshot.data!.toStringAsFixed(2)} MB',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey.shade600,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          ),

          // Actions
          if (!image.isPrimary)
            IconButton(
              onPressed: () => _setPrimaryImage(index),
              icon: const Icon(Icons.star_border),
              color: AppColors.textSecondary,
              tooltip: 'Définir comme principale',
            ),
          IconButton(
            onPressed: () => _removeImage(index),
            icon: const Icon(Icons.delete_outline),
            color: AppColors.error,
            tooltip: 'Supprimer',
          ),
        ],
      ),
    );
  }
}