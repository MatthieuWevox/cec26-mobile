import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../legal_information_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true;
  bool _termsAccepted = false;
  bool _showTermsError = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final formIsValid = _formKey.currentState!.validate();
    setState(() => _showTermsError = !_termsAccepted);
    if (!formIsValid || !_termsAccepted) return;
    FocusScope.of(context).unfocus();

    final auth = context.read<AuthProvider>();
    auth.clearError();
    final ok = await auth.login(
      _emailCtrl.text.trim(),
      _passwordCtrl.text,
      acceptTerms: _termsAccepted,
    );
    if (!ok && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.error ?? 'Erreur de connexion.'),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  Future<void> _openTerms() async {
    final opened = await launchUrl(
      LegalInformationScreen.termsUrl,
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LegalInformationScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 28, 22, 126),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Image.asset(
                  'assets/logo_purple_nobg.png',
                  width: 112,
                  height: 70,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 30),
              Text(
                'Heureux de\nvous retrouver.',
                style: Theme.of(
                  context,
                ).textTheme.headlineLarge?.copyWith(fontSize: 30),
              ),
              const SizedBox(height: 12),
              Text(
                'Vos contacts, vos projets et la vie du réseau vous attendent.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 30),
              AutofillGroup(
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _emailCtrl,
                        enabled: !auth.isLoading,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        autofillHints: const [
                          AutofillHints.username,
                          AutofillHints.email,
                        ],
                        decoration: const InputDecoration(
                          labelText: 'Adresse email',
                        ),
                        validator: (v) =>
                            v == null ||
                                !RegExp(
                                  r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                                ).hasMatch(v.trim())
                            ? 'Saisissez une adresse email valide.'
                            : null,
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _passwordCtrl,
                        enabled: !auth.isLoading,
                        obscureText: _obscure,
                        textInputAction: TextInputAction.done,
                        autofillHints: const [AutofillHints.password],
                        onFieldSubmitted: (_) {
                          if (!auth.isLoading) _submit();
                        },
                        decoration: InputDecoration(
                          labelText: 'Mot de passe',
                          suffixIcon: IconButton(
                            tooltip: _obscure
                                ? 'Afficher le mot de passe'
                                : 'Masquer le mot de passe',
                            onPressed: () =>
                                setState(() => _obscure = !_obscure),
                            icon: Icon(
                              _obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined,
                            ),
                          ),
                        ),
                        validator: (v) => v == null || v.isEmpty
                            ? 'Saisissez votre mot de passe.'
                            : null,
                      ),
                      const SizedBox(height: 18),
                      CheckboxListTile(
                        value: _termsAccepted,
                        contentPadding: EdgeInsets.zero,
                        controlAffinity: ListTileControlAffinity.leading,
                        title: const Text(
                          'J’accepte les conditions et règles d’utilisation.',
                          style: TextStyle(fontSize: 12),
                        ),
                        onChanged: auth.isLoading
                            ? null
                            : (value) => setState(() {
                                _termsAccepted = value ?? false;
                                _showTermsError = !_termsAccepted;
                              }),
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: _openTerms,
                          child: const Text('Consulter les conditions'),
                        ),
                      ),
                      if (_showTermsError)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'Acceptez les conditions pour continuer.',
                            style: TextStyle(color: AppTheme.errorColor),
                          ),
                        ),
                      const SizedBox(height: 12),
                      ElevatedButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox.square(
                                dimension: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text('Se connecter'),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextButton(
                onPressed: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const LegalInformationScreen(),
                  ),
                ),
                child: const Text('Confidentialité et assistance'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
