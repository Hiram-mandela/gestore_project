// ========================================
// lib/features/sales/domain/usecases/calculate_discount_usecase.dart
// Use case pour calculer/simuler une remise
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../repositories/sales_repository.dart';

@lazySingleton
class CalculateDiscountUseCase {
  final SalesRepository repository;
  final Logger logger;

  CalculateDiscountUseCase({
    required this.repository,
    required this.logger,
  });

  /// Calcule le montant d'une remise pour un scénario donné
  ///
  /// [discountId] : ID de la remise à calculer
  /// [params] : Paramètres de calcul
  ///   - amount: double (montant de la vente/article)
  ///   - quantity: int (quantité d'articles)
  ///   - customer_id: String (optionnel, ID client)
  ///   - article_id: String (optionnel, ID article)
  ///   - category_id: String (optionnel, ID catégorie)
  ///
  /// Retourne un Map avec:
  ///   - discount_amount: double (montant de la remise)
  ///   - final_amount: double (montant après remise)
  ///   - is_applicable: bool (si la remise peut être appliquée)
  ///   - message: String (message d'information)
  Future<(Map<String, dynamic>?, String?)> call(
      String discountId,
      Map<String, dynamic> params,
      ) async {
    try {
      logger.d('🎁 UseCase: Calcul remise $discountId');
      logger.d('Params: $params');

      // Validation de l'ID
      if (discountId.isEmpty) {
        return (null, 'ID de la remise requis');
      }

      // Validation du montant
      if (!params.containsKey('amount')) {
        return (null, 'Le montant est requis pour le calcul');
      }

      // Appel au repository
      final result = await repository.calculateDiscount(discountId, params);

      if (result.$2 != null) {
        logger.e('❌ UseCase: Erreur calcul remise: ${result.$2}');
        return result;
      }

      logger.i('✅ UseCase: Remise calculée avec succès');
      return result;
    } catch (e) {
      logger.e('❌ UseCase: Exception calcul remise: $e');
      return (null, 'Erreur lors du calcul de la remise');
    }
  }
}