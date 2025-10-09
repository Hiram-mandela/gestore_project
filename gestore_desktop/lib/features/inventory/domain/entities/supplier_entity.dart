// ========================================
// lib/features/inventory/domain/entities/supplier_entity.dart
// Entity pour les fournisseurs (version simplifiée)
// ========================================

import 'package:equatable/equatable.dart';

/// Entity représentant un fournisseur
class SupplierEntity extends Equatable {
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
  final DateTime createdAt;
  final DateTime updatedAt;
  final String syncStatus;
  final bool needsSync;

  const SupplierEntity({
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

  /// Vérifie si le fournisseur a un contact
  bool get hasContact => contactPerson != null && contactPerson!.isNotEmpty;

  /// Vérifie si le fournisseur a un téléphone
  bool get hasPhone => phone != null && phone!.isNotEmpty;

  /// Vérifie si le fournisseur a un email
  bool get hasEmail => email != null && email!.isNotEmpty;

  /// Informations de contact formatées
  String get formattedContact {
    final parts = <String>[];
    if (hasContact) parts.add(contactPerson!);
    if (hasPhone) parts.add(phone!);
    if (hasEmail) parts.add(email!);
    return parts.join(' • ');
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    code,
    contactPerson,
    phone,
    email,
    isActive,
    statusDisplay,
    articlesCount,
    createdAt,
    updatedAt,
    syncStatus,
    needsSync,
  ];

  @override
  String toString() => 'SupplierEntity(id: $id, name: $name, code: $code)';
}