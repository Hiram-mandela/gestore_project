// ========================================
// lib/features/sales/domain/entities/payment_entity.dart
// Entité Payment - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';
import 'payment_method_entity.dart';

/// Entité représentant un paiement
class PaymentEntity extends Equatable {
  final String id;
  final PaymentMethodEntity? paymentMethod;
  final String paymentMethodId;
  final double amount;
  final String status; // 'pending', 'completed', 'failed', 'cancelled', 'refunded'

  // Informations spécifiques au type de paiement
  final String? cardLastDigits;
  final String? authorizationCode;
  final String? transactionId;
  final String? mobileMoneyNumber;
  final String? checkNumber;

  // Espèces
  final double? cashReceived;
  final double? cashChange;

  // Métadonnées
  final DateTime paymentDate;
  final String? notes;
  final String? createdBy;
  final DateTime createdAt;

  const PaymentEntity({
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

  /// Retourne le statut formaté
  String get statusDisplay {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminé';
      case 'failed':
        return 'Échoué';
      case 'cancelled':
        return 'Annulé';
      case 'refunded':
        return 'Remboursé';
      default:
        return status;
    }
  }

  /// Vérifie si le paiement est complété
  bool get isCompleted => status == 'completed';

  /// Vérifie si le paiement a échoué
  bool get isFailed => status == 'failed';

  /// Vérifie si c'est un paiement en espèces
  bool get isCashPayment => paymentMethod?.paymentType == 'cash';

  /// Copie avec modifications
  PaymentEntity copyWith({
    String? id,
    PaymentMethodEntity? paymentMethod,
    String? paymentMethodId,
    double? amount,
    String? status,
    String? cardLastDigits,
    String? authorizationCode,
    String? transactionId,
    String? mobileMoneyNumber,
    String? checkNumber,
    double? cashReceived,
    double? cashChange,
    DateTime? paymentDate,
    String? notes,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return PaymentEntity(
      id: id ?? this.id,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentMethodId: paymentMethodId ?? this.paymentMethodId,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      cardLastDigits: cardLastDigits ?? this.cardLastDigits,
      authorizationCode: authorizationCode ?? this.authorizationCode,
      transactionId: transactionId ?? this.transactionId,
      mobileMoneyNumber: mobileMoneyNumber ?? this.mobileMoneyNumber,
      checkNumber: checkNumber ?? this.checkNumber,
      cashReceived: cashReceived ?? this.cashReceived,
      cashChange: cashChange ?? this.cashChange,
      paymentDate: paymentDate ?? this.paymentDate,
      notes: notes ?? this.notes,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    paymentMethod,
    paymentMethodId,
    amount,
    status,
    cardLastDigits,
    authorizationCode,
    transactionId,
    mobileMoneyNumber,
    checkNumber,
    cashReceived,
    cashChange,
    paymentDate,
    notes,
    createdBy,
    createdAt,
  ];

  @override
  String toString() => 'PaymentEntity(id: $id, amount: $amount, status: $status)';
}