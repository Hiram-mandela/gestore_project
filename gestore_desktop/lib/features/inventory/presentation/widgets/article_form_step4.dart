// ========================================
// lib/features/inventory/presentation/widgets/article_form_step4.dart
// ÉTAPE 4 : Prix et Fournisseur
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Remplacement des Card par des conteneurs de section stylisés (fond, bordure, ombre).
// - Application de la palette GESTORE (AppColors) pour les textes, icônes et fonds.
// - Refonte complète du bloc d'analyse de marge avec les couleurs de statut GESTORE.
// - Amélioration des bannières d'information et des boîtes de dialogue.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_state.dart';
import 'form_field_widgets.dart';

class ArticleFormStep4 extends ConsumerWidget {
  final ArticleFormData formData;
  final Map<String, String> errors;
  final Function(String, dynamic) onFieldChanged;

  const ArticleFormStep4({
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

        // Section 1 : Prix
        _buildPricingSection(),
        const SizedBox(height: 24),

        // Section 2 : Calculs et marges
        _buildMarginSection(),
        const SizedBox(height: 24),

        // Section 3 : Fournisseur principal
        _buildSupplierSection(context),
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
            Icons.attach_money,
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
                'Prix et Fournisseur',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Définissez les prix et associez un fournisseur.',
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

  // ==================== SECTION PRIX ====================
  Widget _buildPricingSection() {
    return _buildSectionContainer(
      title: 'Prix',
      icon: Icons.payments_outlined,
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: CustomNumberField(
                  label: 'Prix d\'achat (HT)',
                  initialValue: formData.purchasePrice,
                  errorText: errors['purchasePrice'],
                  onChanged: (value) => onFieldChanged('purchasePrice', value),
                  prefixIcon: Icons.shopping_cart_outlined,
                  required: true,
                  suffix: 'FCFA',
                  helperText: 'Coût d\'achat hors taxes',
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: CustomNumberField(
                  label: 'Prix de vente (TTC)',
                  initialValue: formData.sellingPrice,
                  errorText: errors['sellingPrice'],
                  onChanged: (value) => onFieldChanged('sellingPrice', value),
                  prefixIcon: Icons.sell_outlined,
                  required: true,
                  suffix: 'FCFA',
                  helperText: 'Prix de vente toutes taxes comprises',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Info TVA
          _buildInfoBanner(
            message:
            'Le taux de TVA applicable est défini dans la catégorie de l\'article.',
            color: AppColors.info,
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  // ==================== SECTION MARGE ====================
  Widget _buildMarginSection() {
    final margin = formData.marginPercent;
    final profit = formData.sellingPrice - formData.purchasePrice;

    Color marginColor = AppColors.textTertiary;
    IconData marginIcon = Icons.trending_flat;
    String marginQuality = 'Marge nulle';

    if (margin > 0) {
      if (margin < 20) {
        marginColor = AppColors.warning;
        marginIcon = Icons.trending_down;
        marginQuality = 'Faible';
      } else if (margin < 40) {
        marginColor = AppColors.info;
        marginIcon = Icons.trending_up;
        marginQuality = 'Correcte';
      } else {
        marginColor = AppColors.success;
        marginIcon = Icons.trending_up;
        marginQuality = 'Bonne';
      }
    } else if (margin < 0) {
      marginColor = AppColors.error;
      marginIcon = Icons.trending_down;
      marginQuality = 'Perte';
    }

    return _buildSectionContainer(
      title: 'Analyse de marge',
      icon: Icons.analytics_outlined,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: marginColor.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: marginColor.withValues(alpha: 0.2)),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(marginIcon, color: marginColor, size: 36),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Marge',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        Text(
                          '${margin.toStringAsFixed(1)}%',
                          style: TextStyle(
                            color: marginColor,
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            fontFamily: 'monospace',
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: marginColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    marginQuality,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 24, color: AppColors.border),
            _buildCalculationRow(
                'Profit unitaire', '${profit.toStringAsFixed(0)} FCFA', profit >= 0, profit < 0 ? AppColors.error : AppColors.success),
            const SizedBox(height: 8),
            _buildCalculationRow('Prix d\'achat',
                '${formData.purchasePrice.toStringAsFixed(0)} FCFA', false, AppColors.textPrimary),
            const SizedBox(height: 8),
            _buildCalculationRow('Prix de vente',
                '${formData.sellingPrice.toStringAsFixed(0)} FCFA', true, AppColors.textPrimary),
          ],
        ),
      ),
    );
  }

  Widget _buildCalculationRow(String label, String value, bool isBold, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
            fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
            fontFamily: 'monospace',
            color: valueColor,
          ),
        ),
      ],
    );
  }

  // ==================== SECTION FOURNISSEUR ====================
  Widget _buildSupplierSection(BuildContext context) {
    return _buildSectionContainer(
      title: 'Fournisseur principal',
      icon: Icons.business_center_outlined,
      action: TextButton.icon(
        onPressed: () => _showCreateSupplierDialog(context),
        icon: const Icon(Icons.add, size: 18),
        label: const Text('Créer'),
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        ),
      ),
      child: Column(
        children: [
          CustomTextField(
            label: 'Sélectionner un fournisseur',
            initialValue: formData.mainSupplierId.isNotEmpty
                ? 'ID: ${formData.mainSupplierId.substring(0, 8)}...'
                : 'Aucun fournisseur sélectionné',
            errorText: errors['mainSupplierId'],
            onChanged: (value) => onFieldChanged('mainSupplierId', value),
            prefixIcon: Icons.local_shipping_outlined,
            helperText: 'Le module sera bientôt disponible',
            enabled: false,
          ),
          const SizedBox(height: 16),
          _buildInfoBanner(
            message:
            'Le module Fournisseurs arrive bientôt. Vous pourrez alors lier vos articles et gérer les prix d\'achat spécifiques.',
            color: AppColors.info,
            icon: Icons.info_outline_rounded,
          ),
        ],
      ),
    );
  }

  // ==================== WIDGETS RÉUTILISABLES ====================

  Widget _buildSectionContainer({
    required String title,
    required IconData icon,
    required Widget child,
    Widget? action,
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
              if (action != null) action,
            ],
          ),
          const SizedBox(height: 20),
          child,
        ],
      ),
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
              style: TextStyle(color: color.withValues(alpha: 0.9), fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }


  void _showCreateSupplierDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text(
          'Création rapide de fournisseur',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'Cette fonctionnalité sera disponible avec le module Fournisseurs. Vous pourrez associer cet article à un fournisseur plus tard.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:
            const Text('OK', style: TextStyle(color: AppColors.primary)),
          ),
        ],
      ),
    );
  }
}