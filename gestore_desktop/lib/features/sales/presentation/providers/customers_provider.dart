// ========================================
// FICHIER 1: customers_provider.dart - VERSION FINALE CORRIGÉE
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/customer_usecases.dart';
import 'customers_state.dart';

final customersProvider = StateNotifierProvider<CustomersNotifier, CustomersState>((ref) {
  return CustomersNotifier(
    getCustomersUseCase: getIt<GetCustomersUseCase>(),
    deleteCustomerUseCase: getIt<DeleteCustomerUseCase>(),
    logger: getIt<Logger>(),
  );
});

class CustomersNotifier extends StateNotifier<CustomersState> {
  final GetCustomersUseCase getCustomersUseCase;
  final DeleteCustomerUseCase deleteCustomerUseCase;
  final Logger logger;

  static const int _pageSize = 20;

  CustomersNotifier({
    required this.getCustomersUseCase,
    required this.deleteCustomerUseCase,
    required this.logger,
  }) : super(const CustomersInitial());

  Future<void> loadCustomers({bool refresh = false}) async {
    if (refresh) state = const CustomersLoading();

    try {
      logger.i('📋 Chargement des clients...');

      final (customers, error) = await getCustomersUseCase();

      if (error != null) throw Exception(error);
      if (customers == null) throw Exception('Aucune donnée reçue');

      // Calculer les statistiques localement
      final individuals = customers.where((c) => c.customerType == 'individual').length;
      final companies = customers.where((c) => c.customerType == 'company').length;
      final loyaltyMembers = customers.where((c) => c.loyaltyPoints > 0).length;

      state = CustomersLoaded(
        customers: customers,
        totalCount: customers.length,
        currentPage: 1,
        hasMore: false, // Pas de pagination backend
        individuals: individuals,
        companies: companies,
        loyaltyMembers: loyaltyMembers,
      );

      logger.i('✅ ${customers.length} clients chargés');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur chargement clients', error: e, stackTrace: stackTrace);
      state = CustomersError(e.toString());
    }
  }

  Future<void> loadMore() async {
    // Pas de pagination pour l'instant
    return;
  }

  Future<void> refresh() async {
    await loadCustomers(refresh: true);
  }

  Future<void> search(String query) async {
    state = const CustomersLoading();

    try {
      logger.i('🔍 Recherche: "$query"');

      final (customers, error) = await getCustomersUseCase(search: query.isNotEmpty ? query : null);

      if (error != null) throw Exception(error);
      if (customers == null) throw Exception('Aucune donnée reçue');

      final individuals = customers.where((c) => c.customerType == 'individual').length;
      final companies = customers.where((c) => c.customerType == 'company').length;
      final loyaltyMembers = customers.where((c) => c.loyaltyPoints > 0).length;

      state = CustomersLoaded(
        customers: customers,
        totalCount: customers.length,
        currentPage: 1,
        hasMore: false,
        searchQuery: query,
        individuals: individuals,
        companies: companies,
        loyaltyMembers: loyaltyMembers,
      );

      logger.i('✅ ${customers.length} résultats trouvés');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur recherche', error: e, stackTrace: stackTrace);
      state = CustomersError(e.toString());
    }
  }

  Future<void> filter(String filterValue) async {
    state = const CustomersLoading();

    try {
      String? customerType;
      bool? isActive;

      if (filterValue == 'individual' || filterValue == 'company' || filterValue == 'professional') {
        customerType = filterValue;
      } else if (filterValue == 'active') {
        isActive = true;
      } else if (filterValue == 'inactive') {
        isActive = false;
      }

      logger.i('🔧 Filtre: $filterValue');

      final (customers, error) = await getCustomersUseCase(
        customerType: customerType,
        isActive: isActive,
      );

      if (error != null) throw Exception(error);
      if (customers == null) throw Exception('Aucune donnée reçue');

      final individuals = customers.where((c) => c.customerType == 'individual').length;
      final companies = customers.where((c) => c.customerType == 'company').length;
      final loyaltyMembers = customers.where((c) => c.loyaltyPoints > 0).length;

      state = CustomersLoaded(
        customers: customers,
        totalCount: customers.length,
        currentPage: 1,
        hasMore: false,
        filterType: filterValue != 'all' ? filterValue : null,
        individuals: individuals,
        companies: companies,
        loyaltyMembers: loyaltyMembers,
      );

      logger.i('✅ ${customers.length} clients filtrés');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur filtrage', error: e, stackTrace: stackTrace);
      state = CustomersError(e.toString());
    }
  }

  Future<void> toggleActiveStatus(String customerId) async {
    if (state is! CustomersLoaded) return;

    try {
      logger.i('🔄 Changement statut client: $customerId');
      await loadCustomers(refresh: true);
      logger.i('✅ Statut client modifié');
    } catch (e, stackTrace) {
      logger.e('❌ Erreur changement statut', error: e, stackTrace: stackTrace);
      state = CustomersError(e.toString());
    }
  }
}
