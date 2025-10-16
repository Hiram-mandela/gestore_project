// ========================================
// lib/features/sales/presentation/screens/customer_form_screen.dart
// Formulaire Création/Édition Client - Module Sales
// VERSION AMÉLIORÉE - DESIGN REFACTORING
//
// Changements stylistiques majeurs :
// - Intégration de la palette GESTORE pour les couleurs et le contraste.
// - Modernisation des champs de formulaire avec un style unifié et un focus clair.
// - Amélioration du design des cartes et des sélecteurs pour une meilleure lisibilité.
// - Harmonisation des boutons d'action et des dialogues avec la charte graphique.
// ========================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../shared/constants/app_colors.dart';
import '../providers/customer_form_provider.dart';
import '../providers/customer_form_state.dart';

/// Écran de formulaire client (création/édition)
class CustomerFormScreen extends ConsumerStatefulWidget {
  final String? customerId;

  const CustomerFormScreen({
    super.key,
    this.customerId,
  });

  @override
  ConsumerState<CustomerFormScreen> createState() => _CustomerFormScreenState();
}

class _CustomerFormScreenState extends ConsumerState<CustomerFormScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _companyNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _taxNumberController = TextEditingController();
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _isEditing = widget.customerId != null;

    // Charger le client si édition
    if (_isEditing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(customerFormProvider.notifier)
            .loadCustomer(widget.customerId!);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _companyNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _taxNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(customerFormProvider);

    // Écouter les changements d'état
    ref.listen<CustomerFormState>(customerFormProvider, (previous, next) {
      if (next is CustomerFormLoaded && previous is! CustomerFormLoaded) {
        _populateForm(next);
      } else if (next is CustomerFormSuccess) {
        _showSuccessDialog(next.message);
      } else if (next is CustomerFormError) {
        _showErrorSnackBar(next.message);
      }
    });

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        _isEditing ? 'Modifier le client' : 'Nouveau client',
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: AppColors.surfaceLight,
      foregroundColor: AppColors.textPrimary,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1.0),
        child: Container(
          color: AppColors.border,
          height: 1.0,
        ),
      ),
    );
  }

  /// Corps selon l'état
  Widget _buildBody(CustomerFormState state) {
    if (state is CustomerFormLoading) {
      return const Center(child: CircularProgressIndicator(color: AppColors.primary));
    }
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Sélection type de client
            _buildCustomerTypeSection(state),
            const SizedBox(height: 24),
            // Informations générales
            _buildGeneralInfoSection(state),
            const SizedBox(height: 24),
            // Informations de contact
            _buildContactSection(state),
            const SizedBox(height: 24),
            // Adresse
            _buildAddressSection(state),
            const SizedBox(height: 24),
            // Préférences
            _buildPreferencesSection(state),
            const SizedBox(height: 32),
            // Boutons d'action
            _buildActionButtons(state),
          ],
        ),
      ),
    );
  }

  // Style de décoration réutilisable pour les champs de texte
  InputDecoration _inputDecoration({
    required String labelText,
    String? hintText,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: labelText,
      hintText: hintText,
      labelStyle: const TextStyle(color: AppColors.textSecondary),
      hintStyle: const TextStyle(color: AppColors.textTertiary),
      prefixIcon: Icon(icon, color: AppColors.textSecondary),
      filled: true,
      fillColor: AppColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.primary, width: 2),
      ),
    );
  }

  /// Widget de carte de section
  Widget _buildSectionCard({required String title, required List<Widget> children}) {
    return Card(
      elevation: 0,
      color: AppColors.surfaceLight,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            ...children,
          ],
        ),
      ),
    );
  }

  /// Section type de client
  Widget _buildCustomerTypeSection(CustomerFormState state) {
    final customerType = state is CustomerFormLoaded
        ? state.formData.customerType
        : 'individual';

    return _buildSectionCard(
      title: 'Type de client',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildTypeRadio(
                value: 'individual',
                groupValue: customerType,
                icon: Icons.person,
                label: 'Particulier',
                description: 'Client individuel',
                onChanged: (value) {
                  ref.read(customerFormProvider.notifier).updateCustomerType(value!);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeRadio(
                value: 'company',
                groupValue: customerType,
                icon: Icons.business,
                label: 'Entreprise',
                description: 'Client société',
                onChanged: (value) {
                  ref.read(customerFormProvider.notifier).updateCustomerType(value!);
                  setState(() {});
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _buildTypeRadio(
                value: 'professional',
                groupValue: customerType,
                icon: Icons.work,
                label: 'Professionnel',
                description: 'Client pro',
                onChanged: (value) {
                  ref.read(customerFormProvider.notifier).updateCustomerType(value!);
                  setState(() {});
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Radio button pour type de client
  Widget _buildTypeRadio({
    required String value,
    required String groupValue,
    required IconData icon,
    required String label,
    required String description,
    required ValueChanged<String?> onChanged,
  }) {
    final isSelected = value == groupValue;
    return InkWell(
      onTap: () => onChanged(value),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.backgroundLight,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : AppColors.textSecondary,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: const TextStyle(
                fontSize: 11,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Section informations générales
  Widget _buildGeneralInfoSection(CustomerFormState state) {
    final customerType = state is CustomerFormLoaded
        ? state.formData.customerType
        : 'individual';

    return _buildSectionCard(
      title: 'Informations générales',
      children: [
        TextFormField(
          controller: _nameController,
          decoration: _inputDecoration(
            labelText: 'Nom interne *',
            hintText: 'Ex: Client fidèle - Jean',
            icon: Icons.badge,
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Le nom interne est requis';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),
        if (customerType == 'company') ...[
          TextFormField(
            controller: _companyNameController,
            decoration: _inputDecoration(
              labelText: 'Nom de l\'entreprise *',
              hintText: 'Raison sociale',
              icon: Icons.business,
            ),
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Le nom de l\'entreprise est requis';
              }
              return null;
            },
          ),
        ] else ...[
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _firstNameController,
                  decoration: _inputDecoration(
                    labelText: 'Prénom',
                    icon: Icons.person_outline,
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextFormField(
                  controller: _lastNameController,
                  decoration: _inputDecoration(
                    labelText: 'Nom de famille',
                    icon: Icons.person,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 16),
        TextFormField(
          controller: _descriptionController,
          decoration: _inputDecoration(
            labelText: 'Description',
            hintText: 'Notes et informations sur le client',
            icon: Icons.description,
          ),
          maxLines: 3,
        ),
        if (customerType == 'company') ...[
          const SizedBox(height: 16),
          TextFormField(
            controller: _taxNumberController,
            decoration: _inputDecoration(
              labelText: 'Numéro fiscal / TVA',
              hintText: 'Ex: CI-12345678',
              icon: Icons.receipt_long,
            ),
          ),
        ],
      ],
    );
  }

  /// Section contact
  Widget _buildContactSection(CustomerFormState state) {
    return _buildSectionCard(
      title: 'Contact',
      children: [
        TextFormField(
          controller: _phoneController,
          decoration: _inputDecoration(
            labelText: 'Téléphone',
            hintText: '+225 XX XX XX XX XX',
            icon: Icons.phone,
          ),
          keyboardType: TextInputType.phone,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(15),
          ],
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailController,
          decoration: _inputDecoration(
            labelText: 'Email',
            hintText: 'client@example.com',
            icon: Icons.email,
          ),
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.contains('@') || !value.contains('.')) {
                return 'Email invalide';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  /// Section adresse
  Widget _buildAddressSection(CustomerFormState state) {
    return _buildSectionCard(
      title: 'Adresse',
      children: [
        TextFormField(
          controller: _addressController,
          decoration: _inputDecoration(
            labelText: 'Adresse',
            hintText: 'Rue, quartier, ville',
            icon: Icons.location_on,
          ),
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              flex: 2,
              child: TextFormField(
                controller: _cityController,
                decoration: _inputDecoration(
                  labelText: 'Ville',
                  hintText: 'Ex: Abidjan',
                  icon: Icons.location_city,
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _postalCodeController,
                decoration: _inputDecoration(
                  labelText: 'Code postal',
                  hintText: '00225',
                  icon: Icons.markunread_mailbox,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Section préférences
  Widget _buildPreferencesSection(CustomerFormState state) {
    final marketingConsent = state is CustomerFormLoaded
        ? state.formData.marketingConsent
        : false;
    final isActive = state is CustomerFormLoaded
        ? state.formData.isActive
        : true;

    return _buildSectionCard(
      title: 'Préférences',
      children: [
        SwitchListTile(
          value: marketingConsent,
          onChanged: (value) {
            ref.read(customerFormProvider.notifier).updateMarketingConsent(value);
          },
          title: const Text(
            'Accepte les communications marketing',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: const Text(
            'Email, SMS, notifications',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.primary,
        ),
        const Divider(color: AppColors.border),
        SwitchListTile(
          value: isActive,
          onChanged: (value) {
            ref.read(customerFormProvider.notifier).updateActiveStatus(value);
          },
          title: const Text(
            'Client actif',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          subtitle: const Text(
            'Peut effectuer des achats et se connecter',
            style: TextStyle(color: AppColors.textSecondary),
          ),
          contentPadding: EdgeInsets.zero,
          activeThumbColor: AppColors.success,
        ),
      ],
    );
  }

  /// Boutons d'action
  Widget _buildActionButtons(CustomerFormState state) {
    final isSubmitting = state is CustomerFormSubmitting;
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textSecondary,
              side: const BorderSide(color: AppColors.border),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Annuler', style: TextStyle(fontSize: 16)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: isSubmitting ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: isSubmitting
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              _isEditing ? 'Enregistrer les modifications' : 'Créer le client',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ),
      ],
    );
  }

  /// Remplir le formulaire avec les données du client
  void _populateForm(CustomerFormLoaded state) {
    _nameController.text = state.formData.name;
    _descriptionController.text = state.formData.description ?? '';
    _firstNameController.text = state.formData.firstName ?? '';
    _lastNameController.text = state.formData.lastName ?? '';
    _companyNameController.text = state.formData.companyName ?? '';
    _emailController.text = state.formData.email ?? '';
    _phoneController.text = state.formData.phone ?? '';
    _addressController.text = state.formData.address ?? '';
    _cityController.text = state.formData.city ?? '';
    _postalCodeController.text = state.formData.postalCode ?? '';
    _taxNumberController.text = state.formData.taxNumber ?? '';
  }

  /// Soumettre le formulaire
  void _handleSubmit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final formData = _collectFormData();
    if (_isEditing) {
      ref
          .read(customerFormProvider.notifier)
          .updateCustomer(widget.customerId!, formData);
    } else {
      ref.read(customerFormProvider.notifier).createCustomer(formData);
    }
  }

  /// Collecter les données du formulaire
  Map<String, dynamic> _collectFormData() {
    final state = ref.read(customerFormProvider);
    final customerType = state is CustomerFormLoaded
        ? state.formData.customerType
        : 'individual';
    return {
      'name': _nameController.text.trim(),
      'description': _descriptionController.text.trim().isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      'customer_type': customerType,
      'first_name': _firstNameController.text.trim().isNotEmpty
          ? _firstNameController.text.trim()
          : null,
      'last_name': _lastNameController.text.trim().isNotEmpty
          ? _lastNameController.text.trim()
          : null,
      'company_name': _companyNameController.text.trim().isNotEmpty
          ? _companyNameController.text.trim()
          : null,
      'email': _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : null,
      'phone': _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      'address': _addressController.text.trim().isNotEmpty
          ? _addressController.text.trim()
          : null,
      'city': _cityController.text.trim().isNotEmpty
          ? _cityController.text.trim()
          : null,
      'postal_code': _postalCodeController.text.trim().isNotEmpty
          ? _postalCodeController.text.trim()
          : null,
      'tax_number': _taxNumberController.text.trim().isNotEmpty
          ? _taxNumberController.text.trim()
          : null,
      'marketing_consent': state is CustomerFormLoaded
          ? state.formData.marketingConsent
          : false,
      'is_active': state is CustomerFormLoaded
          ? state.formData.isActive
          : true,
    };
  }

  /// Afficher le dialogue de succès
  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: AppColors.success,
          size: 48,
        ),
        title: const Text('Succès'),
        content: Text(message),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(context);
              context.pop(); // Retour à la liste
            },
            style: FilledButton.styleFrom(backgroundColor: AppColors.success),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  /// Afficher un message d'erreur
  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}