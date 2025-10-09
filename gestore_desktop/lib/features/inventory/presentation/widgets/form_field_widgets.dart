// ========================================
// lib/features/inventory/presentation/widgets/form_field_widgets.dart
// Widgets réutilisables pour les formulaires
// VERSION CORRIGÉE - Bug TextField résolu
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
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue ?? '');

    // ✅ CORRECTION: Écouter uniquement les changements utilisateur
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ CORRECTION CRITIQUE: Ne mettre à jour que si le texte est vraiment différent
    // ET que le champ n'a pas le focus (pas en cours d'édition)
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text &&
        !_focusNode.hasFocus) {
      // Préserver la position du curseur si possible
      final currentSelection = _controller.selection;
      _controller.text = widget.initialValue ?? '';

      // Restaurer la sélection si elle est valide
      if (currentSelection.baseOffset <= _controller.text.length) {
        _controller.selection = currentSelection;
      }
    }
  }

  void _onControllerChanged() {
    // ✅ Appeler onChanged uniquement si l'utilisateur tape
    if (_focusNode.hasFocus) {
      widget.onChanged(_controller.text);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
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
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[100],
        // ✅ Style d'erreur amélioré
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      // ✅ SUPPRIMÉ: onChanged ici car géré par le listener
    );
  }
}

// ==================== CUSTOM NUMBER FIELD ====================

class CustomNumberField extends StatefulWidget {
  final String label;
  final double? initialValue;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? suffix;
  final bool required;
  final bool enabled;
  final int decimals;
  final double? minValue;
  final double? maxValue;
  final Function(double) onChanged;

  const CustomNumberField({
    super.key,
    required this.label,
    this.initialValue,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffix,
    this.required = false,
    this.enabled = true,
    this.decimals = 2,
    this.minValue,
    this.maxValue,
    required this.onChanged,
  });

  @override
  State<CustomNumberField> createState() => _CustomNumberFieldState();
}

class _CustomNumberFieldState extends State<CustomNumberField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    final initialText = widget.initialValue != null && widget.initialValue! > 0
        ? widget.initialValue!.toStringAsFixed(widget.decimals)
        : '';
    _controller = TextEditingController(text: initialText);
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomNumberField oldWidget) {
    super.didUpdateWidget(oldWidget);

    // ✅ CORRECTION: Même logique que CustomTextField
    if (widget.initialValue != oldWidget.initialValue && !_focusNode.hasFocus) {
      final newText = widget.initialValue != null && widget.initialValue! > 0
          ? widget.initialValue!.toStringAsFixed(widget.decimals)
          : '';

      if (_controller.text != newText) {
        final currentSelection = _controller.selection;
        _controller.text = newText;

        if (currentSelection.baseOffset <= _controller.text.length) {
          _controller.selection = currentSelection;
        }
      }
    }
  }

  void _onControllerChanged() {
    if (_focusNode.hasFocus) {
      final text = _controller.text.trim();
      if (text.isEmpty) {
        widget.onChanged(0.0);
        return;
      }

      final value = double.tryParse(text) ?? 0.0;

      // Validation des limites
      if (widget.minValue != null && value < widget.minValue!) {
        return;
      }
      if (widget.maxValue != null && value > widget.maxValue!) {
        return;
      }

      widget.onChanged(value);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      keyboardType: TextInputType.numberWithOptions(
        decimal: widget.decimals > 0,
        signed: (widget.minValue ?? 0) < 0,
      ),
      inputFormatters: [
        FilteringTextInputFormatter.allow(
          RegExp(r'^\d*\.?\d{0,' + widget.decimals.toString() + r'}'),
        ),
      ],
      decoration: InputDecoration(
        labelText: widget.required ? '${widget.label} *' : widget.label,
        helperText: widget.helperText,
        errorText: widget.errorText,
        prefixIcon: widget.prefixIcon != null
            ? Icon(widget.prefixIcon)
            : null,
        suffixText: widget.suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: widget.enabled ? Colors.white : Colors.grey[100],
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}

// ==================== CUSTOM DROPDOWN ====================

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final bool required;
  final bool enabled;
  final Function(T?) onChanged;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.required = false,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<T>(
      initialValue: value,
      items: items,
      onChanged: enabled ? onChanged : null,
      decoration: InputDecoration(
        labelText: required ? '$label *' : label,
        helperText: helperText,
        errorText: errorText,
        prefixIcon: prefixIcon != null ? Icon(prefixIcon) : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        filled: true,
        fillColor: enabled ? Colors.white : Colors.grey[100],
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
      ),
    );
  }
}

// ==================== CUSTOM SWITCH TILE ====================

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final IconData? icon;
  final bool enabled;
  final Function(bool) onChanged;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    this.icon,
    this.enabled = true,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.grey[50],
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[300]!),
      ),
      child: SwitchListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: subtitle != null ? Text(subtitle!) : null,
        value: value,
        onChanged: enabled ? onChanged : null,
        secondary: icon != null
            ? Icon(icon, color: value ? AppColors.primary : Colors.grey)
            : null,
        activeThumbColor: AppColors.primary,
      ),
    );
  }
}

// ==================== IMAGE PICKER PLACEHOLDER ====================

class CustomImagePicker extends StatelessWidget {
  final String label;
  final String? imagePath;
  final String? errorText;
  final bool enabled;
  final VoidCallback onTap;
  final VoidCallback? onClear;

  const CustomImagePicker({
    super.key,
    required this.label,
    this.imagePath,
    this.errorText,
    this.enabled = true,
    required this.onTap,
    this.onClear,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? AppColors.error : Colors.grey[300]!,
              width: errorText != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: enabled ? Colors.grey[50] : Colors.grey[100],
          ),
          child: Stack(
            children: [
              // Prévisualisation ou placeholder
              if (imagePath != null && imagePath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imagePath!,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildPlaceholder(context);
                    },
                  ),
                )
              else
                _buildPlaceholder(context),

              // Bouton de sélection
              Positioned.fill(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: enabled ? onTap : null,
                    borderRadius: BorderRadius.circular(12),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            imagePath != null && imagePath!.isNotEmpty
                                ? Icons.edit
                                : Icons.add_photo_alternate,
                            size: 48,
                            color: enabled ? AppColors.primary : Colors.grey,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            imagePath != null && imagePath!.isNotEmpty
                                ? 'Modifier l\'image'
                                : 'Ajouter une image',
                            style: TextStyle(
                              color: enabled ? AppColors.primary : Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Bouton de suppression
              if (imagePath != null && imagePath!.isNotEmpty && onClear != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton(
                    onPressed: enabled ? onClear : null,
                    icon: const Icon(Icons.close),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.red.withValues(alpha: 0.8),
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Text(
              errorText!,
              style: TextStyle(
                color: AppColors.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      color: Colors.grey[100],
      child: Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: Colors.grey[400],
        ),
      ),
    );
  }
}