// ========================================
// lib/features/sales/domain/usecases/create_discount_usecase.dart
// Use case pour créer une remise/promotion
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../entities/discount_entity.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class CreateDiscountUseCase {
  final SalesRepository repository;
  final Logger logger;

  CreateDiscountUseCase({
    required this.repository,
    required this.logger,
  });

  /// Crée une nouvelle remise/promotion
  ///
  /// Champs requis dans [data] :
  /// - name: String
  /// - discount_type: String ('percentage', 'fixed_amount', 'buy_x_get_y', 'loyalty_points')
  /// - scope: String ('sale', 'category', 'article', 'customer')
  /// - start_date: String (ISO 8601)
  ///
  /// Champs conditionnels selon discount_type :
  /// - percentage_value: double (si type = percentage)
  /// - fixed_value: double (si type = fixed_amount)
  ///
  /// Champs optionnels :
  /// - description: String
  /// - code: String (code promo)
  /// - end_date: String (ISO 8601)
  /// - min_quantity: int
  /// - min_amount: double
  /// - max_uses: int
  /// - max_uses_per_customer: int
  /// - max_amount: double
  /// - priority: int
  /// - combinable: bool
  /// - is_active: bool
  Future<(DiscountEntity?, String?)> call(
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('🎁 UseCase: Création remise');
      logger.d('Data: $data');

      // Validation des champs requis
      if (!data.containsKey('name') || data['name'].toString().isEmpty) {
        return (null, 'Le nom de la remise est requis');
      }

      if (!data.containsKey('discount_type') || data['discount_type'].toString().isEmpty) {
        return (null, 'Le type de remise est requis');
      }

      if (!data.containsKey('scope') || data['scope'].toString().isEmpty) {
        return (null, 'La portée de la remise est requise');
      }

      if (!data.containsKey('start_date') || data['start_date'].toString().isEmpty) {
        return (null, 'La date de début est requise');
      }

      // Validation du type de remise
      final validTypes = ['percentage', 'fixed_amount', 'buy_x_get_y', 'loyalty_points'];
      if (!validTypes.contains(data['discount_type'])) {
        return (null, 'Type de remise invalide');
      }

      // Validation de la portée
      final validScopes = ['sale', 'category', 'article', 'customer'];
      if (!validScopes.contains(data['scope'])) {
        return (null, 'Portée de remise invalide');
      }

      // Validation conditionnelle selon le type
      if (data['discount_type'] == 'percentage') {
        if (!data.containsKey('percentage_value')) {
          return (null, 'La valeur en pourcentage est requise');
        }
      } else if (data['discount_type'] == 'fixed_amount') {
        if (!data.containsKey('fixed_value')) {
          return (null, 'Le montant fixe est requis');
        }
      }

      // Appel au repository
      final result = await repository.createDiscount(data);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur création remise: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Remise ${result.$1?.name} créée avec succès');
      return result;
    } catch (e) {
      logger.e('❌ UseCase: Exception création remise: $e');
      return (null, 'Erreur lors de la création de la remise');
    }
  }
}