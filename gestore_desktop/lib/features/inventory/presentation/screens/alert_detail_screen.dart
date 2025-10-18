// ========================================
// lib/features/inventory/presentation/pages/alert_detail_screen.dart
// Page détail d'une alerte de stock - VERSION COMPLÈTE
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/stock_alert_entity.dart';
import '../providers/stock_alerts_provider.dart';
import '../providers/stock_alerts_state.dart';

class AlertDetailScreen extends ConsumerStatefulWidget {
  final String alertId;

  const AlertDetailScreen({
    super.key,
    required this.alertId,
  });

  @override
  ConsumerState<AlertDetailScreen> createState() => _AlertDetailScreenState();
}

class _AlertDetailScreenState extends ConsumerState<AlertDetailScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(
          () => ref
          .read(stockAlertsProvider.notifier)
          .loadAlertDetail(widget.alertId),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stockAlertsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Détail de l\'alerte'),
        actions: [
          if (state is StockAlertDetailLoaded && !state.alert.isAcknowledged)
            IconButton(
              icon: const Icon(Icons.check_circle),
              tooltip: 'Acquitter',
              onPressed: () => _acknowledgeAlert(state.alert.id),
            ),
        ],
      ),
      body: _buildBody(state, theme),
    );
  }

  Widget _buildBody(StockAlertsState state, ThemeData theme) {
    if (state is StockAlertsLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is StockAlertsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red.shade300),
            const SizedBox(height: 16),
            Text('Erreur', style: theme.textTheme.titleLarge),
            const SizedBox(height: 8),
            Text(state.message, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(stockAlertsProvider.notifier)
                    .loadAlertDetail(widget.alertId);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (state is StockAlertDetailLoaded) {
      return _buildAlertDetail(state.alert, theme);
    }

    return const Center(child: Text('Aucune donnée'));
  }

  Widget _buildAlertDetail(StockAlertEntity alert, ThemeData theme) {
    final levelColor = _getLevelColor(alert.alertLevel);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Carte principale de l'alerte
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: levelColor, width: 3),
            ),
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header avec badges
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: levelColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: levelColor, width: 2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getLevelIcon(alert.alertLevel),
                              color: levelColor,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alert.alertLevel.label.toUpperCase(),
                              style: TextStyle(
                                color: levelColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              _getTypeIcon(alert.alertType),
                              size: 18,
                              color: Colors.grey.shade700,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              alert.alertType.label,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade700,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Message de l'alerte
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: levelColor.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: levelColor.withValues(alpha: 0.2)),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.message, color: levelColor),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            alert.message,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Statut d'acquittement
                  if (alert.isAcknowledged)
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.check_circle,
                              color: Colors.green.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Alerte acquittée',
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.green.shade900,
                                  ),
                                ),
                                if (alert.acknowledgedBy != null) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    'Par ${alert.acknowledgedBy}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                                if (alert.acknowledgedAt != null) ...[
                                  const SizedBox(height: 2),
                                  Text(
                                    'Le ${_formatDateTime(alert.acknowledgedAt!)}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.green.shade700,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.orange.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.pending, color: Colors.orange.shade700),
                          const SizedBox(width: 12),
                          Text(
                            'Alerte en attente d\'acquittement',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Informations temporelles
          _buildInfoSection(
            title: 'Informations temporelles',
            icon: Icons.access_time,
            children: [
              _buildInfoRow(
                'Date de création',
                _formatDateTime(alert.createdAt),
                Icons.calendar_today,
              ),
              _buildInfoRow(
                'Ancienneté',
                _formatDuration(alert.age),
                Icons.schedule,
              ),
              if (alert.isRecent)
                Container(
                  margin: const EdgeInsets.only(top: 8),
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.orange.shade100,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.new_releases,
                          size: 16, color: Colors.orange.shade700),
                      const SizedBox(width: 6),
                      Text(
                        'Alerte récente (moins de 24h)',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Informations article
          if (alert.article != null)
            _buildInfoSection(
              title: 'Article concerné',
              icon: Icons.inventory_2,
              children: [
                _buildInfoRow(
                  'Nom',
                  alert.article!.name,
                  Icons.label,
                ),
                if (alert.article!.code.isNotEmpty)
                  _buildInfoRow(
                    'Code',
                    alert.article!.code,
                    Icons.qr_code,
                  ),
                _buildInfoRow(
                  'Catégorie',
                  alert.article!.categoryName,
                  Icons.category,
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () {
                    context.push('/inventory/articles/${alert.articleId}');
                  },
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Voir l\'article'),
                ),
              ],
            ),

          const SizedBox(height: 16),

          // Informations stock/emplacement
          if (alert.stock != null && alert.stock!.location != null)
            _buildInfoSection(
              title: 'Emplacement',
              icon: Icons.location_on,
              children: [
                _buildInfoRow(
                  'Nom',
                  alert.stock!.location!.name,
                  Icons.warehouse,
                ),
                if (alert.stock!.location!.code.isNotEmpty)
                  _buildInfoRow(
                    'Code',
                    alert.stock!.location!.code,
                    Icons.qr_code_2,
                  ),
                _buildInfoRow(
                  'Quantité disponible',
                  '${alert.stock!.quantityAvailable}',
                  Icons.inventory,
                ),
                if (alert.stock!.lotNumber != null &&
                    alert.stock!.lotNumber!.isNotEmpty)
                  _buildInfoRow(
                    'N° de lot',
                    alert.stock!.lotNumber!,
                    Icons.numbers,
                  ),
                if (alert.stock!.expiryDate != null)
                  _buildInfoRow(
                    'Date d\'expiration',
                    DateFormat('dd/MM/yyyy').format(alert.stock!.expiryDate!),
                    Icons.event,
                  ),
              ],
            ),

          const SizedBox(height: 20),

          // Bouton d'action
          if (!alert.isAcknowledged)
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _acknowledgeAlert(alert.id),
                icon: const Icon(Icons.check_circle),
                label: const Text('Acquitter cette alerte'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildInfoSection({
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 20),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade600),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  Color _getLevelColor(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Colors.red;
      case AlertLevel.warning:
        return Colors.orange;
      case AlertLevel.info:
        return Colors.blue;
    }
  }

  IconData _getLevelIcon(AlertLevel level) {
    switch (level) {
      case AlertLevel.critical:
        return Icons.error;
      case AlertLevel.warning:
        return Icons.warning;
      case AlertLevel.info:
        return Icons.info;
    }
  }

  IconData _getTypeIcon(AlertType type) {
    switch (type) {
      case AlertType.lowStock:
        return Icons.trending_down;
      case AlertType.outOfStock:
        return Icons.remove_shopping_cart;
      case AlertType.expirySoon:
        return Icons.schedule;
      case AlertType.expired:
        return Icons.dangerous;
      case AlertType.overstock:
        return Icons.trending_up;
    }
  }

  String _formatDateTime(DateTime date) {
    return DateFormat('dd/MM/yyyy à HH:mm').format(date);
  }

  String _formatDuration(Duration duration) {
    if (duration.inDays > 0) {
      return '${duration.inDays} jour(s)';
    } else if (duration.inHours > 0) {
      return '${duration.inHours} heure(s)';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute(s)';
    } else {
      return 'Moins d\'une minute';
    }
  }

  Future<void> _acknowledgeAlert(String alertId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Acquitter l\'alerte'),
        content: const Text(
          'Êtes-vous sûr de vouloir acquitter cette alerte ?\n\n'
              'Cette action confirmera que vous avez pris connaissance de l\'alerte '
              'et que les mesures appropriées ont été prises.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Acquitter'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(stockAlertsProvider.notifier).acknowledgeAlert(alertId);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Alerte acquittée avec succès'),
            backgroundColor: Colors.green,
          ),
        );

        // Retour à la liste après 1 seconde
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            context.pop();
          }
        });
      }
    }
  }
}