// ========================================
// lib/features/inventory/domain/repositories/inventory_repository.dart
// Repository abstrait pour l'inventaire
// VERSION CORRIGÉE - Signatures cohérentes
// ========================================

import '../entities/article_entity.dart';
import '../entities/article_detail_entity.dart';
import '../entities/category_entity.dart';
import '../entities/brand_entity.dart';
import '../entities/location_entity.dart';
import '../entities/stock_alert_entity.dart';
import '../entities/stock_entity.dart';
import '../entities/stock_movement_entity.dart';
import '../entities/unit_conversion_entity.dart';
import '../entities/unit_of_measure_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../usecases/article_bulk_operations_usecases.dart';
import '../usecases/stock_movement_usecases.dart';
import '../usecases/unit_conversion_usecases.dart';

/// Repository abstrait pour l'inventaire
/// Contrat entre Domain Layer et Data Layer
abstract class InventoryRepository {
  // ==================== ARTICLES - LECTURE ====================

  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> getArticles({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? brandId,
    bool? isActive,
    bool? isLowStock,
    String? ordering,
  });

  Future<(ArticleEntity?, String?)> getArticleById(String id);
  Future<(ArticleDetailEntity?, String?)> getArticleDetailById(String id);

  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> searchArticles({
    required String query,
    int page = 1,
  });

  Future<(List<ArticleEntity>?, String?)> getLowStockArticles();
  Future<(List<ArticleEntity>?, String?)> getExpiringSoonArticles();

  // ==================== CRUD ARTICLES ====================

  /// Crée un nouvel article avec support multi-images
  ///
  /// [data] Les données de l'article
  /// [primaryImagePath] Chemin local de l'image principale (optionnel)
  /// [secondaryImagePaths] Liste des chemins locaux des images secondaires (optionnel)
  Future<(ArticleDetailEntity?, String?)> createArticle(
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU
      );

