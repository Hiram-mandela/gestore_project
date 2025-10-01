// ========================================
// role_entity.dart
// ========================================

import 'package:equatable/equatable.dart';

/// Entité rôle - Domain Layer
/// Représente un rôle utilisateur avec ses permissions
class RoleEntity extends Equatable {
  final String id;
  final String name;
  final String description;
  final String roleType;
  final bool isActive;

  // Permissions modules
  final bool canManageUsers;
  final bool canManageInventory;
  final bool canManageSales;
  final bool canManageSuppliers;
  final bool canViewReports;
  final bool canManageReports;
  final bool canManageSettings;

  // Permissions financières
  final bool canApplyDiscounts;
  final double maxDiscountPercent;
  final bool canVoidTransactions;

  const RoleEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.roleType,
    required this.isActive,
    required this.canManageUsers,
    required this.canManageInventory,
    required this.canManageSales,
    required this.canManageSuppliers,
    required this.canViewReports,
    required this.canManageReports,
    required this.canManageSettings,
    required this.canApplyDiscounts,
    required this.maxDiscountPercent,
    required this.canVoidTransactions,
  });

  /// Vérifier si le rôle a accès à un module
  bool hasModuleAccess(String module) {
    switch (module.toLowerCase()) {
      case 'users':
      case 'authentication':
        return canManageUsers;
      case 'inventory':
        return canManageInventory;
      case 'sales':
        return canManageSales;
      case 'suppliers':
        return canManageSuppliers;
      case 'reports':
      case 'reporting':
        return canViewReports;
      case 'settings':
        return canManageSettings;
      default:
        return false;
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    roleType,
    isActive,
    canManageUsers,
    canManageInventory,
    canManageSales,
    canManageSuppliers,
    canViewReports,
    canManageReports,
    canManageSettings,
    canApplyDiscounts,
    maxDiscountPercent,
    canVoidTransactions,
  ];
}
