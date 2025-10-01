// ========================================
// features/authentication/data/models/login_response_model.dart
// VERSION CORRIGÉE - Noms de champs exacts du backend
// ========================================
import 'user_model.dart';

/// Modèle pour la réponse de login
/// ATTENTION: L'API Django renvoie "access_token" et "refresh_token"
class LoginResponseModel {
  final String accessToken;
  final String refreshToken;
  final UserModel user;
  final String? sessionId;

  const LoginResponseModel({
    required this.accessToken,
    required this.refreshToken,
    required this.user,
    this.sessionId,
  });

  factory LoginResponseModel.fromJson(Map<String, dynamic> json) {
    return LoginResponseModel(
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      user: UserModel.fromJson(json['user'] as Map<String, dynamic>),
      sessionId: json['session_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'user': user.toJson(),
      if (sessionId != null) 'session_id': sessionId,
    };
  }
}