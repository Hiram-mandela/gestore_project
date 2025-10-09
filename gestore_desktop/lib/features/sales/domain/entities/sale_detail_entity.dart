// ========================================
// lib/features/sales/domain/entities/sale_detail_entity.dart
// Entité SaleDetail (détail complet) - Domain Layer
// ========================================

import 'package:equatable/equatable.dart';
import 'customer_entity.dart';
import 'sale_item_entity.dart';
import 'payment_entity.dart';
import 'discount_entity.dart';

/// Entité représentant une vente complète avec tous les détails
class SaleDetailEntity extends Equatable {
  final String id;
  final String saleNumber;
  final String saleType; // 'regular', 'return', 'exchange', 'quote'
  final String status; // 'draft', 'pending', 'completed', 'cancelled', 'refunded', 'partially_refunded'

  // Relations
  final CustomerEntity? customer;
  final String? customerId;
  final String cashier;
  final String cashierId;

  // Dates
  final DateTime saleDate;

  // Montants
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double changeAmount;

  // Fidélité
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;

  // Vente originale (pour retours/échanges)
  final String? originalSale;
  final String? originalSaleId;

  // Notes
  final String? notes;
  final String? customerNotes;

  // Configuration
  final bool receiptPrinted;
  final bool receiptEmailed;

  // Relations imbriquées
  final List<SaleItemEntity> items;
  final List<PaymentEntity> payments;
  final List<DiscountEntity> appliedDiscounts;

  // Champs calculés
  final bool isPaid;
  final double balance;
  final bool canBeReturned;

  // Audit
  final String? createdBy;
  final DateTime createdAt;
  final String? updatedBy;
  final DateTime? updatedAt;

  const SaleDetailEntity({
    required this.id,
    required this.saleNumber,
    required this.saleType,
    required this.status,
    this.customer,
    this.customerId,
    required this.cashier,
    required this.cashierId,
    required this.saleDate,
    required this.subtotal,
    this.discountAmount = 0.0,
    required this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.changeAmount = 0.0,
    this.loyaltyPointsEarned = 0,
    this.loyaltyPointsUsed = 0,
    this.originalSale,
    this.originalSaleId,
    this.notes,
    this.customerNotes,
    this.receiptPrinted = false,
    this.receiptEmailed = false,
    this.items = const [],
    this.payments = const [],
    this.appliedDiscounts = const [],
    this.isPaid = false,
    this.balance = 0.0,
    this.canBeReturned = false,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
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

  /// Nombre total d'articles
  int get totalItemsCount {
    return items.fold(0, (sum, item) => sum + item.quantity.toInt());
  }

  /// Vérifie si la vente est complétée
  bool get isCompleted => status == 'completed';

  /// Vérifie si la vente peut être modifiée
  bool get canBeModified => status == 'draft' || status == 'pending';

  /// Vérifie si la vente peut être annulée
  bool get canBeCancelled => status == 'completed' || status == 'pending';

  /// Vérifie si c'est un retour
  bool get isReturn => saleType == 'return';

  /// Vérifie si c'est un échange
  bool get isExchange => saleType == 'exchange';

  /// Copie avec modifications
  SaleDetailEntity copyWith({
    String? id,
    String? saleNumber,
    String? saleType,
    String? status,
    CustomerEntity? customer,
    String? customerId,
    String? cashier,
    String? cashierId,
    DateTime? saleDate,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    double? paidAmount,
    double? changeAmount,
    int? loyaltyPointsEarned,
    int? loyaltyPointsUsed,
    String? originalSale,
    String? originalSaleId,
    String? notes,
    String? customerNotes,
    bool? receiptPrinted,
    bool? receiptEmailed,
    List<SaleItemEntity>? items,
    List<PaymentEntity>? payments,
    List<DiscountEntity>? appliedDiscounts,
    bool? isPaid,
    double? balance,
    bool? canBeReturned,
    String? createdBy,
    DateTime? createdAt,
    String? updatedBy,
    DateTime? updatedAt,
  }) {
    return SaleDetailEntity(
      id: id ?? this.id,
      saleNumber: saleNumber ?? this.saleNumber,
      saleType: saleType ?? this.saleType,
      status: status ?? this.status,
      customer: customer ?? this.customer,
      customerId: customerId ?? this.customerId,
      cashier: cashier ?? this.cashier,
      cashierId: cashierId ?? this.cashierId,
      saleDate: saleDate ?? this.saleDate,
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      changeAmount: changeAmount ?? this.changeAmount,
      loyaltyPointsEarned: loyaltyPointsEarned ?? this.loyaltyPointsEarned,
      loyaltyPointsUsed: loyaltyPointsUsed ?? this.loyaltyPointsUsed,
      originalSale: originalSale ?? this.originalSale,
      originalSaleId: originalSaleId ?? this.originalSaleId,
      notes: notes ?? this.notes,
      customerNotes: customerNotes ?? this.customerNotes,
      receiptPrinted: receiptPrinted ?? this.receiptPrinted,
      receiptEmailed: receiptEmailed ?? this.receiptEmailed,
      items: items ?? this.items,
      payments: payments ?? this.payments,
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      isPaid: isPaid ?? this.isPaid,
      balance: balance ?? this.balance,
      canBeReturned: canBeReturned ?? this.canBeReturned,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      updatedBy: updatedBy ?? this.updatedBy,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    saleNumber,
    saleType,
    status,
    customer,
    customerId,
    cashier,
    cashierId,
    saleDate,
    subtotal,
    discountAmount,
    taxAmount,
    totalAmount,
    paidAmount,
    changeAmount,
    loyaltyPointsEarned,
    loyaltyPointsUsed,
    originalSale,
    originalSaleId,
    notes,
    customerNotes,
    receiptPrinted,
    receiptEmailed,
    items,
    payments,
    appliedDiscounts,
    isPaid,
    balance,
    canBeReturned,
    createdBy,
    createdAt,
    updatedBy,
    updatedAt,
  ];

  @override
  String toString() => 'SaleDetailEntity(number: $saleNumber, items: ${items.length}, total: $totalAmount)';
}