// ========================================
// features/authentication/data/models/user_model.dart
// VERSION CORRIGÉE COMPLÈTE
// ========================================
import '../../domain/entities/user_entity.dart';
import 'role_model.dart';
import 'user_profile_model.dart';

/// Modèle utilisateur avec TOUS les champs du backend
class UserModel extends UserEntity {
  final RoleModel? roleModel;
  final UserProfileModel? profileModel;

  // Champs supplémentaires du backend
  final String employeeCode;
  final String phoneNumber;
  final DateTime? hireDate;
  final String department;
  final bool isLocked;
  final DateTime? lockedUntil;
  final int failedLoginAttempts;
  final DateTime? lastPasswordChange;
  final bool isOnline;
  final List<String> permissionsSummary;
  final String? lastLoginFormatted;

  const UserModel({
    required super.id,
    required super.username,
    required super.email,
    super.firstName,
    super.lastName,
    super.phone,
    required super.isActive,
    required super.isStaff,
    required super.isSuperuser,
    this.roleModel,
    this.profileModel,
    required super.createdAt,
    super.lastLogin,
    required this.employeeCode,
    required this.phoneNumber,
    this.hireDate,
    required this.department,
    required this.isLocked,
    this.lockedUntil,
    required this.failedLoginAttempts,
    this.lastPasswordChange,
    required this.isOnline,
    required this.permissionsSummary,
    this.lastLoginFormatted,
  }) : super(
    role: roleModel,
    profile: profileModel,
  );

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      username: json['username'] as String,
      email: json['email'] as String,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      phone: json['phone_number'] as String? ?? '',
      isActive: json['is_active'] as bool? ?? true,
      isStaff: json['is_staff'] as bool? ?? false,
      isSuperuser: json['is_superuser'] as bool? ?? false,
      roleModel: json['role'] != null
          ? RoleModel.fromJson(json['role'] as Map<String, dynamic>)
          : null,
      profileModel: json['profile'] != null
          ? UserProfileModel.fromJson(json['profile'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'] as String)
          : null,
      employeeCode: json['employee_code'] as String? ?? '',
      phoneNumber: json['phone_number'] as String? ?? '',
      hireDate: json['hire_date'] != null
          ? DateTime.parse(json['hire_date'] as String)
          : null,
      department: json['department'] as String? ?? '',
      isLocked: json['is_locked'] as bool? ?? false,
      lockedUntil: json['locked_until'] != null
          ? DateTime.parse(json['locked_until'] as String)
          : null,
      failedLoginAttempts: json['failed_login_attempts'] as int? ?? 0,
      lastPasswordChange: json['last_password_change'] != null
          ? DateTime.parse(json['last_password_change'] as String)
          : null,
      isOnline: json['is_online'] as bool? ?? false,
      permissionsSummary: json['permissions_summary'] != null
          ? List<String>.from(json['permissions_summary'] as List)
          : [],
      lastLoginFormatted: json['last_login_formatted'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'phone_number': phoneNumber,
      'is_active': isActive,
      'is_staff': isStaff,
      'is_superuser': isSuperuser,
      if (roleModel != null) 'role': roleModel!.toJson(),
      if (profileModel != null) 'profile': profileModel!.toJson(),
      'created_at': createdAt.toIso8601String(),
      if (lastLogin != null) 'last_login': lastLogin!.toIso8601String(),
      'employee_code': employeeCode,
      if (hireDate != null) 'hire_date': hireDate!.toIso8601String(),
      'department': department,
      'is_locked': isLocked,
      if (lockedUntil != null) 'locked_until': lockedUntil!.toIso8601String(),
      'failed_login_attempts': failedLoginAttempts,
      if (lastPasswordChange != null)
        'last_password_change': lastPasswordChange!.toIso8601String(),
      'is_online': isOnline,
      'permissions_summary': permissionsSummary,
      if (lastLoginFormatted != null) 'last_login_formatted': lastLoginFormatted,
    };
  }

  UserEntity toEntity() => UserEntity(
    id: id,
    username: username,
    email: email,
    firstName: firstName,
    lastName: lastName,
    phone: phoneNumber,
    isActive: isActive,
    isStaff: isStaff,
    isSuperuser: isSuperuser,
    role: roleModel?.toEntity(),
    profile: profileModel?.toEntity(),
    createdAt: createdAt,
    lastLogin: lastLogin,
  );

  factory UserModel.fromEntity(UserEntity entity) => UserModel(
    id: entity.id,
    username: entity.username,
    email: entity.email,
    firstName: entity.firstName,
    lastName: entity.lastName,
    phone: entity.phone,
    isActive: entity.isActive,
    isStaff: entity.isStaff,
    isSuperuser: entity.isSuperuser,
    roleModel: entity.role != null
        ? RoleModel.fromEntity(entity.role!)
        : null,
    profileModel: entity.profile != null
        ? UserProfileModel.fromEntity(entity.profile!)
        : null,
    createdAt: entity.createdAt,
    lastLogin: entity.lastLogin,
    employeeCode: '',
    phoneNumber: entity.phone ?? '',
    hireDate: null,
    department: '',
    isLocked: false,
    lockedUntil: null,
    failedLoginAttempts: 0,
    lastPasswordChange: null,
    isOnline: false,
    permissionsSummary: [],
    lastLoginFormatted: null,
  );
}
