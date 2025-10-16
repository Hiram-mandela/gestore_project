// ========================================
// lib/features/sales/presentation/screens/payment_method_form_screen.dart
// Écran Formulaire Moyen de Paiement (Création/Édition) - Module Sales
// VERSION AMÉLIORÉE - DESIGN REFACTORING
//
// Changements stylistiques majeurs :
// - Application de la palette GESTORE pour une interface unifiée.
// - Organisation du formulaire en cartes de section pour une meilleure clarté.
// - Modernisation des champs de formulaire avec un style et un focus cohérents.
// - Amélioration du design des switchs et des boutons d'action.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/payment_method_form_provider.dart';
import '../providers/payment_method_form_state.dart';

/// Écran de formulaire pour créer/éditer un moyen de paiement
class PaymentMethodFormScreen extends ConsumerStatefulWidget {
  final String? paymentMethodId;

  const PaymentMethodFormScreen({
    super.key,
    this.paymentMethodId,
  });

  @override
  ConsumerState<PaymentMethodFormScreen> createState() =>
      _PaymentMethodFormScreenState();
}

class _PaymentMethodFormScreenState
    extends ConsumerState<PaymentMethodFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.paymentMethodId != null;

    // Charger le moyen de paiement en mode édition
    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(paymentMethodFormProvider.notifier)
            .loadPaymentMethodForEdit(widget.paymentMethodId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(paymentMethodFormProvider);

    // Écouter les changements d'état
    ref.listen<PaymentMethodFormState>(paymentMethodFormProvider,
            (previous, next) {
          if (next is PaymentMethodFormSuccess) {
            _showSuccessDialog(next.message);
          } else if (next is PaymentMethodFormError) {
            _showErrorSnackBar(next.message);
          }
        });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditMode
            ? 'Modifier un moyen de paiement'
            : 'Nouveau moyen de paiement',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.border,
          height: 1.0,
        ),
      ),
    );
  }

  Widget _buildBody(PaymentMethodFormState state) {
    if (state is PaymentMethodFormLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }
    if (state is PaymentMethodFormError && _isEditMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16, color: AppColors.textPrimary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la liste'),
            ),
          ],
        ),
      );
    }

    if (_isEditMode && state is! PaymentMethodFormLoadedForEdit) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.primary),
      );
    }

    return _buildForm(state);
  }

  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    String? helperText,
    Widget? prefixIcon,
    Widget? suffix,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      helperText: helperText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      prefixIcon: prefixIcon,
      suffix: suffix,
      filled: true,
      fillColor: AppColors.surfaceLight,
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
    );
  }

  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildForm(PaymentMethodFormState state) {
    final initialData = state is PaymentMethodFormLoadedForEdit
        ? {
      'name': state.paymentMethod.name,
      'description': state.paymentMethod.description,
      'payment_type': state.paymentMethod.paymentType,
      'requires_authorization': state.paymentMethod.requiresAuthorization,
      'max_amount': state.paymentMethod.maxAmount?.toString(),
      'fee_percentage': state.paymentMethod.feePercentage.toString(),
      'is_active': state.paymentMethod.isActive,
    }
        : {
      'requires_authorization': false,
      'fee_percentage': '0',
      'is_active': true,
    };

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: FormBuilder(
        key: _formKey,
        initialValue: initialData,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildGeneralInfoSection(),
            const SizedBox(height: 24),
            _buildConfigurationSection(),
            const SizedBox(height: 32),
            _buildActionButtons(state),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneralInfoSection() {
    return _buildSectionCard(
      title: 'Informations générales',
      children: [
        FormBuilderTextField(
          name: 'name',
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            labelText: 'Nom du moyen de paiement *',
            hintText: 'Ex: Espèces, Orange Money',
            prefixIcon:
            const Icon(Icons.payment, color: AppColors.textSecondary),
          ),
          validator: FormBuilderValidators.required(
            errorText: 'Le nom est requis',
          ),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'description',
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            labelText: 'Description (optionnel)',
            hintText: 'Brève description du moyen de paiement',
            prefixIcon: const Icon(Icons.description,
                color: AppColors.textSecondary),
          ),
        ),
        const SizedBox(height: 16),
        FormBuilderDropdown<String>(
          name: 'payment_type',
          decoration: _inputDecoration(
            labelText: 'Type de paiement *',
            prefixIcon:
            const Icon(Icons.category, color: AppColors.textSecondary),
          ),
          validator: FormBuilderValidators.required(
              errorText: 'Le type est requis'),
          items: const [
            DropdownMenuItem(
                value: 'cash',
                child: Row(children: [
                  Icon(Icons.attach_money, size: 20),
                  SizedBox(width: 8),
                  Text('Espèces')
                ])),
            DropdownMenuItem(
                value: 'card',
                child: Row(children: [
                  Icon(Icons.credit_card, size: 20),
                  SizedBox(width: 8),
                  Text('Carte bancaire')
                ])),
            DropdownMenuItem(
                value: 'mobile_money',
                child: Row(children: [
                  Icon(Icons.phone_android, size: 20),
                  SizedBox(width: 8),
                  Text('Mobile Money')
                ])),
            DropdownMenuItem(
                value: 'check',
                child: Row(children: [
                  Icon(Icons.receipt, size: 20),
                  SizedBox(width: 8),
                  Text('Chèque')
                ])),
            DropdownMenuItem(
                value: 'credit',
                child: Row(children: [
                  Icon(Icons.account_balance_wallet, size: 20),
                  SizedBox(width: 8),
                  Text('Crédit')
                ])),
            DropdownMenuItem(
                value: 'voucher',
                child: Row(children: [
                  Icon(Icons.card_giftcard, size: 20),
                  SizedBox(width: 8),
                  Text('Bon d\'achat')
                ])),
            DropdownMenuItem(
                value: 'loyalty_points',
                child: Row(children: [
                  Icon(Icons.stars, size: 20),
                  SizedBox(width: 8),
                  Text('Points fidélité')
                ])),
          ],
        ),
      ],
    );
  }

  Widget _buildConfigurationSection() {
    return _buildSectionCard(
      title: 'Configuration',
      children: [
        FormBuilderTextField(
          name: 'max_amount',
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            labelText: 'Montant maximum (optionnel)',
            hintText: 'Ex: 500000',
            prefixIcon:
            const Icon(Icons.attach_money, color: AppColors.textSecondary),
            suffix:
            const Text('FCFA', style: TextStyle(color: AppColors.textSecondary)),
            helperText: 'Laisser vide pour aucune limite',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          validator: FormBuilderValidators.numeric(
            errorText: 'Montant invalide',
          ),
        ),
        const SizedBox(height: 16),
        FormBuilderTextField(
          name: 'fee_percentage',
          style: const TextStyle(color: AppColors.textPrimary),
          decoration: _inputDecoration(
            labelText: 'Frais en pourcentage',
            hintText: 'Ex: 2.5',
            prefixIcon: const Icon(Icons.percent, color: AppColors.textSecondary),
            suffix:
            const Text('%', style: TextStyle(color: AppColors.textSecondary)),
            helperText: 'Pourcentage de frais appliqué (0 = aucun frais)',
          ),
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
          ],
          validator: FormBuilderValidators.compose([
            FormBuilderValidators.numeric(errorText: 'Valeur invalide'),
            FormBuilderValidators.min(0, errorText: 'Minimum 0'),
            FormBuilderValidators.max(100, errorText: 'Maximum 100'),
          ]),
        ),
        const SizedBox(height: 8),
        const Divider(height: 24, color: AppColors.border),
        FormBuilderSwitch(
          name: 'requires_authorization',
          title: const Text('Nécessite une autorisation',
              style: TextStyle(color: AppColors.textPrimary)),
          subtitle: const Text(
            'Une autorisation sera requise pour utiliser ce moyen de paiement',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          activeColor: AppColors.primary,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
        const Divider(height: 16, color: AppColors.border),
        FormBuilderSwitch(
          name: 'is_active',
          title: const Text('Moyen de paiement actif',
              style: TextStyle(color: AppColors.textPrimary)),
          subtitle: const Text(
            'Seuls les moyens actifs sont disponibles au POS',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          activeColor: AppColors.success,
          decoration: const InputDecoration(border: InputBorder.none),
        ),
      ],
    );
  }

  Widget _buildActionButtons(PaymentMethodFormState state) {
    final isSubmitting = state is PaymentMethodFormSubmitting;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Annuler', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton.icon(
            onPressed: isSubmitting ? null : _submitForm,
            icon: isSubmitting
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Icon(Icons.save),
            label: Text(
              isSubmitting
                  ? 'Enregistrement...'
                  : _isEditMode
                  ? 'Modifier'
                  : 'Créer',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _submitForm() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final formData =
      Map<String, dynamic>.from(_formKey.currentState!.value);

      // Convertir les valeurs
      if (formData['max_amount'] != null &&
          formData['max_amount'].toString().isNotEmpty) {
        formData['max_amount'] =
            double.parse(formData['max_amount'].toString());
      } else {
        formData.remove('max_amount');
      }
      if (formData['fee_percentage'] != null) {
        formData['fee_percentage'] =
            double.parse(formData['fee_percentage'].toString());
      }
      formData.removeWhere((key, value) => value == null || value == '');

      // Soumettre
      if (_isEditMode) {
        ref
            .read(paymentMethodFormProvider.notifier)
            .updatePaymentMethod(widget.paymentMethodId!, formData);
      } else {
        ref
            .read(paymentMethodFormProvider.notifier)
            .createPaymentMethod(formData);
      }
    } else {
      _showErrorSnackBar('Veuillez corriger les erreurs du formulaire');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 48,
        ),
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.go('/sales/payment-methods');
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}