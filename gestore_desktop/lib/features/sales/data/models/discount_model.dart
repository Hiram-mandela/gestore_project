// ========================================
// lib/features/sales/data/models/discount_model.dart
// Model Discount - Data Layer
// ========================================
import '../../domain/entities/discount_entity.dart';

/// Model représentant une remise/promotion
class DiscountModel {
  final String id;
  final String name;
  final String? description;
  final String discountType;
  final String scope;

  // Valeurs de remise
  final String? percentageValue;
  final String? fixedValue;

  // Conditions
  final int? minQuantity;
  final String? minAmount;
  final String? maxAmount;

  // Période de validité
  final String? startDate;
  final String? endDate;

  // État
  final bool isActive;
  final String createdAt;
  final String? updatedAt;

  // --- CHAMPS AJOUTÉS ---
  // Limitations
  final int? maxUses;
  final int? maxUsesPerCustomer;
  final int? currentUses;

  // Cibles
  final List<String>? targetCategories;
  final List<String>? targetArticles;
  final List<String>? targetCustomers;

  DiscountModel({
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
    // --- AJOUTÉS AU CONSTRUCTEUR ---
    this.maxUses,
    this.maxUsesPerCustomer,
    this.currentUses,
    this.targetCategories,
    this.targetArticles,
    this.targetCustomers,
  });

  /// Depuis JSON (API response)
  factory DiscountModel.fromJson(Map<String, dynamic> json) {
    return DiscountModel(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      discountType: json['discount_type'] as String,
      scope: json['scope'] as String,
      percentageValue: json['percentage_value']?.toString(),
      fixedValue: json['fixed_value']?.toString(),
      minQuantity: json['min_quantity'] as int?,
      minAmount: json['min_amount']?.toString(),
      maxAmount: json['max_amount']?.toString(),
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String?,
      // --- AJOUTÉS À FROMJSON ---
      maxUses: json['max_uses'] as int?,
      maxUsesPerCustomer: json['max_uses_per_customer'] as int?,
      currentUses: json['current_uses'] as int?,
      targetCategories: json['target_categories'] != null ? List<String>.from(json['target_categories']) : null,
      targetArticles: json['target_articles'] != null ? List<String>.from(json['target_articles']) : null,
      targetCustomers: json['target_customers'] != null ? List<String>.from(json['target_customers']) : null,
    );
  }

  /// Vers JSON (API request)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      if (description != null) 'description': description,
      'discount_type': discountType,
      'scope': scope,
      if (percentageValue != null) 'percentage_value': percentageValue,
      if (fixedValue != null) 'fixed_value': fixedValue,
      if (minQuantity != null) 'min_quantity': minQuantity,
      if (minAmount != null) 'min_amount': minAmount,
      if (maxAmount != null) 'max_amount': maxAmount,
      if (startDate != null) 'start_date': startDate,
      if (endDate != null) 'end_date': endDate,
      'is_active': isActive,
      // --- AJOUTÉS À TOJSON ---
      if (maxUses != null) 'max_uses': maxUses,
      if (maxUsesPerCustomer != null) 'max_uses_per_customer': maxUsesPerCustomer,
      if (targetCategories != null) 'target_categories': targetCategories,
      if (targetArticles != null) 'target_articles': targetArticles,
      if (targetCustomers != null) 'target_customers': targetCustomers,
    };
  }

  /// Conversion vers Entity
  DiscountEntity toEntity() {
    return DiscountEntity(
      id: id,
      name: name,
      description: description,
      discountType: discountType,
      scope: scope,
      percentageValue: percentageValue != null ? double.tryParse(percentageValue!) : null,
      fixedValue: fixedValue != null ? double.tryParse(fixedValue!) : null,
      minQuantity: minQuantity,
      minAmount: minAmount != null ? double.tryParse(minAmount!) : null,
      maxAmount: maxAmount != null ? double.tryParse(maxAmount!) : null,
      startDate: startDate != null ? DateTime.parse(startDate!) : null,
      endDate: endDate != null ? DateTime.parse(endDate!) : null,
      isActive: isActive,
      createdAt: DateTime.parse(createdAt),
      updatedAt: updatedAt != null ? DateTime.parse(updatedAt!) : null,
      // --- AJOUTÉS À TOENTITY ---
      maxUses: maxUses,
      maxUsesPerCustomer: maxUsesPerCustomer,
      currentUses: currentUses,
      targetCategories: targetCategories,
      targetArticles: targetArticles,
      targetCustomers: targetCustomers,
    );
  }
}