// ========================================
// user_entity.dart
// VERSION MISE À JOUR - Support multi-magasins
// Date: 23 Octobre 2025
// ========================================
import 'package:equatable/equatable.dart';

import 'role_entity.dart';
import 'user_profile_entity.dart';
import 'store_info_entity.dart';

/// Entité utilisateur - Domain Layer
/// Représente un utilisateur dans le domaine métier
/// VERSION MULTI-MAGASINS: Ajout assignedStore, isMultiStoreAdmin, availableStores
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

  // 🔴 NOUVEAUX CHAMPS MULTI-MAGASINS
  /// Magasin assigné à l'employé (null pour les admins multi-magasins)
  final StoreInfoEntity? assignedStore;

  /// Indique si l'utilisateur est un admin multi-magasins (assigned_store = null)
  final bool isMultiStoreAdmin;

  /// Liste des magasins accessibles par l'utilisateur
  final List<StoreInfoEntity> availableStores;

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
    // 🔴 Nouveaux paramètres
    this.assignedStore,
    this.isMultiStoreAdmin = false,
    this.availableStores = const [],
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

  /// Vérifie si l'utilisateur peut accéder à plusieurs magasins
  bool get canAccessMultipleStores => isMultiStoreAdmin && availableStores.length > 1;

  /// Retourne le nom du magasin assigné ou "Tous les magasins" pour les admins
  String get storeDisplayName {
    if (isMultiStoreAdmin) return 'Tous les magasins';
    return assignedStore?.name ?? 'Aucun magasin';
  }

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
    assignedStore,
    isMultiStoreAdmin,
    availableStores,
  ];
}