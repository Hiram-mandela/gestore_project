// ========================================
// lib/features/inventory/domain/repositories/inventory_repository.dart
// Repository abstrait pour l'inventaire
// VERSION CORRIGÉE - Signatures cohérentes
// ========================================

import '../entities/article_entity.dart';
import '../entities/article_detail_entity.dart';
import '../entities/category_entity.dart';
import '../entities/brand_entity.dart';
import '../entities/unit_of_measure_entity.dart';
import '../entities/paginated_response_entity.dart';

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
  // ⭐ CORRECTION: Signatures cohérentes avec Map + imagePath

  /// Crée un nouvel article
  /// [data] : Map contenant les données
  /// [imagePath] : Chemin optionnel de l'image
  Future<(ArticleEntity?, String?)> createArticle(
      Map<String, dynamic> data,
      String? imagePath,
      );

  /// Met à jour un article existant
  /// [id] : ID de l'article
  /// [data] : Map contenant les données à mettre à jour
  /// [imagePath] : Chemin optionnel de la nouvelle image
  Future<(ArticleEntity?, String?)> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? imagePath,
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
}