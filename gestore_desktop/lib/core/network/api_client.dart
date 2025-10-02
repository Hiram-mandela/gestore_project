// ========================================
// lib/core/network/api_client.dart
// VERSION COMPLÈTE ET FINALE - Avec toutes les corrections
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
/// Gère l'authentification JWT avec cache en mémoire, les retries, les timeouts, et les erreurs
class ApiClient {
  late final Dio _dio;
  final FlutterSecureStorage _secureStorage;
  final Logger _logger;
  final AppEnvironment _environment;

  // CACHE EN MÉMOIRE pour éviter les problèmes de lecture FlutterSecureStorage
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
    _loadTokensToCache(); // Charger les tokens au démarrage
  }

  /// Charger les tokens depuis le storage vers le cache au démarrage
  Future<void> _loadTokensToCache() async {
    try {
      _cachedAccessToken = await _secureStorage.read(key: StorageKeys.accessToken);
      _cachedRefreshToken = await _secureStorage.read(key: StorageKeys.refreshToken);

      if (_cachedAccessToken != null) {
        _logger.i('✅ Token chargé en cache: ${_cachedAccessToken!.substring(0, 20)}...');
      } else {
        _logger.d('ℹ️ Aucun token en cache au démarrage');
      }
    } catch (e) {
      _logger.e('❌ Erreur chargement tokens en cache: $e');
    }
  }

  /// Sauvegarder les tokens (storage + cache)
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      // Sauvegarder dans le storage
      await Future.wait([
        _secureStorage.write(key: StorageKeys.accessToken, value: accessToken),
        _secureStorage.write(key: StorageKeys.refreshToken, value: refreshToken),
      ]);

      // Mettre à jour le cache
      _cachedAccessToken = accessToken;
      _cachedRefreshToken = refreshToken;

      _logger.i('✅ Tokens sauvegardés (storage + cache): ${accessToken.substring(0, 20)}...');
    } catch (e) {
      _logger.e('❌ Erreur sauvegarde tokens: $e');
      rethrow;
    }
  }

  /// Supprimer les tokens (storage + cache)
  Future<void> clearTokens() async {
    try {
      await Future.wait([
        _secureStorage.delete(key: StorageKeys.accessToken),
        _secureStorage.delete(key: StorageKeys.refreshToken),
      ]);

      // Vider le cache
      _cachedAccessToken = null;
      _cachedRefreshToken = null;

      _logger.i('✅ Tokens supprimés (storage + cache)');
    } catch (e) {
      _logger.e('❌ Erreur suppression tokens: $e');
      rethrow;
    }
  }

  /// Obtenir le token d'accès (depuis le cache)
  String? get accessToken => _cachedAccessToken;

  /// Obtenir le token de rafraîchissement (depuis le cache)
  String? get refreshToken => _cachedRefreshToken;

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
    // 1. Intercepteur d'authentification (EN PREMIER)
    _dio.interceptors.add(
      QueuedInterceptorsWrapper(
        onRequest: (options, handler) async {
          // Lire le token depuis le CACHE (pas depuis FlutterSecureStorage)
          final token = _cachedAccessToken;

          if (token != null && token.isNotEmpty) {
            // Ajouter le token aux headers
            options.headers['Authorization'] = 'Bearer $token';
            _logger.d('🔐 Token JWT ajouté depuis cache: Bearer ${token.substring(0, 20)}...');
          } else {
            _logger.w('⚠️ Aucun token JWT en cache pour: ${options.method} ${options.path}');
          }

          return handler.next(options);
        },
        onError: (error, handler) async {
          // Gérer le refresh token automatique si 401
          if (error.response?.statusCode == 401) {
            _logger.w('⚠️ 401 Unauthorized détecté sur: ${error.requestOptions.path}');

            // Vérifier si c'est une requête de refresh token pour éviter boucle infinie
            if (error.requestOptions.path.contains('refresh') ||
                error.requestOptions.path.contains('token/refresh')) {
              _logger.e('❌ Refresh token invalide ou expiré, déconnexion nécessaire');
              return handler.next(error);
            }

            // Tenter de rafraîchir le token
            _logger.i('🔄 Tentative de rafraîchissement du token...');
            final refreshed = await _refreshToken();

            if (refreshed) {
              _logger.i('✅ Token rafraîchi avec succès, nouvelle tentative de la requête');
              // Retenter la requête avec le nouveau token
              try {
                final response = await _retry(error.requestOptions);
                return handler.resolve(response);
              } catch (e) {
                _logger.e('❌ Échec de la nouvelle tentative: $e');
                return handler.next(error);
              }
            } else {
              _logger.e('❌ Impossible de rafraîchir le token');
            }
          }
          return handler.next(error);
        },
      ),
    );

    // 2. Intercepteur de logs (EN DERNIER pour voir les headers modifiés)
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
      final refreshToken = _cachedRefreshToken;
      if (refreshToken == null || refreshToken.isEmpty) {
        _logger.w('⚠️ Aucun refresh token en cache');
        return false;
      }

      _logger.i('🔄 Tentative de rafraîchissement du token...');

      // Créer un Dio temporaire SANS intercepteurs pour éviter boucle infinie
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
        final newRefreshToken = response.data['refresh'] as String?;

        // Sauvegarder les nouveaux tokens (storage + cache)
        await saveTokens(
          accessToken: newAccessToken,
          refreshToken: newRefreshToken ?? refreshToken,
        );

        _logger.i('✅ Token rafraîchi avec succès');
        return true;
      } else {
        _logger.w('⚠️ Réponse non-200 lors du refresh: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      _logger.e('❌ Erreur lors du rafraîchissement du token: $e');
      return false;
    }
  }

  /// Retenter une requête après rafraîchissement du token
  Future<Response<dynamic>> _retry(RequestOptions requestOptions) async {
    final token = _cachedAccessToken;

    // Créer une copie des headers avec le nouveau token
    final newHeaders = Map<String, dynamic>.from(requestOptions.headers);
    if (token != null && token.isNotEmpty) {
      newHeaders['Authorization'] = 'Bearer $token';
      _logger.d('🔐 Nouveau token ajouté pour retry: Bearer ${token.substring(0, 20)}...');
    }

    final options = Options(
      method: requestOptions.method,
      headers: newHeaders,
    );

    return _dio.request(
      requestOptions.path,
      options: options,
      data: requestOptions.data,
      queryParameters: requestOptions.queryParameters,
    );
  }

  /// Vérifier le statusCode et lancer une DioException si erreur
  /// Cette méthode transforme les réponses 4xx/5xx en exceptions
  void _checkResponseStatus(Response response) {
    final statusCode = response.statusCode;

    if (statusCode != null && statusCode >= 400) {
      _logger.w('⚠️ Status code $statusCode détecté, transformation en erreur');

      // Créer une DioException pour la passer par _handleDioError
      final dioException = DioException(
        requestOptions: response.requestOptions,
        response: response,
        type: DioExceptionType.badResponse,
        message: 'HTTP $statusCode',
      );

      // Lancer le Failure correspondant
      throw _handleDioError(dioException);
    }
  }

  /// GET request
  Future<Response> get(
      String path, {
        Map<String, dynamic>? queryParameters,
        Options? options,
      }) async {
    try {
      _logger.d('📤 GET $path');
      final response = await _dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );

      // Vérifier le statusCode et lancer une erreur si >= 400
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ GET Error on $path: ${e.message}');
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
      _logger.d('📤 POST $path');
      final response = await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      // Vérifier le statusCode et lancer une erreur si >= 400
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ POST Error on $path: ${e.message}');
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
      _logger.d('📤 PUT $path');
      final response = await _dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      // Vérifier le statusCode et lancer une erreur si >= 400
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ PUT Error on $path: ${e.message}');
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
      _logger.d('📤 PATCH $path');
      final response = await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      // Vérifier le statusCode et lancer une erreur si >= 400
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ PATCH Error on $path: ${e.message}');
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
      _logger.d('📤 DELETE $path');
      final response = await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );

      // Vérifier le statusCode et lancer une erreur si >= 400
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ DELETE Error on $path: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Upload de fichier
  Future<Response> uploadFile(
      String path,
      String filePath, {
        String fieldName = 'file',
        Map<String, dynamic>? data,
        ProgressCallback? onSendProgress,
      }) async {
    try {
      _logger.d('📤 UPLOAD FILE to $path');
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      final response = await _dio.post(
        path,
        data: formData,
        onSendProgress: onSendProgress,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
        ),
      );

      // Vérifier le statusCode
      _checkResponseStatus(response);

      return response;
    } on DioException catch (e) {
      _logger.e('❌ Upload Error on $path: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Download de fichier
  Future<Response> downloadFile(
      String urlPath,
      String savePath, {
        ProgressCallback? onReceiveProgress,
        Map<String, dynamic>? queryParameters,
        CancelToken? cancelToken,
      }) async {
    try {
      _logger.d('📥 DOWNLOAD FILE from $urlPath to $savePath');
      return await _dio.download(
        urlPath,
        savePath,
        onReceiveProgress: onReceiveProgress,
        queryParameters: queryParameters,
        cancelToken: cancelToken,
      );
    } on DioException catch (e) {
      _logger.e('❌ Download Error from $urlPath: ${e.message}');
      throw _handleDioError(e);
    }
  }

  /// Gérer les erreurs Dio et les convertir en Failures personnalisés
  Exception _handleDioError(DioException error) {
    _logger.e('🚨 DioException Type: ${error.type}');
    _logger.e('🚨 Status Code: ${error.response?.statusCode}');
    _logger.e('🚨 Response Data: ${error.response?.data}');

    switch (error.type) {
    // Erreurs de timeout
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return TimeoutFailure(
          message: 'La requête a expiré. Veuillez réessayer.',
          error: error,
        );

    // Erreurs de connexion
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          message: 'Impossible de se connecter au serveur. Vérifiez votre connexion internet.',
        );

    // Erreurs de réponse HTTP
      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final responseData = error.response?.data;

        // Extraire le message d'erreur avec PRIORITÉ pour Django REST Framework
        String message = _extractErrorMessage(responseData);

        _logger.e('🚨 Message extrait: $message');

        // Gérer selon le code HTTP
        switch (statusCode) {
          case 400:
            return ValidationFailure(
              message: message,
              statusCode: statusCode,
              error: error,
              fieldErrors: _extractFieldErrors(responseData),
            );

          case 401:
            return AuthenticationFailure(
              message: message.isEmpty ? 'Authentification requise.' : message,
              statusCode: statusCode,
              error: error,
            );

          case 403:
            return PermissionFailure(
              message: message.isEmpty ? 'Accès refusé.' : message,
              statusCode: statusCode,
              error: error,
            );

          case 404:
            return NotFoundFailure(
              message: message.isEmpty ? 'Ressource non trouvée.' : message,
              statusCode: statusCode,
              error: error,
            );

          case 409:
            return ConflictFailure(
              message: message.isEmpty ? 'Conflit détecté.' : message,
              statusCode: statusCode,
              error: error,
            );

          case 422:
            return ValidationFailure(
              message: message,
              statusCode: statusCode,
              error: error,
              fieldErrors: _extractFieldErrors(responseData),
            );

          case 429:
            return ServerFailure(
              message: 'Trop de requêtes. Veuillez patienter.',
              statusCode: statusCode,
              error: error,
            );

          default:
            if (statusCode != null && statusCode >= 500) {
              return ServerFailure(
                message: 'Erreur serveur. Veuillez réessayer plus tard.',
                statusCode: statusCode,
                error: error,
              );
            }
            return UnknownFailure(
              message: message.isEmpty ? 'Une erreur est survenue.' : message,
              statusCode: statusCode,
              error: error,
            );
        }

    // Requête annulée
      case DioExceptionType.cancel:
        return const UnknownFailure(
          message: 'Requête annulée.',
        );

    // Erreurs inconnues
      case DioExceptionType.badCertificate:
        return const NetworkFailure(
          message: 'Certificat SSL invalide.',
        );

      case DioExceptionType.unknown:
      return UnknownFailure(
          message: error.message ?? 'Une erreur inconnue est survenue.',
          error: error,
        );
    }
  }

  /// Extraire le message d'erreur de la réponse (spécifique Django REST Framework)
  String _extractErrorMessage(dynamic responseData) {
    if (responseData == null) return 'Une erreur est survenue.';

    // Si c'est une chaîne, la retourner directement
    if (responseData is String) {
      return responseData;
    }

    // Si c'est un Map (objet JSON)
    if (responseData is Map) {
      // PRIORITÉ 1: non_field_errors (Django REST Framework validation errors)
      if (responseData.containsKey('non_field_errors')) {
        final errors = responseData['non_field_errors'];
        if (errors is List && errors.isNotEmpty) {
          return errors.first.toString();
        }
      }

      // PRIORITÉ 2: detail (erreur générale Django)
      if (responseData.containsKey('detail')) {
        final detail = responseData['detail'];
        if (detail is String && detail.isNotEmpty) {
          return detail;
        }
      }

      // PRIORITÉ 3: message (erreur personnalisée)
      if (responseData.containsKey('message')) {
        final message = responseData['message'];
        if (message is String && message.isNotEmpty) {
          return message;
        }
      }

      // PRIORITÉ 4: error (autre format)
      if (responseData.containsKey('error')) {
        final error = responseData['error'];
        if (error is String && error.isNotEmpty) {
          return error;
        }
        if (error is Map && error.containsKey('message')) {
          return error['message'].toString();
        }
      }

      // PRIORITÉ 5: Chercher le premier champ avec une erreur
      for (final entry in responseData.entries) {
        // Ignorer les clés méta ou techniques
        if (entry.key == '_meta' ||
            entry.key == 'status' ||
            entry.key == 'code') {
          continue;
        }

        final value = entry.value;
        if (value is List && value.isNotEmpty) {
          return value.first.toString();
        } else if (value is String && value.isNotEmpty) {
          return value;
        }
      }
    }

    // Si c'est une liste directement
    if (responseData is List && responseData.isNotEmpty) {
      return responseData.first.toString();
    }

    // Message par défaut
    return 'Une erreur est survenue.';
  }

  /// Extraire les erreurs de champs depuis la réponse de l'API
  Map<String, List<String>>? _extractFieldErrors(dynamic responseData) {
    if (responseData is! Map) return null;

    final errors = <String, List<String>>{};

    responseData.forEach((key, value) {
      // Ignorer les clés qui ne sont pas des champs
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
        // Liste d'erreurs pour ce champ
        errors[key] = value.map((e) => e.toString()).toList();
      } else if (value is String) {
        // Erreur simple pour ce champ
        errors[key] = [value];
      } else if (value is Map) {
        // Erreur imbriquée (rare mais possible)
        final nestedErrors = <String>[];
        value.forEach((k, v) {
          if (v is List) {
            nestedErrors.addAll(v.map((e) => '$k: $e'));
          } else {
            nestedErrors.add('$k: $v');
          }
        });
        if (nestedErrors.isNotEmpty) {
          errors[key] = nestedErrors;
        }
      }
    });

    return errors.isNotEmpty ? errors : null;
  }

  /// Nettoyer les ressources
  void dispose() {
    _dio.close();
    _cachedAccessToken = null;
    _cachedRefreshToken = null;
    _logger.i('🔌 ApiClient disposed');
  }
}