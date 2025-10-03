// ========================================
// lib/core/network/api_client.dart
// VERSION ADAPTÉE - Support URL dynamique pour modes de connexion
// ========================================
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:logger/logger.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../../config/environment.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import '../errors/failures.dart';

/// Client API configuré avec Dio pour toutes les requêtes HTTP
/// Supporte le changement d'URL à chaud pour les modes de connexion
class ApiClient {
  late Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  AppEnvironment _environment;

  // Cache en mémoire pour les tokens
  String? _cachedAccessToken;
  String? _cachedRefreshToken;

  ApiClient({
    required FlutterSecureStorage secureStorage,
    required Logger logger,
    AppEnvironment? environment,
  })  : _secureStorage = secureStorage,
        _logger = logger,
        _environment = environment ?? AppEnvironment.current {
    _dio = _createDio();
    _setupInterceptors();
    _loadTokensToCache();
  }

  // ==================== GESTION URL DYNAMIQUE ====================

  /// Mettre à jour l'environnement et l'URL de l'API
  /// Permet de changer de mode de connexion à chaud
  void updateEnvironment(AppEnvironment newEnvironment) {
    _logger.i('🔄 Changement d\'environnement: ${_environment.name} → ${newEnvironment.name}');
    _logger.i('📡 Nouvelle URL API: ${newEnvironment.apiBaseUrl}');

    _environment = newEnvironment;

    // Mettre à jour la baseUrl du Dio existant
    _dio.options.baseUrl = newEnvironment.apiBaseUrl;
    _dio.options.connectTimeout = Duration(milliseconds: newEnvironment.connectTimeout);
    _dio.options.receiveTimeout = Duration(milliseconds: newEnvironment.receiveTimeout);

    // Reconfigurer les intercepteurs si nécessaire
    _reconfigureLogging();

    _logger.i('✅ Environnement mis à jour avec succès');
  }

  /// Obtenir l'environnement actuel
  AppEnvironment get currentEnvironment => _environment;

  /// Obtenir l'URL API actuelle
  String get currentApiUrl => _environment.apiBaseUrl;

