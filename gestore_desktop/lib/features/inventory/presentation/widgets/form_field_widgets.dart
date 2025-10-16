// ========================================
// lib/features/inventory/presentation/widgets/form_field_widgets.dart
// Widgets de formulaire réutilisables avec support validation inline
// VERSION 3.0 - AMÉLIORATIONS COMPLÈTES
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../shared/constants/app_colors.dart';

// ==================== CUSTOM TEXT FIELD ====================

class CustomTextField extends StatelessWidget {
  final String label;
  final String? initialValue;
  final Function(String) onChanged;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool required;
  final bool enabled;
  final int maxLines;
  final int? maxLength;
  final TextInputType keyboardType;
  final TextCapitalization textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final AutovalidateMode autovalidateMode; // ✨ NOUVEAU

  const CustomTextField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixText,
    this.required = false,
    this.enabled = true,
    this.maxLines = 1,
    this.maxLength,
    this.keyboardType = TextInputType.text,
    this.textCapitalization = TextCapitalization.none,
    this.inputFormatters,
    this.autovalidateMode = AutovalidateMode.disabled, // ✨ PAR DÉFAUT: disabled
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label personnalisé avec astérisque
        if (label.isNotEmpty) ...[
          Text(
            required ? '$label *' : label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        // Champ de texte
        TextFormField(
          initialValue: initialValue,
          onChanged: onChanged,
          enabled: enabled,
          maxLines: maxLines,
          maxLength: maxLength,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          inputFormatters: inputFormatters,
          autovalidateMode: autovalidateMode, // ✨ VALIDATION INLINE
          validator: errorText != null ? (_) => errorText : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
              size: 20,
            )
                : null,
            suffixText: suffixText,
            hintText: 'Saisir $label',
            errorText: errorText,
            helperText: helperText,
            helperStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceLight
                : AppColors.surfaceLight.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 2),
            ),
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: AppColors.border.withValues(alpha: 0.5)),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }
}

// ==================== CUSTOM DROPDOWN ====================

class CustomDropdown<T> extends StatelessWidget {
  final String label;
  final T? value;
  final List<DropdownMenuItem<T>> items;
  final Function(T?) onChanged;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final bool required;
  final bool enabled;

  const CustomDropdown({
    super.key,
    required this.label,
    this.value,
    required this.items,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.required = false,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label.isNotEmpty) ...[
          Text(
            required ? '$label *' : label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
        ],

        DropdownButtonFormField<T>(
          initialValue: value,
          items: items,
          onChanged: enabled ? onChanged : null,
          decoration: InputDecoration(
            prefixIcon: prefixIcon != null
                ? Icon(
              prefixIcon,
              color: enabled ? AppColors.textSecondary : AppColors.textTertiary,
              size: 20,
            )
                : null,
            errorText: errorText,
            helperText: helperText,
            helperStyle: const TextStyle(color: AppColors.textSecondary),
            filled: true,
            fillColor: enabled
                ? AppColors.surfaceLight
                : AppColors.surfaceLight.withValues(alpha: 0.5),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.border,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: errorText != null ? AppColors.error : AppColors.primary,
                width: 2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          dropdownColor: Colors.white,
        ),
      ],
    );
  }
}

// ==================== CUSTOM SWITCH TILE ====================

class CustomSwitchTile extends StatelessWidget {
  final String title;
  final String? subtitle;
  final bool value;
  final Function(bool) onChanged;
  final IconData? icon;
  final bool enabled;

  const CustomSwitchTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.value,
    required this.onChanged,
    this.icon,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: value ? AppColors.primary.withValues(alpha: 0.3) : AppColors.border,
        ),
      ),
      child: Row(
        children: [
          if (icon != null) ...[
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: value
                    ? AppColors.primary.withValues(alpha: 0.1)
                    : Colors.grey.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: value ? AppColors.primary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle!,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: AppColors.primary,
          ),
        ],
      ),
    );
  }
}

// ==================== CUSTOM NUMBER FIELD ====================

class CustomNumberField extends StatelessWidget {
  final String label;
  final double? initialValue;
  final Function(double) onChanged;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool required;
  final bool enabled;
  final double min;
  final double max;
  final int decimals;
  final AutovalidateMode autovalidateMode; // ✨ NOUVEAU

  const CustomNumberField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixText,
    this.required = false,
    this.enabled = true,
    this.min = 0,
    this.max = double.infinity,
    this.decimals = 2,
    this.autovalidateMode = AutovalidateMode.disabled, // ✨ PAR DÉFAUT: disabled
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      initialValue: initialValue != null && initialValue! > 0
          ? initialValue!.toStringAsFixed(decimals)
          : '',
      onChanged: (value) {
        final number = double.tryParse(value) ?? 0.0;
        onChanged(number.clamp(min, max));
      },
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      required: required,
      enabled: enabled,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,' + decimals.toString() + r'}')),
      ],
      autovalidateMode: autovalidateMode, // ✨ VALIDATION INLINE
    );
  }
}

// ==================== CUSTOM INTEGER FIELD ====================

class CustomIntegerField extends StatelessWidget {
  final String label;
  final int? initialValue;
  final Function(int) onChanged;
  final String? errorText;
  final String? helperText;
  final IconData? prefixIcon;
  final String? suffixText;
  final bool required;
  final bool enabled;
  final int min;
  final int max;
  final AutovalidateMode autovalidateMode; // ✨ NOUVEAU

  const CustomIntegerField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.prefixIcon,
    this.suffixText,
    this.required = false,
    this.enabled = true,
    this.min = 0,
    this.max = 999999,
    this.autovalidateMode = AutovalidateMode.disabled, // ✨ PAR DÉFAUT: disabled
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      label: label,
      initialValue: initialValue != null && initialValue! > 0
          ? initialValue.toString()
          : '',
      onChanged: (value) {
        final number = int.tryParse(value) ?? 0;
        onChanged(number.clamp(min, max));
      },
      errorText: errorText,
      helperText: helperText,
      prefixIcon: prefixIcon,
      suffixText: suffixText,
      required: required,
      enabled: enabled,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
      ],
      autovalidateMode: autovalidateMode, // ✨ VALIDATION INLINE
    );
  }
}