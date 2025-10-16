// ========================================
// lib/features/sales/presentation/screens/discount_form_screen.dart
// Écran Formulaire Remise Multi-Étapes (Création/Édition) - Module Sales
// VERSION FINALE - DESIGN AMÉLIORÉ ET CONTRASTE CORRIGÉ
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../../shared/constants/app_colors.dart';
import '../providers/discount_form_provider.dart';
import '../providers/discount_form_state.dart';

/// Écran de formulaire multi-étapes pour créer/éditer une remise
class DiscountFormScreen extends ConsumerStatefulWidget {
  final String? discountId;

  const DiscountFormScreen({
    super.key,
    this.discountId,
  });

  @override
  ConsumerState<DiscountFormScreen> createState() => _DiscountFormScreenState();
}

class _DiscountFormScreenState extends ConsumerState<DiscountFormScreen> {
  final _formKey = GlobalKey<FormBuilderState>();
  int _currentStep = 0;
  bool _isEditMode = false;

  // Utilisés pour la logique d'affichage conditionnel dans l'UI
  String? _selectedDiscountType;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.discountId != null;

    if (_isEditMode) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(discountFormProvider.notifier)
            .loadDiscountForEdit(widget.discountId!);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(discountFormProvider);

    ref.listen<DiscountFormState>(discountFormProvider, (previous, next) {
      if (next is DiscountFormSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.success,
          ),
        );
        context.go('/sales/discounts');
      } else if (next is DiscountFormError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.error,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _isEditMode ? 'Modifier une remise' : 'Nouvelle remise',
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        shadowColor: Colors.black.withValues(alpha: 0.1),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => _onBackPressed(),
        ),
      ),
      body: _buildBody(state),
    );
  }

  Widget _buildBody(DiscountFormState state) {
    if (state is DiscountFormLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state is DiscountFormError && _isEditMode) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: AppColors.error),
            const SizedBox(height: 16),
            Text(
              state.message,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: () => context.go('/sales/discounts'),
              icon: const Icon(Icons.arrow_back),
              label: const Text('Retour à la liste'),
            ),
          ],
        ),
      );
    }

    if (_isEditMode && state is! DiscountFormLoadedForEdit) {
      return const Center(child: CircularProgressIndicator());
    }

    return _buildStepper(state);
  }

  Widget _buildStepper(DiscountFormState state) {
    final initialData = _getInitialData(state);

    if (state is DiscountFormLoadedForEdit) {
      _selectedDiscountType = state.discount.discountType;
    }

    // CORRECTION: Thème global pour les champs de formulaire
    // Applique un style avec fond blanc et texte noir/gris foncé.
    final inputDecorationTheme = InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey[300]!),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.warning, width: 2),
      ),
      labelStyle: TextStyle(color: Colors.grey[700]),
      hintStyle: TextStyle(color: Colors.grey[500]),
      prefixIconColor: Colors.grey[600],
    );

    return Theme(
      data: Theme.of(context).copyWith(
        // Applique le thème de décoration
        inputDecorationTheme: inputDecorationTheme,
        // Assure que le texte saisi par l'utilisateur est bien noir
        textTheme: Theme.of(context).textTheme.apply(
          bodyColor: Colors.black87,
          displayColor: Colors.black87,
        ),
      ),
      child: FormBuilder(
        key: _formKey,
        initialValue: initialData,
        child: Column(
          children: [
            _buildStepperHeader(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: _buildStepContent(),
              ),
            ),
            _buildNavigationButtons(state),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getInitialData(DiscountFormState state) {
    if (state is DiscountFormLoadedForEdit) {
      final d = state.discount;
      return {
        'name': d.name,
        'code': d.name.replaceAll(' ', '').toUpperCase(),
        'description': d.description,
        'discount_type': d.discountType,
        'scope': d.scope,
        'percentage_value': d.percentageValue?.toString(),
        'fixed_value': d.fixedValue?.toString(),
        'min_quantity': d.minQuantity?.toString(),
        'min_amount': d.minAmount?.toString(),
        'max_amount': d.maxAmount?.toString(),
        'max_uses': d.maxUses?.toString(),
        'max_uses_per_customer': d.maxUsesPerCustomer?.toString(),
        'is_active': d.isActive,
        'start_date': d.startDate,
        'end_date': d.endDate,
        'target_categories': d.targetCategories ?? [],
        'target_articles': d.targetArticles ?? [],
        'target_customers': d.targetCustomers ?? [],
      };
    }
    return {
      'is_active': true,
      'target_categories': <String>[],
      'target_articles': <String>[],
      'target_customers': <String>[],
    };
  }

  Widget _buildStepperHeader() {
    final steps = [
      'Informations',
      'Valeur',
      'Conditions',
      'Restrictions',
      'Récapitulatif',
    ];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: List.generate(steps.length, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? AppColors.success
                              : isActive
                              ? AppColors.warning
                              : Colors.grey[300],
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: isCompleted
                              ? const Icon(Icons.check,
                              color: Colors.white, size: 20)
                              : Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: isActive
                                  ? Colors.white
                                  : Colors.grey[700],
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        steps[index],
                        style: TextStyle(
                          fontSize: 12,
                          color:
                          isActive ? AppColors.warning : Colors.grey[700],
                          fontWeight:
                          isActive ? FontWeight.bold : FontWeight.normal,
                        ),
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (index < steps.length - 1)
                  Expanded(
                    child: Container(
                      height: 2,
                      color:
                      isCompleted ? AppColors.success : Colors.grey[300],
                      margin: const EdgeInsets.only(bottom: 30),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_currentStep) {
      case 0:
        return _buildStep1BasicInfo();
      case 1:
        return _buildStep2ValueConfig();
      case 2:
        return _buildStep3Conditions();
      case 3:
        return _buildStep4Restrictions();
      case 4:
        return _buildStep5Summary();
      default:
        return const SizedBox.shrink();
    }
  }

  // ========================================
  // ÉTAPES DU FORMULAIRE
  // ========================================

  Widget _buildStep1BasicInfo() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations de base',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'name',
              decoration: const InputDecoration(
                labelText: 'Nom de la remise *',
                hintText: 'Ex: Promotion Été 2025',
                prefixIcon: Icon(Icons.label),
              ),
              validator: FormBuilderValidators.compose([
                FormBuilderValidators.required(errorText: 'Le nom est requis'),
                FormBuilderValidators.minLength(3,
                    errorText: 'Minimum 3 caractères'),
              ]),
              onChanged: (value) {
                _formKey.currentState?.fields['code']
                    ?.didChange(value?.replaceAll(' ', '').toUpperCase() ?? '');
              },
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'description',
              decoration: const InputDecoration(
                labelText: 'Description (optionnel)',
                hintText: 'Description détaillée de la remise',
                prefixIcon: Icon(Icons.description),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'code',
              readOnly: true,
              decoration: InputDecoration(
                labelText: 'Code promo (généré depuis le nom)',
                prefixIcon: const Icon(Icons.qr_code),
                fillColor: Colors.grey[100],
              ),
            ),
            const SizedBox(height: 32),
            const Text(
              'Type de remise *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            FormBuilderField<String>(
              name: 'discount_type',
              validator: FormBuilderValidators.required(
                errorText: 'Le type de remise est requis',
              ),
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildTypeCard(
                            'percentage',
                            'Pourcentage',
                            'Réduction en %',
                            Icons.percent,
                            AppColors.warning,
                            field),
                        _buildTypeCard(
                            'fixed_amount',
                            'Montant fixe',
                            'Réduction en FCFA',
                            Icons.attach_money,
                            AppColors.success,
                            field),
                        _buildTypeCard('buy_x_get_y', 'Achetez X Obtenez Y',
                            'Offre quantitative', Icons.redeem, Colors.purple, field),
                        _buildTypeCard('loyalty_points', 'Points fidélité',
                            'Conversion points', Icons.stars, Colors.amber, field),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          field.errorText!,
                          style:
                          TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
            const SizedBox(height: 32),
            const Text(
              'Portée de la remise *',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            FormBuilderField<String>(
              name: 'scope',
              validator: FormBuilderValidators.required(
                errorText: 'La portée est requise',
              ),
              builder: (field) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _buildScopeCard('sale', 'Vente totale',
                            'Sur tout le montant', Icons.shopping_cart, field),
                        _buildScopeCard('category', 'Catégorie',
                            'Sur une catégorie', Icons.category, field),
                        _buildScopeCard('article', 'Article', 'Sur un article',
                            Icons.inventory_2, field),
                        _buildScopeCard('customer', 'Client', 'Pour un client',
                            Icons.person, field),
                      ],
                    ),
                    if (field.hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          field.errorText!,
                          style:
                          TextStyle(color: AppColors.error, fontSize: 12),
                        ),
                      ),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep2ValueConfig() {
    final discountType = _formKey.currentState?.value['discount_type'] ?? _selectedDiscountType;
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Configuration de la valeur',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 24),
            if (discountType == null)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning, color: AppColors.warning),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Text(
                        'Veuillez d\'abord sélectionner un type de remise à l\'étape 1.',
                        style: TextStyle(fontSize: 14),
                      ),
                    ),
                  ],
                ),
              )
            else ...[
              if (discountType == 'percentage') ...[
                FormBuilderTextField(
                  name: 'percentage_value',
                  decoration: const InputDecoration(
                    labelText: 'Pourcentage de réduction *',
                    hintText: 'Ex: 10',
                    prefixIcon: Icon(Icons.percent),
                    suffixText: '%',
                  ),
                  keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
                  inputFormatters: [
                    FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                  ],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'Le pourcentage est requis'),
                    FormBuilderValidators.min(0.01, errorText: 'Minimum 0.01%'),
                    FormBuilderValidators.max(100, errorText: 'Maximum 100%'),
                  ]),
                ),
              ] else if (discountType == 'fixed_amount') ...[
                FormBuilderTextField(
                  name: 'fixed_value',
                  decoration: const InputDecoration(
                    labelText: 'Montant de réduction *',
                    hintText: 'Ex: 5000',
                    prefixIcon: Icon(Icons.attach_money),
                    suffixText: 'FCFA',
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: FormBuilderValidators.compose([
                    FormBuilderValidators.required(
                        errorText: 'Le montant est requis'),
                    FormBuilderValidators.min(1, errorText: 'Minimum 1 FCFA'),
                  ]),
                ),
              ] else if (discountType == 'buy_x_get_y') ...[
                const Text(
                  'Configuration "Achetez X Obtenez Y"',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  'Ce type de remise est principalement géré par les conditions (ex: quantité minimum) et le ciblage d\'articles spécifiques. Aucune valeur monétaire n\'est à définir ici.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ] else if (discountType == 'loyalty_points') ...[
                const Text(
                  'Configuration "Points fidélité"',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87),
                ),
                const SizedBox(height: 16),
                Text(
                  'La conversion des points en montant de réduction est gérée automatiquement par le système lors du paiement. Aucune valeur n\'est à définir ici.',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
              const SizedBox(height: 24),
              FormBuilderTextField(
                name: 'max_amount',
                decoration: const InputDecoration(
                  labelText: 'Montant maximum de remise (optionnel)',
                  hintText: 'Ex: 50000',
                  prefixIcon: Icon(Icons.account_balance_wallet),
                  suffixText: 'FCFA',
                  helperText: 'Limite le montant de la remise appliquée, même pour un pourcentage.',
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: FormBuilderValidators.integer(errorText: 'Veuillez entrer un nombre valide'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStep3Conditions() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Conditions d\'application',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Définissez les critères qui doivent être remplis pour que la remise s\'applique.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'min_amount',
              decoration: const InputDecoration(
                labelText: 'Montant minimum d\'achat (optionnel)',
                hintText: 'Ex: 20000',
                prefixIcon: Icon(Icons.shopping_cart_checkout),
                suffixText: 'FCFA',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: FormBuilderValidators.integer(errorText: 'Veuillez entrer un nombre valide'),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'min_quantity',
              decoration: const InputDecoration(
                labelText: 'Quantité minimum d\'articles (optionnel)',
                hintText: 'Ex: 3',
                prefixIcon: Icon(Icons.production_quantity_limits),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: FormBuilderValidators.integer(errorText: 'Veuillez entrer un nombre valide'),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: 'start_date',
                    inputType: InputType.date,
                    format: DateFormat('dd/MM/yyyy'),
                    decoration: const InputDecoration(
                      labelText: 'Date de début (optionnel)',
                      prefixIcon: Icon(Icons.event_available),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: FormBuilderDateTimePicker(
                    name: 'end_date',
                    inputType: InputType.date,
                    format: DateFormat('dd/MM/yyyy'),
                    decoration: const InputDecoration(
                      labelText: 'Date de fin (optionnel)',
                      prefixIcon: Icon(Icons.event_busy),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep4Restrictions() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Restrictions et Ciblage',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 8),
            Text(
              'Limitez qui peut utiliser la remise et sur quels produits elle s\'applique.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            FormBuilderTextField(
              name: 'max_uses',
              decoration: const InputDecoration(
                labelText: 'Utilisations totales maximum (optionnel)',
                hintText: 'Ex: 100',
                prefixIcon: Icon(Icons.repeat),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: FormBuilderValidators.integer(errorText: 'Veuillez entrer un nombre valide'),
            ),
            const SizedBox(height: 20),
            FormBuilderTextField(
              name: 'max_uses_per_customer',
              decoration: const InputDecoration(
                labelText: 'Utilisations max par client (optionnel)',
                hintText: 'Ex: 1',
                prefixIcon: Icon(Icons.repeat_one),
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              validator: FormBuilderValidators.integer(errorText: 'Veuillez entrer un nombre valide'),
            ),
            const SizedBox(height: 32),
            _buildTargetSelector('target_categories', 'Catégories Cibles',
                'Ajouter une catégorie'),
            const SizedBox(height: 20),
            _buildTargetSelector(
                'target_articles', 'Articles Cibles', 'Ajouter un article'),
            const SizedBox(height: 20),
            _buildTargetSelector(
                'target_customers', 'Clients Cibles', 'Ajouter un client'),
          ],
        ),
      ),
    );
  }

  Widget _buildStep5Summary() {
    _formKey.currentState?.save();
    final formData = _formKey.currentState?.value ?? {};
    final dateFormat = DateFormat('dd/MM/yyyy');

    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Récapitulatif',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black87),
            ),
            const SizedBox(height: 16),
            _buildSummaryTile('Nom', formData['name']),
            _buildSummaryTile('Code', formData['code']),
            _buildSummaryTile('Type', formData['discount_type']),
            _buildSummaryTile('Portée', formData['scope']),
            if (formData['percentage_value'] != null && formData['percentage_value'].isNotEmpty)
              _buildSummaryTile('Pourcentage', '${formData['percentage_value']}%'),
            if (formData['fixed_value'] != null && formData['fixed_value'].isNotEmpty)
              _buildSummaryTile('Montant fixe', '${formData['fixed_value']} FCFA'),
            const Divider(height: 32),
            _buildSummaryTile('Montant d\'achat minimum', formData['min_amount'] ?? 'Aucun'),
            _buildSummaryTile('Quantité d\'articles min.', formData['min_quantity'] ?? 'Aucune'),
            _buildSummaryTile('Date de début', formData['start_date'] != null ? dateFormat.format(formData['start_date']) : 'Aucune'),
            _buildSummaryTile('Date de fin', formData['end_date'] != null ? dateFormat.format(formData['end_date']) : 'Aucune'),
            const Divider(height: 32),
            _buildSummaryTile('Utilisations totales max', formData['max_uses'] ?? 'Illimité'),
            _buildSummaryTile('Utilisations max par client', formData['max_uses_per_customer'] ?? 'Illimité'),
            _buildSummaryTile('Statut', (formData['is_active'] ?? true) ? 'Actif' : 'Inactif'),
          ],
        ),
      ),
    );
  }

  // ========================================
  // WIDGETS HELPERS
  // ========================================

  Widget _buildTypeCard(String value, String title, String subtitle, IconData icon, Color color, FormFieldState<String> field) {
    final isSelected = field.value == value;
    return InkWell(
      onTap: () {
        field.didChange(value);
        setState(() => _selectedDiscountType = value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? color : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? color : Colors.grey[600], size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? color : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScopeCard(String value, String title, String subtitle, IconData icon, FormFieldState<String> field) {
    final isSelected = field.value == value;
    const activeColor = AppColors.warning;
    return InkWell(
      onTap: () {
        field.didChange(value);
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: 180,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? activeColor.withValues(alpha: 0.1) : Colors.white,
          border: Border.all(
            color: isSelected ? activeColor : Colors.grey[300]!,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: isSelected ? activeColor : Colors.grey[600], size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isSelected ? activeColor : Colors.black87,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetSelector(String name, String title, String buttonLabel) {
    return FormBuilderField<List<String>>(
      name: name,
      builder: (field) {
        final items = field.value ?? [];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black87)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (items.isEmpty)
                    Text('Aucun élément ciblé pour le moment.', style: TextStyle(color: Colors.grey[600]))
                  else
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: items.map((id) => Chip(
                        label: Text('ID: $id'),
                        onDeleted: () {
                          final newList = List<String>.from(items)..remove(id);
                          field.didChange(newList);
                        },
                      )).toList(),
                    ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    icon: const Icon(Icons.add, size: 18),
                    label: Text(buttonLabel),
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('La sélection d\'éléments n\'est pas encore implémentée.'),
                      ));
                    },
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryTile(String title, dynamic value) {
    final displayValue = (value is String && value.isEmpty) ? 'N/A' : (value?.toString() ?? 'N/A');
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(color: Colors.grey[700], fontSize: 14)),
          Text(
            displayValue,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.black87),
          ),
        ],
      ),
    );
  }

  // ========================================
  // LOGIQUE DE NAVIGATION ET SOUMISSION
  // ========================================

  Widget _buildNavigationButtons(DiscountFormState state) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            OutlinedButton.icon(
              onPressed: () {
                setState(() => _currentStep--);
              },
              icon: const Icon(Icons.arrow_back),
              label: const Text('Précédent'),
            ),
          const Spacer(),
          if (_currentStep < 4)
            FilledButton.icon(
              onPressed: _onNextStep,
              icon: const Icon(Icons.arrow_forward),
              label: const Text('Suivant'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.warning,
              ),
            )
          else
            FilledButton.icon(
              onPressed: state is DiscountFormSubmitting ? null : _onSubmit,
              icon: state is DiscountFormSubmitting
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    strokeWidth: 2, color: Colors.white),
              )
                  : const Icon(Icons.check),
              label: Text(_isEditMode ? 'Modifier' : 'Créer'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.success,
              ),
            ),
        ],
      ),
    );
  }

  void _onNextStep() {
    if (!_validateCurrentStep()) return;
    setState(() => _currentStep++);
  }

  bool _validateCurrentStep() {
    final form = _formKey.currentState;
    if (form == null) return false;
    form.save();

    List<String> fieldsToValidate = [];
    if (_currentStep == 0) {
      fieldsToValidate = ['name', 'discount_type', 'scope'];
    } else if (_currentStep == 1) {
      final discountType = form.value['discount_type'];
      if (discountType == 'percentage') {
        fieldsToValidate = ['percentage_value'];
      } else if (discountType == 'fixed_amount') {
        fieldsToValidate = ['fixed_value'];
      }
    }

    bool isValid = true;
    for (var fieldName in fieldsToValidate) {
      final field = form.fields[fieldName];
      if (field != null && !field.validate()) {
        isValid = false;
      }
    }
    return isValid;
  }

  void _onSubmit() {
    if (!_formKey.currentState!.saveAndValidate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez corriger les erreurs du formulaire.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }
    final formData = Map<String, dynamic>.from(_formKey.currentState!.value);

    final cleanData = Map<String, dynamic>.from(formData);
    cleanData.removeWhere((key, value) => value == null || (value is String && value.isEmpty));

    if (cleanData['start_date'] is DateTime) {
      cleanData['start_date'] = (cleanData['start_date'] as DateTime).toIso8601String();
    }
    if (cleanData['end_date'] is DateTime) {
      cleanData['end_date'] = (cleanData['end_date'] as DateTime).toIso8601String();
    }

    if (_isEditMode) {
      ref
          .read(discountFormProvider.notifier)
          .updateDiscount(widget.discountId!, cleanData);
    } else {
      ref.read(discountFormProvider.notifier).createDiscount(cleanData);
    }
  }

  void _onBackPressed() {
    if (_currentStep > 0) {
      setState(() => _currentStep--);
    } else {
      context.go('/sales/discounts');
    }
  }
}