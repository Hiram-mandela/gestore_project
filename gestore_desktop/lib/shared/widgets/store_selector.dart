// ========================================
// lib/shared/widgets/store_selector.dart
// Widget de sélection de magasin (multi-magasins)
// Date: 23 Octobre 2025
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/authentication/domain/entities/store_info_entity.dart';
import '../../features/authentication/presentation/providers/auth_provider.dart';
import '../constants/app_colors.dart';

/// Widget de sélection de magasin
/// - Pour les employés : Affiche le magasin assigné (non cliquable)
/// - Pour les admins : Dropdown pour changer de magasin
class StoreSelector extends ConsumerStatefulWidget {
  /// Désactive la sélection (utile pendant une transaction POS)
  final bool isDisabled;

  /// Affiche une version compacte (sans texte "Magasin:")
  final bool compact;

  const StoreSelector({
    super.key,
    this.isDisabled = false,
    this.compact = false,
  });

  @override
  ConsumerState<StoreSelector> createState() => _StoreSelectorState();
}

class _StoreSelectorState extends ConsumerState<StoreSelector> {
  bool _isChanging = false;

  @override
  Widget build(BuildContext context) {
    final currentStore = ref.watch(currentStoreProvider);
    final isAdmin = ref.watch(isMultiStoreAdminProvider);
    final availableStores = ref.watch(availableStoresProvider);

    // Aucun magasin (cas rare)
    if (currentStore == null) {
      return _buildNoStore();
    }

    // Employé : Affichage simple (non cliquable)
    if (!isAdmin) {
      return _buildEmployeeView(currentStore);
    }

    // Admin avec un seul magasin : Affichage simple
    if (availableStores.length <= 1) {
      return _buildEmployeeView(currentStore);
    }

    // Admin avec plusieurs magasins : Dropdown
    return _buildAdminDropdown(
      currentStore: currentStore,
      availableStores: availableStores,
    );
  }

  /// Affichage quand aucun magasin n'est disponible
  Widget _buildNoStore() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 18),
          const SizedBox(width: 8),
          Text(
            'Aucun magasin',
            style: TextStyle(
              fontSize: 13,
              color: Colors.orange[900],
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  /// Affichage pour employé (non cliquable)
  Widget _buildEmployeeView(StoreInfoEntity store) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store_outlined,
            color: AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          if (!widget.compact) ...[
            Text(
              'Magasin: ',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey[600],
              ),
            ),
          ],
          Text(
            store.name,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              store.code,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Dropdown pour admin multi-magasins
  Widget _buildAdminDropdown({
    required StoreInfoEntity currentStore,
    required List<StoreInfoEntity> availableStores,
  }) {
    final isDisabled = widget.isDisabled || _isChanging;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      decoration: BoxDecoration(
        color: isDisabled
            ? Colors.grey[100]
            : AppColors.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isDisabled
              ? Colors.grey[300]!
              : AppColors.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(width: 8),
          Icon(
            Icons.store_outlined,
            color: isDisabled ? Colors.grey[500] : AppColors.primary,
            size: 18,
          ),
          const SizedBox(width: 8),
          if (!widget.compact) ...[
            Text(
              'Magasin: ',
              style: TextStyle(
                fontSize: 13,
                color: isDisabled ? Colors.grey[500] : Colors.grey[600],
              ),
            ),
          ],
          if (_isChanging)
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: AppColors.primary,
              ),
            )
          else
            DropdownButton<String>(
              value: currentStore.id,
              isDense: true,
              underline: const SizedBox(),
              icon: Icon(
                Icons.arrow_drop_down,
                color: isDisabled ? Colors.grey[500] : AppColors.primary,
              ),
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isDisabled ? Colors.grey[500] : AppColors.primary,
              ),
              dropdownColor: Colors.white,
              borderRadius: BorderRadius.circular(8),
              onChanged: isDisabled ? null : _handleStoreChange,
              items: availableStores.map((store) {
                final isSelected = store.id == currentStore.id;
                return DropdownMenuItem<String>(
                  value: store.id,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected)
                        const Icon(
                          Icons.check,
                          size: 16,
                          color: AppColors.primary,
                        ),
                      if (isSelected) const SizedBox(width: 6),
                      Text(
                        store.name,
                        style: TextStyle(
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                          color: isSelected ? AppColors.primary : Colors.grey[800],
                        ),
                      ),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? AppColors.primary.withValues(alpha: 0.15)
                              : Colors.grey[200],
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          store.code,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: isSelected ? AppColors.primary : Colors.grey[600],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  /// Gestion du changement de magasin
  Future<void> _handleStoreChange(String? newStoreId) async {
    if (newStoreId == null || _isChanging) return;

    final currentStore = ref.read(currentStoreProvider);
    if (currentStore?.id == newStoreId) return;

    setState(() => _isChanging = true);

    try {
      // Changer le magasin via le AuthNotifier
      await ref.read(authProvider.notifier).selectStore(newStoreId);

      if (mounted) {
        // Afficher un message de succès
        final newStore = ref
            .read(availableStoresProvider)
            .firstWhere((s) => s.id == newStoreId);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Magasin changé : ${newStore.name}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Afficher un message d'erreur
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error_outline, color: Colors.white),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Erreur lors du changement de magasin',
                    style: TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.red[600],
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChanging = false);
      }
    }
  }
}