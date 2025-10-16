// ========================================
// lib/features/inventory/presentation/screens/article_form_screen.dart
// Écran du formulaire article (création/édition) avec 5 étapes
// VERSION 2.1 - Refonte visuelle GESTORE
// --
// Changements majeurs :
// - Palette de couleurs GESTORE intégrée (AppColors).
// - Fond d'écran et AppBar stylisés pour une meilleure hiérarchie.
// - Stepper visuel amélioré avec des indicateurs clairs et lisibles.
// - Boutons et barre de navigation modernisés avec des styles cohérents.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../shared/constants/app_colors.dart';
import '../providers/article_form_provider.dart';
import '../providers/article_form_state.dart';
import '../widgets/article_form_step1.dart';
import '../widgets/article_form_step2.dart';
import '../widgets/article_form_step3.dart';
import '../widgets/article_form_step4.dart';
import '../widgets/article_form_step5.dart';

class ArticleFormScreen extends ConsumerStatefulWidget {
  final ArticleFormMode mode;
  final String? articleId;

  const ArticleFormScreen({
    super.key,
    required this.mode,
    this.articleId,
  });

  @override
  ConsumerState<ArticleFormScreen> createState() => _ArticleFormScreenState();
}

class _ArticleFormScreenState extends ConsumerState<ArticleFormScreen> {
  @override
  Widget build(BuildContext context) {
    final state = ref.watch(articleFormProvider((widget.mode, widget.articleId)));

    // Écouter les changements d'état pour la navigation
    ref.listen<ArticleFormState>(
      articleFormProvider((widget.mode, widget.articleId)),
          (previous, next) {
        if (next is ArticleFormSuccess) {
          _showSuccessAndNavigate(next);
        } else if (next is ArticleFormError) {
          _showError(next.message);
        }
      },
    );

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(state),
      body: _buildBody(state),
      bottomNavigationBar: _buildBottomBar(state),
    );
  }

  // ==================== APP BAR ====================
  PreferredSizeWidget _buildAppBar(ArticleFormState state) {
    return AppBar(
      title: Text(
        widget.mode == ArticleFormMode.create
            ? 'Nouvel article'
            : 'Modifier l\'article',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      elevation: 0,
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      surfaceTintColor: Colors.transparent,
      actions: [
        if (state is ArticleFormReady)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmCancel(context),
            tooltip: 'Annuler',
            color: AppColors.textSecondary,
          ),
      ],
    );
  }

  // ==================== BODY ====================
  Widget _buildBody(ArticleFormState state) {
    if (state is ArticleFormLoading) {
      return _buildLoadingState();
    } else if (state is ArticleFormReady) {
      return _buildFormState(state);
    } else if (state is ArticleFormSubmitting) {
      return _buildSubmittingState();
    } else if (state is ArticleFormError) {
      return _buildErrorState(state);
    }
    return _buildInitialState();
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(color: AppColors.primary),
          SizedBox(height: 16),
          Text(
            'Chargement de l\'article...',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: AppColors.primary),
          const SizedBox(height: 16),
          Text(
            widget.mode == ArticleFormMode.create
                ? 'Création en cours...'
                : 'Mise à jour en cours...',
            style: const TextStyle(color: AppColors.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(ArticleFormError state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Une erreur est survenue',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                  style: _getOutlinedButtonStyle(),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(articleFormProvider((widget.mode, widget.articleId))
                      .notifier)
                      .retryAfterError(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                  style: _getFilledButtonStyle(color: AppColors.primary),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInitialState() {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }

  Widget _buildFormState(ArticleFormReady state) {
    return Column(
      children: [
        // Stepper horizontal
        _buildStepper(state),
        const Divider(height: 1, color: AppColors.border),
        // Contenu de l'étape
        Expanded(
          child: _buildStepContent(state),
        ),
      ],
    );
  }

  // ==================== STEPPER ====================
  Widget _buildStepper(ArticleFormReady state) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      color: AppColors.surfaceLight,
      child: Row(
        children: List.generate(
          5,
              (index) => Expanded(
            child: _buildStepIndicator(
              step: index,
              currentStep: state.currentStep,
              isCompleted: index < state.currentStep,
              onTap: () => _goToStep(index),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepIndicator({
    required int step,
    required int currentStep,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    final isActive = step == currentStep;
    final color = isCompleted || isActive ? AppColors.primary : AppColors.border;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (step > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : AppColors.border,
                  ),
                ),
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : isCompleted
                      ? AppColors.surfaceLight
                      : AppColors.backgroundLight,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 20, color: AppColors.primary)
                      : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive
                          ? Colors.white
                          : AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              if (step < 4)
                Expanded(
                  child: Container(
                    height: 2,
                    color:
                    isCompleted && step < currentStep ? AppColors.primary : AppColors.border,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepLabel(step),
            style: TextStyle(
              fontSize: 12,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  String _getStepLabel(int step) {
    switch (step) {
      case 0:
        return 'Infos de base';
      case 1:
        return 'Classification';
      case 2:
        return 'Stock';
      case 3:
        return 'Prix';
      case 4:
        return 'Avancé';
      default:
        return '';
    }
  }

  // ==================== STEP CONTENT ====================
  Widget _buildStepContent(ArticleFormReady state) {
    // Le padding est géré dans chaque widget d'étape pour plus de flexibilité
    switch (state.currentStep) {
      case 0:
        return ArticleFormStep1(
          formData: state.formData,
          errors: state.errors,
          onFieldChanged: _updateField,
        );
      case 1:
        return ArticleFormStep2(
          formData: state.formData,
          errors: state.errors,
          onFieldChanged: _updateField,
        );
      case 2:
        return ArticleFormStep3(
          formData: state.formData,
          errors: state.errors,
          onFieldChanged: _updateField,
        );
      case 3:
        return ArticleFormStep4(
          formData: state.formData,
          errors: state.errors,
          onFieldChanged: _updateField,
        );
      case 4:
        return ArticleFormStep5(
          formData: state.formData,
          errors: state.errors,
          onFieldChanged: _updateField,
        );
      default:
        return const SizedBox.shrink();
    }
  }

  // ==================== BOTTOM BAR ====================
  Widget? _buildBottomBar(ArticleFormState state) {
    if (state is! ArticleFormReady) return null;
    final notifier =
    ref.read(articleFormProvider((widget.mode, widget.articleId)).notifier);

    return Container(
      padding: const EdgeInsets.all(16.0).copyWith(
          bottom: MediaQuery.of(context).padding.bottom + 16.0),
      decoration: BoxDecoration(
        color: AppColors.surfaceLight,
        boxShadow: [AppColors.subtleShadow()],
        border: const Border(
          top: BorderSide(color: AppColors.border, width: 1.0),
        ),
      ),
      child: Row(
        children: [
          // Bouton Précédent
          if (!state.isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: notifier.previousStep,
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: _getOutlinedButtonStyle(),
              ),
            ),
          if (!state.isFirstStep) const SizedBox(width: 16),
          // Bouton Suivant ou Enregistrer
          Expanded(
            child: state.isLastStep
                ? FilledButton.icon(
              onPressed: state.errors.isEmpty ? _submitForm : null,
              icon: Icon(
                widget.mode == ArticleFormMode.create
                    ? Icons.add_circle_outline
                    : Icons.save,
              ),
              label: Text(
                widget.mode == ArticleFormMode.create
                    ? 'Créer l\'article'
                    : 'Enregistrer',
              ),
              style: _getFilledButtonStyle(),
            )
                : FilledButton.icon(
              onPressed: notifier.nextStep,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant'),
              style: _getFilledButtonStyle(),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== STYLES ====================
  ButtonStyle _getFilledButtonStyle({Color? color}) {
    return FilledButton.styleFrom(
      backgroundColor: color ?? AppColors.primary,
      foregroundColor: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  ButtonStyle _getOutlinedButtonStyle() {
    return OutlinedButton.styleFrom(
      foregroundColor: AppColors.textSecondary,
      side: const BorderSide(color: AppColors.border),
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(fontWeight: FontWeight.bold),
    );
  }

  // ==================== ACTIONS ====================
  void _updateField(String field, dynamic value) {
    ref
        .read(articleFormProvider((widget.mode, widget.articleId)).notifier)
        .updateField(field, value);
  }

  void _goToStep(int step) {
    ref
        .read(articleFormProvider((widget.mode, widget.articleId)).notifier)
        .goToStep(step);
  }

  void _submitForm() {
    ref
        .read(articleFormProvider((widget.mode, widget.articleId)).notifier)
        .submit();
  }

  void _confirmCancel(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceLight,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Annuler les modifications ?', style: TextStyle(color: AppColors.textPrimary)),
        content: const Text(
          'Toutes les modifications non enregistrées seront perdues. Êtes-vous sûr ?',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Rester', style: TextStyle(color: AppColors.textSecondary)),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: _getFilledButtonStyle(color: AppColors.error),
            child: const Text('Oui, annuler'),
          ),
        ],
      ),
    );
  }

  void _showSuccessAndNavigate(ArticleFormSuccess state) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(state.message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
    // Retourner à la liste ou au détail
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        if (widget.mode == ArticleFormMode.create) {
          // Rediriger vers le détail du nouvel article
          context.go('/inventory/article/${state.article.id}');
        } else {
          // Retourner au détail
          context.pop();
        }
      }
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}