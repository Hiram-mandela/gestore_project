// ========================================
// lib/features/sales/data/datasources/sales_remote_datasource.dart
// DataSource distant pour Sales - Data Layer
// ========================================

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/paginated_response_model.dart';
import '../models/customer_model.dart';
import '../models/payment_method_model.dart';
import '../models/sale_model.dart';
import '../models/sale_detail_model.dart';
import '../models/discount_model.dart';

/// DataSource pour les appels API Sales
@lazySingleton
class SalesRemoteDataSource {
  final ApiClient apiClient;
  final Logger logger;

  SalesRemoteDataSource({
    required this.apiClient,
    required this.logger,
  });

  // ==================== CUSTOMERS ====================

  /// Récupère la liste des clients
  Future<List<CustomerModel>> getCustomers({
    String? search,
    String? customerType,
    bool? isActive,
  }) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.customers}');

      final queryParams = <String, dynamic>{};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (customerType != null) queryParams['customer_type'] = customerType;
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await apiClient.get(
        ApiEndpoints.customers,
        queryParameters: queryParams,
      );

      final List<dynamic> results = response.data['results'] as List<dynamic>;
      return results
          .map((json) => CustomerModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET customers: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère un client par ID
  Future<CustomerModel> getCustomerById(String id) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.customerDetail(id)}');

      final response = await apiClient.get(ApiEndpoints.customerDetail(id));

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET customer $id: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Crée un nouveau client
  Future<CustomerModel> createCustomer(Map<String, dynamic> data) async {
    try {
      logger.d('🌐 DataSource: POST ${ApiEndpoints.customers}');

      final response = await apiClient.post(
        ApiEndpoints.customers,
        data: data,
      );

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur POST customer: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Met à jour un client
  Future<CustomerModel> updateCustomer(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('🌐 DataSource: PUT ${ApiEndpoints.customerDetail(id)}');

      final response = await apiClient.put(
        ApiEndpoints.customerDetail(id),
        data: data,
      );

      return CustomerModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur PUT customer $id: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Supprime un client
  Future<void> deleteCustomer(String id) async {
    try {
      logger.d('🌐 DataSource: DELETE ${ApiEndpoints.customerDetail(id)}');

      await apiClient.delete(ApiEndpoints.customerDetail(id));
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur DELETE customer $id: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère les informations de fidélité d'un client
  Future<Map<String, dynamic>> getCustomerLoyalty(String customerId) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.customerLoyaltyPoints(customerId)}');

      final response = await apiClient.get(
        ApiEndpoints.customerLoyaltyPoints(customerId),
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET customer loyalty: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  // ==================== PAYMENT METHODS ====================

  /// Récupère la liste des moyens de paiement
  Future<List<PaymentMethodModel>> getPaymentMethods({
    bool? isActive,
  }) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.paymentMethods}');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await apiClient.get(
        ApiEndpoints.paymentMethods,
        queryParameters: queryParams,
      );

      final List<dynamic> results = response.data['results'] as List<dynamic>;
      return results
          .map((json) =>
          PaymentMethodModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET payment methods: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère un moyen de paiement par ID
  Future<PaymentMethodModel> getPaymentMethodById(String id) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.paymentMethodDetail(id)}');

      final response =
      await apiClient.get(ApiEndpoints.paymentMethodDetail(id));

      return PaymentMethodModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET payment method $id: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Crée un nouveau moyen de paiement
  Future<PaymentMethodModel> createPaymentMethod(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📡 API: POST ${ApiEndpoints.paymentMethods}');
      logger.d('Data: $data');

      final response = await apiClient.post(
        ApiEndpoints.paymentMethods,
        data: data,
      );

      logger.i('✅ API: Moyen de paiement créé avec succès');
      return PaymentMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ API: Erreur création moyen de paiement: ${e.message}');
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          // Extraire le premier message d'erreur
          final firstError = errorData.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          } else if (firstError is String) {
            throw Exception(firstError);
          }
        }
      }
      throw Exception('Erreur lors de la création du moyen de paiement');
    } catch (e) {
      logger.e('❌ API: Exception création moyen de paiement: $e');
      throw Exception('Erreur inattendue lors de la création');
    }
  }

  /// Met à jour un moyen de paiement
  Future<PaymentMethodModel> updatePaymentMethod(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📡 API: PUT ${ApiEndpoints.paymentMethodDetail(id)}');
      logger.d('Data: $data');

      final response = await apiClient.put(
        ApiEndpoints.paymentMethodDetail(id),
        data: data,
      );

      logger.i('✅ API: Moyen de paiement modifié avec succès');
      return PaymentMethodModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ API: Erreur modification moyen de paiement: ${e.message}');
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          final firstError = errorData.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          } else if (firstError is String) {
            throw Exception(firstError);
          }
        }
      }
      throw Exception('Erreur lors de la modification du moyen de paiement');
    } catch (e) {
      logger.e('❌ API: Exception modification moyen de paiement: $e');
      throw Exception('Erreur inattendue lors de la modification');
    }
  }

  /// Supprime un moyen de paiement
  Future<void> deletePaymentMethod(String id) async {
    try {
      logger.d('📡 API: DELETE ${ApiEndpoints.paymentMethodDetail(id)}');

      await apiClient.delete(ApiEndpoints.paymentMethodDetail(id));

      logger.i('✅ API: Moyen de paiement supprimé avec succès');
    } on DioException catch (e) {
      logger.e('❌ API: Erreur suppression moyen de paiement: ${e.message}');
      if (e.response != null && e.response!.data != null) {
        final errorData = e.response!.data;
        if (errorData is Map<String, dynamic>) {
          if (errorData.containsKey('detail')) {
            throw Exception(errorData['detail'].toString());
          }
          final firstError = errorData.values.first;
          if (firstError is List && firstError.isNotEmpty) {
            throw Exception(firstError.first.toString());
          } else if (firstError is String) {
            throw Exception(firstError);
          }
        }
      }
      throw Exception('Erreur lors de la suppression du moyen de paiement');
    } catch (e) {
      logger.e('❌ API: Exception suppression moyen de paiement: $e');
      throw Exception('Erreur inattendue lors de la suppression');
    }
  }

  // ==================== DISCOUNTS ====================

  /// Récupère les remises actives
  Future<List<DiscountModel>> getActiveDiscounts() async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.discountsActive}');

      final response = await apiClient.get(ApiEndpoints.discountsActive);

      final List<dynamic> results = response.data['results'] as List<dynamic>;
      return results
          .map((json) => DiscountModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET active discounts: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère une remise par ID
  Future<DiscountModel> getDiscountById(String id) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.discountDetail(id)}');

      final response = await apiClient.get(ApiEndpoints.discountDetail(id));

      return DiscountModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET discount $id: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  // ==================== SALES ====================

  /// Récupère la liste des ventes avec pagination
  Future<PaginatedResponseModel<SaleModel>> getSales({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? status,
    String? saleType,
    String? customerId,
    DateTime? dateFrom,
    DateTime? dateTo,
    String? ordering,
  }) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.sales} page $page');

      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (status != null) queryParams['status'] = status;
      if (saleType != null) queryParams['sale_type'] = saleType;
      if (customerId != null) queryParams['customer'] = customerId;
      if (dateFrom != null) {
        queryParams['date_from'] = dateFrom.toIso8601String();
      }
      if (dateTo != null) {
        queryParams['date_to'] = dateTo.toIso8601String();
      }
      if (ordering != null) queryParams['ordering'] = ordering;

      final response = await apiClient.get(
        ApiEndpoints.sales,
        queryParameters: queryParams,
      );

      return PaginatedResponseModel.fromJson(
        response.data as Map<String, dynamic>,
            (json) => SaleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET sales: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère le détail complet d'une vente
  Future<SaleDetailModel> getSaleDetail(String saleId) async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.saleDetail(saleId)}');

      final response = await apiClient.get(ApiEndpoints.saleDetail(saleId));

      return SaleDetailModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET sale detail: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère le résumé quotidien des ventes
  Future<Map<String, dynamic>> getDailySummary() async {
    try {
      logger.d('🌐 DataSource: GET ${ApiEndpoints.sales}/daily-summary/');

      final response = await apiClient.get('${ApiEndpoints.sales}daily-summary/');

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur GET daily summary: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  // ==================== POS OPERATIONS ====================

  /// Calcule le montant total d'une vente avant finalisation
  Future<Map<String, dynamic>> calculateSale({
    required List<Map<String, dynamic>> items,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
  }) async {
    try {
      logger.d('🌐 DataSource: POST ${ApiEndpoints.posCalculate}');

      final data = {
        'items': items,
        if (customerId != null) 'customer_id': customerId,
        'loyalty_points_to_use': loyaltyPointsToUse,
        if (discountCodes.isNotEmpty) 'discount_codes': discountCodes,
      };

      final response = await apiClient.post(
        ApiEndpoints.posCalculate,
        data: data,
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur POST calculate sale: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Finalise une vente (checkout complet)
  Future<SaleDetailModel> checkout({
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> payments,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
    String? notes,
  }) async {
    try {
      logger.d('🌐 DataSource: POST ${ApiEndpoints.posCheckout}');

      final data = {
        'items': items,
        'payments': payments,
        if (customerId != null) 'customer_id': customerId,
        'loyalty_points_to_use': loyaltyPointsToUse,
        if (discountCodes.isNotEmpty) 'discount_codes': discountCodes,
        if (notes != null && notes.isNotEmpty) 'notes': notes,
      };

      final response = await apiClient.post(
        ApiEndpoints.posCheckout,
        data: data,
      );

      // Le backend retourne { "sale": {...}, "message": "..." }
      final saleData = response.data['sale'] as Map<String, dynamic>;
      return SaleDetailModel.fromJson(saleData);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur POST checkout: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Annule une vente
  Future<SaleDetailModel> voidSale({
    required String saleId,
    required String reason,
    String? authorizationCode,
  }) async {
    try {
      logger.d('🌐 DataSource: POST ${ApiEndpoints.saleVoid(saleId)}');

      final data = {
        'reason': reason,
        if (authorizationCode != null) 'authorization_code': authorizationCode,
      };

      final response = await apiClient.post(
        ApiEndpoints.saleVoid(saleId),
        data: data,
      );

      // Le backend retourne { "sale": {...}, "message": "..." }
      final saleData = response.data['sale'] as Map<String, dynamic>;
      return SaleDetailModel.fromJson(saleData);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur POST void sale: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Retourne une vente
  Future<SaleDetailModel> returnSale({
    required String originalSaleId,
    required List<Map<String, dynamic>> items,
    required String reason,
    required String refundMethod,
  }) async {
    try {
      logger.d('🌐 DataSource: POST ${ApiEndpoints.saleReturn(originalSaleId)}');

      final data = {
        'original_sale_id': originalSaleId,
        'items': items,
        'reason': reason,
        'refund_method': refundMethod,
      };

      final response = await apiClient.post(
        ApiEndpoints.saleReturn(originalSaleId),
        data: data,
      );

      // Le backend retourne { "sale": {...}, "message": "..." }
      final saleData = response.data['sale'] as Map<String, dynamic>;
      return SaleDetailModel.fromJson(saleData);
    } on DioException catch (e) {
      logger.e('❌ DataSource: Erreur POST return sale: ${e.message}');
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}