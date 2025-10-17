// ========================================
// lib/features/inventory/presentation/providers/locations_provider.dart
// Provider pour la gestion des emplacements
// ========================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logger/logger.dart';
import '../../../../config/dependencies.dart';
import '../../domain/usecases/location_usecases.dart';
import 'locations_state.dart';

/// Provider pour l'état des emplacements
final locationsProvider =
StateNotifierProvider<LocationsNotifier, LocationsState>((ref) {
  return LocationsNotifier(
    getLocationsUseCase: getIt<GetLocationsUseCase>(),
    getLocationByIdUseCase: getIt<GetLocationByIdUseCase>(),
    createLocationUseCase: getIt<CreateLocationUseCase>(),
    updateLocationUseCase: getIt<UpdateLocationUseCase>(),
    deleteLocationUseCase: getIt<DeleteLocationUseCase>(),
    logger: getIt<Logger>(),
  );
});

/// Notifier pour gérer l'état des emplacements
class LocationsNotifier extends StateNotifier<LocationsState> {
  final GetLocationsUseCase getLocationsUseCase;
  final GetLocationByIdUseCase getLocationByIdUseCase;
  final CreateLocationUseCase createLocationUseCase;
  final UpdateLocationUseCase updateLocationUseCase;
  final DeleteLocationUseCase deleteLocationUseCase;
  final Logger logger;

  LocationsNotifier({
    required this.getLocationsUseCase,
    required this.getLocationByIdUseCase,
    required this.createLocationUseCase,
    required this.updateLocationUseCase,
    required this.deleteLocationUseCase,
    required this.logger,
  }) : super(const LocationsInitial());

  /// Charge tous les emplacements avec filtres optionnels
  Future<void> loadLocations({
    bool? isActive,
    String? locationType,
    String? parentId,
  }) async {
    logger.i('🏪 Chargement emplacements...');
    state = const LocationsLoading();

    try {
      final (locations, error) = await getLocationsUseCase(
        isActive: isActive,
        locationType: locationType,
        parentId: parentId,
      );

      if (error != null) {
        logger.e('❌ Erreur chargement emplacements: $error');
        state = LocationsError(message: error);
        return;
      }

      if (locations != null) {
        logger.i('✅ Emplacements chargés: ${locations.length}');
        state = LocationsLoaded(
          locations: locations,
          currentLocationType: locationType,
          currentParentId: parentId,
          currentIsActive: isActive,
        );
      }
    } catch (e) {
      logger.e('❌ Exception chargement emplacements: $e');
      state = const LocationsError(message: 'Une erreur est survenue');
    }
  }

  /// Charge un emplacement par son ID
  Future<void> loadLocationById(String id) async {
    logger.i('🏪 Chargement emplacement $id...');
    state = const LocationsLoading();

    try {
      final (location, error) = await getLocationByIdUseCase(id);

      if (error != null) {
        logger.e('❌ Erreur chargement emplacement: $error');
        state = LocationsError(message: error);
        return;
      }

      if (location != null) {
        logger.i('✅ Emplacement ${location.name} chargé');
        state = LocationDetailLoaded(location: location);
      }
    } catch (e) {
      logger.e('❌ Exception chargement emplacement: $e');
      state = const LocationsError(message: 'Une erreur est survenue');
    }
  }

  /// Crée un nouvel emplacement
  Future<bool> createLocation(Map<String, dynamic> data) async {
    logger.i('🏪 Création emplacement...');

    try {
      final (location, error) = await createLocationUseCase(data);

      if (error != null) {
        logger.e('❌ Erreur création emplacement: $error');
        state = LocationsError(message: error);
        return false;
      }

      if (location != null) {
        logger.i('✅ Emplacement "${location.name}" créé');
        state = LocationOperationSuccess(
          message: 'Emplacement créé avec succès',
          location: location,
        );

        // Recharger la liste
        await loadLocations();
        return true;
      }

      return false;
    } catch (e) {
      logger.e('❌ Exception création emplacement: $e');
      state = const LocationsError(message: 'Une erreur est survenue');
      return false;
    }
  }

  /// Met à jour un emplacement existant
  Future<bool> updateLocation(String id, Map<String, dynamic> data) async {
    logger.i('🏪 Mise à jour emplacement $id...');

    try {
      final (location, error) = await updateLocationUseCase(id, data);

      if (error != null) {
        logger.e('❌ Erreur mise à jour emplacement: $error');
        state = LocationsError(message: error);
        return false;
      }

      if (location != null) {
        logger.i('✅ Emplacement "${location.name}" mis à jour');
        state = LocationOperationSuccess(
          message: 'Emplacement mis à jour avec succès',
          location: location,
        );

        // Recharger la liste
        await loadLocations();
        return true;
      }

      return false;
    } catch (e) {
      logger.e('❌ Exception mise à jour emplacement: $e');
      state = const LocationsError(message: 'Une erreur est survenue');
      return false;
    }
  }

  /// Supprime un emplacement
  Future<bool> deleteLocation(String id) async {
    logger.i('🏪 Suppression emplacement $id...');

    try {
      final (_, error) = await deleteLocationUseCase(id);

      if (error != null) {
        logger.e('❌ Erreur suppression emplacement: $error');
        state = LocationsError(message: error);
        return false;
      }

      logger.i('✅ Emplacement supprimé');
      state = const LocationOperationSuccess(
        message: 'Emplacement supprimé avec succès',
      );

      // Recharger la liste
      await loadLocations();
      return true;
    } catch (e) {
      logger.e('❌ Exception suppression emplacement: $e');
      state = const LocationsError(message: 'Une erreur est survenue');
      return false;
    }
  }

  /// Réinitialise l'état
  void reset() {
    state = const LocationsInitial();
  }
}