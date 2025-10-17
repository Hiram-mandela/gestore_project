// ========================================
// lib/features/inventory/presentation/providers/locations_state.dart
// États pour la gestion des emplacements
// ========================================

import 'package:equatable/equatable.dart';
import '../../domain/entities/location_entity.dart';

/// État de base
abstract class LocationsState extends Equatable {
  const LocationsState();

  @override
  List<Object?> get props => [];
}

/// État initial
class LocationsInitial extends LocationsState {
  const LocationsInitial();
}

/// État de chargement
class LocationsLoading extends LocationsState {
  const LocationsLoading();
}

/// État de succès avec liste d'emplacements
class LocationsLoaded extends LocationsState {
  final List<LocationEntity> locations;
  final String? currentLocationType;
  final String? currentParentId;
  final bool? currentIsActive;

  const LocationsLoaded({
    required this.locations,
    this.currentLocationType,
    this.currentParentId,
    this.currentIsActive,
  });

  @override
  List<Object?> get props => [
    locations,
    currentLocationType,
    currentParentId,
    currentIsActive,
  ];

  /// Nombre total d'emplacements
  int get count => locations.length;

  /// Emplacements actifs
  List<LocationEntity> get activeLocations =>
      locations.where((loc) => loc.isActive).toList();

  /// Emplacements racines (sans parent)
  List<LocationEntity> get rootLocations =>
      locations.where((loc) => loc.isRoot).toList();

  /// Filtre les emplacements par type
  List<LocationEntity> filterByType(String type) {
    return locations
        .where((loc) => loc.locationType.value == type)
        .toList();
  }

  /// Filtre les emplacements par parent
  List<LocationEntity> filterByParent(String? parentId) {
    if (parentId == null) {
      return rootLocations;
    }
    return locations.where((loc) => loc.parentId == parentId).toList();
  }
}

/// État d'erreur
class LocationsError extends LocationsState {
  final String message;

  const LocationsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// État pour un seul emplacement
class LocationDetailLoaded extends LocationsState {
  final LocationEntity location;

  const LocationDetailLoaded({required this.location});

  @override
  List<Object?> get props => [location];
}

/// État de succès pour création/modification
class LocationOperationSuccess extends LocationsState {
  final String message;
  final LocationEntity? location;

  const LocationOperationSuccess({
    required this.message,
    this.location,
  });

  @override
  List<Object?> get props => [message, location];
}