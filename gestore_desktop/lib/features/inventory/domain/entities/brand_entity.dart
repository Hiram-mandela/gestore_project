// ========================================
// lib/features/inventory/domain/entities/brand_entity.dart
// Entity pour les marques
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant une marque
/// Correspond au modèle Brand du backend
class BrandEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? website;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  const BrandEntity({
    required this.id,
    required this.name,
    this.description,
    this.logoUrl,
    this.website,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Vérifie si la marque a un logo
  bool get hasLogo => logoUrl != null && logoUrl!.isNotEmpty;

  /// Vérifie si la marque a un site web
  bool get hasWebsite => website != null && website!.isNotEmpty;

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    logoUrl,
    website,
    isActive,
    createdAt,
    updatedAt,
  ];

  @override
  String toString() => 'BrandEntity(id: $id, name: $name)';
}