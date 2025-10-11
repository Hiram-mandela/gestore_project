// ========================================
// lib/features/sales/domain/repositories/sales_repository.dart
// Repository abstrait pour Sales - Domain Layer
// ========================================

import '../entities/customer_entity.dart';
import '../entities/payment_method_entity.dart';
import '../entities/sale_entity.dart';
import '../entities/sale_detail_entity.dart';
import '../entities/discount_entity.dart';
import '../../../inventory/domain/entities/paginated_response_entity.dart';

/// Repository abstrait pour la gestion des ventes
/// Contrat entre Domain Layer et Data Layer
abstract class SalesRepository {
  // ==================== CUSTOMERS - CRUD ====================

  Future<(List<CustomerEntity>?, String?)> getCustomers({
    String? search,
    String? customerType,
    bool? isActive,
  });

  Future<(CustomerEntity?, String?)> getCustomerById(String id);

  Future<(CustomerEntity?, String?)> createCustomer(Map<String, dynamic> data);

  Future<(CustomerEntity?, String?)> updateCustomer(
      String id,
      Map<String, dynamic> data,
      );

  Future<(void, String?)> deleteCustomer(String id);

  Future<(Map<String, dynamic>?, String?)> getCustomerLoyalty(String customerId);

  // ==================== PAYMENT METHODS ====================

  Future<(List<PaymentMethodEntity>?, String?)> getPaymentMethods({
    bool? isActive,
  });

  Future<(PaymentMethodEntity?, String?)> getPaymentMethodById(String id);

  Future<(PaymentMethodEntity?, String?)> createPaymentMethod(
      Map<String, dynamic> data,
      );

  /// Met à jour un moyen de paiement existant
  Future<(PaymentMethodEntity?, String?)> updatePaymentMethod(
      String id,
      Map<String, dynamic> data,
      );

  /// Supprime un moyen de paiement
  Future<(void, String?)> deletePaymentMethod(String id);

  // ==================== DISCOUNTS ====================

  Future<(List<DiscountEntity>?, String?)> getActiveDiscounts();

  Future<(DiscountEntity?, String?)> getDiscountById(String id);

  // ==================== SALES - LECTURE ====================

  Future<(PaginatedResponseEntity<SaleEntity>?, String?)> getSales({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? saleType,
    String? customerId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? ordering,
  });

  Future<(SaleDetailEntity?, String?)> getSaleDetail(String saleId);

  Future<(Map<String, dynamic>?, String?)> getDailySummary();

  // ==================== POS OPERATIONS ====================

  /// Calcule le montant total d'une vente avant finalisation
  Future<(Map<String, dynamic>?, String?)> calculateSale({
    required List<Map<String, dynamic>> items,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
  });

  /// Finalise une vente (checkout complet)
  Future<(SaleDetailEntity?, String?)> checkout({
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> payments,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
    String? notes,
  });

  /// Annule une vente
  Future<(SaleDetailEntity?, String?)> voidSale({
    required String saleId,
    required String reason,
    String? authorizationCode,
  });

  /// Retourne une vente
  Future<(SaleDetailEntity?, String?)> returnSale({
    required String originalSaleId,
    required List<Map<String, dynamic>> items,
    required String reason,
    required String refundMethod,
  });
}