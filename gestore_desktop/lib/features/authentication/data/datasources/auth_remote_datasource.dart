// ========================================
// auth_remote_datasource.dart
// ========================================
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/login_request_model.dart';
import '../models/login_response_model.dart';
import '../models/user_model.dart';

/// Interface du datasource distant
abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login(LoginRequestModel request);
  Future<void> logout();
  Future<Map<String, String>> refreshToken(String refreshToken);
  Future<UserModel> getCurrentUser();
}

/// Implémentation du datasource distant
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSourceImpl(this.apiClient);

  @override
  Future<LoginResponseModel> login(LoginRequestModel request) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authLogin,
        data: request.toJson(),
      );

      if (response.statusCode == 200) {
        return LoginResponseModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.authLogout);
    } catch (e) {
      // Continuer même si le logout échoue côté serveur
      // Les tokens seront supprimés localement
    }
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.authRefresh,
        data: {'refresh': refreshToken},
      );

      if (response.statusCode == 200) {
        return {
          'access': response.data['access'] as String,
          'refresh': response.data['refresh'] as String? ??
              refreshToken, // Garder l'ancien si pas de nouveau
        };
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await apiClient.get(ApiEndpoints.authMe);

      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data);
      } else {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }
    } catch (e) {
      rethrow;
    }
  }
}
