// ========================================
// lib/features/inventory/data/models/supplier_model.dart
// Model pour les fournisseurs (version simplifiée pour ArticleDetail)
// ========================================

import '../../domain/entities/supplier_entity.dart';

/// Model pour mapper les données JSON du fournisseur
class SupplierModel {
  final String id;
  final String name;
  final String? description;
  final String code;
  final String? contactPerson;
  final String? phone;
  final String? email;
  final bool isActive;
  final String statusDisplay;
  final int articlesCount;
  final String createdAt;
  final String updatedAt;
  final String syncStatus;
  final bool needsSync;

  SupplierModel({
    required this.id,
    required this.name,
    this.description,
    required this.code,
    this.contactPerson,
    this.phone,
    this.email,
    required this.isActive,
    required this.statusDisplay,
    required this.articlesCount,
    required this.createdAt,
    required this.updatedAt,
    required this.syncStatus,
    required this.needsSync,
  });

  /// Convertit le JSON de l'API en Model
  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      code: json['code'] as String,
      contactPerson: json['contact_person'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      statusDisplay: json['status_display'] as String? ?? '',
      articlesCount: json['articles_count'] as int? ?? 0,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
      syncStatus: json['sync_status'] as String? ?? 'pending',
      needsSync: json['needs_sync'] as bool? ?? false,
    );
  }

  /// Convertit le Model en Entity
  SupplierEntity toEntity() {
    return SupplierEntity(
      id: id,
      name: name,
      description: description,
      code: code,
      contactPerson: contactPerson,
      phone: phone,
      email: email,
      isActive: isActive,
      statusDisplay: statusDisplay,
      articlesCount: articlesCount,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
      syncStatus: syncStatus,
      needsSync: needsSync,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'code': code,
      'contact_person': contactPerson,
      'phone': phone,
      'email': email,
      'is_active': isActive,
      'status_display': statusDisplay,
      'articles_count': articlesCount,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'sync_status': syncStatus,
      'needs_sync': needsSync,
    };
  }
}