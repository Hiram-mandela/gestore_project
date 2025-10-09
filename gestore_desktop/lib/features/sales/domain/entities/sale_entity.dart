// ========================================
// lib/features/sales/domain/entities/sale_entity.dart
// Entité Sale (liste) - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';
import 'customer_entity.dart';

/// Entité représentant une vente (version liste optimisée)
class SaleEntity extends Equatable {
  final String id;
  final String saleNumber;
  final String saleType; // 'regular', 'return', 'exchange', 'quote'
  final String status; // 'draft', 'pending', 'completed', 'cancelled', 'refunded', 'partially_refunded'

  // Relations
  final CustomerEntity? customer;
  final String? cashier;

  // Dates
  final DateTime saleDate;

  // Montants
  final double totalAmount;
  final double paidAmount;

  // Statistiques
  final int itemsCount;
  final bool isPaid;
  final double balance;

  final DateTime createdAt;

  const SaleEntity({
    required this.id,
    required this.saleNumber,
    required this.saleType,
    required this.status,
    this.customer,
    this.cashier,
    required this.saleDate,
    required this.totalAmount,
    required this.paidAmount,
    this.itemsCount = 0,
    this.isPaid = false,
    this.balance = 0.0,
    required this.createdAt,
  });

  /// Retourne le type de vente formaté
  String get saleTypeDisplay {
    switch (saleType) {
      case 'regular':
        return 'Vente normale';
      case 'return':
        return 'Retour';
      case 'exchange':
        return 'Échange';
      case 'quote':
        return 'Devis';
      default:
        return saleType;
    }
  }

  /// Retourne le statut formaté
  String get statusDisplay {
    switch (status) {
      case 'draft':
        return 'Brouillon';
      case 'pending':
        return 'En attente';
      case 'completed':
        return 'Terminée';
      case 'cancelled':
        return 'Annulée';
      case 'refunded':
        return 'Remboursée';
      case 'partially_refunded':
        return 'Partiellement remboursée';
      default:
        return status;
    }
  }

  /// Vérifie si la vente est complétée
  bool get isCompleted => status == 'completed';

  /// Vérifie si la vente peut être modifiée
  bool get canBeModified => status == 'draft' || status == 'pending';

  /// Vérifie si la vente peut être annulée
  bool get canBeCancelled => status == 'completed' || status == 'pending';

  /// Copie avec modifications
  SaleEntity copyWith({
    String? id,
    String? saleNumber,
    String? saleType,
    String? status,
    CustomerEntity? customer,
    String? cashier,
    DateTime? saleDate,
    double? totalAmount,
    double? paidAmount,
    int? itemsCount,
    bool? isPaid,
    double? balance,
    DateTime? createdAt,
  }) {
    return SaleEntity(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      saleType: saleType ?? this.saleType,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      cashier: cashier ?? this.cashier,
      saleDate: saleDate ?? this.saleDate,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      itemsCount: itemsCount ?? this.itemsCount,
      isPaid: isPaid ?? this.isPaid,
      balance: balance ?? this.balance,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    saleNumber,
    saleType,
    status,
    customer,
    cashier,
    saleDate,
    totalAmount,
    paidAmount,
    itemsCount,
    isPaid,
    balance,
    createdAt,
  ];

  @override
  String toString() => 'SaleEntity(number: $saleNumber, total: $totalAmount, status: $status)';
}