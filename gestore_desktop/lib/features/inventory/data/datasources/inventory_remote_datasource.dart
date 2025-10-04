// ========================================
// lib/features/inventory/data/datasources/inventory_remote_datasource.dart
// DataSource pour les appels API du module inventory
// VERSION COMPLÈTE avec CRUD
// ========================================

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/article_model.dart';
import '../models/article_detail_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../models/paginated_response_model.dart';
import '../models/unit_of_measure_model.dart';

/// DataSource abstraite pour les opérations d'inventaire
abstract class InventoryRemoteDataSource {
  // ==================== ARTICLES - LECTURE ====================

  /// Récupère la liste paginée des articles
  Future<PaginatedResponseModel<ArticleModel>> getArticles({
    int page = 1,
    int pageSize = 20,
    String? search,
    String? categoryId,
    String? brandId,
    bool? isActive,
    bool? isLowStock,
    String? ordering,
  });

  /// Récupère un article par ID (version liste simplifiée)
  Future<ArticleModel> getArticleById(String id);

  /// Récupère le détail complet d'un article par ID
  Future<ArticleDetailModel> getArticleDetailById(String id);

  /// Recherche des articles
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  });

  /// Récupère les articles avec stock bas
  Future<List<ArticleModel>> getLowStockArticles();

  /// Récupère les articles proches de la péremption
  Future<List<ArticleModel>> getExpiringSoonArticles();

  // ==================== ARTICLES - CRUD ====================

  /// Crée un nouvel article
  Future<ArticleModel> createArticle(Map<String, dynamic> data, String? imagePath);

  /// Met à jour un article
  Future<ArticleModel> updateArticle(String id, Map<String, dynamic> data, String? imagePath);

  /// Supprime un article
  Future<void> deleteArticle(String id);

  // ==================== CATEGORIES ====================

  /// Récupère toutes les catégories
  Future<List<CategoryModel>> getCategories({bool? isActive});

  /// Récupère une catégorie par ID
  Future<CategoryModel> getCategoryById(String id);

  // ==================== BRANDS ====================

  /// Récupère toutes les marques
  Future<List<BrandModel>> getBrands({bool? isActive});

  /// Récupère une marque par ID
  Future<BrandModel> getBrandById(String id);

  // ==================== UNITS OF MEASURE ====================

  /// Récupère toutes les unités de mesure
  Future<List<UnitOfMeasureModel>> getUnitsOfMeasure({bool? isActive});
}

/// Implémentation du DataSource avec Dio
@LazySingleton(as: InventoryRemoteDataSource)
class InventoryRemoteDataSourceImpl implements InventoryRemoteDataSource {
  final ApiClient apiClient;
  final Logger logger;

  InventoryRemoteDataSourceImpl({
    required this.apiClient,
    required this.logger,
  });

  // ==================== ARTICLES - LECTURE - IMPLÉMENTATION ====================

