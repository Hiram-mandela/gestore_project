// ========================================
// lib/features/inventory/domain/entities/location_entity.dart
// Entity pour les emplacements de stockage
// ========================================

import 'package:equatable/equatable.dart';

/// Types d'emplacements
enum LocationType {
  store('store', 'Magasin', '🏪'),
  zone('zone', 'Zone', '📦'),
  aisle('aisle', 'Rayon', '📋'),
  shelf('shelf', 'Étagère', '🗄️'),
  bin('bin', 'Casier', '📮');

  final String value;
  final String label;
  final String icon;

  const LocationType(this.value, this.label, this.icon);

  static LocationType fromString(String value) {
    return LocationType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => LocationType.store,
    );
  }

  @override
  String toString() => value;
}

/// Entity représentant un emplacement de stockage
class LocationEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String code;
  final LocationType locationType;
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

  const LocationEntity({
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
  });

  /// Indique si l'emplacement a des enfants
  bool get hasChildren => childrenCount > 0;

  /// Indique si l'emplacement contient des stocks
  bool get hasStocks => stocksCount > 0;

  /// Indique si l'emplacement est un emplacement racine (sans parent)
  bool get isRoot => parentId == null;

  /// Retourne le niveau dans la hiérarchie (0 = racine)
  int get level {
    return fullPath.split(' > ').length - 1;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    code,
    locationType,
    parentId,
    parentName,
    barcode,
    isActive,
    statusDisplay,
    childrenCount,
    stocksCount,
    fullPath,
    createdAt,
    updatedAt,
  ];

  /// Crée une copie avec des champs modifiés
  LocationEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? code,
    LocationType? locationType,
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
  }) {
    return LocationEntity(
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
    );
  }
}