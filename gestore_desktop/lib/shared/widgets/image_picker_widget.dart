// ========================================
// lib/shared/widgets/image_picker_widget.dart
// Widget réutilisable pour upload d'images
// Support Drag & Drop + Click + Prévisualisation
// ========================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../constants/app_colors.dart';

/// Widget pour sélectionner et uploader une image
/// Support : Click, Drag & Drop, Prévisualisation, Validation
class ImagePickerWidget extends StatefulWidget {
  /// URL de l'image existante (pour édition)
  final String? initialImageUrl;

  /// Chemin local de l'image sélectionnée
  final String? initialImagePath;

  /// Callback quand une image est sélectionnée
  final Function(String? path) onImageSelected;

  /// Largeur du widget
  final double width;

  /// Hauteur du widget
  final double height;

  /// Taille maximale en MB
  final double maxSizeMB;

  /// Extensions autorisées
  final List<String> allowedExtensions;

  /// Label personnalisé
  final String? label;

  /// Texte d'aide
  final String? helperText;

  /// Afficher le bouton supprimer
  final bool showDeleteButton;

  /// Forme (rectangle ou cercle)
  final ImagePickerShape shape;

  const ImagePickerWidget({
    super.key,
    this.initialImageUrl,
    this.initialImagePath,
    required this.onImageSelected,
    this.width = 200,
    this.height = 200,
    this.maxSizeMB = 5.0,
    this.allowedExtensions = const ['jpg', 'jpeg', 'png'],
    this.label,
    this.helperText,
    this.showDeleteButton = true,
    this.shape = ImagePickerShape.rectangle,
  });

  @override
  State<ImagePickerWidget> createState() => _ImagePickerWidgetState();
}

class _ImagePickerWidgetState extends State<ImagePickerWidget> {
  String? _selectedImagePath;
  bool _isHovering = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _selectedImagePath = widget.initialImagePath;
  }

  /// Sélectionne une image via file picker
  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: widget.allowedExtensions,
        allowMultiple: false,
      );

      if (result != null && result.files.isNotEmpty) {
        final file = result.files.first;

        // Validation taille
        if (file.size > widget.maxSizeMB * 1024 * 1024) {
          setState(() {
            _errorMessage =
            'Fichier trop volumineux (max ${widget.maxSizeMB}MB)';
          });
          return;
        }

        // Validation extension
        final extension = file.extension?.toLowerCase();
        if (extension == null ||
            !widget.allowedExtensions.contains(extension)) {
          setState(() {
            _errorMessage =
            'Format non autorisé. Utilisez: ${widget.allowedExtensions.join(", ")}';
          });
          return;
        }

        setState(() {
          _selectedImagePath = file.path;
          _errorMessage = null;
        });

        widget.onImageSelected(file.path);
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Erreur lors de la sélection: $e';
      });
    }
  }

  /// Supprime l'image sélectionnée
  void _removeImage() {
    setState(() {
      _selectedImagePath = null;
      _errorMessage = null;
    });
    widget.onImageSelected(null);
  }

  /// Construit le widget d'affichage de l'image
  Widget _buildImageDisplay() {
    // Image locale sélectionnée
    if (_selectedImagePath != null && _selectedImagePath!.isNotEmpty) {
      return _buildLocalImage();
    }

    // Image existante (URL)
    if (widget.initialImageUrl != null &&
        widget.initialImageUrl!.isNotEmpty) {
      return _buildNetworkImage();
    }

    // Placeholder
    return _buildPlaceholder();
  }

  /// Image locale
  Widget _buildLocalImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: widget.shape == ImagePickerShape.circle
              ? BorderRadius.circular(widget.width / 2)
              : BorderRadius.circular(12),
          child: Image.file(
            File(_selectedImagePath!),
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
          ),
        ),
        if (widget.showDeleteButton) _buildDeleteButton(),
      ],
    );
  }

  /// Image réseau (URL)
  Widget _buildNetworkImage() {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: widget.shape == ImagePickerShape.circle
              ? BorderRadius.circular(widget.width / 2)
              : BorderRadius.circular(12),
          child: Image.network(
            widget.initialImageUrl!,
            width: widget.width,
            height: widget.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder();
            },
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Center(
                child: CircularProgressIndicator(
                  value: loadingProgress.expectedTotalBytes != null
                      ? loadingProgress.cumulativeBytesLoaded /
                      loadingProgress.expectedTotalBytes!
                      : null,
                ),
              );
            },
          ),
        ),
        if (widget.showDeleteButton) _buildDeleteButton(),
      ],
    );
  }

  /// Placeholder (aucune image)
  Widget _buildPlaceholder() {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      child: GestureDetector(
        onTap: _pickImage,
        child: Container(
          width: widget.width,
          height: widget.height,
          decoration: BoxDecoration(
            color: _isHovering
                ? AppColors.primary.withValues(alpha: 0.05)
                : Colors.grey.shade100,
            borderRadius: widget.shape == ImagePickerShape.circle
                ? BorderRadius.circular(widget.width / 2)
                : BorderRadius.circular(12),
            border: Border.all(
              color: _isHovering ? AppColors.primary : Colors.grey.shade300,
              width: 2,
              style: BorderStyle.solid,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.cloud_upload_outlined,
                size: 48,
                color: _isHovering ? AppColors.primary : Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              Text(
                'Cliquer pour sélectionner',
                style: TextStyle(
                  color: _isHovering ? AppColors.primary : Colors.grey.shade600,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'ou glisser-déposer',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                ),
              ),
              if (widget.helperText != null) ...[
                const SizedBox(height: 8),
                Text(
                  widget.helperText!,
                  style: TextStyle(
                    color: Colors.grey.shade500,
                    fontSize: 11,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Bouton supprimer
  Widget _buildDeleteButton() {
    return Positioned(
      top: 8,
      right: 8,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _removeImage,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: Colors.red.shade500,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.2),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
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
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Widget image
        _buildImageDisplay(),

        // Message d'erreur
        if (_errorMessage != null) ...[
          const SizedBox(height: 8),
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

        // Bouton changer (si image déjà sélectionnée)
        if (_selectedImagePath != null || widget.initialImageUrl != null) ...[
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.edit, size: 16),
            label: const Text('Changer l\'image'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
            ),
          ),
        ],
      ],
    );
  }
}

/// Forme du widget
enum ImagePickerShape {
  rectangle,
  circle,
}