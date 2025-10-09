// ========================================
// lib/features/sales/domain/usecases/customer_usecases.dart
// Use cases pour la gestion des clients
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/customer_entity.dart';
import '../repositories/sales_repository.dart';

// ==================== GET CUSTOMERS ====================

@lazySingleton
class GetCustomersUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetCustomersUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(List<CustomerEntity>?, String?)> call({
    String? search,
    String? customerType,
    bool? isActive,
  }) async {
    try {
      logger.d('📞 UseCase: Récupération des clients (search: $search)');
      return await repository.getCustomers(
        search: search,
        customerType: customerType,
        isActive: isActive,
      );
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération clients: $e');
      return (null, 'Erreur lors de la récupération des clients');
    }
  }
}

// ==================== GET CUSTOMER BY ID ====================

@lazySingleton
class GetCustomerByIdUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetCustomerByIdUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(CustomerEntity?, String?)> call(String id) async {
    try {
      logger.d('📞 UseCase: Récupération client $id');
      return await repository.getCustomerById(id);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération client: $e');
      return (null, 'Erreur lors de la récupération du client');
    }
  }
}

// ==================== CREATE CUSTOMER ====================

@lazySingleton
class CreateCustomerUseCase {
  final SalesRepository repository;
  final Logger logger;

  CreateCustomerUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(CustomerEntity?, String?)> call(Map<String, dynamic> data) async {
    try {
      logger.d('📞 UseCase: Création client ${data['name']}');
      return await repository.createCustomer(data);
    } catch (e) {
      logger.e('❌ UseCase: Erreur création client: $e');
      return (null, 'Erreur lors de la création du client');
    }
  }
}

// ==================== UPDATE CUSTOMER ====================

@lazySingleton
class UpdateCustomerUseCase {
  final SalesRepository repository;
  final Logger logger;

  UpdateCustomerUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(CustomerEntity?, String?)> call(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📞 UseCase: Mise à jour client $id');
      return await repository.updateCustomer(id, data);
    } catch (e) {
      logger.e('❌ UseCase: Erreur mise à jour client: $e');
      return (null, 'Erreur lors de la mise à jour du client');
    }
  }
}

// ==================== DELETE CUSTOMER ====================

@lazySingleton
class DeleteCustomerUseCase {
  final SalesRepository repository;
  final Logger logger;

  DeleteCustomerUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(void, String?)> call(String id) async {
    try {
      logger.d('📞 UseCase: Suppression client $id');
      return await repository.deleteCustomer(id);
    } catch (e) {
      logger.e('❌ UseCase: Erreur suppression client: $e');
      return (null, 'Erreur lors de la suppression du client');
    }
  }
}

// ==================== GET CUSTOMER LOYALTY ====================

@lazySingleton
class GetCustomerLoyaltyUseCase {
  final SalesRepository repository;
  final Logger logger;

  GetCustomerLoyaltyUseCase({
    required this.repository,
    required this.logger,
  });

  Future<(Map<String, dynamic>?, String?)> call(String customerId) async {
    try {
      logger.d('📞 UseCase: Récupération fidélité client $customerId');
      return await repository.getCustomerLoyalty(customerId);
    } catch (e) {
      logger.e('❌ UseCase: Erreur récupération fidélité: $e');
      return (null, 'Erreur lors de la récupération de la fidélité');
    }
  }
}