// ========================================
// lib/features/sales/presentation/screens/customer_form_screen.dart
// Formulaire Création/Édition Client - Module Sales
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
      backgroundColor: Colors.grey[50],
      appBar: _buildAppBar(),
      body: _buildBody(state),
    );
  }

  /// AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(_isEditing ? 'Modifier le client' : 'Nouveau client'),
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => context.pop(),
      ),
    );
  }

  /// Corps selon l'état
  Widget _buildBody(CustomerFormState state) {
    if (state is CustomerFormLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
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

  /// Section type de client
  Widget _buildCustomerTypeSection(CustomerFormState state) {
    final customerType = state is CustomerFormLoaded
        ? state.formData.customerType
        : 'individual';

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Type de client',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
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
                      ref.read(customerFormProvider.notifier)
                          .updateCustomerType(value!);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeRadio(
                    value: 'company',
                    groupValue: customerType,
                    icon: Icons.business,
                    label: 'Entreprise',
                    description: 'Client société',
                    onChanged: (value) {
                      ref.read(customerFormProvider.notifier)
                          .updateCustomerType(value!);
                      setState(() {});
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildTypeRadio(
                    value: 'professional',
                    groupValue: customerType,
                    icon: Icons.work,
                    label: 'Professionnel',
                    description: 'Client pro',
                    onChanged: (value) {
                      ref.read(customerFormProvider.notifier)
                          .updateCustomerType(value!);
                      setState(() {});
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withValues(alpha: 0.1)
              : Colors.grey[100],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 32,
              color: isSelected ? AppColors.primary : Colors.grey[600],
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.primary : Colors.grey[700],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Informations générales',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Nom (champ requis)
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nom *',
                hintText: 'Nom interne du client',
                prefixIcon: const Icon(Icons.badge),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              validator: (value) {
                if (value == null || value
                    .trim()
                    .isEmpty) {
                  return 'Le nom est requis';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // Selon le type
            if (customerType == 'company') ...[
              // Nom de l'entreprise
              TextFormField(
                controller: _companyNameController,
                decoration: InputDecoration(
                  labelText: 'Nom de l\'entreprise *',
                  hintText: 'Raison sociale',
                  prefixIcon: const Icon(Icons.business),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                validator: (value) {
                  if (value == null || value
                      .trim()
                      .isEmpty) {
                    return 'Le nom de l\'entreprise est requis';
                  }
                  return null;
                },
              ),
            ] else
              ...[
                // Prénom et nom
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _firstNameController,
                        decoration: InputDecoration(
                          labelText: 'Prénom',
                          hintText: 'Prénom du client',
                          prefixIcon: const Icon(Icons.person_outline),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _lastNameController,
                        decoration: InputDecoration(
                          labelText: 'Nom',
                          hintText: 'Nom de famille',
                          prefixIcon: const Icon(Icons.person),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          filled: true,
                          fillColor: Colors.grey[50],
                        ),
                      ),
                    ),
                  ],
                ),
              ],

            const SizedBox(height: 16),

            // Description
            TextFormField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Description',
                hintText: 'Notes sur le client',
                prefixIcon: const Icon(Icons.description),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 3,
            ),

            if (customerType == 'company') ...[
              const SizedBox(height: 16),
              // Numéro fiscal
              TextFormField(
                controller: _taxNumberController,
                decoration: InputDecoration(
                  labelText: 'Numéro fiscal / TVA',
                  hintText: 'Ex: CI-12345678',
                  prefixIcon: const Icon(Icons.receipt_long),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Section contact
  Widget _buildContactSection(CustomerFormState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Contact',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Téléphone
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: 'Téléphone',
                hintText: '+225 XX XX XX XX XX',
                prefixIcon: const Icon(Icons.phone),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(15),
              ],
            ),

            const SizedBox(height: 16),

            // Email
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'client@example.com',
                prefixIcon: const Icon(Icons.email),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (value) {
                if (value != null && value.isNotEmpty) {
                  if (!value.contains('@')) {
                    return 'Email invalide';
                  }
                }
                return null;
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Section adresse
  Widget _buildAddressSection(CustomerFormState state) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Adresse',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Adresse
            TextFormField(
              controller: _addressController,
              decoration: InputDecoration(
                labelText: 'Adresse',
                hintText: 'Rue, quartier, ville',
                prefixIcon: const Icon(Icons.location_on),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
              maxLines: 2,
            ),

            const SizedBox(height: 16),

            // Ville et Code postal
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: InputDecoration(
                      labelText: 'Ville',
                      hintText: 'Ex: Abidjan',
                      prefixIcon: const Icon(Icons.location_city),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: InputDecoration(
                      labelText: 'Code postal',
                      hintText: '00225',
                      prefixIcon: const Icon(Icons.markunread_mailbox),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[50],
                    ),
                    keyboardType: TextInputType.number,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey[200]!),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Préférences',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // Consentement marketing
            SwitchListTile(
              value: marketingConsent,
              onChanged: (value) {
                ref.read(customerFormProvider.notifier)
                    .updateMarketingConsent(value);
              },
              title: const Text('Accepte les communications marketing'),
              subtitle: const Text('Email, SMS, notifications'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.primary,
            ),

            const Divider(),

            // Statut actif
            SwitchListTile(
              value: isActive,
              onChanged: (value) {
                ref.read(customerFormProvider.notifier)
                    .updateActiveStatus(value);
              },
              title: const Text('Client actif'),
              subtitle: const Text('Peut effectuer des achats'),
              contentPadding: EdgeInsets.zero,
              activeThumbColor: AppColors.success,
            ),
          ],
        ),
      ),
    );
  }

  /// Boutons d'action
  Widget _buildActionButtons(CustomerFormState state) {
    final isSubmitting = state is CustomerFormSubmitting;

    return Row(
      children: [
        // Bouton Annuler
        Expanded(
          child: OutlinedButton(
            onPressed: isSubmitting ? null : () => context.pop(),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Annuler',
              style: TextStyle(fontSize: 16),
            ),
          ),
        ),

        const SizedBox(width: 16),

        // Bouton Enregistrer
        Expanded(
          flex: 2,
          child: FilledButton(
            onPressed: isSubmitting ? null : _handleSubmit,
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
              _isEditing ? 'Enregistrer' : 'Créer le client',
              style: const TextStyle(fontSize: 16),
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
      'description': _descriptionController.text
          .trim()
          .isNotEmpty
          ? _descriptionController.text.trim()
          : null,
      'customer_type': customerType,
      'first_name': _firstNameController.text
          .trim()
          .isNotEmpty
          ? _firstNameController.text.trim()
          : null,
      'last_name': _lastNameController.text
          .trim()
          .isNotEmpty
          ? _lastNameController.text.trim()
          : null,
      'company_name': _companyNameController.text
          .trim()
          .isNotEmpty
          ? _companyNameController.text.trim()
          : null,
      'email': _emailController.text
          .trim()
          .isNotEmpty
          ? _emailController.text.trim()
          : null,
      'phone': _phoneController.text
          .trim()
          .isNotEmpty
          ? _phoneController.text.trim()
          : null,
      'address': _addressController.text
          .trim()
          .isNotEmpty
          ? _addressController.text.trim()
          : null,
      'city': _cityController.text
          .trim()
          .isNotEmpty
          ? _cityController.text.trim()
          : null,
      'postal_code': _postalCodeController.text
          .trim()
          .isNotEmpty
          ? _postalCodeController.text.trim()
          : null,
      'tax_number': _taxNumberController.text
          .trim()
          .isNotEmpty
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
      builder: (context) =>
          AlertDialog(
            icon: Icon(
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