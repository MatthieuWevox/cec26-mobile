import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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
      value: SystemUiOverlayStyle.dark.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundLight,
        body: DecoratedBox(
          decoration: const BoxDecoration(gradient: AppTheme.canvasGradient),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                right: -72,
                top: 92,
                child: IgnorePointer(
                  child: Opacity(
                    opacity: 0.045,
                    child: Image.asset(
                      'assets/logo_purple_nobg.png',
                      width: 320,
                    ),
                  ),
                ),
              ),
              Align(
                alignment: Alignment.topRight,
                child: Container(
                  width: 150,
                  height: 3,
                  color: AppTheme.accentColor,
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 126),
                      child: Center(
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            maxWidth: 500,
                            minHeight: constraints.maxHeight > 40
                                ? constraints.maxHeight - 40
                                : 0,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 58,
                                width: 148,
                                child: Image.asset(
                                  'assets/logo_purple_nobg.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                  errorBuilder: (_, __, ___) => const Align(
                                    alignment: Alignment.centerLeft,
                                    child: Icon(
                                      Icons.business_center_rounded,
                                      color: AppTheme.primaryColor,
                                      size: 44,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 14),
                              Text(
                                'Votre réseau,\nà portée de main.',
                                style: Theme.of(context).textTheme.displayMedium
                                    ?.copyWith(
                                      color: AppTheme.textPrimary,
                                      fontSize: 28,
                                      height: 1.14,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Retrouvez vos échanges et développez votre réseau.',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppTheme.textSecondary),
                              ),
                              const SizedBox(height: 20),
                              CecLayeredCard(
                                child: CecGlassPanel(
                                  color: Colors.white.withAlpha(224),
                                  blur: 24,
                                  padding: const EdgeInsets.all(18),
                                  border: Border.all(
                                    color: Colors.white.withAlpha(224),
                                  ),
                                  child: Form(
                                    key: _formKey,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 38,
                                              height: 38,
                                              decoration: BoxDecoration(
                                                color: AppTheme.accentSoft,
                                                borderRadius:
                                                    BorderRadius.circular(
                                                      AppTheme.radius,
                                                    ),
                                              ),
                                              child: const Icon(
                                                Icons.lock_open_rounded,
                                                size: 19,
                                                color: AppTheme.primaryColor,
                                              ),
                                            ),
                                            const SizedBox(width: 11),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    'Espace membre',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.headlineSmall,
                                                  ),
                                                  Text(
                                                    'Connexion sécurisée',
                                                    style: Theme.of(
                                                      context,
                                                    ).textTheme.bodySmall,
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 16),
                                        TextFormField(
                                          controller: _emailCtrl,
                                          keyboardType:
                                              TextInputType.emailAddress,
                                          textInputAction: TextInputAction.next,
                                          autofillHints: const [
                                            AutofillHints.email,
                                          ],
                                          decoration: const InputDecoration(
                                            labelText: 'Adresse email',
                                            prefixIcon: Icon(
                                              Icons.email_outlined,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.trim().isEmpty) {
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
                                          autofillHints: const [
                                            AutofillHints.password,
                                          ],
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
                                                      ? Icons
                                                            .visibility_outlined
                                                      : Icons
                                                            .visibility_off_outlined,
                                                ),
                                                onPressed: () {
                                                  setState(
                                                    () => _obscure = !_obscure,
                                                  );
                                                },
                                              ),
                                            ),
                                          ),
                                          validator: (value) =>
                                              value == null || value.isEmpty
                                              ? 'Veuillez saisir votre mot de passe.'
                                              : null,
                                        ),
                                        const SizedBox(height: 10),
                                        Material(
                                          type: MaterialType.transparency,
                                          child: CheckboxListTile(
                                            value: _termsAccepted,
                                            onChanged: auth.isLoading
                                                ? null
                                                : (value) {
                                                    setState(() {
                                                      _termsAccepted =
                                                          value ?? false;
                                                      _showTermsError = false;
                                                    });
                                                  },
                                            contentPadding: EdgeInsets.zero,
                                            controlAffinity:
                                                ListTileControlAffinity.leading,
                                            dense: true,
                                            title: const Text(
                                              'J’accepte les conditions et règles d’utilisation.',
                                            ),
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
                                            label: const Text(
                                              'Lire les conditions',
                                            ),
                                          ),
                                        ),
                                        if (_showTermsError)
                                          const Padding(
                                            padding: EdgeInsets.only(
                                              left: 12,
                                              bottom: 8,
                                            ),
                                            child: Text(
                                              'Vous devez accepter les conditions pour vous connecter.',
                                              style: TextStyle(
                                                color: AppTheme.errorColor,
                                                fontSize: 12,
                                                letterSpacing: 0,
                                              ),
                                            ),
                                          ),
                                        const SizedBox(height: 7),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: auth.isLoading
                                                ? null
                                                : _submit,
                                            icon: auth.isLoading
                                                ? const SizedBox.square(
                                                    dimension: 18,
                                                    child:
                                                        CircularProgressIndicator(
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
                                  Flexible(
                                    child: Text(
                                      'Accès réservé aux comptes membres',
                                      textAlign: TextAlign.center,
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodySmall
                                          ?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Center(
                                child: TextButton.icon(
                                  onPressed: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          const LegalInformationScreen(),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.info_outline_rounded,
                                    size: 18,
                                  ),
                                  label: const Text(
                                    'Confidentialité et assistance',
                                  ),
                                  style: TextButton.styleFrom(
                                    foregroundColor: AppTheme.primaryColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