  @override
  Future<PaginatedResponseModel<ArticleModel>> getArticles({
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
      logger.d('📡 API Call: GET /articles (page: $page)');

      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoryId != null) 'category': categoryId,
        if (brandId != null) 'brand': brandId,
        if (isActive != null) 'is_active': isActive,
        if (isLowStock != null) 'is_low_stock': isLowStock,
        if (ordering != null) 'ordering': ordering,
      };

      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: queryParams,
      );

      logger.i('✅ API Success: Articles récupérés');

      return PaginatedResponseModel<ArticleModel>.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    try {
      logger.d('📡 API Call: GET /articles/$id');

      final response = await apiClient.get('${ApiEndpoints.articles}$id/');

      logger.i('✅ API Success: Article $id récupéré');

      return ArticleModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleDetailModel> getArticleDetailById(String id) async {
    try {
      logger.d('📡 API Call: GET /articles/$id/ (détail complet)');

      final response = await apiClient.get('${ApiEndpoints.articles}$id/');

      logger.i('✅ API Success: Détail article $id récupéré');

      return ArticleDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error getArticleDetailById: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      logger.d('📡 API Call: SEARCH articles "$query"');

      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: {'search': query, 'page': page},
      );

      logger.i('✅ API Success: Recherche terminée');

      return PaginatedResponseModel<ArticleModel>.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getLowStockArticles() async {
    try {
      logger.d('📡 API Call: GET /articles?is_low_stock=true');

      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: {'is_low_stock': true},
      );

      logger.i('✅ API Success: Articles stock bas récupérés');

      final results = response.data['results'] as List;
      return results.map((json) => ArticleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getExpiringSoonArticles() async {
    try {
      logger.d('📡 API Call: GET /articles/expiring-soon');

      final response = await apiClient.get(
        '${ApiEndpoints.articles}expiring-soon/',
      );

      logger.i('✅ API Success: Articles péremption proche récupérés');

      final results = response.data as List;
      return results.map((json) => ArticleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== ARTICLES - CRUD - IMPLÉMENTATION ====================

  @override
  Future<ArticleModel> createArticle(
      Map<String, dynamic> data,
      String? imagePath,
      ) async {
    try {
      logger.d('📡 API Call: POST /articles (création)');
      logger.d('   Data: $data');

      dynamic requestData = data;

      // Si une image est fournie, utiliser FormData
      if (imagePath != null && imagePath.isNotEmpty) {
        requestData = FormData.fromMap({
          ...data,
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
        logger.d('   Image: ${imagePath.split('/').last}');
      }

      final response = await apiClient.post(
        ApiEndpoints.articles,
        data: requestData,
      );

      logger.i('✅ API Success: Article créé');

      return ArticleModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error createArticle: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleModel> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? imagePath,
      ) async {
    try {
      logger.d('📡 API Call: PUT /articles/$id/ (mise à jour)');
      logger.d('   Data: $data');

      dynamic requestData = data;

      // Si une nouvelle image est fournie
      if (imagePath != null && imagePath.isNotEmpty) {
        requestData = FormData.fromMap({
          ...data,
          'image': await MultipartFile.fromFile(
            imagePath,
            filename: imagePath.split('/').last,
          ),
        });
        logger.d('   Nouvelle image: ${imagePath.split('/').last}');
      }

      final response = await apiClient.put(
        '${ApiEndpoints.articles}$id/',
        data: requestData,
      );

      logger.i('✅ API Success: Article $id mis à jour');

      return ArticleModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error updateArticle: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      logger.d('📡 API Call: DELETE /articles/$id/');

      await apiClient.delete('${ApiEndpoints.articles}$id/');

      logger.i('✅ API Success: Article $id supprimé');
    } on DioException catch (e) {
      logger.e('❌ API Error deleteArticle: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== CATEGORIES - IMPLÉMENTATION ====================

  @override
  Future<List<CategoryModel>> getCategories({bool? isActive}) async {
    try {
      logger.d('📡 API Call: GET /categories');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await apiClient.get(
        ApiEndpoints.categories,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      logger.i('✅ API Success: Catégories récupérées');

      final results = response.data as List;
      return results.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      logger.d('📡 API Call: GET /categories/$id');

      final response = await apiClient.get('${ApiEndpoints.categories}$id/');

      logger.i('✅ API Success: Catégorie $id récupérée');

      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== BRANDS - IMPLÉMENTATION ====================

  @override
  Future<List<BrandModel>> getBrands({bool? isActive}) async {
    try {
      logger.d('📡 API Call: GET /brands');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await apiClient.get(
        ApiEndpoints.brands,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      logger.i('✅ API Success: Marques récupérées');

      final results = response.data as List;
      return results.map((json) => BrandModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BrandModel> getBrandById(String id) async {
    try {
      logger.d('📡 API Call: GET /brands/$id');

      final response = await apiClient.get('${ApiEndpoints.brands}$id/');

      logger.i('✅ API Success: Marque $id récupérée');

      return BrandModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== UNITS OF MEASURE - IMPLÉMENTATION ====================

  @override
  Future<List<UnitOfMeasureModel>> getUnitsOfMeasure({bool? isActive}) async {
    try {
      logger.d('📡 API Call: GET /units-of-measure');

      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await apiClient.get(
        ApiEndpoints.units,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      logger.i('✅ API Success: Unités de mesure récupérées');

      final results = response.data as List;
      return results.map((json) => UnitOfMeasureModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e('❌ API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== GESTION DES ERREURS ====================

  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception(
          'Délai d\'attente dépassé. Vérifiez votre connexion.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['detail'] ??
            error.response?.data?['message'] ??
            'Erreur serveur';

        switch (statusCode) {
          case 400:
            return Exception('Requête invalide: $message');
          case 401:
            return Exception('Non authentifié. Reconnectez-vous.');
          case 403:
            return Exception('Accès refusé: $message');
          case 404:
            return Exception('Ressource non trouvée');
          case 500:
          case 502:
          case 503:
            return Exception('Erreur serveur. Réessayez plus tard.');
          default:
            return Exception('Erreur HTTP $statusCode: $message');
        }

      case DioExceptionType.cancel:
        return Exception('Requête annulée');

      case DioExceptionType.unknown:
        if (error.message?.contains('SocketException') ?? false) {
          return Exception(
            'Impossible de se connecter au serveur. Vérifiez votre réseau.',
          );
        }
        return Exception('Erreur inconnue: ${error.message}');

      default:
        return Exception('Erreur réseau: ${error.message}');
    }
  }
}