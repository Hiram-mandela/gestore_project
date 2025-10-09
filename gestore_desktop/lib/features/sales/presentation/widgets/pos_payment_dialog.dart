// ========================================
// lib/features/sales/presentation/widgets/pos_payment_dialog.dart
// Dialogue de paiement pour POS
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/pos_provider.dart';
import '../providers/pos_state.dart';
import '../providers/payment_methods_provider.dart';
import '../../domain/entities/payment_method_entity.dart';

/// Dialogue de paiement moderne
class PosPaymentDialog extends ConsumerStatefulWidget {
  final double totalAmount;
  final double balance;
  final List<PaymentItem> existingPayments;

  const PosPaymentDialog({
    super.key,
    required this.totalAmount,
    required this.balance,
    required this.existingPayments,
  });

  @override
  ConsumerState<PosPaymentDialog> createState() => _PosPaymentDialogState();
}

class _PosPaymentDialogState extends ConsumerState<PosPaymentDialog> {
  PaymentMethodEntity? _selectedPaymentMethod;
  final _amountController = TextEditingController();
  final _referenceController = TextEditingController();
  final _cashReceivedController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Pré-remplir avec le montant restant
    _amountController.text = widget.balance.toStringAsFixed(0);
  }

  @override
  void dispose() {
    _amountController.dispose();
    _referenceController.dispose();
    _cashReceivedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paymentMethodsState = ref.watch(paymentMethodsProvider);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: 600,
        constraints: const BoxConstraints(maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            _buildHeader(),

            // Corps
            Expanded(
              child: paymentMethodsState is PaymentMethodsLoaded
                  ? _buildBody(paymentMethodsState.paymentMethods)
                  : const Center(child: CircularProgressIndicator()),
            ),

            // Actions
            _buildActions(),
          ],
        ),
      ),
    );
  }

  /// Header
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.payment, color: AppColors.primary, size: 28),
              const SizedBox(width: 12),
              const Text(
                'PAIEMENT',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () => Navigator.of(context).pop(false),
                icon: const Icon(Icons.close),
                tooltip: 'Fermer',
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildAmountSummary(),
        ],
      ),
    );
  }

  /// Résumé des montants
  Widget _buildAmountSummary() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        children: [
          _buildAmountRow('Total', widget.totalAmount, isTotal: true),
          if (widget.existingPayments.isNotEmpty) ...[
            const Divider(height: 16),
            _buildAmountRow(
              'Déjà payé',
              widget.totalAmount - widget.balance,
              color: AppColors.info,
            ),
            const SizedBox(height: 4),
            _buildAmountRow(
              'Reste à payer',
              widget.balance,
              color: AppColors.error,
            ),
          ],
        ],
      ),
    );
  }

  /// Ligne de montant
  Widget _buildAmountRow(
      String label,
      double amount, {
        bool isTotal = false,
        Color? color,
      }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isTotal ? 16 : 14,
            fontWeight: isTotal ? FontWeight.bold : FontWeight.w500,
            color: color,
          ),
        ),
        Text(
          '${amount.toStringAsFixed(0)} FCFA',
          style: TextStyle(
            fontSize: isTotal ? 20 : 16,
            fontWeight: FontWeight.bold,
            color: color ?? AppColors.primary,
          ),
        ),
      ],
    );
  }

  /// Corps du dialogue
  Widget _buildBody(List<PaymentMethodEntity> paymentMethods) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Paiements existants
          if (widget.existingPayments.isNotEmpty) ...[
            _buildExistingPayments(),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
          ],

          // Titre
          const Text(
            'Ajouter un paiement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Moyens de paiement
          _buildPaymentMethodsGrid(paymentMethods),
          const SizedBox(height: 20),

          // Formulaire de paiement
          if (_selectedPaymentMethod != null) ...[
            _buildPaymentForm(),
          ],
        ],
      ),
    );
  }

  /// Paiements déjà ajoutés
  Widget _buildExistingPayments() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Paiements ajoutés',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        ...widget.existingPayments.asMap().entries.map((entry) {
          final index = entry.key;
          final payment = entry.value;
          return _buildExistingPaymentCard(payment, index);
        }).toList(),
      ],
    );
  }

  /// Carte paiement existant
  Widget _buildExistingPaymentCard(PaymentItem payment, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            _getPaymentIcon(payment.paymentMethod.paymentType),
            color: AppColors.success,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  payment.paymentMethod.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (payment.reference != null)
                  Text(
                    'Réf: ${payment.reference}',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            '${payment.amount.toStringAsFixed(0)} F',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.success,
            ),
          ),
          IconButton(
            onPressed: () {
              ref.read(posProvider.notifier).removePayment(index);
              setState(() {});
            },
            icon: const Icon(Icons.close, size: 20),
            color: AppColors.error,
          ),
        ],
      ),
    );
  }

  /// Grille des moyens de paiement
  Widget _buildPaymentMethodsGrid(List<PaymentMethodEntity> methods) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: methods.length,
      itemBuilder: (context, index) {
        final method = methods[index];
        final isSelected = _selectedPaymentMethod?.id == method.id;

        return InkWell(
          onTap: () {
            setState(() {
              _selectedPaymentMethod = method;
              // Pré-remplir le montant si espèces
              if (method.paymentType == 'cash') {
                _cashReceivedController.text = widget.balance.toStringAsFixed(0);
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.primary.withValues(alpha: 0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? AppColors.primary : Colors.grey[300]!,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _getPaymentIcon(method.paymentType),
                  size: 32,
                  color: isSelected ? AppColors.primary : Colors.grey[600],
                ),
                const SizedBox(height: 8),
                Text(
                  method.name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                    color: isSelected ? AppColors.primary : Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Formulaire de paiement
  Widget _buildPaymentForm() {
    final isCash = _selectedPaymentMethod!.paymentType == 'cash';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Montant
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            autofocus: !isCash,
            decoration: InputDecoration(
              labelText: 'Montant *',
              suffixText: 'FCFA',
              border: const OutlineInputBorder(),
              filled: true,
              fillColor: Colors.white,
            ),
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),

          const SizedBox(height: 16),

          // Espèces reçues (pour espèces uniquement)
          if (isCash) ...[
            TextField(
              controller: _cashReceivedController,
              keyboardType: TextInputType.number,
              autofocus: true,
              decoration: InputDecoration(
                labelText: 'Espèces reçues *',
                suffixText: 'FCFA',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
              ],
              onChanged: (value) => setState(() {}),
            ),
            const SizedBox(height: 12),

            // Monnaie à rendre
            if (_cashReceivedController.text.isNotEmpty &&
                _amountController.text.isNotEmpty)
              _buildChangeAmount(),

            const SizedBox(height: 16),
          ],

          // Référence (pour autres modes)
          if (!isCash)
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                labelText: 'Référence/Transaction ID',
                hintText: 'Optionnel',
                border: const OutlineInputBorder(),
                filled: true,
                fillColor: Colors.white,
              ),
            ),

          const SizedBox(height: 16),

          // Bouton ajouter paiement
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              onPressed: _canAddPayment() ? _addPayment : null,
              icon: const Icon(Icons.add),
              label: const Text('AJOUTER CE PAIEMENT'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Montant de la monnaie
  Widget _buildChangeAmount() {
    final received = double.tryParse(_cashReceivedController.text) ?? 0;
    final amount = double.tryParse(_amountController.text) ?? 0;
    final change = received - amount;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: change >= 0 ? AppColors.success.withValues(alpha: 0.1) : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Monnaie à rendre',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: change >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
          Text(
            '${change.toStringAsFixed(0)} FCFA',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: change >= 0 ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  /// Actions
  /// Actions du dialogue
  Widget _buildActions() {
    final posState = ref.watch(posProvider);
    final isReady = posState is PosReady;
    final canFinalize = isReady && (posState).isFullyPaid;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          // Bouton Annuler
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(false),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'ANNULER',
                style: TextStyle(fontSize: 16),
              ),
            ),
          ),

          const SizedBox(width: 16),

          // Bouton Finaliser
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: canFinalize
                  ? () => Navigator.of(context).pop(true)
                  : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.success,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'FINALISER LA VENTE',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== HELPERS ====================

  /// Vérifie si on peut ajouter un paiement
  bool _canAddPayment() {
    if (_selectedPaymentMethod == null) return false;

    final amount = double.tryParse(_amountController.text) ?? 0;
    if (amount <= 0) return false;

    // Pour espèces, vérifier espèces reçues
    if (_selectedPaymentMethod!.paymentType == 'cash') {
      final received = double.tryParse(_cashReceivedController.text) ?? 0;
      if (received < amount) return false;
    }

    return true;
  }

  /// Ajoute un paiement
  void _addPayment() {
    if (!_canAddPayment()) return;

    final amount = double.parse(_amountController.text);
    double? cashReceived;

    if (_selectedPaymentMethod!.paymentType == 'cash') {
      cashReceived = double.parse(_cashReceivedController.text);
    }

    final payment = PaymentItem(
      paymentMethod: _selectedPaymentMethod!,
      amount: amount,
      reference: _referenceController.text.isNotEmpty
          ? _referenceController.text
          : null,
      cashReceived: cashReceived,
    );

    ref.read(posProvider.notifier).addPayment(payment);

    // Réinitialiser le formulaire
    setState(() {
      _selectedPaymentMethod = null;
      _amountController.text = widget.balance.toStringAsFixed(0);
      _referenceController.clear();
      _cashReceivedController.clear();
    });
  }

  /// Retourne l'icône pour un type de paiement
  IconData _getPaymentIcon(String paymentType) {
    switch (paymentType) {
      case 'cash':
        return Icons.attach_money;
      case 'card':
        return Icons.credit_card;
      case 'mobile_money':
        return Icons.phone_android;
      case 'check':
        return Icons.receipt;
      case 'credit':
        return Icons.account_balance_wallet;
      case 'voucher':
        return Icons.card_giftcard;
      case 'loyalty_points':
        return Icons.stars;
      default:
        return Icons.payment;
    }
  }
}