// ========================================
// lib/features/inventory/data/datasources/inventory_remote_datasource.dart
// DataSource pour les appels API du module inventory
// VERSION 2.2 - FIX: Gestion correcte de FormData pour l'upload de fichiers
// ========================================
import 'dart:convert'; // Import pour jsonE
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../models/article_model.dart';
import '../models/article_detail_model.dart';
import '../models/category_model.dart';
import '../models/brand_model.dart';
import '../../../../core/network/paginated_response_model.dart';
import '../models/unit_of_measure_model.dart';

/// DataSource abstraite pour les opérations d'inventaire
abstract class InventoryRemoteDataSource {
  // ==================== ARTICLES - LECTURE ====================
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
  Future<ArticleModel> getArticleById(String id);
  Future<ArticleDetailModel> getArticleDetailById(String id);
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  });
  Future<List<ArticleModel>> getLowStockArticles();
  Future<List<ArticleModel>> getExpiringSoonArticles();

  // ==================== ARTICLES - CRUD ====================
  Future<ArticleDetailModel> createArticle(
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU paramètre
      );

  Future<ArticleDetailModel> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths, // ⭐ NOUVEAU paramètre
      );
  Future<void> deleteArticle(String id);

  // ==================== CATEGORIES ====================
  Future<List<CategoryModel>> getCategories({bool? isActive});
  Future<CategoryModel> getCategoryById(String id);
  Future<CategoryModel> createCategory(Map<String, dynamic> data);
  Future<CategoryModel> updateCategory(String id, Map<String, dynamic> data);
  Future<void> deleteCategory(String id);

  // ==================== BRANDS ====================
  Future<List<BrandModel>> getBrands({bool? isActive});
  Future<BrandModel> getBrandById(String id);
  Future<BrandModel> createBrand(Map<String, dynamic> data, String? logoPath);
  Future<BrandModel> updateBrand(String id, Map<String, dynamic> data, String? logoPath);
  Future<void> deleteBrand(String id);

  // ==================== UNITS OF MEASURE ====================
  Future<List<UnitOfMeasureModel>> getUnitsOfMeasure({bool? isActive});
  Future<UnitOfMeasureModel> getUnitOfMeasureById(String id);
  Future<UnitOfMeasureModel> createUnitOfMeasure(Map<String, dynamic> data);
  Future<UnitOfMeasureModel> updateUnitOfMeasure(String id, Map<String, dynamic> data);
  Future<void> deleteUnitOfMeasure(String id);
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

  // ==================== ARTICLES - LECTURE ====================
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
      logger.d(' 📡  API Call: GET /articles (page: $page)');
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
      logger.i(' ✅  API Success: Articles récupérés');
      return PaginatedResponseModel<ArticleModel>.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleModel> getArticleById(String id) async {
    try {
      logger.d(' 📡  API Call: GET /articles/$id');
      final response = await apiClient.get('${ApiEndpoints.articles}$id/');
      logger.i(' ✅  API Success: Article $id récupéré');
      return ArticleModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<ArticleDetailModel> getArticleDetailById(String id) async {
    try {
      logger.d(' 📡  API Call: GET /articles/$id/ (détail complet)');
      final response = await apiClient.get('${ApiEndpoints.articles}$id/');
      logger.i(' ✅  API Success: Détail article $id récupéré');
      return ArticleDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error getArticleDetailById: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<PaginatedResponseModel<ArticleModel>> searchArticles({
    required String query,
    int page = 1,
  }) async {
    try {
      logger.d(' 📡  API Call: SEARCH articles "$query"');
      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: {'search': query, 'page': page},
      );
      logger.i(' ✅  API Success: Recherche terminée');
      return PaginatedResponseModel<ArticleModel>.fromJson(
        response.data,
            (json) => ArticleModel.fromJson(json),
      );
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getLowStockArticles() async {
    try {
      logger.d(' 📡  API Call: GET /articles?is_low_stock=true');
      final response = await apiClient.get(
        ApiEndpoints.articles,
        queryParameters: {'is_low_stock': true},
      );
      logger.i(' ✅  API Success: Articles stock bas récupérés');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map((json) => ArticleModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<List<ArticleModel>> getExpiringSoonArticles() async {
    try {
      logger.d(' 📡  API Call: GET /articles/expiring-soon');
      final response = await apiClient.get(
        '${ApiEndpoints.articles}expiring-soon/',
      );
      logger.i(' ✅  API Success: Articles péremption proche récupérés');
      if (response.data is List) {
        final results = response.data as List;
        return results.map((json) => ArticleModel.fromJson(json)).toList();
      } else {
        final data = response.data as Map<String, dynamic>;
        final results = data['results'] as List;
        return results.map((json) => ArticleModel.fromJson(json)).toList();
      }
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== ARTICLES - CRUD ====================

  @override
  Future<ArticleDetailModel> createArticle(
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths,
      ) async {
    try {
      logger.d(' 📡  API Call: POST /articles (création avec multi-images)');
      final Map<String, dynamic> formDataMap = {};

      // 1. Ajouter toutes les paires clé-valeur simples
      data.forEach((key, value) {
        if (key != 'images_data' &&
            key != 'additional_barcodes_data' &&
            key != 'secondary_images') {
          if (value != null) {
            formDataMap[key] = value;
          }
        }
      });

      // 2. Traiter les codes-barres additionnels
      if (data['additional_barcodes_data'] != null &&
          (data['additional_barcodes_data'] as List).isNotEmpty) {
        formDataMap['additional_barcodes_data'] =
            jsonEncode(data['additional_barcodes_data']);
      }

      // 3. ⭐ Image principale: Upload du fichier
      if (primaryImagePath != null && primaryImagePath.isNotEmpty) {
        final file = File(primaryImagePath);
        if (await file.exists()) {
          formDataMap['image'] = await MultipartFile.fromFile(
            primaryImagePath,
            filename: primaryImagePath.split(RegExp(r'[/\\]')).last,
          );
          logger.d('   📸 Image principale uploadée: ${formDataMap['image'].filename}');
        } else {
          logger.w('   ⚠️  Fichier image principale introuvable: $primaryImagePath');
        }
      }

      // 4. ⭐ NOUVEAU: Images secondaires - Upload des fichiers
      if (secondaryImagePaths != null && secondaryImagePaths.isNotEmpty) {
        final secondaryFiles = <MultipartFile>[];
        final metadataList = <Map<String, dynamic>>[];

        // Récupérer les métadonnées depuis data['images_data']
        List<dynamic> allImagesData = [];
        if (data['images_data'] != null) {
          allImagesData = data['images_data'] as List;
        }

        int fileIndex = 0;
        for (final imagePath in secondaryImagePaths) {
          final file = File(imagePath);

          if (await file.exists()) {
            // Ajouter le fichier
            final multipartFile = await MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split(RegExp(r'[/\\]')).last,
            );
            secondaryFiles.add(multipartFile);

            // Récupérer les métadonnées correspondantes
            Map<String, dynamic> metadata = {
              'alt_text': '',
              'caption': '',
              'order': fileIndex + 1,
            };

            // Chercher les métadonnées dans allImagesData
            if (fileIndex < allImagesData.length) {
              final imgData = allImagesData[fileIndex];
              if (imgData is Map<String, dynamic>) {
                metadata['alt_text'] = imgData['alt_text'] ?? '';
                metadata['caption'] = imgData['caption'] ?? '';
                metadata['order'] = imgData['order'] ?? (fileIndex + 1);
              }
            }

            metadataList.add(metadata);
            fileIndex++;

            logger.d('   📸 Image secondaire ${fileIndex}: ${multipartFile.filename}');
          } else {
            logger.w('   ⚠️  Fichier image secondaire introuvable: $imagePath');
          }
        }

        // Ajouter les fichiers et métadonnées au FormData
        if (secondaryFiles.isNotEmpty) {
          formDataMap['secondary_images'] = secondaryFiles;
          formDataMap['images_data'] = jsonEncode(metadataList);

          logger.i('   ✅ ${secondaryFiles.length} images secondaires préparées');
        }
      } else {
        // Pas de fichiers secondaires mais peut-être des métadonnées
        if (data['images_data'] != null) {
          final allImages = data['images_data'] as List;

          // Filtrer pour exclure l'image principale
          final secondaryMetadata = allImages
              .where((img) => !(img['is_primary'] as bool? ?? false))
              .map((img) {
            final cleaned = Map<String, dynamic>.from(img);
            cleaned.remove('image_path'); // Supprimer le chemin local
            return cleaned;
          })
              .toList();

          if (secondaryMetadata.isNotEmpty) {
            formDataMap['images_data'] = jsonEncode(secondaryMetadata);
            logger.w('   ⚠️  ${secondaryMetadata.length} images secondaires créées SANS fichiers');
          }
        }
      }

      // 5. Créer le FormData et envoyer la requête
      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.post(
        ApiEndpoints.articles,
        data: formData,
      );

      logger.i(' ✅  API Success: Article créé avec images');
      return ArticleDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error createArticle: ${e.response?.data ?? e.message}');
      throw _handleDioError(e);
    } catch (e) {
      logger.e(' ❌  Erreur inattendue dans createArticle: $e');
      rethrow;
    }
  }

  @override
  Future<ArticleDetailModel> updateArticle(
      String id,
      Map<String, dynamic> data,
      String? primaryImagePath,
      List<String>? secondaryImagePaths,
      ) async {
    try {
      logger.d(' 📡  API Call: PATCH /articles/$id/ (mise à jour avec multi-images)');
      final Map<String, dynamic> formDataMap = {};

      // 1. Copier les champs simples
      data.forEach((key, value) {
        if (key != 'images_data' &&
            key != 'additional_barcodes_data' &&
            key != 'secondary_images') {
          if (value != null) {
            formDataMap[key] = value;
          }
        }
      });

      // 2. Codes-barres
      if (data['additional_barcodes_data'] != null) {
        formDataMap['additional_barcodes_data'] =
            jsonEncode(data['additional_barcodes_data']);
      }

      // 3. Image principale
      if (primaryImagePath != null && primaryImagePath.isNotEmpty) {
        final file = File(primaryImagePath);
        if (await file.exists()) {
          formDataMap['image'] = await MultipartFile.fromFile(
            primaryImagePath,
            filename: primaryImagePath.split(RegExp(r'[/\\]')).last,
          );
          logger.d('   📸 Nouvelle image principale: ${formDataMap['image'].filename}');
        }
      }

      // 4. ⭐ Images secondaires
      if (secondaryImagePaths != null && secondaryImagePaths.isNotEmpty) {
        final secondaryFiles = <MultipartFile>[];
        final metadataList = <Map<String, dynamic>>[];

        List<dynamic> allImagesData = [];
        if (data['images_data'] != null) {
          allImagesData = data['images_data'] as List;
        }

        int fileIndex = 0;
        for (final imagePath in secondaryImagePaths) {
          final file = File(imagePath);

          if (await file.exists()) {
            final multipartFile = await MultipartFile.fromFile(
              imagePath,
              filename: imagePath.split(RegExp(r'[/\\]')).last,
            );
            secondaryFiles.add(multipartFile);

            Map<String, dynamic> metadata = {
              'alt_text': '',
              'caption': '',
              'order': fileIndex + 1,
            };

            if (fileIndex < allImagesData.length) {
              final imgData = allImagesData[fileIndex];
              if (imgData is Map<String, dynamic>) {
                metadata['alt_text'] = imgData['alt_text'] ?? '';
                metadata['caption'] = imgData['caption'] ?? '';
                metadata['order'] = imgData['order'] ?? (fileIndex + 1);
              }
            }

            metadataList.add(metadata);
            fileIndex++;
          }
        }

        if (secondaryFiles.isNotEmpty) {
          formDataMap['secondary_images'] = secondaryFiles;
          formDataMap['images_data'] = jsonEncode(metadataList);

          logger.i('   ✅ ${secondaryFiles.length} images secondaires mises à jour');
        }
      } else if (data['images_data'] != null) {
        final allImages = data['images_data'] as List;
        final secondaryMetadata = allImages
            .where((img) => !(img['is_primary'] as bool? ?? false))
            .map((img) {
          final cleaned = Map<String, dynamic>.from(img);
          cleaned.remove('image_path');
          return cleaned;
        })
            .toList();

        if (secondaryMetadata.isNotEmpty) {
          formDataMap['images_data'] = jsonEncode(secondaryMetadata);
        }
      }

      final formData = FormData.fromMap(formDataMap);
      final response = await apiClient.patch(
        '${ApiEndpoints.articles}$id/',
        data: formData,
      );

      logger.i(' ✅  API Success: Article $id mis à jour');
      return ArticleDetailModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error updateArticle: ${e.response?.data ?? e.message}');
      throw _handleDioError(e);
    } catch (e) {
      logger.e(' ❌  Erreur inattendue dans updateArticle: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteArticle(String id) async {
    try {
      logger.d(' 📡  API Call: DELETE /articles/$id/');
      await apiClient.delete('${ApiEndpoints.articles}$id/');
      logger.i(' ✅  API Success: Article $id supprimé');
    } on DioException catch (e) {
      logger.e(' ❌  API Error deleteArticle: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== CATEGORIES ====================
  @override
  Future<List<CategoryModel>> getCategories({bool? isActive}) async {
    try {
      logger.d(' 📡  API Call: GET /categories');
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;
      final response = await apiClient.get(
        ApiEndpoints.categories,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      logger.i(' ✅  API Success: Catégories récupérées');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map((json) => CategoryModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> getCategoryById(String id) async {
    try {
      logger.d(' 📡  API Call: GET /categories/$id');
      final response = await apiClient.get('${ApiEndpoints.categories}$id/');
      logger.i(' ✅  API Success: Catégorie $id récupérée');
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> createCategory(Map<String, dynamic> data) async {
    try {
      logger.d(' 📡  API Call: POST /categories');
      logger.d('   Data: $data');
      final response = await apiClient.post(
        ApiEndpoints.categories,
        data: data,
      );
      logger.i(' ✅  API Success: Catégorie créée');
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<CategoryModel> updateCategory(
      String id, Map<String, dynamic> data) async {
    try {
      logger.d(' 📡  API Call: PUT /categories/$id');
      logger.d('   Data: $data');
      final response = await apiClient.put(
        '${ApiEndpoints.categories}$id/',
        data: data,
      );
      logger.i(' ✅  API Success: Catégorie mise à jour');
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteCategory(String id) async {
    try {
      logger.d(' 📡  API Call: DELETE /categories/$id');
      await apiClient.delete('${ApiEndpoints.categories}$id/');
      logger.i(' ✅  API Success: Catégorie supprimée');
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== BRANDS ====================
  @override
  Future<List<BrandModel>> getBrands({bool? isActive}) async {
    try {
      logger.d(' 📡  API Call: GET /brands');
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;
      final response = await apiClient.get(
        ApiEndpoints.brands,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      logger.i(' ✅  API Success: Marques récupérées');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map((json) => BrandModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BrandModel> getBrandById(String id) async {
    try {
      logger.d(' 📡  API Call: GET /brands/$id');
      final response = await apiClient.get('${ApiEndpoints.brands}$id/');
      logger.i(' ✅  API Success: Marque $id récupérée');
      return BrandModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BrandModel> createBrand(
      Map<String, dynamic> data, String? logoPath) async {
    try {
      logger.d(' 📡  API Call: POST /brands');
      dynamic requestData;
      if (logoPath != null && logoPath.isNotEmpty) {
        final formData = FormData.fromMap({
          ...data,
          'logo': await MultipartFile.fromFile(logoPath),
        });
        requestData = formData;
      } else {
        requestData = data;
      }
      final response = await apiClient.post(
        ApiEndpoints.brands,
        data: requestData,
      );
      logger.i(' ✅  API Success: Marque créée');
      return BrandModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<BrandModel> updateBrand(
      String id, Map<String, dynamic> data, String? logoPath) async {
    try {
      logger.d(' 📡  API Call: PUT /brands/$id');
      dynamic requestData;
      if (logoPath != null && logoPath.isNotEmpty) {
        final formData = FormData.fromMap({
          ...data,
          'logo': await MultipartFile.fromFile(logoPath),
        });
        requestData = formData;
      } else {
        requestData = data;
      }
      final response = await apiClient.put(
        '${ApiEndpoints.brands}$id/',
        data: requestData,
      );
      logger.i(' ✅  API Success: Marque mise à jour');
      return BrandModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteBrand(String id) async {
    try {
      logger.d(' 📡  API Call: DELETE /brands/$id');
      await apiClient.delete('${ApiEndpoints.brands}$id/');
      logger.i(' ✅  API Success: Marque supprimée');
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  // ==================== UNITS OF MEASURE ====================
  @override
  Future<List<UnitOfMeasureModel>> getUnitsOfMeasure({bool? isActive}) async {
    try {
      logger.d(' 📡  API Call: GET /units-of-measure');
      final queryParams = <String, dynamic>{};
      if (isActive != null) queryParams['is_active'] = isActive;
      final response = await apiClient.get(
        ApiEndpoints.units,
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );
      logger.i(' ✅  API Success: Unités de mesure récupérées');
      final data = response.data as Map<String, dynamic>;
      final results = data['results'] as List;
      return results.map((json) => UnitOfMeasureModel.fromJson(json)).toList();
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<UnitOfMeasureModel> getUnitOfMeasureById(String id) async {
    try {
      logger.d(' 📡  API Call: GET /units/$id');
      final response = await apiClient.get('${ApiEndpoints.units}$id/');
      logger.i(' ✅  API Success: Unité $id récupérée');
      return UnitOfMeasureModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<UnitOfMeasureModel> createUnitOfMeasure(
      Map<String, dynamic> data) async {
    try {
      logger.d(' 📡  API Call: POST /units');
      final response = await apiClient.post(
        ApiEndpoints.units,
        data: data,
      );
      logger.i(' ✅  API Success: Unité créée');
      return UnitOfMeasureModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<UnitOfMeasureModel> updateUnitOfMeasure(
      String id, Map<String, dynamic> data) async {
    try {
      logger.d(' 📡  API Call: PUT /units/$id');
      final response = await apiClient.put(
        '${ApiEndpoints.units}$id/',
        data: data,
      );
      logger.i(' ✅  API Success: Unité mise à jour');
      return UnitOfMeasureModel.fromJson(response.data);
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
      throw _handleDioError(e);
    }
  }

  @override
  Future<void> deleteUnitOfMeasure(String id) async {
    try {
      logger.d(' 📡  API Call: DELETE /units/$id');
      await apiClient.delete('${ApiEndpoints.units}$id/');
      logger.i(' ✅  API Success: Unité supprimée');
    } on DioException catch (e) {
      logger.e(' ❌  API Error: ${e.message}');
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