// ========================================
// lib/features/inventory/data/repositories/inventory_repository_impl.dart
// Implémentation du repository inventory
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/entities/paginated_response_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

/// Implémentation du repository inventory
/// Fait le pont entre le DataSource et le Domain Layer
@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final Logger logger;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.logger,
  });

  @override
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> getArticles({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? brandId,
    bool? isActive,
    bool? isLowStock,
    String? ordering,
  }) async {
    try {
      logger.d('📦 Repository: Récupération articles page $page');

      final responseModel = await remoteDataSource.getArticles(
        page: page,
        pageSize: pageSize,
        search: search,
        categoryId: categoryId,
        brandId: brandId,
        isActive: isActive,
        isLowStock: isLowStock,
        ordering: ordering,
      );

      // Convertir le model en entity
      final responseEntity = responseModel.toEntity(
            (articleModel) => articleModel.toEntity(),
      );

      logger.i('✅ Repository: ${responseEntity.count} articles récupérés');

      return (responseEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération articles: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(ArticleEntity?, String?)> getArticleById(String id) async {
    try {
      logger.d('📦 Repository: Récupération article $id');

      final articleModel = await remoteDataSource.getArticleById(id);
      final articleEntity = articleModel.toEntity();

      logger.i('✅ Repository: Article ${articleEntity.name} récupéré');

      return (articleEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération article: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      logger.d('🔍 Repository: Recherche "$query"');

      final responseModel = await remoteDataSource.searchArticles(
        query: query,
        page: page,
      );

      final responseEntity = responseModel.toEntity(
            (articleModel) => articleModel.toEntity(),
      );

      logger.i('✅ Repository: ${responseEntity.count} résultats trouvés');

      return (responseEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur recherche: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(List<ArticleEntity>?, String?)> getLowStockArticles() async {
    try {
      logger.d('📦 Repository: Récupération articles stock bas');

      final articlesModel = await remoteDataSource.getLowStockArticles();
      final articlesEntity =
      articlesModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${articlesEntity.length} articles stock bas');

      return (articlesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur stock bas: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(List<ArticleEntity>?, String?)> getExpiringSoonArticles() async {
    try {
      logger.d('📦 Repository: Récupération articles péremption proche');

      final articlesModel = await remoteDataSource.getExpiringSoonArticles();
      final articlesEntity =
      articlesModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${articlesEntity.length} articles péremption proche');

      return (articlesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur péremption: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(List<CategoryEntity>?, String?)> getCategories({
    bool? isActive,
  }) async {
    try {
      logger.d('📂 Repository: Récupération catégories');

      final categoriesModel =
      await remoteDataSource.getCategories(isActive: isActive);
      final categoriesEntity =
      categoriesModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${categoriesEntity.length} catégories récupérées');

      return (categoriesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur catégories: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(CategoryEntity?, String?)> getCategoryById(String id) async {
    try {
      logger.d('📂 Repository: Récupération catégorie $id');

      final categoryModel = await remoteDataSource.getCategoryById(id);
      final categoryEntity = categoryModel.toEntity();

      logger.i('✅ Repository: Catégorie ${categoryEntity.name} récupérée');

      return (categoryEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur catégorie: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(List<BrandEntity>?, String?)> getBrands({
    bool? isActive,
  }) async {
    try {
      logger.d('🏷️ Repository: Récupération marques');

      final brandsModel = await remoteDataSource.getBrands(isActive: isActive);
      final brandsEntity = brandsModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${brandsEntity.length} marques récupérées');

      return (brandsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur marques: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(BrandEntity?, String?)> getBrandById(String id) async {
    try {
      logger.d('🏷️ Repository: Récupération marque $id');

      final brandModel = await remoteDataSource.getBrandById(id);
      final brandEntity = brandModel.toEntity();

      logger.i('✅ Repository: Marque ${brandEntity.name} récupérée');

      return (brandEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur marque: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(List<UnitOfMeasureEntity>?, String?)> getUnitsOfMeasure({
    bool? isActive,
  }) async {
    try {
      logger.d('📏 Repository: Récupération unités de mesure');

      final unitsModel =
      await remoteDataSource.getUnitsOfMeasure(isActive: isActive);
      final unitsEntity = unitsModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${unitsEntity.length} unités récupérées');

      return (unitsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur unités: $errorMessage');
      return (null, errorMessage);
    }
  }
}