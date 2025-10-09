// ========================================
// lib/features/sales/data/models/sale_detail_model.dart
// Model SaleDetail (détail complet) - Data Layer
// ========================================

import '../../domain/entities/sale_detail_entity.dart';
import 'customer_model.dart';
import 'sale_item_model.dart';
import 'payment_model.dart';
import 'discount_model.dart';

/// Model représentant une vente complète avec tous les détails
class SaleDetailModel {
  final String id;
  final String saleNumber;
  final String saleType;
  final String status;

  // Relations
  final CustomerModel? customer;
  final String? customerId;
  final String cashier;
  final String cashierId;

  // Dates
  final String saleDate;

  // Montants
  final String subtotal;
  final String discountAmount;
  final String taxAmount;
  final String totalAmount;
  final String paidAmount;
  final String changeAmount;

  // Fidélité
  final int loyaltyPointsEarned;
  final int loyaltyPointsUsed;

  // Vente originale
  final String? originalSale;
  final String? originalSaleId;

  // Notes
  final String? notes;
  final String? customerNotes;

  // Configuration
  final bool receiptPrinted;
  final bool receiptEmailed;

  // Relations imbriquées
  final List<SaleItemModel> items;
  final List<PaymentModel> payments;
  final List<DiscountModel> appliedDiscounts;

  // Champs calculés
  final bool isPaid;
  final String balance;
  final bool canBeReturned;

  // Audit
  final String? createdBy;
  final String createdAt;
  final String? updatedBy;
  final String? updatedAt;

  SaleDetailModel({
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
    this.discountAmount = '0.00',
    required this.taxAmount,
    required this.totalAmount,
    required this.paidAmount,
    this.changeAmount = '0.00',
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
    this.balance = '0.00',
    this.canBeReturned = false,
    this.createdBy,
    required this.createdAt,
    this.updatedBy,
    this.updatedAt,
  });

  /// Depuis JSON (API response)
  factory SaleDetailModel.fromJson(Map<String, dynamic> json) {
    return SaleDetailModel(
      id: json['id'] as String,
      saleNumber: json['sale_number'] as String,
      saleType: json['sale_type'] as String,
      status: json['status'] as String,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      customerId: json['customer_id'] as String?,
      cashier: json['cashier'] as String,
      cashierId: json['cashier_id'] as String,
      saleDate: json['sale_date'] as String,
      subtotal: json['subtotal']?.toString() ?? '0.00',
      discountAmount: json['discount_amount']?.toString() ?? '0.00',
      taxAmount: json['tax_amount']?.toString() ?? '0.00',
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      changeAmount: json['change_amount']?.toString() ?? '0.00',
      loyaltyPointsEarned: json['loyalty_points_earned'] as int? ?? 0,
      loyaltyPointsUsed: json['loyalty_points_used'] as int? ?? 0,
      originalSale: json['original_sale'] as String?,
      originalSaleId: json['original_sale_id'] as String?,
      notes: json['notes'] as String?,
      customerNotes: json['customer_notes'] as String?,
      receiptPrinted: json['receipt_printed'] as bool? ?? false,
      receiptEmailed: json['receipt_emailed'] as bool? ?? false,
      items: (json['items'] as List<dynamic>?)
          ?.map((item) => SaleItemModel.fromJson(item as Map<String, dynamic>))
          .toList() ??
          [],
      payments: (json['payments'] as List<dynamic>?)
          ?.map((payment) => PaymentModel.fromJson(payment as Map<String, dynamic>))
          .toList() ??
          [],
      appliedDiscounts: (json['applied_discounts'] as List<dynamic>?)
          ?.map((discount) => DiscountModel.fromJson(
          (discount as Map<String, dynamic>)['discount'] as Map<String, dynamic>))
          .toList() ??
          [],
      isPaid: json['is_paid'] as bool? ?? false,
      balance: json['balance']?.toString() ?? '0.00',
      canBeReturned: json['can_be_returned'] as bool? ?? false,
      createdBy: json['created_by'] as String?,
      createdAt: json['created_at'] as String,
      updatedBy: json['updated_by'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'sale_type': saleType,
      'status': status,
      if (customerId != null) 'customer_id': customerId,
      'cashier_id': cashierId,
      'sale_date': saleDate,
      'subtotal': subtotal,
      'discount_amount': discountAmount,
      'tax_amount': taxAmount,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      'change_amount': changeAmount,
      'loyalty_points_earned': loyaltyPointsEarned,
      'loyalty_points_used': loyaltyPointsUsed,
      if (originalSaleId != null) 'original_sale_id': originalSaleId,
      if (notes != null) 'notes': notes,
      if (customerNotes != null) 'customer_notes': customerNotes,
      'receipt_printed': receiptPrinted,
      'receipt_emailed': receiptEmailed,
      'items': items.map((item) => item.toJson()).toList(),
      'payments': payments.map((payment) => payment.toJson()).toList(),
      'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    };
  }

  /// Conversion vers Entity
  SaleDetailEntity toEntity() {
    return SaleDetailEntity(
      id: id,
      saleNumber: saleNumber,
      saleType: saleType,
      status: status,
      customer: customer?.toEntity(),
      customerId: customerId,
      cashier: cashier,
      cashierId: cashierId,
      saleDate: DateTime.parse(saleDate),
      subtotal: double.tryParse(subtotal) ?? 0.0,
      discountAmount: double.tryParse(discountAmount) ?? 0.0,
      taxAmount: double.tryParse(taxAmount) ?? 0.0,
      totalAmount: double.tryParse(totalAmount) ?? 0.0,
      paidAmount: double.tryParse(paidAmount) ?? 0.0,
      changeAmount: double.tryParse(changeAmount) ?? 0.0,
      loyaltyPointsEarned: loyaltyPointsEarned,
      loyaltyPointsUsed: loyaltyPointsUsed,
      originalSale: originalSale,
      originalSaleId: originalSaleId,
      notes: notes,
      customerNotes: customerNotes,
      receiptPrinted: receiptPrinted,
      receiptEmailed: receiptEmailed,
      items: items.map((item) => item.toEntity()).toList(),
      payments: payments.map((payment) => payment.toEntity()).toList(),
      appliedDiscounts: appliedDiscounts.map((discount) => discount.toEntity()).toList(),
      isPaid: isPaid,
      balance: double.tryParse(balance) ?? 0.0,
      canBeReturned: canBeReturned,
      createdBy: createdBy,
      createdAt: DateTime.parse(createdAt),
      updatedBy: updatedBy,
      updatedAt: updatedAt != null ? DateTime.tryParse(updatedAt!) : null,
    );
  }
}