import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../legal_information_screen.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

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
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: AppTheme.primaryDark,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 26),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 48,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 76,
                        width: 178,
                        child: Image.asset(
                          'assets/logo_white_nobg.png',
                          fit: BoxFit.contain,
                          alignment: Alignment.centerLeft,
                          errorBuilder: (_, __, ___) => const Align(
                            alignment: Alignment.centerLeft,
                            child: Icon(
                              Icons.business_center_rounded,
                              color: Colors.white,
                              size: 46,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 34),
                      Text(
                        'Votre réseau,\nà portée de main.',
                        style: Theme.of(context).textTheme.displayMedium
                            ?.copyWith(color: Colors.white, fontSize: 31),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Connectez-vous pour accéder aux échanges entre membres.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white.withAlpha(176),
                        ),
                      ),
                      const SizedBox(height: 30),
                      CecSurface(
                        padding: const EdgeInsets.all(20),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: AppTheme.accentSoft,
                                      borderRadius: BorderRadius.circular(
                                        AppTheme.radiusSmall,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.lock_open_rounded,
                                      size: 19,
                                      color: AppTheme.primaryColor,
                                    ),
                                  ),
                                  const SizedBox(width: 11),
                                  Text(
                                    'Espace membre',
                                    style: Theme.of(
                                      context,
                                    ).textTheme.headlineSmall,
                                  ),
                                ],
                              ),
                              const SizedBox(height: 22),
                              TextFormField(
                                controller: _emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                autofillHints: const [AutofillHints.email],
                                decoration: const InputDecoration(
                                  labelText: 'Adresse email',
                                  prefixIcon: Icon(Icons.email_outlined),
                                ),
                                validator: (value) {
                                  if (value == null || value.trim().isEmpty) {
                                    return 'Veuillez saisir votre email.';
                                  }
                                  if (!RegExp(
                                    r'^[^@]+@[^@]+\.[^@]+',
                                  ).hasMatch(value)) {
                                    return 'Adresse email invalide.';
                                  }
                                  return null;
                                },
                              ),
                              const SizedBox(height: 13),
                              TextFormField(
                                controller: _passwordCtrl,
                                obscureText: _obscure,
                                textInputAction: TextInputAction.done,
                                autofillHints: const [AutofillHints.password],
                                onFieldSubmitted: (_) => _submit(),
                                decoration: InputDecoration(
                                  labelText: 'Mot de passe',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline_rounded,
                                  ),
                                  suffixIcon: Tooltip(
                                    message: _obscure
                                        ? 'Afficher le mot de passe'
                                        : 'Masquer le mot de passe',
                                    child: IconButton(
                                      icon: Icon(
                                        _obscure
                                            ? Icons.visibility_outlined
                                            : Icons.visibility_off_outlined,
                                      ),
                                      onPressed: () {
                                        setState(() => _obscure = !_obscure);
                                      },
                                    ),
                                  ),
                                ),
                                validator: (value) {
                                  return value == null || value.isEmpty
                                      ? 'Veuillez saisir votre mot de passe.'
                                      : null;
                                },
                              ),
                              const SizedBox(height: 12),
                              CheckboxListTile(
                                value: _termsAccepted,
                                onChanged: auth.isLoading
                                    ? null
                                    : (value) {
                                        setState(() {
                                          _termsAccepted = value ?? false;
                                          _showTermsError = false;
                                        });
                                      },
                                contentPadding: EdgeInsets.zero,
                                controlAffinity:
                                    ListTileControlAffinity.leading,
                                title: const Text(
                                  'J’accepte les conditions et règles d’utilisation.',
                                ),
                              ),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: TextButton.icon(
                                  onPressed: _openTerms,
                                  icon: const Icon(
                                    Icons.open_in_new_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('Lire les conditions'),
                                ),
                              ),
                              if (_showTermsError)
                                const Padding(
                                  padding: EdgeInsets.only(left: 12, bottom: 8),
                                  child: Text(
                                    'Vous devez accepter les conditions pour vous connecter.',
                                    style: TextStyle(
                                      color: AppTheme.errorColor,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              const SizedBox(height: 8),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton.icon(
                                  onPressed: auth.isLoading ? null : _submit,
                                  icon: auth.isLoading
                                      ? const SizedBox.square(
                                          dimension: 18,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white,
                                          ),
                                        )
                                      : const Icon(
                                          Icons.login_rounded,
                                          size: 19,
                                        ),
                                  label: Text(
                                    auth.isLoading
                                        ? 'Connexion...'
                                        : 'Se connecter',
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.shield_outlined,
                            color: AppTheme.accentColor,
                            size: 15,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Accès sécurisé réservé aux comptes membres',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.white.withAlpha(158)),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LegalInformationScreen(),
                            ),
                          ),
                          icon: const Icon(
                            Icons.info_outline_rounded,
                            size: 18,
                          ),
                          label: const Text(
                            'À propos, confidentialité et aide',
                          ),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
