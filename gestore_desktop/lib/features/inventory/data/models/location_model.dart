// ========================================
// lib/features/inventory/data/models/location_model.dart
// Model pour les emplacements de stockage
// Basé sur le backend: apps/inventory/models.py - Location
// ========================================

import '../../domain/entities/location_entity.dart';

class LocationModel {
  final String id;
  final String name;
  final String? description;
  final String code;
  final String locationType;
  final String? parentId;
  final String? parentName;
  final String? barcode;
  final bool isActive;
  final String statusDisplay;
  final int childrenCount;
  final int stocksCount;
  final String fullPath;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final bool needsSync;

  LocationModel({
    required this.id,
    required this.name,
    this.description,
    required this.code,
    required this.locationType,
    this.parentId,
    this.parentName,
    this.barcode,
    required this.isActive,
    required this.statusDisplay,
    this.childrenCount = 0,
    this.stocksCount = 0,
    required this.fullPath,
    required this.createdAt,
    required this.updatedAt,
    this.syncStatus = 'synced',
    this.needsSync = false,
  });

  /// Convertit le JSON de l'API en Model
  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      code: json['code'] as String,
      locationType: json['location_type'] as String,
      parentId: json['parent'] as String?,
      parentName: json['parent_name'] as String?,
      barcode: json['barcode'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      statusDisplay: json['status_display'] as String? ?? 'Actif',
      childrenCount: json['children_count'] as int? ?? 0,
      stocksCount: json['stocks_count'] as int? ?? 0,
      fullPath: json['full_path'] as String? ?? '',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      syncStatus: json['sync_status'] as String? ?? 'synced',
      needsSync: json['needs_sync'] as bool? ?? false,
    );
  }

  /// Convertit le Model en Entity
  LocationEntity toEntity() {
    return LocationEntity(
      id: id,
      name: name,
      description: description,
      code: code,
      locationType: LocationType.fromString(locationType),
      parentId: parentId,
      parentName: parentName,
      barcode: barcode,
      isActive: isActive,
      statusDisplay: statusDisplay,
      childrenCount: childrenCount,
      stocksCount: stocksCount,
      fullPath: fullPath,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convertit le Model en JSON pour l'API
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'code': code,
      'location_type': locationType,
      'parent_id': parentId,
      'barcode': barcode,
      'is_active': isActive,
    };
  }

  /// Crée une copie avec des champs modifiés
  LocationModel copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    String? locationType,
    String? parentId,
    String? parentName,
    String? barcode,
    bool? isActive,
    String? statusDisplay,
    int? childrenCount,
    int? stocksCount,
    String? fullPath,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? syncStatus,
    bool? needsSync,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      code: code ?? this.code,
      locationType: locationType ?? this.locationType,
      parentId: parentId ?? this.parentId,
      parentName: parentName ?? this.parentName,
      barcode: barcode ?? this.barcode,
      isActive: isActive ?? this.isActive,
      statusDisplay: statusDisplay ?? this.statusDisplay,
      childrenCount: childrenCount ?? this.childrenCount,
      stocksCount: stocksCount ?? this.stocksCount,
      fullPath: fullPath ?? this.fullPath,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      needsSync: needsSync ?? this.needsSync,
    );
  }
}