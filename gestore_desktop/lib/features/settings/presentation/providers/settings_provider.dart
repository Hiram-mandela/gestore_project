// ========================================
// lib/features/settings/presentation/providers/settings_provider.dart
// Providers Riverpod pour Settings
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../config/dependencies.dart';
import '../../../../core/network/connection_mode.dart';
import '../../../../core/usecases/usecase.dart';
import '../../domain/entities/connection_settings_entity.dart';
import '../../domain/usecases/get_connection_config_usecase.dart';
import '../../domain/usecases/get_connection_history_usecase.dart';
import '../../domain/usecases/save_connection_config_usecase.dart';
import '../../domain/usecases/validate_connection_usecase.dart';

// ==================== STATE CLASSES ====================

/// État de validation de connexion
class ConnectionValidationState {
  final bool isValidating;
  final ConnectionValidationResult? result;
  final String? errorMessage;

  const ConnectionValidationState({
    this.isValidating = false,
    this.result,
    this.errorMessage,
  });

  ConnectionValidationState copyWith({
    bool? isValidating,
    ConnectionValidationResult? result,
    String? errorMessage,
  }) {
    return ConnectionValidationState(
      isValidating: isValidating ?? this.isValidating,
      result: result,
      errorMessage: errorMessage,
    );
  }
}

// ==================== PROVIDERS ====================

/// Provider pour les paramètres de connexion actuels
final connectionSettingsProvider =
FutureProvider<ConnectionSettingsEntity>((ref) async {
  final useCase = getIt<GetConnectionConfigUseCase>();
  final result = await useCase(NoParams());

  // Vérifier directement left/right au lieu d'utiliser fold
  if (result.left != null) {
    // En cas d'erreur, retourner les paramètres par défaut
    return ConnectionSettingsEntity.defaultSettings();
  }

  return result.right ?? ConnectionSettingsEntity.defaultSettings();
});

/// Provider pour l'historique des connexions
final connectionHistoryProvider =
FutureProvider<List<ConnectionConfig>>((ref) async {
  final useCase = getIt<GetConnectionHistoryUseCase>();
  final result = await useCase(NoParams());

  // Vérifier directement left/right au lieu d'utiliser fold
  if (result.left != null) {
    return <ConnectionConfig>[];
  }

  return result.right ?? <ConnectionConfig>[];
});

/// Provider pour la configuration actuelle
final currentConnectionConfigProvider = Provider<ConnectionConfig>((ref) {
  final settingsAsync = ref.watch(connectionSettingsProvider);

  return settingsAsync.when(
    data: (settings) => settings.currentConfig,
    loading: () => ConnectionConfig.localhost(),
    error: (_, __) => ConnectionConfig.localhost(),
  );
});

/// Provider pour le mode de connexion actuel
final currentConnectionModeProvider = Provider<ConnectionMode>((ref) {
  final config = ref.watch(currentConnectionConfigProvider);
  return config.mode;
});

/// Provider pour l'état de validation
final connectionValidationStateProvider =
StateProvider<ConnectionValidationState>((ref) {
  return const ConnectionValidationState();
});

// ==================== CONTROLLER ====================

/// Controller pour gérer les actions Settings
class SettingsController {
  final Ref ref;

  SettingsController(this.ref);

  /// Sauvegarder et appliquer une configuration
  Future<bool> saveAndApplyConfig(ConnectionConfig config) async {
    try {
      final useCase = getIt<SaveConnectionConfigUseCase>();
      final result = await useCase(SaveConnectionParams(
        config: config,
        applyImmediately: true,
      ));

      // Vérifier directement left/right
      if (result.left != null) {
        // Erreur
        return false;
      }

      // Succès - Invalider les providers pour rafraîchir
      ref.invalidate(connectionSettingsProvider);
      ref.invalidate(connectionHistoryProvider);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Valider une connexion
  Future<ConnectionValidationResult?> validateConnection(
      ConnectionConfig config,
      ) async {
    try {
      // Marquer comme en cours de validation
      ref.read(connectionValidationStateProvider.notifier).state =
      const ConnectionValidationState(isValidating: true);

      final useCase = getIt<ValidateConnectionUseCase>();
      final result = await useCase(ValidateConnectionParams(config: config));

      // Vérifier directement left/right
      if (result.left != null) {
        // Erreur
        ref.read(connectionValidationStateProvider.notifier).state =
            ConnectionValidationState(
              isValidating: false,
              errorMessage: result.left!.message,
            );
        return null;
      }

      // Succès
      final validationResult = result.right;
      ref.read(connectionValidationStateProvider.notifier).state =
          ConnectionValidationState(
            isValidating: false,
            result: validationResult,
          );
      return validationResult;
    } catch (e) {
      ref.read(connectionValidationStateProvider.notifier).state =
          ConnectionValidationState(
            isValidating: false,
            errorMessage: 'Erreur lors de la validation: $e',
          );
      return null;
    }
  }

  /// Réinitialiser l'état de validation
  void resetValidationState() {
    ref.read(connectionValidationStateProvider.notifier).state =
    const ConnectionValidationState();
  }

  /// Sélectionner une configuration depuis l'historique
  Future<bool> selectFromHistory(ConnectionConfig config) async {
    return await saveAndApplyConfig(config);
  }
}

/// Provider pour le controller
final settingsControllerProvider = Provider<SettingsController>((ref) {
  return SettingsController(ref);
});