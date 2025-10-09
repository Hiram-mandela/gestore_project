// ========================================
// lib/features/sales/data/models/sale_model.dart
// Model Sale (liste) - Data Layer
// ========================================

import '../../domain/entities/sale_entity.dart';
import 'customer_model.dart';

/// Model représentant une vente (version liste optimisée)
class SaleModel {
  final String id;
  final String saleNumber;
  final String saleType;
  final String status;

  // Relations
  final CustomerModel? customer;
  final String? cashier;

  // Dates
  final String saleDate;

  // Montants
  final String totalAmount;
  final String paidAmount;

  // Statistiques
  final int? itemsCount;
  final bool? isPaid;
  final String? balance;

  final String createdAt;

  SaleModel({
    required this.id,
    required this.saleNumber,
    required this.saleType,
    required this.status,
    this.customer,
    this.cashier,
    required this.saleDate,
    required this.totalAmount,
    required this.paidAmount,
    this.itemsCount,
    this.isPaid,
    this.balance,
    required this.createdAt,
  });

  /// Depuis JSON (API response)
  factory SaleModel.fromJson(Map<String, dynamic> json) {
    return SaleModel(
      id: json['id'] as String,
      saleNumber: json['sale_number'] as String,
      saleType: json['sale_type'] as String,
      status: json['status'] as String,
      customer: json['customer'] != null
          ? CustomerModel.fromJson(json['customer'] as Map<String, dynamic>)
          : null,
      cashier: json['cashier'] as String?,
      saleDate: json['sale_date'] as String,
      totalAmount: json['total_amount']?.toString() ?? '0.00',
      paidAmount: json['paid_amount']?.toString() ?? '0.00',
      itemsCount: json['items_count'] as int?,
      isPaid: json['is_paid'] as bool?,
      balance: json['balance']?.toString(),
      createdAt: json['created_at'] as String,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sale_number': saleNumber,
      'sale_type': saleType,
      'status': status,
      if (customer != null) 'customer': customer!.toJson(),
      if (cashier != null) 'cashier': cashier,
      'sale_date': saleDate,
      'total_amount': totalAmount,
      'paid_amount': paidAmount,
      if (itemsCount != null) 'items_count': itemsCount,
      if (isPaid != null) 'is_paid': isPaid,
      if (balance != null) 'balance': balance,
      'created_at': createdAt,
    };
  }

  /// Conversion vers Entity
  SaleEntity toEntity() {
    return SaleEntity(
      id: id,
      saleNumber: saleNumber,
      saleType: saleType,
      status: status,
      customer: customer?.toEntity(),
      cashier: cashier,
      saleDate: DateTime.parse(saleDate),
      totalAmount: double.tryParse(totalAmount) ?? 0.0,
      paidAmount: double.tryParse(paidAmount) ?? 0.0,
      itemsCount: itemsCount ?? 0,
      isPaid: isPaid ?? false,
      balance: balance != null ? (double.tryParse(balance!) ?? 0.0) : 0.0,
      createdAt: DateTime.parse(createdAt),
    );
  }
}