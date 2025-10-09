// ========================================
// lib/features/sales/domain/entities/customer_entity.dart
// Entité Customer - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';

/// Entité représentant un client
class CustomerEntity extends Equatable {
  final String id;
  final String customerCode;
  final String name;
  final String? description;
  final String customerType; // 'individual', 'company', 'professional'

  // Informations personne
  final String? firstName;
  final String? lastName;

  // Informations entreprise
  final String? companyName;
  final String? taxNumber;

  // Contact
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String country;

  // Fidélité
  final String? loyaltyCardNumber;
  final int loyaltyPoints;

  // Statistiques
  final double totalPurchases;
  final int purchaseCount;
  final DateTime? lastPurchaseDate;

  // Préférences
  final String? preferredPaymentMethod;
  final bool marketingConsent;

  // État
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CustomerEntity({
    required this.id,
    required this.customerCode,
    required this.name,
    this.description,
    required this.customerType,
    this.firstName,
    this.lastName,
    this.companyName,
    this.taxNumber,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.country = 'Côte d\'Ivoire',
    this.loyaltyCardNumber,
    this.loyaltyPoints = 0,
    this.totalPurchases = 0.0,
    this.purchaseCount = 0,
    this.lastPurchaseDate,
    this.preferredPaymentMethod,
    this.marketingConsent = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Retourne le nom complet du client
  String get fullName {
    if (customerType == 'company') {
      return companyName ?? name;
    }
    if (firstName != null && lastName != null) {
      return '$firstName $lastName'.trim();
    }
    return name;
  }

  /// Vérifie si le client peut utiliser des points fidélité
  bool get canUseLoyaltyPoints => loyaltyPoints > 0;

  /// Retourne le type de client formaté
  String get customerTypeDisplay {
    switch (customerType) {
      case 'individual':
        return 'Particulier';
      case 'company':
        return 'Entreprise';
      case 'professional':
        return 'Professionnel';
      default:
        return customerType;
    }
  }

  /// Copie avec modifications
  CustomerEntity copyWith({
    String? id,
    String? customerCode,
    String? name,
    String? description,
    String? customerType,
    String? firstName,
    String? lastName,
    String? companyName,
    String? taxNumber,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? country,
    String? loyaltyCardNumber,
    int? loyaltyPoints,
    double? totalPurchases,
    int? purchaseCount,
    DateTime? lastPurchaseDate,
    String? preferredPaymentMethod,
    bool? marketingConsent,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CustomerEntity(
      id: id ?? this.id,
      customerCode: customerCode ?? this.customerCode,
      name: name ?? this.name,
      description: description ?? this.description,
      customerType: customerType ?? this.customerType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      taxNumber: taxNumber ?? this.taxNumber,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      country: country ?? this.country,
      loyaltyCardNumber: loyaltyCardNumber ?? this.loyaltyCardNumber,
      loyaltyPoints: loyaltyPoints ?? this.loyaltyPoints,
      totalPurchases: totalPurchases ?? this.totalPurchases,
      purchaseCount: purchaseCount ?? this.purchaseCount,
      lastPurchaseDate: lastPurchaseDate ?? this.lastPurchaseDate,
      preferredPaymentMethod: preferredPaymentMethod ?? this.preferredPaymentMethod,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    customerCode,
    name,
    description,
    customerType,
    firstName,
    lastName,
    companyName,
    taxNumber,
    email,
    phone,
    address,
    city,
    postalCode,
    country,
    loyaltyCardNumber,
    loyaltyPoints,
    totalPurchases,
    purchaseCount,
    lastPurchaseDate,
    preferredPaymentMethod,
    marketingConsent,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'CustomerEntity(id: $id, code: $customerCode, name: $fullName)';
}