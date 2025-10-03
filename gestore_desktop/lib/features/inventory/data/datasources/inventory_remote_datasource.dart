// ========================================
// lib/features/inventory/data/datasources/inventory_remote_datasource.dart
// DataSource pour les appels API du module inventory
// ========================================

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/article_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../models/paginated_response_model.dart';
import '../models/unit_of_measure_model.dart';

/// DataSource abstraite pour les opérations d'inventaire
abstract class InventoryRemoteDataSource {
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

  /// Récupère un article par ID
  Future<ArticleModel> getArticleById(String id);

  /// Recherche des articles
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  });

  /// Récupère les articles avec stock bas
  Future<List<ArticleModel>> getLowStockArticles();

  /// Récupère les articles proches de la péremption
  Future<List<ArticleModel>> getExpiringSoonArticles();

  /// Récupère toutes les catégories
  Future<List<CategoryModel>> getCategories({bool? isActive});

  /// Récupère une catégorie par ID
  Future<CategoryModel> getCategoryById(String id);

  /// Récupère toutes les marques
  Future<List<BrandModel>> getBrands({bool? isActive});

  /// Récupère une marque par ID
  Future<BrandModel> getBrandById(String id);

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
      logger.d('📦 Récupération articles: page=$page, pageSize=$pageSize');

      // Construire les query parameters
      final queryParams = <String, dynamic>{
        'page': page,
        'page_size': pageSize,
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (categoryId != null) {
        queryParams['category'] = categoryId;
      }
      if (brandId != null) {
        queryParams['brand'] = brandId;
      }
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }
      if (isLowStock != null) {
        queryParams['is_low_stock'] = isLowStock;
      }
      if (ordering != null) {
        queryParams['ordering'] = ordering;
      }

      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: queryParams,
      );

      logger.i('✅ Articles récupérés: ${response.data['count']} total');

      return PaginatedResponseModel.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération articles: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    try {
      logger.d('📦 Récupération article: $id');

      final response = await apiClient.get(ApiEndpoints.articleDetail(id));

      logger.i('✅ Article récupéré: ${response.data['name']}');

      return ArticleModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération article: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      logger.d('🔍 Recherche articles: "$query"');

      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: {
          'search': query,
          'page': page,
        },
      );

      logger.i('✅ Résultats recherche: ${response.data['count']} trouvés');

      return PaginatedResponseModel.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e('❌ Erreur recherche articles: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getLowStockArticles() async {
    try {
      logger.d('📦 Récupération articles stock bas');

      final response = await apiClient.get(ApiEndpoints.articlesLowStock);

      final List<dynamic> data = response.data as List<dynamic>;
      logger.i('✅ Articles stock bas: ${data.length} trouvés');

      return data
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération stock bas: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getExpiringSoonArticles() async {
    try {
      logger.d('📦 Récupération articles péremption proche');

      final response = await apiClient.get(ApiEndpoints.articlesExpiringSoon);

      final List<dynamic> data = response.data as List<dynamic>;
      logger.i('✅ Articles péremption proche: ${data.length} trouvés');

      return data
          .map((json) => ArticleModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération péremption: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<CategoryModel>> getCategories({bool? isActive}) async {
    try {
      logger.d('📂 Récupération catégories');

      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await apiClient.get(
        ApiEndpoints.categories,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      logger.i('✅ Catégories récupérées: ${data.length}');

      return data
          .map((json) => CategoryModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération catégories: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      logger.d('📂 Récupération catégorie: $id');

      final response = await apiClient.get(ApiEndpoints.categoryDetail(id));

      logger.i('✅ Catégorie récupérée: ${response.data['name']}');

      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération catégorie: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<BrandModel>> getBrands({bool? isActive}) async {
    try {
      logger.d('🏷️ Récupération marques');

      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await apiClient.get(
        ApiEndpoints.brands,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      logger.i('✅ Marques récupérées: ${data.length}');

      return data
          .map((json) => BrandModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération marques: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BrandModel> getBrandById(String id) async {
    try {
      logger.d('🏷️ Récupération marque: $id');

      final response = await apiClient.get(ApiEndpoints.brandDetail(id));

      logger.i('✅ Marque récupérée: ${response.data['name']}');

      return BrandModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération marque: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<UnitOfMeasureModel>> getUnitsOfMeasure({bool? isActive}) async {
    try {
      logger.d('📏 Récupération unités de mesure');

      final queryParams = <String, dynamic>{};
      if (isActive != null) {
        queryParams['is_active'] = isActive;
      }

      final response = await apiClient.get(
        ApiEndpoints.units,
        queryParameters: queryParams,
      );

      final List<dynamic> data = response.data as List<dynamic>;
      logger.i('✅ Unités de mesure récupérées: ${data.length}');

      return data
          .map((json) =>
          UnitOfMeasureModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioException catch (e) {
      logger.e('❌ Erreur récupération unités: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Gère les erreurs Dio et retourne des messages appropriés
  String _handleDioError(DioException error) {
    if (error.response != null) {
      final statusCode = error.response!.statusCode;
      final data = error.response!.data;

      switch (statusCode) {
        case 400:
          return 'Requête invalide: ${data?['detail'] ?? 'Erreur de validation'}';
        case 401:
          return 'Session expirée. Veuillez vous reconnecter.';
        case 403:
          return 'Accès refusé. Permissions insuffisantes.';
        case 404:
          return 'Ressource non trouvée.';
        case 500:
          return 'Erreur serveur. Veuillez réessayer plus tard.';
        default:
          return 'Erreur réseau: ${error.message}';
      }
    }

    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return 'Délai d\'attente dépassé. Vérifiez votre connexion.';
    }

    if (error.type == DioExceptionType.connectionError) {
      return 'Impossible de se connecter au serveur.';
    }

    return 'Une erreur est survenue: ${error.message}';
  }
}