// ========================================
// lib/features/inventory/presentation/pages/stock_transfer_page.dart
// Page de transfert de stock entre emplacements
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import '../providers/stocks_provider.dart';
import '../providers/stocks_state.dart';
import '../widgets/location_selector_dialog.dart';
import '../../domain/entities/article_entity.dart';
import '../../domain/entities/location_entity.dart';

class StockTransferScreen extends ConsumerStatefulWidget {
  const StockTransferScreen({super.key});

  @override
  ConsumerState<StockTransferScreen> createState() => _StockTransferScreenState();
}

class _StockTransferScreenState extends ConsumerState<StockTransferScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _isLoading = false;

  ArticleEntity? _selectedArticle;
  LocationEntity? _fromLocation;
  LocationEntity? _toLocation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    ref.listen<StocksState>(stocksProvider, (previous, next) {
      if (next is StockOperationSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(next.message)),
        );
        context.pop();
      } else if (next is StocksError) {
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
        title: const Text('Transfert de stock'),
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
              // Information
              Card(
                color: theme.colorScheme.primaryContainer,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: theme.colorScheme.onPrimaryContainer,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Transférez du stock d\'un emplacement vers un autre',
                          style: TextStyle(
                            color: theme.colorScheme.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sélection article
              Card(
                child: ListTile(
                  leading: const Icon(Icons.inventory_2),
                  title: Text(
                    _selectedArticle?.name ?? 'Sélectionner un article',
                  ),
                  subtitle: _selectedArticle != null
                      ? Text('Code: ${_selectedArticle!.code}')
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectArticle,
                ),
              ),

              const SizedBox(height: 24),

              // Emplacement source
              Text(
                'De l\'emplacement',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: _fromLocation != null ? 2 : 1,
                color: _fromLocation != null
                    ? theme.colorScheme.secondaryContainer
                    : null,
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: _fromLocation != null
                        ? theme.colorScheme.onSecondaryContainer
                        : null,
                  ),
                  title: Text(
                    _fromLocation?.name ?? 'Sélectionner l\'emplacement source',
                    style: _fromLocation != null
                        ? TextStyle(
                      color: theme.colorScheme.onSecondaryContainer,
                      fontWeight: FontWeight.bold,
                    )
                        : null,
                  ),
                  subtitle: _fromLocation != null
                      ? Text(
                    _fromLocation!.fullPath,
                    style: TextStyle(
                      color: theme.colorScheme.onSecondaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectFromLocation,
                ),
              ),

              const SizedBox(height: 16),

              // Icône de transfert
              Center(
                child: Icon(
                  Icons.arrow_downward,
                  size: 32,
                  color: theme.colorScheme.primary,
                ),
              ),

              const SizedBox(height: 16),

              // Emplacement destination
              Text(
                'Vers l\'emplacement',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Card(
                elevation: _toLocation != null ? 2 : 1,
                color: _toLocation != null
                    ? theme.colorScheme.tertiaryContainer
                    : null,
                child: ListTile(
                  leading: Icon(
                    Icons.location_on,
                    color: _toLocation != null
                        ? theme.colorScheme.onTertiaryContainer
                        : null,
                  ),
                  title: Text(
                    _toLocation?.name ?? 'Sélectionner l\'emplacement cible',
                    style: _toLocation != null
                        ? TextStyle(
                      color: theme.colorScheme.onTertiaryContainer,
                      fontWeight: FontWeight.bold,
                    )
                        : null,
                  ),
                  subtitle: _toLocation != null
                      ? Text(
                    _toLocation!.fullPath,
                    style: TextStyle(
                      color: theme.colorScheme.onTertiaryContainer
                          .withValues(alpha: 0.7),
                    ),
                  )
                      : null,
                  trailing: const Icon(Icons.chevron_right),
                  onTap: _selectToLocation,
                ),
              ),

              const SizedBox(height: 24),

              // Quantité à transférer
              FormBuilderTextField(
                name: 'quantity',
                decoration: const InputDecoration(
                  labelText: 'Quantité à transférer *',
                  hintText: 'Ex: 50',
                  prefixIcon: Icon(Icons.numbers),
                ),
                keyboardType: TextInputType.number,
                validator: FormBuilderValidators.compose([
                  FormBuilderValidators.required(
                    errorText: 'La quantité est obligatoire',
                  ),
                  FormBuilderValidators.numeric(
                    errorText: 'Valeur numérique invalide',
                  ),
                  FormBuilderValidators.min(
                    0.01,
                    errorText: 'La quantité doit être positive',
                  ),
                ]),
              ),

              const SizedBox(height: 16),

              // Document de référence
              FormBuilderTextField(
                name: 'reference_document',
                decoration: const InputDecoration(
                  labelText: 'Document de référence',
                  hintText: 'Ex: TR-2025-001',
                  prefixIcon: Icon(Icons.description),
                ),
              ),

              const SizedBox(height: 16),

              // Notes
              FormBuilderTextField(
                name: 'notes',
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  hintText: 'Notes optionnelles sur le transfert',
                  prefixIcon: Icon(Icons.notes),
                ),
                maxLines: 3,
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
                    child: FilledButton.icon(
                      onPressed: _isLoading ? null : _submitForm,
                      icon: const Icon(Icons.swap_horiz),
                      label: const Text('Transférer'),
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

  Future<void> _selectArticle() async {
    // TODO: Implémenter un sélecteur d'articles
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sélecteur d\'articles (à implémenter)'),
      ),
    );
  }

  Future<void> _selectFromLocation() async {
    final location = await showDialog<LocationEntity>(
      context: context,
      builder: (context) => LocationSelectorDialog(
        excludeId: _toLocation?.id,
        onlyActive: true,
      ),
    );

    if (location != null && mounted) {
      setState(() {
        _fromLocation = location;
      });
    }
  }

  Future<void> _selectToLocation() async {
    final location = await showDialog<LocationEntity>(
      context: context,
      builder: (context) => LocationSelectorDialog(
        excludeId: _fromLocation?.id,
        onlyActive: true,
      ),
    );

    if (location != null && mounted) {
      setState(() {
        _toLocation = location;
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      // Validations
      if (_selectedArticle == null) {
        _showError('Veuillez sélectionner un article');
        return;
      }

      if (_fromLocation == null) {
        _showError('Veuillez sélectionner l\'emplacement source');
        return;
      }

      if (_toLocation == null) {
        _showError('Veuillez sélectionner l\'emplacement cible');
        return;
      }

      if (_fromLocation!.id == _toLocation!.id) {
        _showError('Les emplacements source et cible doivent être différents');
        return;
      }

      setState(() => _isLoading = true);

      final formData = _formKey.currentState!.value;

      try {
        final success = await ref.read(stocksProvider.notifier).transferStock(
          articleId: _selectedArticle!.id,
          fromLocationId: _fromLocation!.id,
          toLocationId: _toLocation!.id,
          quantity: double.parse(formData['quantity']),
          referenceDocument: formData['reference_document'],
          notes: formData['notes'],
        );

        if (!success && mounted) {
          setState(() => _isLoading = false);
        }
      } catch (e) {
        if (mounted) {
          setState(() => _isLoading = false);
          _showError('Erreur: $e');
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
      ),
    );
  }
}