  // ==================== CRÉATION DIO ====================

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
          return status != null && status < 500;
        },
      ),
    );
    return dio;
  }

  // ==================== INTERCEPTEURS ====================

  void _setupInterceptors() {
    // 1. Intercepteur d'authentification
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (_cachedAccessToken != null && _cachedAccessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_cachedAccessToken';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            if (await _refreshToken()) {
              try {
                final opts = error.requestOptions;
                opts.headers['Authorization'] = 'Bearer $_cachedAccessToken';
                final response = await _dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Intercepteur de logs
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

  /// Reconfigurer le logging après changement d'environnement
  void _reconfigureLogging() {
    // Supprimer l'ancien intercepteur de logs s'il existe
    _dio.interceptors.removeWhere((interceptor) => interceptor is PrettyDioLogger);

    // Ajouter un nouveau si nécessaire
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

  // ==================== GESTION TOKENS ====================

  Future<void> _loadTokensToCache() async {
    try {
      _cachedAccessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      _cachedRefreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);

      if (_cachedAccessToken != null) {
        _logger.i('✅ Token chargé en cache');
      }
    } catch (e) {
      _logger.e('❌ Erreur chargement tokens: $e');
    }
  }

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await Future.wait([
        _secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
        _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
      ]);

      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;

      _logger.i('✅ Tokens sauvegardés');
    } catch (e) {
      _logger.e('❌ Erreur sauvegarde tokens: $e');
      rethrow;
    }
  }

  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: StorageKeys.accessToken),
        _secureStorage.delete(key: StorageKeys.refreshToken),
      ]);

      _cachedAccessToken = null;
      _cachedRefreshToken = null;

      _logger.i('✅ Tokens supprimés');
    } catch (e) {
      _logger.e('❌ Erreur suppression tokens: $e');
      rethrow;
    }
  }

  String? get accessToken => _cachedAccessToken;
  String? get refreshToken => _cachedRefreshToken;

  Future<bool> _refreshToken() async {
    try {
      final refreshToken = _cachedRefreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('⚠️ Aucun refresh token');
        return false;
      }

      _logger.i('🔄 Rafraîchissement token...');

      final tempDio = Dio(
        BaseOptions(
          baseUrl: _environment.apiBaseUrl,
          connectTimeout: Duration(milliseconds: _environment.connectTimeout),
          receiveTimeout: Duration(milliseconds: _environment.receiveTimeout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await tempDio.post(
        ApiEndpoints.authRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access'] as String;
        final newRefreshToken = response.data['refresh'] as String? ?? refreshToken;

        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken,
        );

        _logger.i('✅ Token rafraîchi avec succès');
        return true;
      }

      return false;
    } catch (e) {
      _logger.e('❌ Erreur rafraîchissement token: $e');
      return false;
    }
  }

  // ==================== MÉTHODES HTTP ====================

  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> post(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> put(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> patch(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Response> delete(
      String path, {
        dynamic data,
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
      return _handleResponse(response);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // ==================== GESTION ERREURS ====================

  Response _handleResponse(Response response) {
    if (response.statusCode! >= 200 && response.statusCode! < 300) {
      return response;
    } else if (response.statusCode! >= 400) {
      throw _createFailureFromResponse(response);
    }
    return response;
  }

  Failure _handleDioError(DioException error) {
    _logger.e('❌ Erreur Dio: ${error.type} - ${error.message}');

    if (error.response != null) {
      return _createFailureFromResponse(error.response!);
    }

    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          message: 'Délai de connexion dépassé. Vérifiez votre réseau.',
        );

      case DioExceptionType.connectionError:
        return NetworkFailure(
          message: 'Impossible de se connecter au serveur.\n'
              'Vérifiez votre configuration de connexion.',
        );

      case DioExceptionType.cancel:
        return const NetworkFailure(message: 'Requête annulée.');

      default:
        return UnknownFailure(
          message: 'Erreur réseau: ${error.message}',
        );
    }
  }

  Failure _createFailureFromResponse(Response response) {
    final statusCode = response.statusCode ?? 0;
    final data = response.data;

    String message = 'Une erreur est survenue.';
    Map<String, List<String>>? fieldErrors;

    if (data is Map) {
      if (data.containsKey('detail')) {
        message = data['detail'].toString();
      } else if (data.containsKey('message')) {
        message = data['message'].toString();
      } else if (data.containsKey('error')) {
        message = data['error'].toString();
      }

      fieldErrors = _extractFieldErrors(data);
    }

    if (statusCode == 400) {
      return ValidationFailure(
        message: message,
        fieldErrors: fieldErrors,
      );
    } else if (statusCode == 401) {
      return const AuthenticationFailure(
        message: 'Session expirée. Veuillez vous reconnecter.',
      );
    } else if (statusCode == 403) {
      return const PermissionFailure(
        message: 'Vous n\'avez pas les permissions nécessaires.',
      );
    } else if (statusCode == 404) {
      return const NotFoundFailure(
        message: 'Ressource introuvable.',
      );
    } else if (statusCode >= 500) {
      return ServerFailure(
        message: 'Erreur serveur. Veuillez réessayer.',
        statusCode: statusCode,
      );
    }

    return UnknownFailure(message: message);
  }

  Map<String, List<String>>? _extractFieldErrors(dynamic responseData) {
    if (responseData is! Map) return null;

    final errors = <String, List<String>>{};

    responseData.forEach((key, value) {
      if (key == 'message' ||
          key == 'detail' ||
          key == 'error' ||
          key == 'non_field_errors' ||
          key == '_meta' ||
          key == 'status' ||
          key == 'code') {
        return;
      }

      if (value is List) {
        errors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        errors[key] = [value];
      }
    });

    return errors.isNotEmpty ? errors : null;
  }

  // ==================== CLEANUP ====================

  void dispose() {
    _dio.close();
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _logger.i('🔌 ApiClient disposed');
  }
}