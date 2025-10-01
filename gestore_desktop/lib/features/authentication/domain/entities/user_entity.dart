// ========================================
// user_entity.dart
// ========================================
import 'package:equatable/equatable.dart';

import 'role_entity.dart';
import 'user_profile_entity.dart';

/// Entité utilisateur - Domain Layer
/// Représente un utilisateur dans le domaine métier
class UserEntity extends Equatable {
  final String id;
  final String username;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final bool isActive;
  final bool isStaff;
  final bool isSuperuser;
  final RoleEntity? role;
  final UserProfileEntity? profile;
  final DateTime createdAt;
  final DateTime? lastLogin;

  const UserEntity({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phone,
    required this.isActive,
    required this.isStaff,
    required this.isSuperuser,
    this.role,
    this.profile,
    required this.createdAt,
    this.lastLogin,
  });

  /// Nom complet de l'utilisateur
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    }
    if (firstName != null) return firstName!;
    if (lastName != null) return lastName!;
    return username;
  }

  /// Initiales de l'utilisateur
  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    }
    return username.substring(0, 2).toUpperCase();
  }

  /// Est-ce un administrateur ?
  bool get isAdmin => isSuperuser || (role?.roleType == 'admin');

  @override
  List<Object?> get props => [
    id,
    username,
    email,
    firstName,
    lastName,
    phone,
    isActive,
    isStaff,
    isSuperuser,
    role,
    profile,
    createdAt,
    lastLogin,
  ];
}
