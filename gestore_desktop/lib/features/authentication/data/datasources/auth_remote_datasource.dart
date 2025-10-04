// ========================================
// lib/features/authentication/data/datasources/auth_remote_datasource.dart
// VERSION ULTRA-SIMPLIFIÉE - ApiClient gère TOUT
// ========================================
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
    // ApiClient lance automatiquement des Failures si statusCode >= 400
    // Si on arrive ici, c'est forcément un succès (2xx)
    final response = await apiClient.post(
      ApiEndpoints.authLogin,
      data: request.toJson(),
    );

    return LoginResponseModel.fromJson(response.data);
  }

  @override
  Future<void> logout() async {
    // ApiClient gère les erreurs automatiquement
    await apiClient.post(ApiEndpoints.authLogout);
  }

  @override
  Future<Map<String, String>> refreshToken(String refreshToken) async {
    final response = await apiClient.post(
      ApiEndpoints.authRefresh,
      data: {'refresh': refreshToken},  // ✅ Format correct
    );

    return {
      'access': response.data['access'] as String,
      'refresh': response.data['refresh'] as String? ?? refreshToken,
    };
  }

  @override
  Future<UserModel> getCurrentUser() async {
    final response = await apiClient.get(ApiEndpoints.authMe);
    return UserModel.fromJson(response.data);
  }
}