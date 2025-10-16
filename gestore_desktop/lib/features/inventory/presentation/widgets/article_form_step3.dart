// ========================================
// lib/features/inventory/presentation/widgets/article_form_step3.dart
// ÉTAPE 3 : Gestion de Stock (8 champs)
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Remplacement des Card par des conteneurs de section stylisés (fond, bordure, ombre).
// - Application de la palette GESTORE (AppColors) pour les textes, icônes et fonds.
// - Amélioration de l'en-tête pour une meilleure hiérarchie visuelle.
// - Refonte des bannières d'information avec les couleurs de statut GESTORE (info, warning, error).
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep3 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep3({
    super.key,
    required this.formData,
    required this.errors,
    required this.onFieldChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        // En-tête
        _buildHeader(context),
        const SizedBox(height: 24),

        // Section 1 : Configuration du stock
        _buildStockConfigSection(),
        const SizedBox(height: 24),

        // Section 2 : Niveaux de stock (visible si manageStock = true)
        if (formData.manageStock) ...[
          _buildStockLevelsSection(context),
          const SizedBox(height: 24),
        ],

        // Section 3 : Traçabilité
        _buildTraceabilitySection(),
        const SizedBox(height: 24),

        // Section 4 : Disponibilité
        _buildAvailabilitySection(),
      ],
    );
  }

  // ==================== HEADER ====================
  Widget _buildHeader(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(
            Icons.inventory_2_outlined,
            color: AppColors.primary,
            size: 28,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Gestion de stock',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Configurez le suivi des quantités et les alertes.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== SECTIONS ====================

  Widget _buildStockConfigSection() {
    return _buildSectionContainer(
      title: 'Configuration',
      icon: Icons.settings_outlined,
      child: Column(
        children: [
          CustomSwitchTile(
            title: 'Gérer le stock pour cet article',
            subtitle: formData.manageStock
                ? 'Les mouvements de stock seront suivis'
                : 'Aucun suivi de stock ne sera effectué',
            value: formData.manageStock,
            icon: Icons.inventory_2_outlined,
            onChanged: (value) => onFieldChanged('manageStock', value),
          ),
          if (formData.manageStock) ...[
            const SizedBox(height: 12),
            CustomSwitchTile(
              title: 'Autoriser le stock négatif',
              subtitle: formData.allowNegativeStock
                  ? 'Les ventes seront possibles même si le stock est à zéro'
                  : 'Les ventes seront bloquées si le stock est insuffisant',
              value: formData.allowNegativeStock,
              icon: Icons.remove_circle_outline,
              onChanged: (value) => onFieldChanged('allowNegativeStock', value),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStockLevelsSection(BuildContext context) {
    return _buildSectionContainer(
      title: 'Niveaux de stock et alertes',
      icon: Icons.stacked_line_chart,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomNumberField(
                  label: 'Stock minimum',
                  initialValue: formData.minStockLevel.toDouble(),
                  errorText: errors['minStockLevel'],
                  onChanged: (value) =>
                      onFieldChanged('minStockLevel', value.toInt()),
                  prefixIcon: Icons.arrow_downward,
                  decimals: 0,
                  minValue: 0,
                  helperText: 'Niveau d\'alerte de stock bas',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomNumberField(
                  label: 'Stock maximum',
                  initialValue: formData.maxStockLevel.toDouble(),
                  errorText: errors['maxStockLevel'],
                  onChanged: (value) =>
                      onFieldChanged('maxStockLevel', value.toInt()),
                  prefixIcon: Icons.arrow_upward,
                  decimals: 0,
                  minValue: 0,
                  helperText: 'Niveau de stock idéal',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildStockLevelIndicator(),
        ],
      ),
    );
  }

  Widget _buildTraceabilitySection() {
    return _buildSectionContainer(
      title: 'Traçabilité',
      icon: Icons.track_changes_outlined,
      child: Column(
        children: [
          CustomSwitchTile(
            title: 'Suivi par lot ou numéro de série',
            subtitle: formData.requiresLotTracking
                ? 'Un numéro de lot/série sera requis à chaque mouvement'
                : 'Pas de suivi spécifique par lot ou série',
            value: formData.requiresLotTracking,
            icon: Icons.qr_code_scanner_outlined,
            onChanged: (value) => onFieldChanged('requiresLotTracking', value),
          ),
          const SizedBox(height: 12),
          CustomSwitchTile(
            title: 'Gérer les dates d\'expiration',
            subtitle: formData.requiresExpiryDate
                ? 'Une date d\'expiration sera requise'
                : 'Pas de gestion des dates d\'expiration',
            value: formData.requiresExpiryDate,
            icon: Icons.event_available_outlined,
            onChanged: (value) => onFieldChanged('requiresExpiryDate', value),
          ),
          if (formData.requiresLotTracking || formData.requiresExpiryDate) ...[
            const SizedBox(height: 16),
            _buildInfoBanner(
              message:
              'La traçabilité avancée nécessite des informations supplémentaires lors des entrées et sorties de stock.',
              color: AppColors.warning,
              icon: Icons.warning_amber_rounded,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAvailabilitySection() {
    return _buildSectionContainer(
      title: 'Disponibilité commerciale',
      icon: Icons.shopping_cart_outlined,
      child: Column(
        children: [
          CustomSwitchTile(
            title: 'Article vendable',
            subtitle: formData.isSellable
                ? 'Cet article peut être inclus dans les ventes'
                : 'Cet article est masqué pour la vente',
            value: formData.isSellable,
            icon: Icons.point_of_sale_outlined,
            onChanged: (value) => onFieldChanged('isSellable', value),
          ),
          const SizedBox(height: 12),
          CustomSwitchTile(
            title: 'Article achetable',
            subtitle: formData.isPurchasable
                ? 'Cet article peut être commandé aux fournisseurs'
                : 'Cet article ne peut pas être acheté',
            value: formData.isPurchasable,
            icon: Icons.shopping_bag_outlined,
            onChanged: (value) => onFieldChanged('isPurchasable', value),
          ),
          if (!formData.isSellable && !formData.isPurchasable) ...[
            const SizedBox(height: 16),
            _buildInfoBanner(
              message:
              'Attention : Cet article ne peut ni être vendu, ni être acheté. Il ne sera visible que dans l\'inventaire.',
              color: AppColors.error,
              icon: Icons.block_outlined,
            ),
          ],
        ],
      ),
    );
  }

  // ==================== WIDGETS RÉUTILISABLES ====================

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
        boxShadow: [AppColors.subtleShadow()],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 22, color: AppColors.primary),
              const SizedBox(width: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
    );
  }

  Widget _buildStockLevelIndicator() {
    if (formData.minStockLevel == 0 && formData.maxStockLevel == 0) {
      return const SizedBox.shrink();
    }
    String message;
    if (formData.maxStockLevel > 0) {
      message =
      'Alertes actives : Stock bas < ${formData.minStockLevel}, Stock idéal = ${formData.maxStockLevel}';
    } else {
      message = 'Alerte de stock bas activée à ${formData.minStockLevel} unités.';
    }
    return _buildInfoBanner(
      message: message,
      color: AppColors.info,
      icon: Icons.info_outline_rounded,
    );
  }

  Widget _buildInfoBanner({
    required String message,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: color, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}