// ========================================
// lib/features/inventory/domain/repositories/inventory_repository.dart
// Interface du repository pour la gestion de l'inventaire
// MISE À JOUR : Ajout de getArticleDetailById
// ========================================

import '../entities/article_entity.dart';
import '../entities/article_detail_entity.dart';
import '../entities/category_entity.dart';
import '../entities/brand_entity.dart';
import '../entities/unit_of_measure_entity.dart';
import '../entities/paginated_response_entity.dart';
import '../usecases/create_article_usecase.dart';
import '../usecases/update_article_usecase.dart';

/// Repository interface pour la gestion de l'inventaire
/// Définit les contrats que l'implémentation doit respecter
abstract class InventoryRepository {
  // ==================== ARTICLES ====================

  /// Récupère la liste paginée des articles
  ///
  /// [page] : Numéro de page (défaut: 1)
  /// [pageSize] : Nombre d'éléments par page (défaut: 20)
  /// [search] : Terme de recherche (optionnel)
  /// [categoryId] : Filtrer par catégorie (optionnel)
  /// [brandId] : Filtrer par marque (optionnel)
  /// [isActive] : Filtrer par statut actif (optionnel)
  /// [isLowStock] : Filtrer les articles en stock bas (optionnel)
  /// [ordering] : Champ de tri (ex: '-created_at', 'name')
  ///
  /// Returns: [PaginatedResponseEntity<ArticleEntity>] ou une erreur
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

  /// Récupère un article par son ID (version liste simplifiée)
  ///
  /// [id] : ID de l'article
  ///
  /// Returns: [ArticleEntity] ou une erreur
  Future<(ArticleEntity?, String?)> getArticleById(String id);

  /// Récupère le détail complet d'un article par son ID
  /// ⭐ NOUVEAU - Retourne ArticleDetailEntity avec toutes les relations
  ///
  /// [id] : ID de l'article
  ///
  /// Returns: [ArticleDetailEntity] ou une erreur
  Future<(ArticleDetailEntity?, String?)> getArticleDetailById(String id);

  /// Recherche des articles
  ///
  /// [query] : Terme de recherche
  /// [page] : Numéro de page
  ///
  /// Returns: [PaginatedResponseEntity<ArticleEntity>] ou une erreur
  Future<(PaginatedResponseEntity<ArticleEntity>?, String?)> searchArticles({
    required String query,
    int page = 1,
  });

  /// Récupère les articles avec stock bas
  ///
  /// Returns: [List<ArticleEntity>] ou une erreur
  Future<(List<ArticleEntity>?, String?)> getLowStockArticles();

  /// Récupère les articles proches de la péremption
  ///
  /// Returns: [List<ArticleEntity>] ou une erreur
  Future<(List<ArticleEntity>?, String?)> getExpiringSoonArticles();

  // ==================== CATEGORIES ====================

  /// Récupère toutes les catégories
  ///
  /// [isActive] : Filtrer par statut actif (optionnel)
  ///
  /// Returns: [List<CategoryEntity>] ou une erreur
  Future<(List<CategoryEntity>?, String?)> getCategories({
    bool? isActive,
  });

  /// Récupère une catégorie par son ID
  ///
  /// [id] : ID de la catégorie
  ///
  /// Returns: [CategoryEntity] ou une erreur
  Future<(CategoryEntity?, String?)> getCategoryById(String id);

  // ==================== BRANDS ====================

  /// Récupère toutes les marques
  ///
  /// [isActive] : Filtrer par statut actif (optionnel)
  ///
  /// Returns: [List<BrandEntity>] ou une erreur
  Future<(List<BrandEntity>?, String?)> getBrands({
    bool? isActive,
  });

  /// Récupère une marque par son ID
  ///
  /// [id] : ID de la marque
  ///
  /// Returns: [BrandEntity] ou une erreur
  Future<(BrandEntity?, String?)> getBrandById(String id);

  // ==================== UNITS OF MEASURE ====================

  /// Récupère toutes les unités de mesure
  ///
  /// [isActive] : Filtrer par statut actif (optionnel)
  ///
  /// Returns: [List<UnitOfMeasureEntity>] ou une erreur
  Future<(List<UnitOfMeasureEntity>?, String?)> getUnitsOfMeasure({
    bool? isActive,
  });

  // ==================== CRUD ARTICLES ====================

  /// Crée un nouvel article
  ///
  /// [params] : Paramètres de création
  ///
  /// Returns: [ArticleEntity] créé ou une erreur
  Future<(ArticleEntity?, String?)> createArticle(CreateArticleParams params);

  /// Met à jour un article existant
  ///
  /// [params] : Paramètres de mise à jour (avec ID)
  ///
  /// Returns: [ArticleEntity] mis à jour ou une erreur
  Future<(ArticleEntity?, String?)> updateArticle(UpdateArticleParams params);

  /// Supprime un article
  ///
  /// [articleId] : ID de l'article à supprimer
  ///
  /// Returns: void ou une erreur
  Future<(void, String?)> deleteArticle(String articleId);
}