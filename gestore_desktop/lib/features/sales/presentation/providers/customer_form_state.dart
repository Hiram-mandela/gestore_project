// ========================================
// lib/features/sales/presentation/providers/customer_form_state.dart
// États pour le formulaire client
// ========================================

import 'package:equatable/equatable.dart';

/// Données du formulaire client
class CustomerFormData {
  final String name;
  final String? description;
  final String customerType;
  final String? firstName;
  final String? lastName;
  final String? companyName;
  final String? email;
  final String? phone;
  final String? address;
  final String? city;
  final String? postalCode;
  final String? taxNumber;
  final bool marketingConsent;
  final bool isActive;

  const CustomerFormData({
    required this.name,
    this.description,
    this.customerType = 'individual',
    this.firstName,
    this.lastName,
    this.companyName,
    this.email,
    this.phone,
    this.address,
    this.city,
    this.postalCode,
    this.taxNumber,
    this.marketingConsent = false,
    this.isActive = true,
  });

  CustomerFormData copyWith({
    String? name,
    String? description,
    String? customerType,
    String? firstName,
    String? lastName,
    String? companyName,
    String? email,
    String? phone,
    String? address,
    String? city,
    String? postalCode,
    String? taxNumber,
    bool? marketingConsent,
    bool? isActive,
  }) {
    return CustomerFormData(
      name: name ?? this.name,
      description: description ?? this.description,
      customerType: customerType ?? this.customerType,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      companyName: companyName ?? this.companyName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      city: city ?? this.city,
      postalCode: postalCode ?? this.postalCode,
      taxNumber: taxNumber ?? this.taxNumber,
      marketingConsent: marketingConsent ?? this.marketingConsent,
      isActive: isActive ?? this.isActive,
    );
  }
}

/// États du formulaire client
abstract class CustomerFormState extends Equatable {
  const CustomerFormState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CustomerFormInitial extends CustomerFormState {
  const CustomerFormInitial();
}

/// État de chargement
class CustomerFormLoading extends CustomerFormState {
  const CustomerFormLoading();
}

/// État chargé (édition)
class CustomerFormLoaded extends CustomerFormState {
  final CustomerFormData formData;

  const CustomerFormLoaded(this.formData);

  CustomerFormLoaded copyWith({CustomerFormData? formData}) {
    return CustomerFormLoaded(formData ?? this.formData);
  }

  @override
  List<Object?> get props => [formData];
}

/// État de soumission
class CustomerFormSubmitting extends CustomerFormState {
  const CustomerFormSubmitting();
}

/// État de succès
class CustomerFormSuccess extends CustomerFormState {
  final String message;

  const CustomerFormSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

/// État d'erreur
class CustomerFormError extends CustomerFormState {
  final String message;

  const CustomerFormError(this.message);

  @override
  List<Object?> get props => [message];
}
