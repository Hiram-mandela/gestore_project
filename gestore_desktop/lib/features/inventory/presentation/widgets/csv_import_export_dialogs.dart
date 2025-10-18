// ========================================
// lib/features/inventory/presentation/widgets/csv_import_export_dialogs.dart
// Dialogs pour l'import et l'export CSV
// ========================================

import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';

/// Dialog pour l'import CSV
class CSVImportDialog extends StatefulWidget {
  final Function(String filePath) onImport;

  const CSVImportDialog({
    super.key,
    required this.onImport,
  });

  @override
  State<CSVImportDialog> createState() => _CSVImportDialogState();
}

class _CSVImportDialogState extends State<CSVImportDialog> {
  String? _selectedFilePath;
  bool _isLoading = false;

  Future<void> _pickFile() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['csv'],
        dialogTitle: 'Sélectionner un fichier CSV',
      );

      if (result != null && result.files.single.path != null) {
        setState(() {
          _selectedFilePath = result.files.single.path!;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de la sélection du fichier: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.upload_file, color: Colors.blue),
          SizedBox(width: 12),
          Text('Import CSV'),
        ],
      ),
      content: SizedBox(
        width: 500,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Format du fichier CSV attendu:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Text(
                'code,name,description,purchase_price,selling_price,category_id',
                style: TextStyle(
                  fontSize: 12,
                  fontFamily: 'monospace',
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              '• Les colonnes "code" et "name" sont obligatoires\n'
                  '• Si le code existe déjà, l\'article sera mis à jour\n'
                  '• Sinon, un nouvel article sera créé',
              style: TextStyle(fontSize: 13),
            ),
            const SizedBox(height: 24),

            // Sélection de fichier
            InkWell(
              onTap: _isLoading ? null : _pickFile,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blue, width: 2),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.blue.shade50,
                ),
                child: Row(
                  children: [
                    const Icon(Icons.folder_open, color: Colors.blue),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _selectedFilePath ?? 'Cliquez pour sélectionner un fichier CSV',
                        style: TextStyle(
                          color: _selectedFilePath != null
                              ? Colors.black87
                              : Colors.grey.shade600,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Import en cours...',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _selectedFilePath == null || _isLoading
              ? null
              : () async {
            setState(() => _isLoading = true);
            widget.onImport(_selectedFilePath!);
          },
          icon: const Icon(Icons.upload),
          label: const Text('Importer'),
        ),
      ],
    );
  }
}

/// Dialog pour l'export CSV
class CSVExportDialog extends StatefulWidget {
  final Function({
  String? categoryId,
  String? brandId,
  bool? isActive,
  bool? isLowStock,
  }) onExport;

  const CSVExportDialog({
    super.key,
    required this.onExport,
  });

  @override
  State<CSVExportDialog> createState() => _CSVExportDialogState();
}

class _CSVExportDialogState extends State<CSVExportDialog> {
  String? _selectedCategoryId;
  String? _selectedBrandId;
  bool? _isActive;
  bool? _isLowStock;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.download, color: Colors.green),
          SizedBox(width: 12),
          Text('Export CSV'),
        ],
      ),
      content: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtrer les articles à exporter:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),

            // Filtre catégorie
            SwitchListTile(
              title: const Text('Articles actifs uniquement'),
              value: _isActive == true,
              onChanged: (value) {
                setState(() {
                  _isActive = value ? true : null;
                });
              },
            ),

            SwitchListTile(
              title: const Text('Stock bas uniquement'),
              value: _isLowStock == true,
              onChanged: (value) {
                setState(() {
                  _isLowStock = value ? true : null;
                });
              },
            ),

            const SizedBox(height: 8),
            const Text(
              'Le fichier CSV contiendra toutes les informations des articles filtrés.',
              style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
            ),

            if (_isLoading) ...[
              const SizedBox(height: 16),
              const LinearProgressIndicator(),
              const SizedBox(height: 8),
              const Text(
                'Export en cours...',
                style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _isLoading ? null : () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        ElevatedButton.icon(
          onPressed: _isLoading
              ? null
              : () {
            setState(() => _isLoading = true);
            widget.onExport(
              categoryId: _selectedCategoryId,
              brandId: _selectedBrandId,
              isActive: _isActive,
              isLowStock: _isLowStock,
            );
          },
          icon: const Icon(Icons.download),
          label: const Text('Exporter'),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green,
            foregroundColor: Colors.white,
          ),
        ),
      ],
    );
  }
}