// ========================================
// lib/features/sales/domain/entities/payment_method_entity.dart
// Entité PaymentMethod - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';

/// Entité représentant un moyen de paiement
class PaymentMethodEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String paymentType; // 'cash', 'card', 'mobile_money', 'check', 'credit', 'voucher', 'loyalty_points'

  // Configuration
  final bool requiresAuthorization;
  final double? maxAmount;
  final double feePercentage;
  final Map<String, dynamic> integrationConfig;

  // État
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const PaymentMethodEntity({
    required this.id,
    required this.name,
    this.description,
    required this.paymentType,
    this.requiresAuthorization = false,
    this.maxAmount,
    this.feePercentage = 0.0,
    this.integrationConfig = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Retourne le type de paiement formaté
  String get paymentTypeDisplay {
    switch (paymentType) {
      case 'cash':
        return 'Espèces';
      case 'card':
        return 'Carte bancaire';
      case 'mobile_money':
        return 'Mobile Money';
      case 'check':
        return 'Chèque';
      case 'credit':
        return 'Crédit';
      case 'voucher':
        return 'Bon d\'achat';
      case 'loyalty_points':
        return 'Points fidélité';
      default:
        return paymentType;
    }
  }

  /// Vérifie si un montant est valide pour ce mode de paiement
  bool isAmountValid(double amount) {
    if (maxAmount == null) return true;
    return amount <= maxAmount!;
  }

  /// Calcule les frais pour un montant donné
  double calculateFee(double amount) {
    return amount * (feePercentage / 100);
  }

  /// Retourne l'icône associée au type de paiement
  String get iconName {
    switch (paymentType) {
      case 'cash':
        return 'attach_money';
      case 'card':
        return 'credit_card';
      case 'mobile_money':
        return 'phone_android';
      case 'check':
        return 'receipt';
      case 'credit':
        return 'account_balance_wallet';
      case 'voucher':
        return 'card_giftcard';
      case 'loyalty_points':
        return 'stars';
      default:
        return 'payment';
    }
  }

  /// Copie avec modifications
  PaymentMethodEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? paymentType,
    bool? requiresAuthorization,
    double? maxAmount,
    double? feePercentage,
    Map<String, dynamic>? integrationConfig,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return PaymentMethodEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      paymentType: paymentType ?? this.paymentType,
      requiresAuthorization: requiresAuthorization ?? this.requiresAuthorization,
      maxAmount: maxAmount ?? this.maxAmount,
      feePercentage: feePercentage ?? this.feePercentage,
      integrationConfig: integrationConfig ?? this.integrationConfig,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    paymentType,
    requiresAuthorization,
    maxAmount,
    feePercentage,
    integrationConfig,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'PaymentMethodEntity(id: $id, name: $name, type: $paymentType)';
}