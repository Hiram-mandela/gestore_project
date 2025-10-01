// ========================================
// features/authentication/presentation/widgets/login_form.dart
// VERSION CORRIGÉE
// ========================================
import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import '../providers/auth_provider.dart';
import '../providers/auth_state.dart';

/// Formulaire de connexion
class LoginForm extends ConsumerStatefulWidget {
  const LoginForm({super.key});

  @override
  ConsumerState<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends ConsumerState<LoginForm> {
  final _formKey = GlobalKey<FormBuilderState>();
  bool _obscurePassword = true;

  void _handleLogin() {
    if (_formKey.currentState?.saveAndValidate() ?? false) {
      final values = _formKey.currentState!.value;

      ref.read(authProvider.notifier).login(
        username: values['username'] as String,
        password: values['password'] as String,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final isLoading = authState is AuthLoading;

    return FormBuilder(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Champ username
          FormBuilderTextField(
            name: 'username',
            decoration: InputDecoration(
              labelText: 'Nom d\'utilisateur ou Email',
              prefixIcon: const Icon(Icons.person_outline),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Ce champ est requis',
              ),
            ]),
            textInputAction: TextInputAction.next,
            enabled: !isLoading,
          ),
          const SizedBox(height: 16),

          // Champ password
          FormBuilderTextField(
            name: 'password',
            decoration: InputDecoration(
              labelText: 'Mot de passe',
              prefixIcon: const Icon(Icons.lock_outline),
              suffixIcon: IconButton(
                icon: Icon(
                  _obscurePassword ? Icons.visibility : Icons.visibility_off,
                ),
                onPressed: () {
                  setState(() {
                    _obscurePassword = !_obscurePassword;
                  });
                },
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              filled: true,
              fillColor: Colors.grey[50],
            ),
            obscureText: _obscurePassword,
            validator: FormBuilderValidators.compose([
              FormBuilderValidators.required(
                errorText: 'Ce champ est requis',
              ),
            ]),
            textInputAction: TextInputAction.done,
            onSubmitted: (_) => _handleLogin(),
            enabled: !isLoading,
          ),
          const SizedBox(height: 24),

          // Bouton de connexion
          ElevatedButton(
            onPressed: isLoading ? null : _handleLogin,
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
            ),
            child: isLoading
                ? const SizedBox(
              height: 20,
              width: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
              ),
            )
                : const Text(
              'Se connecter',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
