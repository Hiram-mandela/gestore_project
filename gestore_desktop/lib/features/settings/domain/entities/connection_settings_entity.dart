// ========================================
// lib/features/settings/domain/entities/connection_settings_entity.dart
// Entity représentant les paramètres de connexion
// ========================================

import 'package:equatable/equatable.dart';
import '../../../../core/network/connection_mode.dart';

/// Entity représentant les paramètres de connexion actuels
class ConnectionSettingsEntity extends Equatable {
  final ConnectionConfig currentConfig;
  final List<ConnectionConfig> recentConnections;
  final DateTime? lastValidated;
  final bool isValidated;

  const ConnectionSettingsEntity({
    required this.currentConfig,
    this.recentConnections = const [],
    this.lastValidated,
    this.isValidated = false,
  });

  /// Créer une copie avec modifications
  ConnectionSettingsEntity copyWith({
    ConnectionConfig? currentConfig,
    List<ConnectionConfig>? recentConnections,
    DateTime? lastValidated,
    bool? isValidated,
  }) {
    return ConnectionSettingsEntity(
      currentConfig: currentConfig ?? this.currentConfig,
      recentConnections: recentConnections ?? this.recentConnections,
      lastValidated: lastValidated ?? this.lastValidated,
      isValidated: isValidated ?? this.isValidated,
    );
  }

  /// Configuration par défaut (localhost)
  factory ConnectionSettingsEntity.defaultSettings() {
    return ConnectionSettingsEntity(
      currentConfig: ConnectionConfig.localhost(),
    );
  }

  @override
  List<Object?> get props => [
    currentConfig,
    recentConnections,
    lastValidated,
    isValidated,
  ];
}