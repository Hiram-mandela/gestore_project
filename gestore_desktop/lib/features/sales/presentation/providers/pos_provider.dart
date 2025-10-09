// ========================================
// lib/features/sales/presentation/providers/pos_provider.dart
// Provider principal du POS - Riverpod
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/entities/customer_entity.dart';
import '../../domain/entities/discount_entity.dart';
import '../../domain/usecases/pos_checkout_usecase.dart';
import '../../domain/usecases/calculate_sale_usecase.dart';
import '../../domain/usecases/get_active_discounts_usecase.dart';
import '../../../inventory/domain/entities/article_entity.dart';
import 'pos_state.dart';

// ==================== POS PROVIDER ====================

/// Provider principal du POS
final posProvider = StateNotifierProvider<PosNotifier, PosState>((ref) {
  return PosNotifier(
    checkoutUseCase: getIt<PosCheckoutUseCase>(),
    calculateSaleUseCase: getIt<CalculateSaleUseCase>(),
    getActiveDiscountsUseCase: getIt<GetActiveDiscountsUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour le POS
class PosNotifier extends StateNotifier<PosState> {
  final PosCheckoutUseCase checkoutUseCase;
  final CalculateSaleUseCase calculateSaleUseCase;
  final GetActiveDiscountsUseCase getActiveDiscountsUseCase;
  final Logger logger;

  PosNotifier({
    required this.checkoutUseCase,
    required this.calculateSaleUseCase,
    required this.getActiveDiscountsUseCase,
    required this.logger,
  }) : super(const PosInitial());

  // ==================== SESSION ====================

  /// Ouvre une session POS
  Future<void> openSession() async {
    logger.i('🎯 POS: Ouverture session');
    state = const PosReady();
  }

  /// Ferme la session et réinitialise
  void closeSession() {
    logger.i('🎯 POS: Fermeture session');
    state = const PosInitial();
  }

  // ==================== CART MANAGEMENT ====================

  /// Ajoute un article au panier
  void addArticle(ArticleEntity article, {double quantity = 1.0}) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('➕ POS: Ajout article ${article.name} (qty: $quantity)');

    // Vérifier si l'article existe déjà
    final existingIndex = currentState.cartItems.indexWhere(
          (item) => item.article.id == article.id,
    );

    List<CartItem> updatedCart;

    if (existingIndex != -1) {
      // Article existe, augmenter la quantité
      final existingItem = currentState.cartItems[existingIndex];
      updatedCart = List<CartItem>.from(currentState.cartItems);
      updatedCart[existingIndex] = existingItem.copyWith(
        quantity: existingItem.quantity + quantity,
      );
    } else {
      // Nouvel article
      final newItem = CartItem(
        article: article,
        quantity: quantity,
        unitPrice: article.sellingPrice,
      );
      updatedCart = [...currentState.cartItems, newItem];
    }

    _updateCartAndRecalculate(currentState, updatedCart);
  }

  /// Met à jour la quantité d'un article
  void updateQuantity(String articleId, double newQuantity) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('🔄 POS: Mise à jour quantité article $articleId: $newQuantity');

    if (newQuantity <= 0) {
      removeArticle(articleId);
      return;
    }

    final updatedCart = currentState.cartItems.map((item) {
      if (item.article.id == articleId) {
        return item.copyWith(quantity: newQuantity);
      }
      return item;
    }).toList();

    _updateCartAndRecalculate(currentState, updatedCart);
  }

  /// Applique une remise sur un article
  void applyItemDiscount(String articleId, double discountPercentage) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('💰 POS: Remise $discountPercentage% sur article $articleId');

    final updatedCart = currentState.cartItems.map((item) {
      if (item.article.id == articleId) {
        return item.copyWith(discountPercentage: discountPercentage);
      }
      return item;
    }).toList();

    _updateCartAndRecalculate(currentState, updatedCart);
  }

  /// Supprime un article du panier
  void removeArticle(String articleId) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('🗑️ POS: Suppression article $articleId');

    final updatedCart = currentState.cartItems
        .where((item) => item.article.id != articleId)
        .toList();

    _updateCartAndRecalculate(currentState, updatedCart);
  }

  /// Vide le panier
  void clearCart() {
    if (state is! PosReady) return;

    logger.d('🧹 POS: Vidage panier');
    final currentState = state as PosReady;

    state = currentState.copyWith(
      cartItems: [],
      subtotal: 0.0,
      discountAmount: 0.0,
      taxAmount: 0.0,
      totalAmount: 0.0,
      balance: 0.0,
    );
  }

  // ==================== CUSTOMER ====================

  /// Sélectionne un client
  void selectCustomer(CustomerEntity customer) {
    if (state is! PosReady) return;

    logger.d('👤 POS: Sélection client ${customer.fullName}');
    final currentState = state as PosReady;

    state = currentState.copyWith(customer: customer);
    _recalculateTotals();
  }

  /// Retire le client
  void removeCustomer() {
    if (state is! PosReady) return;

    logger.d('👤 POS: Retrait client');
    final currentState = state as PosReady;

    state = currentState.copyWith(clearCustomer: true);
    _recalculateTotals();
  }

  // ==================== DISCOUNTS ====================

  /// Applique une remise globale
  void applyDiscount(DiscountEntity discount) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('🎁 POS: Application remise ${discount.name}');

    final updatedDiscounts = [...currentState.appliedDiscounts, discount];

    state = currentState.copyWith(appliedDiscounts: updatedDiscounts);
    _recalculateTotals();
  }

  /// Retire une remise
  void removeDiscount(String discountId) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('🎁 POS: Retrait remise $discountId');

    final updatedDiscounts = currentState.appliedDiscounts
        .where((discount) => discount.id != discountId)
        .toList();

    state = currentState.copyWith(appliedDiscounts: updatedDiscounts);
    _recalculateTotals();
  }

  // ==================== PAYMENTS ====================

  /// Ajoute un paiement
  void addPayment(PaymentItem payment) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('💳 POS: Ajout paiement ${payment.paymentMethod.name}: ${payment.amount}');

    final updatedPayments = [...currentState.payments, payment];
    final paidAmount = updatedPayments.fold<double>(
      0.0,
          (sum, p) => sum + p.amount,
    );
    final balance = currentState.totalAmount - paidAmount;

    state = currentState.copyWith(
      payments: updatedPayments,
      paidAmount: paidAmount,
      balance: balance,
    );
  }

  /// Retire un paiement
  void removePayment(int index) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    logger.d('💳 POS: Retrait paiement $index');

    final updatedPayments = List<PaymentItem>.from(currentState.payments);
    updatedPayments.removeAt(index);

    final paidAmount = updatedPayments.fold<double>(
      0.0,
          (sum, p) => sum + p.amount,
    );
    final balance = currentState.totalAmount - paidAmount;

    state = currentState.copyWith(
      payments: updatedPayments,
      paidAmount: paidAmount,
      balance: balance,
    );
  }

  /// Vide tous les paiements
  void clearPayments() {
    if (state is! PosReady) return;

    logger.d('💳 POS: Vidage paiements');
    final currentState = state as PosReady;

    state = currentState.copyWith(
      payments: [],
      paidAmount: 0.0,
      balance: currentState.totalAmount,
    );
  }

  // ==================== NOTES ====================

  /// Ajoute une note à la vente
  void setNotes(String notes) {
    if (state is! PosReady) return;

    final currentState = state as PosReady;
    state = currentState.copyWith(notes: notes);
  }

  // ==================== CALCULATIONS ====================

  /// Met à jour le panier et recalcule les totaux
  void _updateCartAndRecalculate(PosReady currentState, List<CartItem> updatedCart) {
    state = currentState.copyWith(cartItems: updatedCart);
    _recalculateTotals();
  }

  /// Recalcule tous les totaux
  void _recalculateTotals() {
    if (state is! PosReady) return;

    final currentState = state as PosReady;

    // Calcul du sous-total
    final subtotal = currentState.cartItems.fold<double>(
      0.0,
          (sum, item) => sum + item.subtotal,
    );

    // Calcul des remises articles
    final itemDiscounts = currentState.cartItems.fold<double>(
      0.0,
          (sum, item) => sum + item.discountAmount,
    );

    // Calcul des remises globales
    final globalDiscounts = currentState.appliedDiscounts.fold<double>(
      0.0,
          (sum, discount) => sum + discount.calculateDiscount(subtotal),
    );

    final totalDiscounts = itemDiscounts + globalDiscounts;

    // Calcul des taxes (TVA 18% en Côte d'Ivoire - à adapter selon les besoins)
    final taxRate = 0.0; // À activer si nécessaire
    final taxAmount = (subtotal - totalDiscounts) * taxRate;

    // Calcul du total
    final totalAmount = subtotal - totalDiscounts + taxAmount;

    // Calcul du solde
    final balance = totalAmount - currentState.paidAmount;

    state = currentState.copyWith(
      subtotal: subtotal,
      discountAmount: totalDiscounts,
      taxAmount: taxAmount,
      totalAmount: totalAmount,
      balance: balance,
    );
  }

  // ==================== CHECKOUT ====================

  /// Finalise la vente (checkout)
  Future<void> checkout() async {
    if (state is! PosReady) return;

    final currentState = state as PosReady;

    if (!currentState.canCheckout) {
      state = const PosError('Impossible de finaliser: panier vide ou paiement incomplet');
      return;
    }

    state = const PosLoading(message: 'Finalisation de la vente...');
    logger.i('🛒 POS: Finalisation vente');

    // Préparer les articles
    final items = currentState.cartItems.map((item) {
      return {
        'article_id': item.article.id,
        'quantity': item.quantity,
        'unit_price': item.unitPrice,
        'discount_percentage': item.discountPercentage,
      };
    }).toList();

    // Préparer les paiements
    final payments = currentState.payments.map((payment) {
      final paymentData = <String, dynamic>{
        'payment_method_id': payment.paymentMethod.id,
        'amount': payment.amount,
      };

      if (payment.reference != null) {
        paymentData['transaction_id'] = payment.reference;
      }

      if (payment.paymentMethod.paymentType == 'cash' && payment.cashReceived != null) {
        paymentData['cash_received'] = payment.cashReceived;
        paymentData['cash_change'] = payment.change;
      }

      return paymentData;
    }).toList();

    // Appeler le use case
    final (saleDetail, error) = await checkoutUseCase(
      items: items,
      payments: payments,
      customerId: currentState.customer?.id,
      notes: currentState.notes,
    );

    if (error != null) {
      logger.e('❌ POS: Erreur checkout: $error');
      state = PosError(error);
      return;
    }

    if (saleDetail == null) {
      state = const PosError('Erreur inconnue lors de la finalisation');
      return;
    }

    logger.i('✅ POS: Vente ${saleDetail.saleNumber} finalisée');

    state = PosCheckoutSuccess(
      saleNumber: saleDetail.saleNumber,
      totalAmount: saleDetail.totalAmount,
      changeAmount: saleDetail.changeAmount,
    );
  }

  /// Réinitialise après un checkout réussi
  void resetAfterCheckout() {
    logger.i('🔄 POS: Réinitialisation après vente');
    state = const PosReady();
  }
}