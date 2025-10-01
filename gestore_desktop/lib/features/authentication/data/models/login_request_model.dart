// ========================================
// login_request_model.dart
// ========================================
import 'package:json_annotation/json_annotation.dart';

part 'login_request_model.g.dart';

/// Modèle pour la requête de login
@JsonSerializable()
class LoginRequestModel {
  final String username;
  final String password;

  const LoginRequestModel({
    required this.username,
    required this.password,
  });

  factory LoginRequestModel.fromJson(Map<String, dynamic> json) =>
      _$LoginRequestModelFromJson(json);

  Map<String, dynamic> toJson() => _$LoginRequestModelToJson(this);
}