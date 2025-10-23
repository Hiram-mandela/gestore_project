// ========================================
// features/authentication/presentation/providers/auth_state.dart
// VERSION MISE À JOUR - Support multi-magasins
// Date: 23 Octobre 2025
// ========================================
import 'package:equatable/equatable.dart';
import '../../domain/entities/user_entity.dart';
import '../../domain/entities/store_info_entity.dart';

/// États d'authentification
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

/// État initial
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// État de chargement
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// État authentifié avec succès
/// 🔴 VERSION MULTI-MAGASINS: Ajout currentStore, isMultiStoreAdmin, availableStores
class AuthAuthenticated extends AuthState {
  final UserEntity user;

  // 🔴 NOUVEAUX CHAMPS MULTI-MAGASINS
  /// Magasin actuellement sélectionné (pour affichage et filtrage)
  /// - Pour un employé: son magasin assigné (verrouillé)
  /// - Pour un admin: le magasin sélectionné (changeable)
  final StoreInfoEntity? currentStore;

  /// Indique si l'utilisateur est un admin multi-magasins
  final bool isMultiStoreAdmin;

  /// Liste des magasins accessibles par l'utilisateur
  final List<StoreInfoEntity> availableStores;

  const AuthAuthenticated({
    required this.user,
    this.currentStore,
    this.isMultiStoreAdmin = false,
    this.availableStores = const [],
  });

  @override
  List<Object?> get props => [user, currentStore, isMultiStoreAdmin, availableStores];

  /// Crée une copie avec des champs modifiés
  /// Utilisé notamment pour changer le magasin sélectionné
  AuthAuthenticated copyWith({
    UserEntity? user,
    StoreInfoEntity? currentStore,
    bool? isMultiStoreAdmin,
    List<StoreInfoEntity>? availableStores,
  }) {
    return AuthAuthenticated(
      user: user ?? this.user,
      currentStore: currentStore ?? this.currentStore,
      isMultiStoreAdmin: isMultiStoreAdmin ?? this.isMultiStoreAdmin,
      availableStores: availableStores ?? this.availableStores,
    );
  }

  /// Getter helper pour vérifier si l'utilisateur peut changer de magasin
  bool get canSwitchStore => isMultiStoreAdmin && availableStores.length > 1;

  /// Getter helper pour le nom du magasin à afficher
  String get storeDisplayName {
    if (currentStore != null) {
      return currentStore!.name;
    }
    if (isMultiStoreAdmin) {
      return 'Tous les magasins';
    }
    return 'Aucun magasin';
  }
}

/// État non authentifié
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// État d'erreur
class AuthError extends AuthState {
  final String message;
  final Map<String, List<String>>? fieldErrors;

  const AuthError({
    required this.message,
    this.fieldErrors,
  });

  @override
  List<Object?> get props => [message, fieldErrors];
}