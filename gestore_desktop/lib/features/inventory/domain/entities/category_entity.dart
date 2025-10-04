// ========================================
// lib/features/inventory/domain/entities/category_entity.dart
// VERSION COMPLÈTE - Entity Catégorie avec tous les champs
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant une catégorie d'articles
class CategoryEntity extends Equatable {
  /// Identifiant unique
  final String id;

  /// Nom de la catégorie
  final String name;

  /// Code unique de la catégorie
  final String code;

  /// Description
  final String description;

  /// ID de la catégorie parent (null si racine)
  final String? parentId;

  /// Nom de la catégorie parent
  final String? parentName;

  /// Taux de TVA en pourcentage (ex: 20.0 pour 20%)
  final double taxRate;

  /// Couleur d'affichage (format hex: #RRGGBB)
  final String color;

  /// Nécessite une prescription médicale
  final bool requiresPrescription;

  /// Nécessite le suivi par numéro de lot
  final bool requiresLotTracking;

  /// Nécessite une date d'expiration
  final bool requiresExpiryDate;

  /// Stock minimum par défaut pour les articles de cette catégorie
  final int defaultMinStock;

  /// Ordre d'affichage
  final int order;

  /// Statut actif/inactif
  final bool isActive;

  /// Date de création
  final DateTime createdAt;

  /// Date de dernière mise à jour
  final DateTime updatedAt;

  /// Constructeur
  const CategoryEntity({
    required this.id,
    required this.name,
    required this.code,
    this.description = '',
    this.parentId,
    this.parentName,
    required this.taxRate,
    required this.color,
    required this.requiresPrescription,
    required this.requiresLotTracking,
    required this.requiresExpiryDate,
    required this.defaultMinStock,
    required this.order,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Retourne le chemin complet de la catégorie (Parent > Enfant)
  String get fullPath {
    if (parentName != null && parentName!.isNotEmpty) {
      return '$parentName > $name';
    }
    return name;
  }

  /// Vérifie si la catégorie a un parent
  bool get hasParent => parentId != null;


  /// Vérifie si c'est une catégorie racine
  bool get isRoot => parentId == null;

  /// Statut d'affichage
  String get statusDisplay => isActive ? 'Actif' : 'Inactif';

  /// Crée une copie avec modifications
  CategoryEntity copyWith({
    String? id,
    String? name,
    String? code,
    String? description,
    String? parentId,
    bool clearParent = false,
    String? parentName,
    double? taxRate,
    String? color,
    bool? requiresPrescription,
    bool? requiresLotTracking,
    bool? requiresExpiryDate,
    int? defaultMinStock,
    int? order,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      description: description ?? this.description,
      parentId: clearParent ? null : (parentId ?? this.parentId),
      parentName: parentName ?? this.parentName,
      taxRate: taxRate ?? this.taxRate,
      color: color ?? this.color,
      requiresPrescription: requiresPrescription ?? this.requiresPrescription,
      requiresLotTracking: requiresLotTracking ?? this.requiresLotTracking,
      requiresExpiryDate: requiresExpiryDate ?? this.requiresExpiryDate,
      defaultMinStock: defaultMinStock ?? this.defaultMinStock,
      order: order ?? this.order,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    parentId,
    parentName,
    taxRate,
    color,
    requiresPrescription,
    requiresLotTracking,
    requiresExpiryDate,
    defaultMinStock,
    order,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, code: $code)';
}