// ========================================
// lib/features/sales/data/models/payment_model.dart
// Model Payment - Data Layer
// ========================================

import '../../domain/entities/payment_entity.dart';
import 'payment_method_model.dart';

/// Model représentant un paiement
class PaymentModel {
  final String id;
  final PaymentMethodModel? paymentMethod;
  final String paymentMethodId;
  final String amount;
  final String status;

  // Informations spécifiques
  final String? cardLastDigits;
  final String? authorizationCode;
  final String? transactionId;
  final String? mobileMoneyNumber;
  final String? checkNumber;

  // Espèces
  final String? cashReceived;
  final String? cashChange;

  // Métadonnées
  final String paymentDate;
  final String? notes;
  final String? createdBy;
  final String createdAt;

  PaymentModel({
    required this.id,
    this.paymentMethod,
    required this.paymentMethodId,
    required this.amount,
    this.status = 'pending',
    this.cardLastDigits,
    this.authorizationCode,
    this.transactionId,
    this.mobileMoneyNumber,
    this.checkNumber,
    this.cashReceived,
    this.cashChange,
    required this.paymentDate,
    this.notes,
    this.createdBy,
    required this.createdAt,
  });

  /// Depuis JSON (API response)
  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json['id'] as String,
      paymentMethod: json['payment_method'] != null
          ? PaymentMethodModel.fromJson(json['payment_method'] as Map<String, dynamic>)
          : null,
      paymentMethodId: json['payment_method_id'] as String? ??
          (json['payment_method'] != null ? json['payment_method']['id'] as String : ''),
      amount: json['amount']?.toString() ?? '0.00',
      status: json['status'] as String? ?? 'pending',
      cardLastDigits: json['card_last_digits'] as String?,
      authorizationCode: json['authorization_code'] as String?,
      transactionId: json['transaction_id'] as String?,
      mobileMoneyNumber: json['mobile_money_number'] as String?,
      checkNumber: json['check_number'] as String?,
      cashReceived: json['cash_received']?.toString(),
      cashChange: json['cash_change']?.toString(),
      paymentDate: json['payment_date'] as String,
      notes: json['notes'] as String?,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'payment_method_id': paymentMethodId,
      'amount': amount,
      'status': status,
      if (cardLastDigits != null) 'card_last_digits': cardLastDigits,
      if (authorizationCode != null) 'authorization_code': authorizationCode,
      if (transactionId != null) 'transaction_id': transactionId,
      if (mobileMoneyNumber != null) 'mobile_money_number': mobileMoneyNumber,
      if (checkNumber != null) 'check_number': checkNumber,
      if (cashReceived != null) 'cash_received': cashReceived,
      if (cashChange != null) 'cash_change': cashChange,
      'payment_date': paymentDate,
      if (notes != null) 'notes': notes,
      'created_at': createdAt,
    };
  }

  /// Conversion vers Entity
  PaymentEntity toEntity() {
    return PaymentEntity(
      id: id,
      paymentMethod: paymentMethod?.toEntity(),
      paymentMethodId: paymentMethodId,
      amount: double.tryParse(amount) ?? 0.0,
      status: status,
      cardLastDigits: cardLastDigits,
      authorizationCode: authorizationCode,
      transactionId: transactionId,
      mobileMoneyNumber: mobileMoneyNumber,
      checkNumber: checkNumber,
      cashReceived: cashReceived != null ? double.tryParse(cashReceived!) : null,
      cashChange: cashChange != null ? double.tryParse(cashChange!) : null,
      paymentDate: DateTime.parse(paymentDate),
      notes: notes,
      createdBy: createdBy,
      createdAt: DateTime.parse(createdAt),
    );
  }

  /// Depuis Entity (pour requêtes POST)
  static Map<String, dynamic> fromEntity(PaymentEntity entity) {
    return {
      'payment_method_id': entity.paymentMethodId,
      'amount': entity.amount,
      'status': entity.status,
      if (entity.cardLastDigits != null) 'card_last_digits': entity.cardLastDigits,
      if (entity.authorizationCode != null) 'authorization_code': entity.authorizationCode,
      if (entity.transactionId != null) 'transaction_id': entity.transactionId,
      if (entity.mobileMoneyNumber != null) 'mobile_money_number': entity.mobileMoneyNumber,
      if (entity.checkNumber != null) 'check_number': entity.checkNumber,
      if (entity.cashReceived != null) 'cash_received': entity.cashReceived,
      if (entity.cashChange != null) 'cash_change': entity.cashChange,
      if (entity.notes != null) 'notes': entity.notes,
    };
  }
}