// ========================================
// lib/features/inventory/presentation/screens/article_form_screen.dart
// Écran du formulaire article (création/édition) avec 5 étapes
// VERSION 2.0 - Formulaire Complet
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
            : 'Modifier article',
      ),
      actions: [
        if (state is ArticleFormReady)
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => _confirmCancel(context),
            tooltip: 'Annuler',
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
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Chargement de l\'article...'),
        ],
      ),
    );
  }

  Widget _buildSubmittingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 16),
          Text(
            widget.mode == ArticleFormMode.create
                ? 'Création en cours...'
                : 'Mise à jour en cours...',
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
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: () => context.pop(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Retour'),
                ),
                const SizedBox(width: 16),
                FilledButton.icon(
                  onPressed: () => ref
                      .read(articleFormProvider((widget.mode, widget.articleId)).notifier)
                      .retryAfterError(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
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
      child: CircularProgressIndicator(),
    );
  }

  Widget _buildFormState(ArticleFormReady state) {
    return Column(
      children: [
        // Stepper horizontal
        _buildStepper(state),
        const Divider(height: 1),

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
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
    final color = isCompleted || isActive
        ? AppColors.primary
        : Colors.grey.shade400;

    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              if (step > 0)
                Expanded(
                  child: Container(
                    height: 2,
                    color: isCompleted ? AppColors.primary : Colors.grey.shade300,
                  ),
                ),
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: isActive
                      ? AppColors.primary
                      : isCompleted
                      ? AppColors.primary.withValues(alpha: 0.1)
                      : Colors.grey.shade200,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: color,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: AppColors.primary)
                      : Text(
                    '${step + 1}',
                    style: TextStyle(
                      color: isActive ? Colors.white : color,
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
                    color: isCompleted && step < currentStep
                        ? AppColors.primary
                        : Colors.grey.shade300,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            _getStepLabel(step),
            style: TextStyle(
              fontSize: 11,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive ? AppColors.primary : Colors.grey.shade600,
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
        return const SizedBox();
    }
  }

  // ==================== BOTTOM BAR ====================

  Widget? _buildBottomBar(ArticleFormState state) {
    if (state is! ArticleFormReady) return null;

    final notifier = ref.read(articleFormProvider((widget.mode, widget.articleId)).notifier);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Row(
        children: [
          // Bouton Précédent
          if (!state.isFirstStep)
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => notifier.previousStep(),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Précédent'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
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
                    ? Icons.add
                    : Icons.save,
              ),
              label: Text(
                widget.mode == ArticleFormMode.create
                    ? 'Créer l\'article'
                    : 'Enregistrer',
              ),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            )
                : FilledButton.icon(
              onPressed: () => notifier.nextStep(),
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
          ),
        ],
      ),
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
        title: const Text('Annuler'),
        content: const Text(
          'Êtes-vous sûr de vouloir annuler ? '
              'Toutes les modifications seront perdues.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Non'),
          ),
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.pop();
            },
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
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