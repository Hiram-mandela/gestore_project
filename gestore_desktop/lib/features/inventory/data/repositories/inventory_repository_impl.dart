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
import '../../domain/entities/location_entity.dart';
import '../../domain/entities/stock_alert_entity.dart';
import '../../domain/entities/stock_entity.dart';
import '../../domain/entities/unit_of_measure_entity.dart';
import '../../domain/entities/paginated_response_entity.dart';
import '../../domain/repositories/inventory_repository.dart';
import '../../domain/usecases/article_bulk_operations_usecases.dart';
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

  @override
  Future<(ArticleDetailEntity?, String?)> createArticle(
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU paramètre
      ) async {
    try {
      logger.d(' 🔄  Repository: Création article...');

      // ⭐ Passer les images secondaires au datasource
      final articleModel = await remoteDataSource.createArticle(
        data,
        primaryImagePath,
        secondaryImagePaths, // ✅ Nouveau paramètre
      );

      final articleEntity = articleModel.toEntity();

      logger.i(' ✅  Repository: Article "${articleEntity.name}" créé avec succès');

      // Compter les images
      final imageCount = articleEntity.images.length;
      if (imageCount > 0) {
        logger.i('    📸 $imageCount image(s) uploadée(s)');
      }

      return (articleEntity, null);
    } catch (e) {
      final errorMessage = 'Erreur création article: ${e.toString()}';
      logger.e(' ❌  Repository Error: $errorMessage');
      return (null, errorMessage);
    }
  }

  @override
  Future<(ArticleDetailEntity?, String?)> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU paramètre
      ) async {
    try {
      logger.d(' 🔄  Repository: Mise à jour article $id...');

      // ⭐ Passer les images secondaires au datasource
      final articleModel = await remoteDataSource.updateArticle(
        id,
        data,
        primaryImagePath,
        secondaryImagePaths, // ✅ Nouveau paramètre
      );

      final articleEntity = articleModel.toEntity();

      logger.i(' ✅  Repository: Article "${articleEntity.name}" mis à jour');

      // Compter les images
      final imageCount = articleEntity.images.length;
      if (imageCount > 0) {
        logger.i('    📸 $imageCount image(s) au total');
      }

      return (articleEntity, null);
    } catch (e) {
      final errorMessage = 'Erreur mise à jour article: ${e.toString()}';
      logger.e(' ❌  Repository Error: $errorMessage');
      return (null, errorMessage);
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

  // ==================== LOCATIONS ====================

  @override
  Future<(List<LocationEntity>?, String?)> getLocations({
    bool? isActive,
    String? locationType,
    String? parentId,
  }) async {
    try {
      logger.d('📦 Repository: Récupération emplacements');

      final locationsModel = await remoteDataSource.getLocations(
        isActive: isActive,
        locationType: locationType,
        parentId: parentId,
      );

      final locationsEntity = locationsModel
          .map((model) => model.toEntity())
          .toList();

      logger.i('✅ Repository: ${locationsEntity.length} emplacements récupérés');

      return (locationsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur emplacements: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(LocationEntity?, String?)> getLocationById(String id) async {
    try {
      logger.d('📦 Repository: Récupération emplacement $id');

      final locationModel = await remoteDataSource.getLocationById(id);
      final locationEntity = locationModel.toEntity();

      logger.i('✅ Repository: Emplacement ${locationEntity.name} récupéré');

      return (locationEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur emplacement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(LocationEntity?, String?)> createLocation(Map<String, dynamic> data) async {
    try {
      logger.d('📦 Repository: Création emplacement "${data['name']}"');

      final locationModel = await remoteDataSource.createLocation(data);
      final locationEntity = locationModel.toEntity();

      logger.i('✅ Repository: Emplacement "${locationEntity.name}" créé');

      return (locationEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur création emplacement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(LocationEntity?, String?)> updateLocation(
      String id,
      Map<String, dynamic> data,
      ) async {
    try {
      logger.d('📦 Repository: Mise à jour emplacement $id');

      final locationModel = await remoteDataSource.updateLocation(id, data);
      final locationEntity = locationModel.toEntity();

      logger.i('✅ Repository: Emplacement mis à jour');

      return (locationEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur mise à jour emplacement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(void, String?)> deleteLocation(String id) async {
    try {
      logger.d('📦 Repository: Suppression emplacement $id');

      await remoteDataSource.deleteLocation(id);

      logger.i('✅ Repository: Emplacement supprimé');

      return (null, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur suppression emplacement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(List<StockEntity>?, String?)> getLocationStocks(String locationId) async {
    try {
      logger.d('📦 Repository: Récupération stocks emplacement $locationId');

      final stocksModel = await remoteDataSource.getLocationStocks(locationId);
      final stocksEntity = stocksModel.map((model) => model.toEntity()).toList();

      logger.i('✅ Repository: ${stocksEntity.length} stocks récupérés');

      return (stocksEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur stocks emplacement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== STOCKS ====================

  @override
  Future<(List<StockEntity>?, String?)> getStocks({
    String? articleId,
    String? locationId,
    DateTime? expiryDate,
  }) async {
    try {
      logger.d('📦 Repository: Récupération stocks');

      final stocksModel = await remoteDataSource.getStocks(
        articleId: articleId,
        locationId: locationId,
        expiryDate: expiryDate,
      );

      final stocksEntity = stocksModel
          .map((model) => model.toEntity())
          .toList();

      logger.i('✅ Repository: ${stocksEntity.length} stocks récupérés');

      return (stocksEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur stocks: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(StockEntity?, String?)> getStockById(String id) async {
    try {
      logger.d('📦 Repository: Récupération stock $id');

      final stockModel = await remoteDataSource.getStockById(id);
      final stockEntity = stockModel.toEntity();

      logger.i('✅ Repository: Stock récupéré');

      return (stockEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur stock: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> adjustStock({
    required String articleId,
    required String locationId,
    required double newQuantity,
    required String reason,
    String? referenceDocument,
    String? notes,
  }) async {
    try {
      logger.d('📦 Repository: Ajustement stock');

      final result = await remoteDataSource.adjustStock(
        articleId: articleId,
        locationId: locationId,
        newQuantity: newQuantity,
        reason: reason,
        referenceDocument: referenceDocument,
        notes: notes,
      );

      logger.i('✅ Repository: Ajustement effectué');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur ajustement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> transferStock({
    required String articleId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? referenceDocument,
    String? notes,
  }) async {
    try {
      logger.d('📦 Repository: Transfert stock');

      final result = await remoteDataSource.transferStock(
        articleId: articleId,
        fromLocationId: fromLocationId,
        toLocationId: toLocationId,
        quantity: quantity,
        referenceDocument: referenceDocument,
        notes: notes,
      );

      logger.i('✅ Repository: Transfert effectué');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur transfert: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getStockValuation() async {
    try {
      logger.d('📦 Repository: Récupération valorisation stock');

      final result = await remoteDataSource.getStockValuation();

      logger.i('✅ Repository: Valorisation récupérée');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur valorisation: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== STOCK ALERTS ====================

  @override
  Future<(List<StockAlertEntity>?, String?)> getStockAlerts({
    String? alertType,
    String? alertLevel,
    bool? isAcknowledged,
  }) async {
    try {
      logger.d('📦 Repository: Récupération alertes');

      final alertsModel = await remoteDataSource.getStockAlerts(
        alertType: alertType,
        alertLevel: alertLevel,
        isAcknowledged: isAcknowledged,
      );

      final alertsEntity = alertsModel
          .map((model) => model.toEntity())
          .toList();

      logger.i('✅ Repository: ${alertsEntity.length} alertes récupérées');

      return (alertsEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur alertes: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(StockAlertEntity?, String?)> getStockAlertById(String id) async {
    try {
      logger.d('📦 Repository: Récupération alerte $id');

      final alertModel = await remoteDataSource.getStockAlertById(id);
      final alertEntity = alertModel.toEntity();

      logger.i('✅ Repository: Alerte récupérée');

      return (alertEntity, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur alerte: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> acknowledgeAlert(String id) async {
    try {
      logger.d('📦 Repository: Acquittement alerte $id');

      final result = await remoteDataSource.acknowledgeAlert(id);

      logger.i('✅ Repository: Alerte acquittée');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur acquittement: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> bulkAcknowledgeAlerts(
      List<String> alertIds,
      ) async {
    try {
      logger.d('📦 Repository: Acquittement masse ${alertIds.length} alertes');

      final result = await remoteDataSource.bulkAcknowledgeAlerts(alertIds);

      logger.i('✅ Repository: Alertes acquittées en masse');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur acquittement masse: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> getAlertsDashboard() async {
    try {
      logger.d('📦 Repository: Récupération dashboard alertes');

      final dashboard = await remoteDataSource.getAlertsDashboard();

      logger.i('✅ Repository: Dashboard récupéré');

      return (dashboard, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur dashboard: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  // ==================== BULK OPERATIONS ====================

  @override
  Future<(Map<String, dynamic>?, String?)> bulkUpdateArticles(
      BulkUpdateArticlesParams params,
      ) async {
    try {
      logger.d('📦 Repository: Opération en masse sur ${params.articleIds.length} articles');

      final result = await remoteDataSource.bulkUpdateArticles(params);

      logger.i('✅ Repository: Opération effectuée');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur bulk update: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> duplicateArticle(
      DuplicateArticleParams params,
      ) async {
    try {
      logger.d('📦 Repository: Duplication article ${params.articleId}');

      final result = await remoteDataSource.duplicateArticle(params);

      logger.i('✅ Repository: Article dupliqué');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur duplication: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(Map<String, dynamic>?, String?)> importArticlesCSV(
      String filePath,
      ) async {
    try {
      logger.d('📦 Repository: Import CSV $filePath');

      final result = await remoteDataSource.importArticlesCSV(filePath);

      logger.i('✅ Repository: Import effectué');

      return (result, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur import CSV: $errorMessage');
      return (null, _extractErrorMessage(errorMessage));
    }
  }

  @override
  Future<(String?, String?)> exportArticlesCSV(
      ExportArticlesCSVParams params,
      ) async {
    try {
      logger.d('📦 Repository: Export CSV');

      final fileName = await remoteDataSource.exportArticlesCSV(params);

      logger.i('✅ Repository: Export effectué - $fileName');

      return (fileName, null);
    } catch (e) {
      final errorMessage = e.toString();
      logger.e('❌ Repository: Erreur export CSV: $errorMessage');
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