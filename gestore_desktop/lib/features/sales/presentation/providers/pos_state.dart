// ========================================
// lib/features/sales/presentation/providers/pos_state.dart
// États du POS (Point of Sale)
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/payment_method_entity.dart';
import '../../domain/entities/discount_entity.dart';
import '../../../inventory/domain/entities/article_entity.dart';

// ==================== CART ITEM ====================

/// Article dans le panier
class CartItem extends Equatable {
  final ArticleEntity article;
  final double quantity;
  final double unitPrice;
  final double discountPercentage;
  final String? note;

  const CartItem({
    required this.article,
    required this.quantity,
    required this.unitPrice,
    this.discountPercentage = 0.0,
    this.note,
  });

  /// Calcule le sous-total avant remise
  double get subtotal => quantity * unitPrice;

  /// Calcule le montant de la remise
  double get discountAmount => subtotal * (discountPercentage / 100);

  /// Calcule le total après remise
  double get total => subtotal - discountAmount;

  CartItem copyWith({
    ArticleEntity? article,
    double? quantity,
    double? unitPrice,
    double? discountPercentage,
    String? note,
  }) {
    return CartItem(
      article: article ?? this.article,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      discountPercentage: discountPercentage ?? this.discountPercentage,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
    article.id,
    quantity,
    unitPrice,
    discountPercentage,
    note,
  ];
}

// ==================== PAYMENT ITEM ====================

/// Paiement dans le panier
class PaymentItem extends Equatable {
  final PaymentMethodEntity paymentMethod;
  final double amount;
  final String? reference;
  final double? cashReceived;

  const PaymentItem({
    required this.paymentMethod,
    required this.amount,
    this.reference,
    this.cashReceived,
  });

  /// Calcule la monnaie rendue (pour espèces)
  double get change {
    if (paymentMethod.paymentType == 'cash' && cashReceived != null) {
      return cashReceived! - amount;
    }
    return 0.0;
  }

  PaymentItem copyWith({
    PaymentMethodEntity? paymentMethod,
    double? amount,
    String? reference,
    double? cashReceived,
  }) {
    return PaymentItem(
      paymentMethod: paymentMethod ?? this.paymentMethod,
      amount: amount ?? this.amount,
      reference: reference ?? this.reference,
      cashReceived: cashReceived ?? this.cashReceived,
    );
  }

  @override
  List<Object?> get props => [
    paymentMethod.id,
    amount,
    reference,
    cashReceived,
  ];
}

// ==================== POS STATE ====================

/// États du POS
sealed class PosState extends Equatable {
  const PosState();

  @override
  List<Object?> get props => [];
}

/// État initial
class PosInitial extends PosState {
  const PosInitial();
}

/// État de chargement
class PosLoading extends PosState {
  final String? message;

  const PosLoading({this.message});

  @override
  List<Object?> get props => [message];
}

/// État prêt (session ouverte)
class PosReady extends PosState {
  final List<CartItem> cartItems;
  final CustomerEntity? customer;
  final List<DiscountEntity> appliedDiscounts;
  final List<PaymentItem> payments;
  final String? notes;

  // Calculs
  final double subtotal;
  final double discountAmount;
  final double taxAmount;
  final double totalAmount;
  final double paidAmount;
  final double balance;

  const PosReady({
    this.cartItems = const [],
    this.customer,
    this.appliedDiscounts = const [],
    this.payments = const [],
    this.notes,
    this.subtotal = 0.0,
    this.discountAmount = 0.0,
    this.taxAmount = 0.0,
    this.totalAmount = 0.0,
    this.paidAmount = 0.0,
    this.balance = 0.0,
  });

  /// Nombre total d'articles
  int get itemsCount => cartItems.length;

  /// Quantité totale d'articles
  double get totalQuantity {
    return cartItems.fold(0.0, (sum, item) => sum + item.quantity);
  }

  /// Vérifie si le panier est vide
  bool get isCartEmpty => cartItems.isEmpty;

  /// Vérifie si le paiement est complet
  bool get isFullyPaid => balance <= 0;

  /// Vérifie si on peut finaliser la vente
  bool get canCheckout => !isCartEmpty && isFullyPaid;

  PosReady copyWith({
    List<CartItem>? cartItems,
    CustomerEntity? customer,
    bool clearCustomer = false,
    List<DiscountEntity>? appliedDiscounts,
    List<PaymentItem>? payments,
    String? notes,
    bool clearNotes = false,
    double? subtotal,
    double? discountAmount,
    double? taxAmount,
    double? totalAmount,
    double? paidAmount,
    double? balance,
  }) {
    return PosReady(
      cartItems: cartItems ?? this.cartItems,
      customer: clearCustomer ? null : (customer ?? this.customer),
      appliedDiscounts: appliedDiscounts ?? this.appliedDiscounts,
      payments: payments ?? this.payments,
      notes: clearNotes ? null : (notes ?? this.notes),
      subtotal: subtotal ?? this.subtotal,
      discountAmount: discountAmount ?? this.discountAmount,
      taxAmount: taxAmount ?? this.taxAmount,
      totalAmount: totalAmount ?? this.totalAmount,
      paidAmount: paidAmount ?? this.paidAmount,
      balance: balance ?? this.balance,
    );
  }

  @override
  List<Object?> get props => [
    cartItems,
    customer,
    appliedDiscounts,
    payments,
    notes,
    subtotal,
    discountAmount,
    taxAmount,
    totalAmount,
    paidAmount,
    balance,
  ];
}

/// Vente finalisée avec succès
class PosCheckoutSuccess extends PosState {
  final String saleNumber;
  final double totalAmount;
  final double changeAmount;

  const PosCheckoutSuccess({
    required this.saleNumber,
    required this.totalAmount,
    required this.changeAmount,
  });

  @override
  List<Object?> get props => [saleNumber, totalAmount, changeAmount];
}

/// Erreur
class PosError extends PosState {
  final String message;

  const PosError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== PAYMENT METHODS STATE ====================

sealed class PaymentMethodsState extends Equatable {
  const PaymentMethodsState();

  @override
  List<Object?> get props => [];
}

class PaymentMethodsInitial extends PaymentMethodsState {
  const PaymentMethodsInitial();
}

class PaymentMethodsLoading extends PaymentMethodsState {
  const PaymentMethodsLoading();
}

class PaymentMethodsLoaded extends PaymentMethodsState {
  final List<PaymentMethodEntity> paymentMethods;

  const PaymentMethodsLoaded(this.paymentMethods);

  @override
  List<Object?> get props => [paymentMethods];
}

class PaymentMethodsError extends PaymentMethodsState {
  final String message;

  const PaymentMethodsError(this.message);

  @override
  List<Object?> get props => [message];
}