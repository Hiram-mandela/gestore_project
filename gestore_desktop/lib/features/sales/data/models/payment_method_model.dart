// ========================================
// lib/features/sales/data/models/payment_method_model.dart
// Model PaymentMethod - Data Layer
// ========================================

import '../../domain/entities/payment_method_entity.dart';

/// Model représentant un moyen de paiement
class PaymentMethodModel {
  final String id;
  final String name;
  final String? description;
  final String paymentType;

  // Configuration
  final bool requiresAuthorization;
  final String? maxAmount;
  final String feePercentage;
  final Map<String, dynamic> integrationConfig;

  // État
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  PaymentMethodModel({
    required this.id,
    required this.name,
    this.description,
    required this.paymentType,
    this.requiresAuthorization = false,
    this.maxAmount,
    this.feePercentage = '0.00',
    this.integrationConfig = const {},
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Depuis JSON (API response)
  factory PaymentMethodModel.fromJson(Map<String, dynamic> json) {
    return PaymentMethodModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      paymentType: json['payment_type'] as String,
      requiresAuthorization: json['requires_authorization'] as bool? ?? false,
      maxAmount: json['max_amount']?.toString(),
      feePercentage: json['fee_percentage']?.toString() ?? '0.00',
      integrationConfig:
      json['integration_config'] as Map<String, dynamic>? ?? {},
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'payment_type': paymentType,
      'requires_authorization': requiresAuthorization,
      if (maxAmount != null) 'max_amount': maxAmount,
      'fee_percentage': feePercentage,
      'integration_config': integrationConfig,
      'is_active': isActive,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Conversion vers Entity
  PaymentMethodEntity toEntity() {
    return PaymentMethodEntity(
      id: id,
      name: name,
      description: description,
      paymentType: paymentType,
      requiresAuthorization: requiresAuthorization,
      maxAmount: maxAmount != null ? double.tryParse(maxAmount!) : null,
      feePercentage: double.tryParse(feePercentage) ?? 0.0,
      integrationConfig: integrationConfig,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}