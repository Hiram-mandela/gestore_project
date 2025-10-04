// ========================================
// lib/features/inventory/presentation/screens/article_form_screen.dart
// Écran du formulaire article (création/édition) avec 3 étapes
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
      appBar: AppBar(
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
      ),
      body: _buildBody(state),
    );
  }

  // ==================== CONSTRUCTION DU BODY ====================

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

        // Contenu de l'étape actuelle
        Expanded(
          child: _buildStepContent(state),
        ),

        const Divider(height: 1),

        // Boutons de navigation
        _buildNavigationButtons(state),
      ],
    );
  }

  // ==================== STEPPER ====================

  Widget _buildStepper(ArticleFormReady state) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      child: Row(
        children: [
          _buildStepIndicator(
            stepNumber: 1,
            label: 'Informations',
            isActive: state.currentStep == 0,
            isCompleted: state.currentStep > 0,
            onTap: () => _goToStep(0),
          ),
          _buildStepConnector(isCompleted: state.currentStep > 0),
          _buildStepIndicator(
            stepNumber: 2,
            label: 'Prix & Stock',
            isActive: state.currentStep == 1,
            isCompleted: state.currentStep > 1,
            onTap: () => _goToStep(1),
          ),
          _buildStepConnector(isCompleted: state.currentStep > 1),
          _buildStepIndicator(
            stepNumber: 3,
            label: 'Options',
            isActive: state.currentStep == 2,
            isCompleted: false,
            onTap: () => _goToStep(2),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator({
    required int stepNumber,
    required String label,
    required bool isActive,
    required bool isCompleted,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isCompleted
                    ? AppColors.success
                    : isActive
                    ? AppColors.primary
                    : AppColors.textSecondary.withValues(alpha: 0.3),
              ),
              child: Center(
                child: isCompleted
                    ? const Icon(Icons.check, color: Colors.white, size: 20)
                    : Text(
                  '$stepNumber',
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.grey,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? AppColors.primary : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepConnector({required bool isCompleted}) {
    return Expanded(
      child: Container(
        height: 2,
        margin: const EdgeInsets.only(bottom: 32),
        decoration: BoxDecoration(
          color: isCompleted ? AppColors.success : AppColors.textSecondary.withValues(alpha: 0.3),
        ),
      ),
    );
  }

  // ==================== CONTENU DES ÉTAPES ====================

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
      default:
        return const SizedBox();
    }
  }

  // ==================== BOUTONS DE NAVIGATION ====================

  Widget _buildNavigationButtons(ArticleFormReady state) {
    final notifier = ref.read(
      articleFormProvider((widget.mode, widget.articleId)).notifier,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Bouton Précédent
          if (state.currentStep > 0)
            OutlinedButton.icon(
              onPressed: notifier.previousStep,
              icon: const Icon(Icons.arrow_back),
              label: const Text('Précédent'),
            )
          else
            const SizedBox(),

          // Indicateur d'étape
          Text(
            'Étape ${state.currentStep + 1} sur 3',
            style: Theme.of(context).textTheme.bodySmall,
          ),

          // Bouton Suivant ou Enregistrer
          if (state.currentStep < 2)
            FilledButton.icon(
              onPressed: state.errors.isEmpty ? notifier.nextStep : null,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant'),
            )
          else
            FilledButton.icon(
              onPressed: state.errors.isEmpty ? () => _submitForm() : null,
              icon: Icon(
                widget.mode == ArticleFormMode.create
                    ? Icons.add
                    : Icons.save,
              ),
              label: Text(
                widget.mode == ArticleFormMode.create
                    ? 'Créer'
                    : 'Enregistrer',
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
          'Êtes-vous sûr de vouloir annuler ? Toutes les modifications seront perdues.',
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