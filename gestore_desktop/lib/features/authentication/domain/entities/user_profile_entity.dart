// ========================================
// user_profile_entity.dart
// ========================================

import 'package:equatable/equatable.dart';

/// Entité profil utilisateur - Domain Layer
/// Informations étendues et préférences utilisateur
class UserProfileEntity extends Equatable {
  final String id;
  final String userId;
  final String? avatar;
  final DateTime? birthDate;
  final String? address;
  final String language;
  final String timezone;
  final String theme;
  final bool emailNotifications;
  final bool smsNotifications;

  const UserProfileEntity({
    required this.id,
    required this.userId,
    this.avatar,
    this.birthDate,
    this.address,
    required this.language,
    required this.timezone,
    required this.theme,
    required this.emailNotifications,
    required this.smsNotifications,
  });

  @override
  List<Object?> get props => [
    id,
    userId,
    avatar,
    birthDate,
    address,
    language,
    timezone,
    theme,
    emailNotifications,
    smsNotifications,
  ];
}