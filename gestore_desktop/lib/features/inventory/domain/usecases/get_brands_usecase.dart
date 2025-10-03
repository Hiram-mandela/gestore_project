// ========================================
// lib/features/inventory/domain/usecases/get_brands_usecase.dart
// Use case pour récupérer les marques
// ========================================

import '../../../../core/usecases/usecase.dart';
import '../entities/brand_entity.dart';
import '../repositories/inventory_repository.dart';

/// Paramètres pour GetBrandsUseCase
class GetBrandsParams {
  final bool? isActive;

  const GetBrandsParams({this.isActive});

  @override
  String toString() => 'GetBrandsParams(isActive: $isActive)';
}

/// Use case pour récupérer toutes les marques
class GetBrandsUseCase implements UseCase<List<BrandEntity>, GetBrandsParams> {
  final InventoryRepository repository;

  GetBrandsUseCase(this.repository);

  @override
  Future<(List<BrandEntity>?, String?)> call(GetBrandsParams params) async {
    return await repository.getBrands(isActive: params.isActive);
  }
}