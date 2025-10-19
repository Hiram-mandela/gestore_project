// ========================================
// lib/features/inventory/domain/entities/stock_movement_entity.dart
// Entity pour les mouvements de stock
// ========================================

import 'package:equatable/equatable.dart';
import 'article_entity.dart';
import 'stock_entity.dart';

/// Types de mouvements de stock
enum MovementType {
  inMovement('in', 'Entrée'),
  out('out', 'Sortie'),
  adjustment('adjustment', 'Ajustement'),
  transfer('transfer', 'Transfert'),
  returnMovement('return', 'Retour'),
  loss('loss', 'Perte'),
  found('found', 'Trouvé');

  final String value;
  final String label;

  const MovementType(this.value, this.label);

  static MovementType fromString(String value) {
    return MovementType.values.firstWhere(
          (type) => type.value == value,
      orElse: () => MovementType.adjustment,
    );
  }
}

/// Raisons des mouvements de stock
enum MovementReason {
  purchase('purchase', 'Achat fournisseur'),
  sale('sale', 'Vente client'),
  returnSupplier('return_supplier', 'Retour fournisseur'),
  returnCustomer('return_customer', 'Retour client'),
  inventory('inventory', 'Inventaire'),
  damage('damage', 'Dommage'),
  theft('theft', 'Vol'),
  expiry('expiry', 'Péremption'),
  transferReason('transfer', 'Transfert'),
  adjustment('adjustment', 'Ajustement'),
  production('production', 'Production'),
  consumption('consumption', 'Consommation');

  final String value;
  final String label;

  const MovementReason(this.value, this.label);

  static MovementReason fromString(String value) {
    return MovementReason.values.firstWhere(
          (reason) => reason.value == value,
      orElse: () => MovementReason.adjustment,
    );
  }
}

/// Entity représentant un mouvement de stock
class StockMovementEntity extends Equatable {
  final String id;
  final ArticleEntity article;
  final StockEntity stock;
  final MovementType movementType;
  final MovementReason reason;
  final double quantity;
  final double? unitCost;
  final String? referenceDocument;
  final String? notes;
  final double stockBefore;
  final double stockAfter;
  final double movementValue;
  final String? createdBy;
  final DateTime createdAt;

  const StockMovementEntity({
    required this.id,
    required this.article,
    required this.stock,
    required this.movementType,
    required this.reason,
    required this.quantity,
    this.unitCost,
    this.referenceDocument,
    this.notes,
    required this.stockBefore,
    required this.stockAfter,
    required this.movementValue,
    this.createdBy,
    required this.createdAt,
  });

  /// Vérifie si c'est une entrée
  bool get isInbound => movementType == MovementType.inMovement;

  /// Vérifie si c'est une sortie
  bool get isOutbound => movementType == MovementType.out;

  /// Vérifie si c'est un ajustement
  bool get isAdjustment => movementType == MovementType.adjustment;

  /// Vérifie si c'est un transfert
  bool get isTransfer => movementType == MovementType.transfer;

  /// Calcule la variation de stock
  double get stockVariation => stockAfter - stockBefore;

  /// Vérifie si le mouvement a une valeur monétaire
  bool get hasValue => unitCost != null && unitCost! > 0;

  /// Format de la date
  String get formattedDate {
    return '${createdAt.day.toString().padLeft(2, '0')}/'
        '${createdAt.month.toString().padLeft(2, '0')}/'
        '${createdAt.year} '
        '${createdAt.hour.toString().padLeft(2, '0')}:'
        '${createdAt.minute.toString().padLeft(2, '0')}';
  }

  /// Copie avec modifications
  StockMovementEntity copyWith({
    String? id,
    ArticleEntity? article,
    StockEntity? stock,
    MovementType? movementType,
    MovementReason? reason,
    double? quantity,
    double? unitCost,
    String? referenceDocument,
    String? notes,
    double? stockBefore,
    double? stockAfter,
    double? movementValue,
    String? createdBy,
    DateTime? createdAt,
  }) {
    return StockMovementEntity(
      id: id ?? this.id,
      article: article ?? this.article,
      stock: stock ?? this.stock,
      movementType: movementType ?? this.movementType,
      reason: reason ?? this.reason,
      quantity: quantity ?? this.quantity,
      unitCost: unitCost ?? this.unitCost,
      referenceDocument: referenceDocument ?? this.referenceDocument,
      notes: notes ?? this.notes,
      stockBefore: stockBefore ?? this.stockBefore,
      stockAfter: stockAfter ?? this.stockAfter,
      movementValue: movementValue ?? this.movementValue,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
    id,
    article,
    stock,
    movementType,
    reason,
    quantity,
    unitCost,
    referenceDocument,
    notes,
    stockBefore,
    stockAfter,
    movementValue,
    createdBy,
    createdAt,
  ];

  @override
  String toString() => 'StockMovementEntity(id: $id, type: ${movementType.label}, '
      'quantity: $quantity, createdAt: $formattedDate)';
}