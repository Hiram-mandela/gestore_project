// ========================================
// lib/features/sales/data/repositories/sales_repository_impl.dart
// Implémentation du repository Sales - Data Layer
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/sale_entity.dart';
import '../../domain/entities/sale_detail_entity.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/repositories/sales_repository.dart';
import '../datasources/sales_remote_datasource.dart';
import '../../../inventory/domain/entities/paginated_response_entity.dart';

@LazySingleton(as: SalesRepository)
class SalesRepositoryImpl implements SalesRepository {
  final SalesRemoteDataSource remoteDataSource;
  final Logger logger;

  SalesRepositoryImpl({
    required this.remoteDataSource,
    required this.logger,
  });

  /// Extrait le message d'erreur
  String _extractErrorMessage(String errorMessage) {
    if (errorMessage.contains('Exception:')) {
      return errorMessage.replaceAll('Exception:', '').trim();
    }
    return errorMessage;
  }

  // ==================== CUSTOMERS ====================

  @override
  Future<(List<CustomerEntity>?, String?)> getCustomers({
    String? search,
    String? customerType,
    bool? isActive,
  }) async {
    try {
      logger.d('📦 Repository: Récupération clients');

      final customerModels = await remoteDataSource.getCustomers(
        search: search,
        customerType: customerType,
        isActive: isActive,
      );

      final customerEntities =
      customerModels.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${customerEntities.length} clients récupérés');
      return (customerEntities, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération clients: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CustomerEntity?, String?)> getCustomerById(String id) async {
    try {
      logger.d('📦 Repository: Récupération client $id');

      final customerModel = await remoteDataSource.getCustomerById(id);
      final customerEntity = customerModel.toEntity();

      logger.i('✅ Repository: Client ${customerEntity.fullName} récupéré');
      return (customerEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération client: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CustomerEntity?, String?)> createCustomer(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Création client ${data['name']}');

      final customerModel = await remoteDataSource.createCustomer(data);
      final customerEntity = customerModel.toEntity();

      logger.i('✅ Repository: Client ${customerEntity.fullName} créé');
      return (customerEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création client: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CustomerEntity?, String?)> updateCustomer(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Mise à jour client $id');

      final customerModel = await remoteDataSource.updateCustomer(id, data);
      final customerEntity = customerModel.toEntity();

      logger.i('✅ Repository: Client ${customerEntity.fullName} mis à jour');
      return (customerEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour client: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteCustomer(String id) async {
    try {
      logger.d('📦 Repository: Suppression client $id');

      await remoteDataSource.deleteCustomer(id);

      logger.i('✅ Repository: Client $id supprimé');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression client: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getCustomerLoyalty(
      String customerId,
      ) async {
    try {
      logger.d('📦 Repository: Récupération fidélité client $customerId');

      final loyaltyData =
      await remoteDataSource.getCustomerLoyalty(customerId);

      logger.i('✅ Repository: Fidélité client récupérée');
      return (loyaltyData, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération fidélité: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== PAYMENT METHODS ====================

  @override
  Future<(List<PaymentMethodEntity>?, String?)> getPaymentMethods({
    bool? isActive,
  }) async {
    try {
      logger.d('📦 Repository: Récupération moyens de paiement');

      final paymentMethodModels =
      await remoteDataSource.getPaymentMethods(isActive: isActive);

      final paymentMethodEntities =
      paymentMethodModels.map((model) => model.toEntity()).toList();

      logger.i(
          '✅ Repository: ${paymentMethodEntities.length} moyens de paiement récupérés');
      return (paymentMethodEntities, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e(
          '❌ Repository: Erreur récupération moyens de paiement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(PaymentMethodEntity?, String?)> getPaymentMethodById(
      String id,
      ) async {
    try {
      logger.d('📦 Repository: Récupération moyen de paiement $id');

      final paymentMethodModel =
      await remoteDataSource.getPaymentMethodById(id);
      final paymentMethodEntity = paymentMethodModel.toEntity();

      logger.i(
          '✅ Repository: Moyen de paiement ${paymentMethodEntity.name} récupéré');
      return (paymentMethodEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e(
          '❌ Repository: Erreur récupération moyen de paiement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(PaymentMethodEntity?, String?)> createPaymentMethod(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Création moyen de paiement');

      final paymentMethodModel = await remoteDataSource.createPaymentMethod(data);
      final paymentMethodEntity = paymentMethodModel.toEntity();

      logger.i('✅ Repository: Moyen de paiement ${paymentMethodEntity.name} créé');
      return (paymentMethodEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création moyen de paiement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(PaymentMethodEntity?, String?)> updatePaymentMethod(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Modification moyen de paiement $id');

      final paymentMethodModel =
      await remoteDataSource.updatePaymentMethod(id, data);
      final paymentMethodEntity = paymentMethodModel.toEntity();

      logger.i('✅ Repository: Moyen de paiement ${paymentMethodEntity.name} modifié');
      return (paymentMethodEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur modification moyen de paiement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deletePaymentMethod(String id) async {
    try {
      logger.d('📦 Repository: Suppression moyen de paiement $id');

      await remoteDataSource.deletePaymentMethod(id);

      logger.i('✅ Repository: Moyen de paiement supprimé');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression moyen de paiement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== DISCOUNTS ====================

  @override
  Future<(List<DiscountEntity>?, String?)> getActiveDiscounts() async {
    try {
      logger.d('📦 Repository: Récupération remises actives');

      final discountModels = await remoteDataSource.getActiveDiscounts();

      final discountEntities =
      discountModels.map((model) => model.toEntity()).toList();

      logger.i(
          '✅ Repository: ${discountEntities.length} remises actives récupérées');
      return (discountEntities, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération remises: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(DiscountEntity?, String?)> getDiscountById(String id) async {
    try {
      logger.d('📦 Repository: Récupération remise $id');

      final discountModel = await remoteDataSource.getDiscountById(id);
      final discountEntity = discountModel.toEntity();

      logger.i('✅ Repository: Remise ${discountEntity.name} récupérée');
      return (discountEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération remise: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== SALES ====================

  @override
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
  }) async {
    try {
      logger.d('📦 Repository: Récupération ventes page $page');

      final responseModel = await remoteDataSource.getSales(
        page: page,
        pageSize: pageSize,
        search: search,
        status: status,
        saleType: saleType,
        customerId: customerId,
        dateFrom: dateFrom,
        dateTo: dateTo,
        ordering: ordering,
      );

      final responseEntity = responseModel.toEntity(
            (saleModel) => saleModel.toEntity(),
      );

      logger.i('✅ Repository: ${responseEntity.count} ventes récupérées');
      return (responseEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération ventes: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(SaleDetailEntity?, String?)> getSaleDetail(String saleId) async {
    try {
      logger.d('📦 Repository: Récupération détail vente $saleId');

      final saleDetailModel = await remoteDataSource.getSaleDetail(saleId);
      final saleDetailEntity = saleDetailModel.toEntity();

      logger.i(
          '✅ Repository: Détail vente ${saleDetailEntity.saleNumber} récupéré');
      return (saleDetailEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération détail vente: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getDailySummary() async {
    try {
      logger.d('📦 Repository: Récupération résumé quotidien');

      final summaryData = await remoteDataSource.getDailySummary();

      logger.i('✅ Repository: Résumé quotidien récupéré');
      return (summaryData, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération résumé: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== POS OPERATIONS ====================

  @override
  Future<(Map<String, dynamic>?, String?)> calculateSale({
    required List<Map<String, dynamic>> items,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
  }) async {
    try {
      logger.d('📦 Repository: Calcul vente (${items.length} articles)');

      final calculationData = await remoteDataSource.calculateSale(
        items: items,
        customerId: customerId,
        loyaltyPointsToUse: loyaltyPointsToUse,
        discountCodes: discountCodes,
      );

      logger.i('✅ Repository: Vente calculée');
      return (calculationData, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur calcul vente: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(SaleDetailEntity?, String?)> checkout({
    required List<Map<String, dynamic>> items,
    required List<Map<String, dynamic>> payments,
    String? customerId,
    int loyaltyPointsToUse = 0,
    List<String> discountCodes = const [],
    String? notes,
  }) async {
    try {
      logger.d('📦 Repository: Checkout POS (${items.length} articles)');

      final saleDetailModel = await remoteDataSource.checkout(
        items: items,
        payments: payments,
        customerId: customerId,
        loyaltyPointsToUse: loyaltyPointsToUse,
        discountCodes: discountCodes,
        notes: notes,
      );

      final saleDetailEntity = saleDetailModel.toEntity();

      logger.i('✅ Repository: Vente ${saleDetailEntity.saleNumber} finalisée');
      return (saleDetailEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur checkout: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(SaleDetailEntity?, String?)> voidSale({
    required String saleId,
    required String reason,
    String? authorizationCode,
  }) async {
    try {
      logger.d('📦 Repository: Annulation vente $saleId');

      final saleDetailModel = await remoteDataSource.voidSale(
        saleId: saleId,
        reason: reason,
        authorizationCode: authorizationCode,
      );

      final saleDetailEntity = saleDetailModel.toEntity();

      logger.i('✅ Repository: Vente ${saleDetailEntity.saleNumber} annulée');
      return (saleDetailEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur annulation vente: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(SaleDetailEntity?, String?)> returnSale({
    required String originalSaleId,
    required List<Map<String, dynamic>> items,
    required String reason,
    required String refundMethod,
  }) async {
    try {
      logger.d('📦 Repository: Retour vente $originalSaleId');

      final saleDetailModel = await remoteDataSource.returnSale(
        originalSaleId: originalSaleId,
        items: items,
        reason: reason,
        refundMethod: refundMethod,
      );

      final saleDetailEntity = saleDetailModel.toEntity();

      logger.i('✅ Repository: Retour vente ${saleDetailEntity.saleNumber} effectué');
      return (saleDetailEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur retour vente: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== DISCOUNTS - CRUD ====================

  @override
  Future<(PaginatedResponseEntity<DiscountEntity>?, String?)> getDiscounts({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? discountType,
    String? scope,
    bool? isActive,
    bool activeOnly = false,
  }) async {
    try {
      logger.d('📦 Repository: Récupération remises (page $page)');

      final paginatedModel = await remoteDataSource.getDiscounts(
        page: page,
        pageSize: pageSize,
        search: search,
        discountType: discountType,
        scope: scope,
        isActive: isActive,
        activeOnly: activeOnly,
      );

      final discountEntities =
      paginatedModel.results.map((model) => model.toEntity()).toList();

      final paginatedEntity = PaginatedResponseEntity<DiscountEntity>(
        count: paginatedModel.count,
        next: paginatedModel.next,
        previous: paginatedModel.previous,
        results: discountEntities,
      );

      logger.i('✅ Repository: ${discountEntities.length} remises récupérées');
      return (paginatedEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération remises: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(DiscountEntity?, String?)> createDiscount(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Création remise');

      final discountModel = await remoteDataSource.createDiscount(data);
      final discountEntity = discountModel.toEntity();

      logger.i('✅ Repository: Remise ${discountEntity.name} créée');
      return (discountEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création remise: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(DiscountEntity?, String?)> updateDiscount(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Modification remise $id');

      final discountModel = await remoteDataSource.updateDiscount(id, data);
      final discountEntity = discountModel.toEntity();

      logger.i('✅ Repository: Remise ${discountEntity.name} modifiée');
      return (discountEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur modification remise: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteDiscount(String id) async {
    try {
      logger.d('📦 Repository: Suppression remise $id');

      await remoteDataSource.deleteDiscount(id);

      logger.i('✅ Repository: Remise supprimée');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression remise: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> calculateDiscount(
      String discountId,
      Map<String, dynamic> params,
      ) async {
    try {
      logger.d('📦 Repository: Calcul remise $discountId');

      final result = await remoteDataSource.calculateDiscount(discountId, params);

      logger.i('✅ Repository: Remise calculée');
      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur calcul remise: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }
}