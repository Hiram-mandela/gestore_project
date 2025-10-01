// ========================================
// features/authentication/data/models/user_profile_model.dart
// VERSION CORRIGÉE - Champ user_name du backend
// ========================================
import '../../domain/entities/user_profile_entity.dart';

/// Modèle profil utilisateur
class UserProfileModel extends UserProfileEntity {
  final String? userName;
  final String? avatarUrl;

  const UserProfileModel({
    required super.id,
    required super.userId,
    super.avatar,
    super.birthDate,
    super.address,
    required super.language,
    required super.timezone,
    required super.theme,
    required super.emailNotifications,
    required super.smsNotifications,
    this.userName,
    this.avatarUrl,
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      id: json['id'] as String,
      userId: json['user'] as String? ?? '',
      avatar: json['avatar'] as String?,
      birthDate: json['birth_date'] != null
          ? DateTime.parse(json['birth_date'] as String)
          : null,
      address: json['address'] as String? ?? '',
      language: json['language'] as String? ?? 'fr',
      timezone: json['timezone'] as String? ?? 'UTC',
      theme: json['theme'] as String? ?? 'light',
      emailNotifications: json['email_notifications'] as bool? ?? true,
      smsNotifications: json['sms_notifications'] as bool? ?? false,
      userName: json['user_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user': userId,
      'avatar': avatar,
      'birth_date': birthDate?.toIso8601String(),
      'address': address,
      'language': language,
      'timezone': timezone,
      'theme': theme,
      'email_notifications': emailNotifications,
      'sms_notifications': smsNotifications,
      if (userName != null) 'user_name': userName,
      if (avatarUrl != null) 'avatar_url': avatarUrl,
    };
  }

  UserProfileEntity toEntity() => UserProfileEntity(
    id: id,
    userId: userId,
    avatar: avatar,
    birthDate: birthDate,
    address: address,
    language: language,
    timezone: timezone,
    theme: theme,
    emailNotifications: emailNotifications,
    smsNotifications: smsNotifications,
  );

  factory UserProfileModel.fromEntity(UserProfileEntity entity) =>
      UserProfileModel(
        id: entity.id,
        userId: entity.userId,
        avatar: entity.avatar,
        birthDate: entity.birthDate,
        address: entity.address,
        language: entity.language,
        timezone: entity.timezone,
        theme: entity.theme,
        emailNotifications: entity.emailNotifications,
        smsNotifications: entity.smsNotifications,
        userName: null,
        avatarUrl: null,
      );
}