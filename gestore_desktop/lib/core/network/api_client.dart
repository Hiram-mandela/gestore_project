import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/environment.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import '../errors/failures.dart';

/// Client API configuré avec Dio pour toutes les requêtes HTTP
/// Gère l'authentification JWT, les retries, les timeouts, etc.
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final AppEnvironment _environment;

  ApiClient({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
    AppEnvironment? environment,
  })  : _secureStorage = secureStorage,
        _logger = logger,
        _environment = environment ?? AppEnvironment.current {
    _dio = _createDio();
    _setupInterceptors();
  }

  /// Créer l'instance Dio avec la configuration de base
  Dio _createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: _environment.apiBaseUrl,
        connectTimeout: Duration(milliseconds: _environment.connectTimeout),
        receiveTimeout: Duration(milliseconds: _environment.receiveTimeout),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        validateStatus: (status) {
          // Considérer toutes les réponses comme valides pour les gérer nous-mêmes
          return status != null && status < 500;
        },
      ),
    );
    return dio;
  }

  /// Configurer les intercepteurs Dio
  void _setupInterceptors() {
    // Intercepteur d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Ajouter le token d'accès à chaque requête
          final token = await _secureStorage.read(key: StorageKeys.accessToken);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          // Gérer le refresh token si 401
          if (error.response?.statusCode == 401) {
            // Tenter de rafraîchir le token
            final refreshed = await _refreshToken();
            if (refreshed) {
              // Retenter la requête avec le nouveau token
              return handler.resolve(await _retry(error.requestOptions));
            }
          }
          return handler.next(error);
        },
      ),
    );

    // Intercepteur de logs (seulement en dev)
    if (_environment.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }
  }

  /// Rafraîchir le token d'accès
  Future<bool> _refreshToken() async {
    try {
      final refreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);
      if (refreshToken == null) {
        _logger.w('Aucun refresh token disponible');
        return false;
      }

      final response = await _dio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'];
        final newRefreshToken = response.data['refresh'];

        // Sauvegarder les nouveaux tokens
        await _secureStorage.write(key: StorageKeys.accessToken, value: newAccessToken);
        if (newRefreshToken != null) {
          await _secureStorage.write(key: StorageKeys.refreshToken, value: newRefreshToken);
        }

        _logger.i('Token rafraîchi avec succès');
        return true;
      }
    } catch (e) {
      _logger.e('Erreur lors du rafraîchissement du token: $e');
    }
    return false;
  }

  /// Retenter une requête après rafraîchissement du token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = await _secureStorage.read(key: StorageKeys.accessToken);
    requestOptions.headers['Authorization'] = 'Bearer $token';
    return _dio.request(
      requestOptions.path,
      options: Options(
        method: requestOptions.method,
        headers: requestOptions.headers,
      ),
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  /// GET request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// POST request
  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PUT request
  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// PATCH request
  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// DELETE request
  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Upload de fichier
  Future<Response> uploadFile(
      String path,
      String filePath, {
        String fieldName = 'file',
        Map<String, dynamic>? data,
      }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      return await _dio.post(
        path,
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  /// Gérer les erreurs Dio et les convertir en exceptions personnalisées
  Exception _handleDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          message: 'La requête a expiré. Veuillez réessayer.',
          error: error,
        );

      case DioExceptionType.connectionError:
        return NetworkException(
          message: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        );

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final message = error.response?.data?['message'] ??
            error.response?.data?['detail'] ??
            'Une erreur est survenue';

        if (statusCode == 401 || statusCode == 403) {
          return AuthenticationFailure(
            message: message,
            statusCode: statusCode,
            error: error,
          );
        } else if (statusCode == 404) {
          return NotFoundFailure(
            message: message,
            statusCode: statusCode,
            error: error,
          );
        } else if (statusCode == 422 || statusCode == 400) {
          return ValidationFailure(
            message: message,
            statusCode: statusCode,
            error: error,
            fieldErrors: _extractFieldErrors(error.response?.data),
          );
        } else if (statusCode == 409) {
          return ConflictFailure(
            message: message,
            statusCode: statusCode,
            error: error,
          );
        } else if (statusCode != null && statusCode >= 500) {
          return ServerFailure(
            message: 'Erreur serveur. Veuillez réessayer plus tard.',
            statusCode: statusCode,
            error: error,
          );
        }
        return ApiException(
          message: message,
          statusCode: statusCode,
          response: error.response?.data,
        );

      case DioExceptionType.cancel:
        return ApiException(
          message: 'Requête annulée',
          statusCode: null,
        );

      default:
        return UnknownFailure(
          message: 'Une erreur inconnue est survenue',
          error: error,
        );
    }
  }

  /// Extraire les erreurs de champs de la réponse
  Map<String, List<String>>? _extractFieldErrors(dynamic responseData) {
    if (responseData is Map) {
      final errors = <String, List<String>>{};
      responseData.forEach((key, value) {
        if (value is List) {
          errors[key] = value.map((e) => e.toString()).toList();
        } else if (value is String) {
          errors[key] = [value];
        }
      });
      return errors.isNotEmpty ? errors : null;
    }
    return null;
  }

  /// Nettoyer les ressources
  void dispose() {
    _dio.close();
  }
}