// ========================================
// lib/features/sales/domain/entities/discount_entity.dart
// Entité Discount - Domain Layer
// ========================================
import 'package:equatable/equatable.dart';

/// Entité représentant une remise/promotion
class DiscountEntity extends Equatable {
  final String id;
  final String name;
  final String? description;
  final String discountType; // 'percentage', 'fixed_amount', etc.
  final String scope; // 'sale', 'category', etc.

  // Valeurs de remise
  final double? percentageValue;
  final double? fixedValue;

  // Conditions
  final int? minQuantity;
  final double? minAmount;
  final double? maxAmount;

  // Période de validité
  final DateTime? startDate;
  final DateTime? endDate;

  // État
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  // --- CHAMPS AJOUTÉS ---
  // Limitations
  final int? maxUses;
  final int? maxUsesPerCustomer;
  final int? currentUses;

  // Cibles (listes d'IDs)
  final List<String>? targetCategories;
  final List<String>? targetArticles;
  final List<String>? targetCustomers;

  const DiscountEntity({
    required this.id,
    required this.name,
    this.description,
    required this.discountType,
    required this.scope,
    this.percentageValue,
    this.fixedValue,
    this.minQuantity,
    this.minAmount,
    this.maxAmount,
    this.startDate,
    this.endDate,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
    this.maxUses,
    this.maxUsesPerCustomer,
    this.currentUses,
    this.targetCategories,
    this.targetArticles,
    this.targetCustomers,
  });

  /// Retourne le type de remise formaté
  String get discountTypeDisplay {
    switch (discountType) {
      case 'percentage':
        return 'Pourcentage';
      case 'fixed_amount':
        return 'Montant fixe';
      case 'buy_x_get_y':
        return 'Achetez X obtenez Y';
      case 'loyalty_points':
        return 'Points fidélité';
      default:
        return discountType;
    }
  }

  /// Retourne la portée formatée
  String get scopeDisplay {
    switch (scope) {
      case 'sale':
        return 'Sur la vente totale';
      case 'category':
        return 'Sur une catégorie';
      case 'article':
        return 'Sur un article';
      case 'customer':
        return 'Pour un client';
      default:
        return scope;
    }
  }

  /// Vérifie si la remise est actuellement valide (logique simple côté client)
  bool get isCurrentlyValid {
    if (!isActive) return false;
    final now = DateTime.now();
    if (startDate != null && now.isBefore(startDate!)) return false;
    if (endDate != null && now.isAfter(endDate!)) return false;
    // La validation complexe (par client, etc.) doit être faite par le backend
    return true;
  }

  /// Calcule le montant de la remise (simulation côté client)
  double calculateDiscount(double amount, {int quantity = 1}) {
    if (!isCurrentlyValid) return 0.0;
    if (minQuantity != null && quantity < minQuantity!) return 0.0;
    if (minAmount != null && amount < minAmount!) return 0.0;

    double discount = 0.0;
    if (discountType == 'percentage' && percentageValue != null) {
      discount = amount * (percentageValue! / 100);
    } else if (discountType == 'fixed_amount' && fixedValue != null) {
      discount = fixedValue!;
    }

    if (maxAmount != null && discount > maxAmount!) {
      discount = maxAmount!;
    }
    if (discount > amount) {
      discount = amount;
    }
    return discount;
  }

  /// Retourne la description de la remise
  String get discountDescription {
    if (discountType == 'percentage' && percentageValue != null) {
      return '${percentageValue!.toStringAsFixed(0)}%';
    } else if (discountType == 'fixed_amount' && fixedValue != null) {
      return '${fixedValue!.toStringAsFixed(0)} FCFA';
    }
    return name;
  }

  /// Copie avec modifications
  DiscountEntity copyWith({
    String? id,
    String? name,
    String? description,
    String? discountType,
    String? scope,
    double? percentageValue,
    double? fixedValue,
    int? minQuantity,
    double? minAmount,
    double? maxAmount,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
    // --- AJOUTÉS À COPYWITH ---
    int? maxUses,
    int? maxUsesPerCustomer,
    int? currentUses,
    List<String>? targetCategories,
    List<String>? targetArticles,
    List<String>? targetCustomers,
  }) {
    return DiscountEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      discountType: discountType ?? this.discountType,
      scope: scope ?? this.scope,
      percentageValue: percentageValue ?? this.percentageValue,
      fixedValue: fixedValue ?? this.fixedValue,
      minQuantity: minQuantity ?? this.minQuantity,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      // --- AJOUTÉS À COPYWITH ---
      maxUses: maxUses ?? this.maxUses,
      maxUsesPerCustomer: maxUsesPerCustomer ?? this.maxUsesPerCustomer,
      currentUses: currentUses ?? this.currentUses,
      targetCategories: targetCategories ?? this.targetCategories,
      targetArticles: targetArticles ?? this.targetArticles,
      targetCustomers: targetCustomers ?? this.targetCustomers,
    );
  }

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    discountType,
    scope,
    percentageValue,
    fixedValue,
    minQuantity,
    minAmount,
    maxAmount,
    startDate,
    endDate,
    isActive,
    createdAt,
    updatedAt,
    maxUses,
    maxUsesPerCustomer,
    currentUses,
    targetCategories,
    targetArticles,
    targetCustomers,
  ];

  @override
  String toString() => 'DiscountEntity(id: $id, name: $name, type: $discountType)';
}