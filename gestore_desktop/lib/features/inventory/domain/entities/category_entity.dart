// ========================================
// lib/features/inventory/domain/entities/category_entity.dart
// Entity pour les catégories d'articles
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant une catégorie d'article
/// Correspond au modèle Category du backend
class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final String code;
  final String? description;
  final String? parentId;
  final String? parentName;
  final String color;
  final double taxRate;
  final bool isActive;
  final int order;
  final DateTime createdAt;
  final DateTime updatedAt;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.code,
    this.description,
    this.parentId,
    this.parentName,
    required this.color,
    required this.taxRate,
    required this.isActive,
    required this.order,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vérifie si la catégorie a un parent
  bool get hasParent => parentId != null;

  /// Retourne le nom complet avec le parent si disponible
  String get fullName {
    if (parentName != null && parentName!.isNotEmpty) {
      return '$parentName > $name';
    }
    return name;
  }

  @override
  List<Object?> get props => [
    id,
    name,
    code,
    description,
    parentId,
    parentName,
    color,
    taxRate,
    isActive,
    order,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'CategoryEntity(id: $id, name: $name, code: $code)';
}