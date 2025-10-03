// ========================================
// lib/features/inventory/domain/usecases/get_categories_usecase.dart
// Use case pour récupérer les catégories
// ========================================

import '../../../../core/usecases/usecase.dart';
import '../entities/category_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour GetCategoriesUseCase
class GetCategoriesParams {
  final bool? isActive;

  const GetCategoriesParams({this.isActive});

  @override
  String toString() => 'GetCategoriesParams(isActive: $isActive)';
}

/// Use case pour récupérer toutes les catégories
class GetCategoriesUseCase implements UseCase<List<CategoryEntity>, GetCategoriesParams> {
  final InventoryRepository repository;

  GetCategoriesUseCase(this.repository);

  @override
  Future<(List<CategoryEntity>?, String?)> call(GetCategoriesParams params) async {
    return await repository.getCategories(isActive: params.isActive);
  }
}