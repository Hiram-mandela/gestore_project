// ========================================
// lib/features/authentication/domain/entities/store_info_entity.dart
// Entity pour les informations de magasin dans le contexte d'authentification
// Modèle léger pour éviter la dépendance vers le module Inventory
// Date: 23 Octobre 2025
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant les informations minimales d'un magasin
/// Utilisée dans le contexte d'authentification pour:
/// - assigned_store (magasin assigné à un employé)
/// - available_stores (magasins accessibles par un admin)
class StoreInfoEntity extends Equatable {
  /// ID unique du magasin
  final String id;

  /// Nom du magasin
  final String name;

  /// Code du magasin (ex: "LYO001", "PAR001")
  final String code;

  /// Statut actif/inactif
  final bool isActive;

  /// Description optionnelle du magasin
  final String? description;

  const StoreInfoEntity({
    required this.id,
    required this.name,
    required this.code,
    required this.isActive,
    this.description,
  });

  @override
  List<Object?> get props => [id, name, code, isActive, description];

  @override
  String toString() => 'StoreInfoEntity(id: $id, name: $name, code: $code, isActive: $isActive)';

  /// Crée une copie avec des champs modifiés
  StoreInfoEntity copyWith({
    String? id,
    String? name,
    String? code,
    bool? isActive,
    String? description,
  }) {
    return StoreInfoEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      code: code ?? this.code,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
    );
  }
}