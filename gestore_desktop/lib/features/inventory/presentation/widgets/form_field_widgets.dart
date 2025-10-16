// ========================================
// lib/features/inventory/presentation/widgets/form_field_widgets.dart
//
// MODIFICATIONS APPORTÉES (Correction Visuelle GESTORE) :
// - Ajout de `helperStyle` pour garantir la visibilité du texte d'aide (helperText).
// - Ajout de `dropdownColor` au CustomDropdown pour forcer un fond clair sur le menu déroulant.
// - Application de la palette AppColors pour tous les textes (labels, input, subtitles) afin d'assurer une lisibilité maximale (contraste élevé).
// - Uniformisation du style de l'InputDecoration pour tous les champs (TextField, Dropdown) en utilisant les couleurs GESTORE pour les fonds, bordures et icônes.
// - Refonte du CustomSwitchTile pour utiliser les fonds, bordures et couleurs de texte GESTORE, corrigeant le texte invisible.
// - Standardisation des couleurs pour les états activé/désactivé des champs.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';

// --- Décoration de champ réutilisable pour le style GESTORE ---
InputDecoration _gestoreInputDecoration({
  required String label,
  required bool isRequired,
  String? errorText,
  String? helperText,
  IconData? prefixIcon,
  String? suffixText,
  bool isEnabled = true,
}) {
  return InputDecoration(
    labelText: isRequired ? '$label *' : label,
    labelStyle: const TextStyle(color: AppColors.textSecondary),
    helperText: helperText,
    // ✨ CORRECTION : Ajout du style pour le helperText pour garantir sa visibilité.
    helperStyle: const TextStyle(color: AppColors.textSecondary),
    errorText: errorText,
    prefixIcon: prefixIcon != null
        ? Icon(prefixIcon, color: AppColors.textSecondary)
        : null,
    suffixText: suffixText,
    filled: true,
    fillColor: isEnabled ? AppColors.surfaceLight : AppColors.backgroundLight,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    // Bordures
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.primary, width: 2),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.border),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 1.5),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.error, width: 2),
    ),
    errorStyle: const TextStyle(color: AppColors.error),
  );
}

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
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(CustomTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue &&
        widget.initialValue != _controller.text &&
        !_focusNode.hasFocus) {
      final currentSelection = _controller.selection;
      _controller.text = widget.initialValue ?? '';
      if (currentSelection.baseOffset <= _controller.text.length) {
        _controller.selection = currentSelection;
      }
    }
  }

  void _onControllerChanged() {
    // Note: Le onChanged est maintenant déclenché en temps réel.
    // La vérification _focusNode.hasFocus a été retirée pour un comportement plus standard.
    widget.onChanged(_controller.text);
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
      style: TextStyle(
          color: widget.enabled
              ? AppColors.textPrimary
              : AppColors.textTertiary),
      decoration: _gestoreInputDecoration(
        label: widget.label,
        isRequired: widget.required,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        isEnabled: widget.enabled,
      ),
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
    final text = _controller.text.trim();
    if (text.isEmpty) {
      widget.onChanged(0.0);
      return;
    }
    final value = double.tryParse(text) ?? 0.0;

    if (widget.minValue != null && value < widget.minValue!) {
      return;
    }
    if (widget.maxValue != null && value > widget.maxValue!) {
      return;
    }
    widget.onChanged(value);
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
      style: TextStyle(
          color: widget.enabled
              ? AppColors.textPrimary
              : AppColors.textTertiary),
      decoration: _gestoreInputDecoration(
        label: widget.label,
        isRequired: widget.required,
        errorText: widget.errorText,
        helperText: widget.helperText,
        prefixIcon: widget.prefixIcon,
        suffixText: widget.suffix,
        isEnabled: widget.enabled,
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
      // ✨ CORRECTION : Ajout de la couleur de fond pour le menu déroulant.
      dropdownColor: AppColors.surfaceLight,
      style: TextStyle(
          color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          overflow: TextOverflow.ellipsis),
      decoration: _gestoreInputDecoration(
        label: label,
        isRequired: required,
        errorText: errorText,
        helperText: helperText,
        prefixIcon: prefixIcon,
        isEnabled: enabled,
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
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: SwitchListTile.adaptive(
        contentPadding:
        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w500,
            color: enabled ? AppColors.textPrimary : AppColors.textTertiary,
          ),
        ),
        subtitle: subtitle != null
            ? Text(subtitle!,
            style: TextStyle(
              color: enabled
                  ? AppColors.textSecondary
                  : AppColors.textTertiary,
            ))
            : null,
        value: value,
        onChanged: enabled ? onChanged : null,
        secondary: icon != null
            ? Icon(icon,
            color: value ? AppColors.primary : AppColors.textTertiary)
            : null,
        activeThumbColor: AppColors.surfaceLight,
        activeTrackColor: AppColors.primary,
        inactiveThumbColor: AppColors.surfaceLight,
        inactiveTrackColor: AppColors.border,
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
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          height: 200,
          decoration: BoxDecoration(
            border: Border.all(
              color: errorText != null ? AppColors.error : AppColors.border,
              width: errorText != null ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
            color: enabled ? AppColors.surfaceLight : AppColors.backgroundLight,
          ),
          child: Stack(
            children: [
              // Prévisualisation ou placeholder
              if (imagePath != null && imagePath!.isNotEmpty)
                ClipRRect(
                  borderRadius: BorderRadius.circular(11),
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
                                ? Icons.edit_outlined
                                : Icons.add_photo_alternate_outlined,
                            size: 48,
                            color: enabled
                                ? AppColors.primary
                                : AppColors.textTertiary,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            imagePath != null && imagePath!.isNotEmpty
                                ? 'Modifier l\'image'
                                : 'Ajouter une image',
                            style: TextStyle(
                              color: enabled
                                  ? AppColors.primary
                                  : AppColors.textTertiary,
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
                      backgroundColor: AppColors.error.withValues(alpha: 0.8),
                      foregroundColor: AppColors.surfaceLight,
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
              style: const TextStyle(
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
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(11),
      ),
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          size: 64,
          color: AppColors.border,
        ),
      ),
    );
  }
}