// ========================================
// lib/features/inventory/presentation/pages/location_form_screen.dart
// Page de formulaire pour créer/modifier un emplacement
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../../domain/entities/location_entity.dart';
import '../providers/locations_provider.dart';
import '../providers/locations_state.dart';

class LocationFormScreen extends ConsumerStatefulWidget {
  final String? locationId; // null pour création, sinon modification

  const LocationFormScreen({super.key, this.locationId});

  @override
  ConsumerState<LocationFormScreen> createState() => _LocationFormScreenState();
}

class _LocationFormScreenState extends ConsumerState<LocationFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;
  LocationEntity? _currentLocation;

  @override
  void initState() {
    super.initState();
    if (widget.locationId != null) {
      _loadLocation();
    }
  }

  Future<void> _loadLocation() async {
    await ref.read(locationsProvider.notifier).loadLocationById(widget.locationId!);

    final state = ref.read(locationsProvider);
    if (state is LocationDetailLoaded) {
      setState(() => _currentLocation = state.location);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isEdit = widget.locationId != null;

    ref.listen<LocationsState>(locationsProvider, (previous, next) {
      if (next is LocationOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        context.pop();
      } else if (next is LocationsError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(isEdit ? 'Modifier l\'emplacement' : 'Nouvel emplacement'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: FormBuilder(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Nom
              FormBuilderTextField(
                name: 'name',
                initialValue: _currentLocation?.name,
                decoration: const InputDecoration(
                  labelText: 'Nom *',
                  hintText: 'Ex: Magasin principal',
                  prefixIcon: Icon(Icons.label),
                ),
                validator: FormBuilderValidators.required(
                  errorText: 'Le nom est obligatoire',
                ),
              ),

              const SizedBox(height: 16),

              // Code
              FormBuilderTextField(
                name: 'code',
                initialValue: _currentLocation?.code,
                decoration: const InputDecoration(
                  labelText: 'Code *',
                  hintText: 'Ex: MAG001',
                  prefixIcon: Icon(Icons.tag),
                ),
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'Le code est obligatoire',
                  ),
                  FormBuilderValidators.match(
                    RegExp(r'^[A-Z0-9_-]+$'),
                    errorText: 'Code invalide (A-Z, 0-9, _, -)',
                  )
                ]),
              ),

              const SizedBox(height: 16),

              // Type d'emplacement
              FormBuilderDropdown<String>(
                name: 'location_type',
                initialValue: _currentLocation?.locationType.value ?? 'store',
                decoration: const InputDecoration(
                  labelText: 'Type d\'emplacement *',
                  prefixIcon: Icon(Icons.category),
                ),
                items: LocationType.values
                    .map((type) => DropdownMenuItem(
                  value: type.value,
                  child: Row(
                    children: [
                      Text(type.icon),
                      const SizedBox(width: 8),
                      Text(type.label),
                    ],
                  ),
                ))
                    .toList(),
                validator: FormBuilderValidators.required(
                  errorText: 'Le type est obligatoire',
                ),
              ),

              const SizedBox(height: 16),

              // Emplacement parent (optionnel)
              FormBuilderDropdown<String?>(
                name: 'parent_id',
                initialValue: _currentLocation?.parentId,
                decoration: const InputDecoration(
                  labelText: 'Emplacement parent',
                  hintText: 'Aucun (racine)',
                  prefixIcon: Icon(Icons.folder),
                ),
                items: [
                  const DropdownMenuItem(
                    value: null,
                    child: Text('Aucun (racine)'),
                  ),
                  // TODO: Charger les emplacements disponibles
                  // Pour l'instant, on laisse vide
                ],
              ),

              const SizedBox(height: 16),

              // Code-barres (optionnel)
              FormBuilderTextField(
                name: 'barcode',
                initialValue: _currentLocation?.barcode,
                decoration: const InputDecoration(
                  labelText: 'Code-barres',
                  hintText: 'Ex: 1234567890123',
                  prefixIcon: Icon(Icons.qr_code),
                ),
              ),

              const SizedBox(height: 16),

              // Description (optionnel)
              FormBuilderTextField(
                name: 'description',
                initialValue: _currentLocation?.description,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  hintText: 'Description de l\'emplacement',
                  prefixIcon: Icon(Icons.description),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 16),

              // Actif
              FormBuilderSwitch(
                name: 'is_active',
                initialValue: _currentLocation?.isActive ?? true,
                title: const Text('Emplacement actif'),
                decoration: const InputDecoration(
                  border: InputBorder.none,
                ),
              ),

              const SizedBox(height: 24),

              // Boutons d'action
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => context.pop(),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: FilledButton(
                      onPressed: _isLoading ? null : _submitForm,
                      child: Text(isEdit ? 'Modifier' : 'Créer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      setState(() => _isLoading = true);

      final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

      try {
        bool success;
        if (widget.locationId != null) {
          // Modification
          success = await ref
              .read(locationsProvider.notifier)
              .updateLocation(widget.locationId!, formData);
        } else {
          // Création
          success = await ref
              .read(locationsProvider.notifier)
              .createLocation(formData);
        }

        if (!success && mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Erreur: $e'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    }
  }
}