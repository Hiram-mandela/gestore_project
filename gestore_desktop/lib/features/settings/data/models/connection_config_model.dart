// ========================================
// lib/features/settings/data/models/connection_config_model.dart
// Model pour la sérialisation de ConnectionConfig
// ========================================

import '../../../../core/network/connection_mode.dart';

/// Extension du ConnectionConfig pour ajouter des méthodes de sérialisation
/// Note: ConnectionConfig existe déjà dans core/network/connection_mode.dart
/// avec toJson() et fromJson(), donc ce fichier sert juste de référence

class ConnectionConfigModel {
  /// Créer depuis JSON (utilise la factory de ConnectionConfig)
  static ConnectionConfig fromJson(Map<String, dynamic> json) {
    return ConnectionConfig.fromJson(json);
  }

  /// Convertir en JSON (utilise la méthode de ConnectionConfig)
  static Map<String, dynamic> toJson(ConnectionConfig config) {
    return config.toJson();
  }

  /// Sérialiser une liste de configurations
  static List<Map<String, dynamic>> listToJson(List<ConnectionConfig> configs) {
    return configs.map((config) => config.toJson()).toList();
  }

  /// Désérialiser une liste de configurations
  static List<ConnectionConfig> listFromJson(List<dynamic> jsonList) {
    return jsonList
        .map((json) => ConnectionConfig.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}