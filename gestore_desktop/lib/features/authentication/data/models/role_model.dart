// ========================================
// features/authentication/data/models/role_model.dart
// PAS DE CHANGEMENT - Déjà correct
// ========================================
import '../../domain/entities/role_entity.dart';

class RoleModel extends RoleEntity {
  const RoleModel({
    required super.id,
    required super.name,
    required super.description,
    required super.roleType,
    required super.isActive,
    required super.canManageUsers,
    required super.canManageInventory,
    required super.canManageSales,
    required super.canManageSuppliers,
    required super.canViewReports,
    required super.canManageReports,
    required super.canManageSettings,
    required super.canApplyDiscounts,
    required super.maxDiscountPercent,
    required super.canVoidTransactions,
  });

  factory RoleModel.fromJson(Map<String, dynamic> json) {
    return RoleModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String? ?? '',
      roleType: json['role_type'] as String,
      isActive: json['is_active'] as bool? ?? true,
      canManageUsers: json['can_manage_users'] as bool? ?? false,
      canManageInventory: json['can_manage_inventory'] as bool? ?? false,
      canManageSales: json['can_manage_sales'] as bool? ?? false,
      canManageSuppliers: json['can_manage_suppliers'] as bool? ?? false,
      canViewReports: json['can_view_reports'] as bool? ?? false,
      canManageReports: json['can_manage_reports'] as bool? ?? false,
      canManageSettings: json['can_manage_settings'] as bool? ?? false,
      canApplyDiscounts: json['can_apply_discounts'] as bool? ?? false,
      maxDiscountPercent: (json['max_discount_percent'] as num?)?.toDouble() ?? 0.0,
      canVoidTransactions: json['can_void_transactions'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'role_type': roleType,
      'is_active': isActive,
      'can_manage_users': canManageUsers,
      'can_manage_inventory': canManageInventory,
      'can_manage_sales': canManageSales,
      'can_manage_suppliers': canManageSuppliers,
      'can_view_reports': canViewReports,
      'can_manage_reports': canManageReports,
      'can_manage_settings': canManageSettings,
      'can_apply_discounts': canApplyDiscounts,
      'max_discount_percent': maxDiscountPercent,
      'can_void_transactions': canVoidTransactions,
    };
  }

  RoleEntity toEntity() => RoleEntity(
    id: id,
    name: name,
    description: description,
    roleType: roleType,
    isActive: isActive,
    canManageUsers: canManageUsers,
    canManageInventory: canManageInventory,
    canManageSales: canManageSales,
    canManageSuppliers: canManageSuppliers,
    canViewReports: canViewReports,
    canManageReports: canManageReports,
    canManageSettings: canManageSettings,
    canApplyDiscounts: canApplyDiscounts,
    maxDiscountPercent: maxDiscountPercent,
    canVoidTransactions: canVoidTransactions,
  );

  factory RoleModel.fromEntity(RoleEntity entity) => RoleModel(
    id: entity.id,
    name: entity.name,
    description: entity.description,
    roleType: entity.roleType,
    isActive: entity.isActive,
    canManageUsers: entity.canManageUsers,
    canManageInventory: entity.canManageInventory,
    canManageSales: entity.canManageSales,
    canManageSuppliers: entity.canManageSuppliers,
    canViewReports: entity.canViewReports,
    canManageReports: entity.canManageReports,
    canManageSettings: entity.canManageSettings,
    canApplyDiscounts: entity.canApplyDiscounts,
    maxDiscountPercent: entity.maxDiscountPercent,
    canVoidTransactions: entity.canVoidTransactions,
  );
}