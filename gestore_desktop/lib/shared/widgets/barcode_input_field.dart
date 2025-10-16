// ========================================
// lib/shared/widgets/barcode_input_field.dart
// Champ de saisie avec support scanner de codes-barres
// Compatible avec les scanners USB type ELITE
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../constants/app_colors.dart';

/// Champ de texte avec support scanner de codes-barres
/// Compatible avec les scanners USB qui émulent un clavier
class BarcodeInputField extends StatefulWidget {
  final String label;
  final String? initialValue;
  final Function(String) onChanged;
  final String? errorText;
  final String? helperText;
  final bool required;
  final bool enabled;
  final IconData? prefixIcon;

  const BarcodeInputField({
    super.key,
    required this.label,
    this.initialValue,
    required this.onChanged,
    this.errorText,
    this.helperText,
    this.required = false,
    this.enabled = true,
    this.prefixIcon,
  });

  @override
  State<BarcodeInputField> createState() => _BarcodeInputFieldState();
}

class _BarcodeInputFieldState extends State<BarcodeInputField> {
  late TextEditingController _controller;
  final FocusNode _focusNode = FocusNode();
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialValue);
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(BarcodeInputField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialValue != oldWidget.initialValue) {
      _controller.text = widget.initialValue ?? '';
    }
  }

  void _onTextChanged() {
    widget.onChanged(_controller.text);
  }

  /// Active le mode scan (focus sur le champ)
  void _activateScanMode() {
    setState(() {
      _isScanning = true;
    });
    _focusNode.requestFocus();

    // Désactiver le mode scan après 10 secondes d'inactivité
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted && _isScanning) {
        setState(() {
          _isScanning = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        if (widget.label.isNotEmpty) ...[
          Row(
            children: [
              Text(
                widget.required ? '${widget.label} *' : widget.label,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(width: 8),
              if (_isScanning)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.success.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                    border: Border.all(color: AppColors.success),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.success,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Text(
                        'Prêt à scanner',
                        style: TextStyle(
                          color: AppColors.success,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],

        // Champ de saisie avec bouton scanner
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                focusNode: _focusNode,
                enabled: widget.enabled,
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                ],
                decoration: InputDecoration(
                  prefixIcon: widget.prefixIcon != null
                      ? Icon(
                    widget.prefixIcon,
                    color: widget.enabled ? AppColors.textSecondary : AppColors.textTertiary,
                    size: 20,
                  )
                      : null,
                  hintText: 'Saisir ou scanner le code-barres',
                  errorText: widget.errorText,
                  helperText: widget.helperText,
                  helperStyle: const TextStyle(color: AppColors.textSecondary),
                  filled: true,
                  fillColor: widget.enabled
                      ? (_isScanning
                      ? AppColors.success.withValues(alpha: 0.05)
                      : AppColors.surfaceLight)
                      : AppColors.surfaceLight.withValues(alpha: 0.5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.errorText != null
                          ? AppColors.error
                          : (_isScanning ? AppColors.success : AppColors.border),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.errorText != null
                          ? AppColors.error
                          : (_isScanning ? AppColors.success : AppColors.border),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: widget.errorText != null
                          ? AppColors.error
                          : (_isScanning ? AppColors.success : AppColors.primary),
                      width: 2,
                    ),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(color: AppColors.error),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
                onTap: () {
                  if (!_isScanning) {
                    setState(() {
                      _isScanning = true;
                    });
                  }
                },
                onEditingComplete: () {
                  setState(() {
                    _isScanning = false;
                  });
                },
              ),
            ),

            const SizedBox(width: 12),

            // Bouton Scanner
            Container(
              height: 50,
              width: 50,
              decoration: BoxDecoration(
                color: _isScanning ? AppColors.success : AppColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: (_isScanning ? AppColors.success : AppColors.primary).withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: widget.enabled ? _activateScanMode : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Icon(
                    _isScanning ? Icons.scanner : Icons.qr_code_scanner,
                    color: Colors.white,
                    size: 24,
                  ),
                ),
              ),
            ),
          ],
        ),

        // Info supplémentaire
        if (_isScanning) ...[
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.info.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.info.withValues(alpha: 0.3)),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.info,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Utilisez votre scanner USB ou saisissez le code manuellement',
                    style: TextStyle(
                      color: AppColors.info,
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