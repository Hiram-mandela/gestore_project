// ========================================
// lib/features/inventory/data/repositories/inventory_repository_impl.dart
// Implémentation du repository inventory
// VERSION CORRIGÉE - Signatures cohérentes
// ========================================

import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/article_detail_entity.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/brand_entity.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/entities/paginated_response_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../datasources/inventory_remote_datasource.dart';

@LazySingleton(as: InventoryRepository)
class InventoryRepositoryImpl implements InventoryRepository {
  final InventoryRemoteDataSource remoteDataSource;
  final Logger logger;

  InventoryRepositoryImpl({
    required this.remoteDataSource,
    required this.logger,
  });

  // ==================== ARTICLES - LECTURE ====================

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

      final responseEntity = responseModel.toEntity(
            (articleModel) => articleModel.toEntity(),
      );

      logger.i('✅ Repository: ${responseEntity.count} articles récupérés');
      return (responseEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur récupération articles: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
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
      logger.e('❌ Repository: Erreur article: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(ArticleDetailEntity?, String?)> getArticleDetailById(String id) async {
    try {
      logger.d('📦 Repository: Récupération détails article $id');
      final articleDetailModel = await remoteDataSource.getArticleDetailById(id);
      final articleDetailEntity = articleDetailModel.toEntity();
      logger.i('✅ Repository: Détails article ${articleDetailEntity.name} récupérés');
      return (articleDetailEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur détails article: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      logger.d('📦 Repository: Recherche articles "$query"');
      final responseModel = await remoteDataSource.searchArticles(
        query: query,
        page: page,
      );
      final responseEntity = responseModel.toEntity(
            (articleModel) => articleModel.toEntity(),
      );
      logger.i('✅ Repository: ${responseEntity.count} articles trouvés');
      return (responseEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur recherche: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(List<ArticleEntity>?, String?)> getLowStockArticles() async {
    try {
      logger.d('📦 Repository: Récupération articles stock bas');
      final articlesModel = await remoteDataSource.getLowStockArticles();
      final articlesEntity = articlesModel.map((model) => model.toEntity()).toList();
      logger.i('✅ Repository: ${articlesEntity.length} articles stock bas');
      return (articlesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur stock bas: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(List<ArticleEntity>?, String?)> getExpiringSoonArticles() async {
    try {
      logger.d('📦 Repository: Récupération articles péremption proche');
      final articlesModel = await remoteDataSource.getExpiringSoonArticles();
      final articlesEntity = articlesModel.map((model) => model.toEntity()).toList();
      logger.i('✅ Repository: ${articlesEntity.length} articles péremption proche');
      return (articlesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur péremption: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== ARTICLES - CRUD ====================
  // ⭐ CORRECTION: Signatures cohérentes

  @override
  Future<(ArticleEntity?, String?)> createArticle(
      Map<String, dynamic> data,
      String? imagePath,
      ) async {
    try {
      logger.d('📦 Repository: Création article "${data['name']}"');
      logger.d('   Code: ${data['code']}');
      logger.d('   Prix vente: ${data['selling_price']} FCFA');

      final articleModel = await remoteDataSource.createArticle(data, imagePath);
      final articleEntity = articleModel.toEntity();

      logger.i('✅ Repository: Article "${articleEntity.name}" créé avec succès');
      return (articleEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création article: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(ArticleEntity?, String?)> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? imagePath,
      ) async {
    try {
      logger.d('📦 Repository: Mise à jour article "${data['name']}" (ID: $id)');
      logger.d('   Code: ${data['code']}');
      logger.d('   Prix vente: ${data['selling_price']} FCFA');

      final articleModel = await remoteDataSource.updateArticle(id, data, imagePath);
      final articleEntity = articleModel.toEntity();

      logger.i('✅ Repository: Article "${articleEntity.name}" mis à jour');
      return (articleEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour article: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteArticle(String articleId) async {
    try {
      logger.d('📦 Repository: Suppression article (ID: $articleId)');
      await remoteDataSource.deleteArticle(articleId);
      logger.i('✅ Repository: Article supprimé avec succès');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression article: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== CATEGORIES ====================

  @override
  Future<(List<CategoryEntity>?, String?)> getCategories({bool? isActive}) async {
    try {
      logger.d('📦 Repository: Récupération catégories');
      final categoriesModel = await remoteDataSource.getCategories(isActive: isActive);
      final categoriesEntity = categoriesModel.map((model) => model.toEntity()).toList();
      logger.i('✅ Repository: ${categoriesEntity.length} catégories récupérées');
      return (categoriesEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur catégories: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CategoryEntity?, String?)> getCategoryById(String id) async {
    try {
      logger.d('📦 Repository: Récupération catégorie $id');
      final categoryModel = await remoteDataSource.getCategoryById(id);
      final categoryEntity = categoryModel.toEntity();
      logger.i('✅ Repository: Catégorie ${categoryEntity.name} récupérée');
      return (categoryEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur catégorie: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CategoryEntity?, String?)> createCategory(Map<String, dynamic> data) async {
    try {
      logger.d('📦 Repository: Création catégorie "${data['name']}"');
      final categoryModel = await remoteDataSource.createCategory(data);
      final categoryEntity = categoryModel.toEntity();
      logger.i('✅ Repository: Catégorie "${categoryEntity.name}" créée');
      return (categoryEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création catégorie: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(CategoryEntity?, String?)> updateCategory(String id, Map<String, dynamic> data) async {
    try {
      logger.d('📦 Repository: Mise à jour catégorie $id');
      final categoryModel = await remoteDataSource.updateCategory(id, data);
      final categoryEntity = categoryModel.toEntity();
      logger.i('✅ Repository: Catégorie mise à jour');
      return (categoryEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour catégorie: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteCategory(String id) async {
    try {
      logger.d('📦 Repository: Suppression catégorie $id');
      await remoteDataSource.deleteCategory(id);
      logger.i('✅ Repository: Catégorie supprimée');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression catégorie: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== BRANDS ====================

  @override
  Future<(List<BrandEntity>?, String?)> getBrands({bool? isActive}) async {
    try {
      logger.d('📦 Repository: Récupération marques');
      final brandsModel = await remoteDataSource.getBrands(isActive: isActive);
      final brandsEntity = brandsModel.map((model) => model.toEntity()).toList();
      logger.i('✅ Repository: ${brandsEntity.length} marques récupérées');
      return (brandsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur marques: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(BrandEntity?, String?)> getBrandById(String id) async {
    try {
      logger.d('📦 Repository: Récupération marque $id');
      final brandModel = await remoteDataSource.getBrandById(id);
      final brandEntity = brandModel.toEntity();
      logger.i('✅ Repository: Marque ${brandEntity.name} récupérée');
      return (brandEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur marque: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(BrandEntity?, String?)> createBrand(Map<String, dynamic> data, String? logoPath) async {
    try {
      logger.d('📦 Repository: Création marque "${data['name']}"');
      final brandModel = await remoteDataSource.createBrand(data, logoPath);
      final brandEntity = brandModel.toEntity();
      logger.i('✅ Repository: Marque "${brandEntity.name}" créée');
      return (brandEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création marque: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(BrandEntity?, String?)> updateBrand(String id, Map<String, dynamic> data, String? logoPath) async {
    try {
      logger.d('📦 Repository: Mise à jour marque $id');
      final brandModel = await remoteDataSource.updateBrand(id, data, logoPath);
      final brandEntity = brandModel.toEntity();
      logger.i('✅ Repository: Marque mise à jour');
      return (brandEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour marque: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteBrand(String id) async {
    try {
      logger.d('📦 Repository: Suppression marque $id');
      await remoteDataSource.deleteBrand(id);
      logger.i('✅ Repository: Marque supprimée');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression marque: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== UNITS OF MEASURE ====================

  @override
  Future<(List<UnitOfMeasureEntity>?, String?)> getUnitsOfMeasure({bool? isActive}) async {
    try {
      logger.d('📦 Repository: Récupération unités de mesure');
      final unitsModel = await remoteDataSource.getUnitsOfMeasure(isActive: isActive);
      final unitsEntity = unitsModel.map((model) => model.toEntity()).toList();
      logger.i('✅ Repository: ${unitsEntity.length} unités récupérées');
      return (unitsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur unités: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(UnitOfMeasureEntity?, String?)> getUnitOfMeasureById(String id) async {
    try {
      logger.d('📦 Repository: Récupération unité $id');
      final unitModel = await remoteDataSource.getUnitOfMeasureById(id);
      final unitEntity = unitModel.toEntity();
      logger.i('✅ Repository: Unité ${unitEntity.name} récupérée');
      return (unitEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur unité: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(UnitOfMeasureEntity?, String?)> createUnitOfMeasure(Map<String, dynamic> data) async {
    try {
      logger.d('📦 Repository: Création unité "${data['name']}"');
      final unitModel = await remoteDataSource.createUnitOfMeasure(data);
      final unitEntity = unitModel.toEntity();
      logger.i('✅ Repository: Unité "${unitEntity.name}" créée');
      return (unitEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création unité: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(UnitOfMeasureEntity?, String?)> updateUnitOfMeasure(String id, Map<String, dynamic> data) async {
    try {
      logger.d('📦 Repository: Mise à jour unité $id');
      final unitModel = await remoteDataSource.updateUnitOfMeasure(id, data);
      final unitEntity = unitModel.toEntity();
      logger.i('✅ Repository: Unité mise à jour');
      return (unitEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour unité: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteUnitOfMeasure(String id) async {
    try {
      logger.d('📦 Repository: Suppression unité $id');
      await remoteDataSource.deleteUnitOfMeasure(id);
      logger.i('✅ Repository: Unité supprimée');
      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression unité: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== UTILS ====================

  String _extractErrorMessage(String errorMessage) {
    if (errorMessage.contains('DioException')) {
      if (errorMessage.contains('401')) return 'Non autorisé';
      if (errorMessage.contains('403')) return 'Accès refusé';
      if (errorMessage.contains('404')) return 'Ressource introuvable';
      if (errorMessage.contains('500')) return 'Erreur serveur';
    }
    return errorMessage;
  }
}