  /// Met à jour un article existant avec support multi-images
  ///
  /// [id] ID de l'article à mettre à jour
  /// [data] Les nouvelles données de l'article
  /// [primaryImagePath] Nouveau chemin de l'image principale (optionnel)
  /// [secondaryImagePaths] Nouveaux chemins des images secondaires (optionnel)
  Future<(ArticleDetailEntity?, String?)> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU
      );

  /// Supprime un article
  Future<(void, String?)> deleteArticle(String articleId);

  // ==================== CATEGORIES - CRUD ====================

  Future<(List<CategoryEntity>?, String?)> getCategories({bool? isActive});
  Future<(CategoryEntity?, String?)> getCategoryById(String id);
  Future<(CategoryEntity?, String?)> createCategory(Map<String, dynamic> data);
  Future<(CategoryEntity?, String?)> updateCategory(String id, Map<String, dynamic> data);
  Future<(void, String?)> deleteCategory(String id);

  // ==================== BRANDS - CRUD ====================

  Future<(List<BrandEntity>?, String?)> getBrands({bool? isActive});
  Future<(BrandEntity?, String?)> getBrandById(String id);
  Future<(BrandEntity?, String?)> createBrand(Map<String, dynamic> data, String? logoPath);
  Future<(BrandEntity?, String?)> updateBrand(String id, Map<String, dynamic> data, String? logoPath);
  Future<(void, String?)> deleteBrand(String id);

  // ==================== UNITS OF MEASURE - CRUD ====================

  Future<(List<UnitOfMeasureEntity>?, String?)> getUnitsOfMeasure({bool? isActive});
  Future<(UnitOfMeasureEntity?, String?)> getUnitOfMeasureById(String id);
  Future<(UnitOfMeasureEntity?, String?)> createUnitOfMeasure(Map<String, dynamic> data);
  Future<(UnitOfMeasureEntity?, String?)> updateUnitOfMeasure(String id, Map<String, dynamic> data);
  Future<(void, String?)> deleteUnitOfMeasure(String id);

  // ==================== LOCATIONS - CRUD ====================

  Future<(List<LocationEntity>?, String?)> getLocations({
    bool? isActive,
    String? locationType,
    String? parentId,
  });

  Future<(LocationEntity?, String?)> getLocationById(String id);

  Future<(LocationEntity?, String?)> createLocation(Map<String, dynamic> data);

  Future<(LocationEntity?, String?)> updateLocation(String id, Map<String, dynamic> data);

  Future<(void, String?)> deleteLocation(String id);

  Future<(List<StockEntity>?, String?)> getLocationStocks(String locationId);

  // ==================== STOCKS - CRUD ====================

  Future<(List<StockEntity>?, String?)> getStocks({
    String? storeId,  // 🔴 NOUVEAU
    String? articleId,
    String? locationId,
    DateTime? expiryDate,
  });

  Future<(StockEntity?, String?)> getStockById(String id);

  Future<(Map<String, dynamic>?, String?)> adjustStock({
    required String articleId,
    required String locationId,
    required double newQuantity,
    required String reason,
    String? referenceDocument,
    String? notes,
  });

  Future<(Map<String, dynamic>?, String?)> transferStock({
    required String articleId,
    required String fromLocationId,
    required String toLocationId,
    required double quantity,
    String? referenceDocument,
    String? notes,
  });

  Future<(Map<String, dynamic>?, String?)> getStockValuation();

  // ==================== STOCK ALERTS ====================

  /// 🔴 MULTI-MAGASINS : Récupère les alertes avec filtrage optionnel par magasin
  /// - [storeId] null : Backend filtre automatiquement (employés)
  /// - [storeId] fourni : Backend filtre sur magasin spécifique (admins)
  Future<(List<StockAlertEntity>?, String?)> getStockAlerts({
    String? storeId,  // 🔴 NOUVEAU
    String? alertType,
    String? alertLevel,
    bool? isAcknowledged,
  });

  /// Récupère une alerte par ID
  Future<(StockAlertEntity?, String?)> getStockAlertById(String id);

  /// Acquitte une alerte
  Future<(Map<String, dynamic>?, String?)> acknowledgeAlert(String id);

  /// Acquitte plusieurs alertes
  Future<(Map<String, dynamic>?, String?)> bulkAcknowledgeAlerts(
      List<String> alertIds,
      );

  /// Récupère le dashboard des alertes
  Future<(Map<String, dynamic>?, String?)> getAlertsDashboard();

  // ==================== BULK OPERATIONS ====================

  /// Opération en masse sur les articles
  Future<(Map<String, dynamic>?, String?)> bulkUpdateArticles(
      BulkUpdateArticlesParams params,
      );

  /// Duplique un article
  Future<(Map<String, dynamic>?, String?)> duplicateArticle(
      DuplicateArticleParams params,
      );

  /// Importe des articles depuis un CSV
  Future<(Map<String, dynamic>?, String?)> importArticlesCSV(String filePath);

  /// Exporte les articles en CSV
  Future<(String?, String?)> exportArticlesCSV(ExportArticlesCSVParams params);

  // ==================== UNIT CONVERSIONS ====================
  Future<(List<UnitConversionEntity>?, String?)> getUnitConversions({
    String? fromUnitId,
    String? toUnitId,
  });
  Future<(UnitConversionEntity?, String?)> getUnitConversionById(String id);
  Future<(UnitConversionEntity?, String?)> createUnitConversion(Map<String, dynamic> data);
  Future<(UnitConversionEntity?, String?)> updateUnitConversion(String id, Map<String, dynamic> data);
  Future<(void, String?)> deleteUnitConversion(String id);
  Future<(ConversionResult?, String?)> calculateConversion({
    required String fromUnitId,
    required String toUnitId,
    required double quantity,
  });

  // ==================== STOCK MOVEMENTS ====================
  /// 🔴 MULTI-MAGASINS : Récupère les mouvements avec filtrage optionnel par magasin
  /// - [storeId] null : Backend filtre automatiquement (employés)
  /// - [storeId] fourni : Backend filtre sur magasin spécifique (admins)
  Future<(PaginatedResponseEntity<StockMovementEntity>?, String?)> getStockMovements({
    String? storeId,  // 🔴 NOUVEAU
    int page = 1,
    int pageSize = 20,
    String? movementType,
    String? reason,
    String? articleId,
    String? locationId,
    String? dateFrom,
    String? dateTo,
    String? search,
    String? ordering,
  });

  Future<(StockMovementEntity?, String?)> getStockMovementById(String id);

  Future<(MovementsSummary?, String?)> getMovementsSummary({
    String? dateFrom,
    String? dateTo,
  });
}