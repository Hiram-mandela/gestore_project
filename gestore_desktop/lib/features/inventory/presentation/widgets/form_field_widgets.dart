// ========================================
// lib/features/inventory/presentation/widgets/form_field_widgets.dart
// Widgets réutilisables pour les formulaires
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../shared/constants/app_colors.dart';

// ==================== CUSTOM TEXT FIELD ====================

class CustomTextField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final bool required;
  final bool enabled;
  final int maxLines;
  final TextInputType? keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final Function(String) onChanged;

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.required = false,
    this.enabled = true,
    this.maxLines = 1,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    required this.onChanged,
  });

  @override
  State<CustomTextField> createState() => _CustomTextFieldState();
}

class _CustomTextFieldState extends State<CustomTextField> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      keyboardType: widget.keyboardType,
      textCapitalization: widget.textCapitalization,
      inputFormatters: widget.inputFormatters,
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        filled: true,
        fillColor: widget.enabled
            ? Theme.of(context).cardColor
            : Theme.of(context).disabledColor.withValues(alpha: 0.1),
      ),
      onChanged: widget.onChanged,
    );
  }
}

// ==================== CUSTOM DROPDOWN ====================

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final String? errorText;
  final IconData? prefixIcon;
  final bool required;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    this.errorText,
    this.prefixIcon,
    this.required = false,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: AppColors.error,
          ),
        ),
        filled: true,
        fillColor: Theme.of(context).cardColor,
      ),
    );
  }
}

// ==================== CUSTOM SWITCH TILE ====================

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: SwitchListTile(
        title: Text(title),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: onChanged,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

// ==================== CUSTOM IMAGE PICKER ====================

class CustomImagePicker extends StatelessWidget {
  final String? imagePath;
  final Function(String) onImageSelected;
  final Function()? onImageRemoved;

  const CustomImagePicker({
    super.key,
    this.imagePath,
    required this.onImageSelected,
    this.onImageRemoved,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        border: Border.all(color: Theme.of(context).dividerColor),
        borderRadius: BorderRadius.circular(8),
      ),
      child: imagePath != null && imagePath!.isNotEmpty
          ? _buildImagePreview(context)
          : _buildPlaceholder(context),
    );
  }

  Widget _buildImagePreview(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: imagePath!.startsWith('http')
              ? Image.network(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          )
              : Image.asset(
            imagePath!,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return _buildPlaceholder(context);
            },
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: Row(
            children: [
              IconButton(
                icon: const Icon(Icons.edit, color: Colors.white),
                onPressed: () => _pickImage(context),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
              if (onImageRemoved != null)
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.white),
                  onPressed: onImageRemoved,
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black54,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return InkWell(
      onTap: () => _pickImage(context),
      borderRadius: BorderRadius.circular(8),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.add_photo_alternate, size: 64, color: Colors.grey),
          SizedBox(height: 8),
          Text(
            'Ajouter une image',
            style: TextStyle(color: Colors.grey),
          ),
          SizedBox(height: 4),
          Text(
            'Cliquez pour sélectionner',
            style: TextStyle(fontSize: 12, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage(BuildContext context) async {
    // TODO: Implémenter file_picker ou image_picker
    // Pour l'instant, simulation
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélection d\'image - À implémenter avec file_picker'),
      ),
    );
  }
}