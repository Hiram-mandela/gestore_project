// ========================================
// lib/features/sales/data/models/customer_model.dart
// Model Customer - Data Layer
// ========================================

import '../../domain/entities/customer_entity.dart';

/// Model représentant un client (mapping API)
class CustomerModel {
  final String id;
  final String customerCode;
  final String name;
  final String? description;
  final String customerType;

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
  final String totalPurchases; // String car vient de l'API comme "0.00"
  final int purchaseCount;
  final String? lastPurchaseDate;

  // Préférences
  final String? preferredPaymentMethod;
  final bool marketingConsent;

  // État
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  CustomerModel({
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
    this.totalPurchases = '0.00',
    this.purchaseCount = 0,
    this.lastPurchaseDate,
    this.preferredPaymentMethod,
    this.marketingConsent = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  /// Depuis JSON (API response)
  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] as String,
      customerCode: json['customer_code'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      customerType: json['customer_type'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      companyName: json['company_name'] as String?,
      taxNumber: json['tax_number'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      address: json['address'] as String?,
      city: json['city'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String? ?? 'Côte d\'Ivoire',
      loyaltyCardNumber: json['loyalty_card_number'] as String?,
      loyaltyPoints: json['loyalty_points'] as int? ?? 0,
      totalPurchases: json['total_purchases']?.toString() ?? '0.00',
      purchaseCount: json['purchase_count'] as int? ?? 0,
      lastPurchaseDate: json['last_purchase_date'] as String?,
      preferredPaymentMethod: json['preferred_payment_method'] as String?,
      marketingConsent: json['marketing_consent'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'customer_code': customerCode,
      'name': name,
      if (description != null) 'description': description,
      'customer_type': customerType,
      if (firstName != null) 'first_name': firstName,
      if (lastName != null) 'last_name': lastName,
      if (companyName != null) 'company_name': companyName,
      if (taxNumber != null) 'tax_number': taxNumber,
      if (email != null) 'email': email,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (city != null) 'city': city,
      if (postalCode != null) 'postal_code': postalCode,
      'country': country,
      if (loyaltyCardNumber != null) 'loyalty_card_number': loyaltyCardNumber,
      'loyalty_points': loyaltyPoints,
      'total_purchases': totalPurchases,
      'purchase_count': purchaseCount,
      if (lastPurchaseDate != null) 'last_purchase_date': lastPurchaseDate,
      if (preferredPaymentMethod != null)
        'preferred_payment_method': preferredPaymentMethod,
      'marketing_consent': marketingConsent,
      'is_active': isActive,
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Conversion vers Entity
  CustomerEntity toEntity() {
    return CustomerEntity(
      id: id,
      customerCode: customerCode,
      name: name,
      description: description,
      customerType: customerType,
      firstName: firstName,
      lastName: lastName,
      companyName: companyName,
      taxNumber: taxNumber,
      email: email,
      phone: phone,
      address: address,
      city: city,
      postalCode: postalCode,
      country: country,
      loyaltyCardNumber: loyaltyCardNumber,
      loyaltyPoints: loyaltyPoints,
      totalPurchases: double.tryParse(totalPurchases) ?? 0.0,
      purchaseCount: purchaseCount,
      lastPurchaseDate: lastPurchaseDate != null
          ? DateTime.tryParse(lastPurchaseDate!)
          : null,
      preferredPaymentMethod: preferredPaymentMethod,
      marketingConsent: marketingConsent,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }

  /// Depuis Entity (pour requêtes)
  static Map<String, dynamic> fromEntity(CustomerEntity entity) {
    return {
      'name': entity.name,
      if (entity.description != null) 'description': entity.description,
      'customer_type': entity.customerType,
      if (entity.firstName != null) 'first_name': entity.firstName,
      if (entity.lastName != null) 'last_name': entity.lastName,
      if (entity.companyName != null) 'company_name': entity.companyName,
      if (entity.taxNumber != null) 'tax_number': entity.taxNumber,
      if (entity.email != null) 'email': entity.email,
      if (entity.phone != null) 'phone': entity.phone,
      if (entity.address != null) 'address': entity.address,
      if (entity.city != null) 'city': entity.city,
      if (entity.postalCode != null) 'postal_code': entity.postalCode,
      'country': entity.country,
      if (entity.loyaltyCardNumber != null)
        'loyalty_card_number': entity.loyaltyCardNumber,
      if (entity.preferredPaymentMethod != null)
        'preferred_payment_method': entity.preferredPaymentMethod,
      'marketing_consent': entity.marketingConsent,
      'is_active': entity.isActive,
    };
  }
}