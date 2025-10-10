// ========================================
// FICHIER 2: customer_form_provider.dart - VERSION FINALE CORRIGÉE
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/customer_usecases.dart';
import 'customer_form_state.dart';

final customerFormProvider = StateNotifierProvider<CustomerFormNotifier, CustomerFormState>((ref) {
  return CustomerFormNotifier(
    getCustomerByIdUseCase: getIt<GetCustomerByIdUseCase>(),
    createCustomerUseCase: getIt<CreateCustomerUseCase>(),
    updateCustomerUseCase: getIt<UpdateCustomerUseCase>(),
    logger: getIt<Logger>(),
  );
});

class CustomerFormNotifier extends StateNotifier<CustomerFormState> {
  final GetCustomerByIdUseCase getCustomerByIdUseCase;
  final CreateCustomerUseCase createCustomerUseCase;
  final UpdateCustomerUseCase updateCustomerUseCase;
  final Logger logger;

  CustomerFormNotifier({
    required this.getCustomerByIdUseCase,
    required this.createCustomerUseCase,
    required this.updateCustomerUseCase,
    required this.logger,
  }) : super(const CustomerFormLoaded(CustomerFormData(name: '')));

  Future<void> loadCustomer(String customerId) async {
    state = const CustomerFormLoading();

    try {
      logger.i('📋 Chargement client: $customerId');

      final (customer, error) = await getCustomerByIdUseCase(customerId);

      if (error != null) throw Exception(error);
      if (customer == null) throw Exception('Client non trouvé');

      state = CustomerFormLoaded(CustomerFormData(
        name: customer.name,
        description: customer.description,
        customerType: customer.customerType,
        firstName: customer.firstName,
        lastName: customer.lastName,
        companyName: customer.companyName,
        email: customer.email,
        phone: customer.phone,
        address: customer.address,
        city: customer.city,
        postalCode: customer.postalCode,
        taxNumber: customer.taxNumber,
        marketingConsent: customer.marketingConsent,
        isActive: customer.isActive,
      ));

      logger.i('✅ Client chargé');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur chargement client', error: e, stackTrace: stackTrace);
      state = CustomerFormError(e.toString());
    }
  }

  Future<void> createCustomer(Map<String, dynamic> data) async {
    state = const CustomerFormSubmitting();

    try {
      logger.i('➕ Création client...');

      final (customer, error) = await createCustomerUseCase(data);

      if (error != null) throw Exception(error);

      state = const CustomerFormSuccess('Client créé avec succès');
      logger.i('✅ Client créé');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur création client', error: e, stackTrace: stackTrace);
      state = CustomerFormError(e.toString());
    }
  }

  Future<void> updateCustomer(String customerId, Map<String, dynamic> data) async {
    state = const CustomerFormSubmitting();

    try {
      logger.i('✏️ Modification client: $customerId');

      // ⭐ CORRECTION: updateCustomerUseCase prend 2 arguments positionnels
      final (customer, error) = await updateCustomerUseCase(customerId, data);

      if (error != null) throw Exception(error);

      state = const CustomerFormSuccess('Client modifié avec succès');
      logger.i('✅ Client modifié');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur modification client', error: e, stackTrace: stackTrace);
      state = CustomerFormError(e.toString());
    }
  }

  void updateCustomerType(String type) {
    if (state is CustomerFormLoaded) {
      final currentState = state as CustomerFormLoaded;
      state = currentState.copyWith(
        formData: currentState.formData.copyWith(customerType: type),
      );
    }
  }

  void updateMarketingConsent(bool value) {
    if (state is CustomerFormLoaded) {
      final currentState = state as CustomerFormLoaded;
      state = currentState.copyWith(
        formData: currentState.formData.copyWith(marketingConsent: value),
      );
    }
  }

  void updateActiveStatus(bool value) {
    if (state is CustomerFormLoaded) {
      final currentState = state as CustomerFormLoaded;
      state = currentState.copyWith(
        formData: currentState.formData.copyWith(isActive: value),
      );
    }
  }
}