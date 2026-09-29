import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import '../widgets/common_widgets.dart';

class LegalInformationScreen extends StatelessWidget {
  const LegalInformationScreen({super.key});

  static final Uri _privacyUrl = Uri.parse(
    'https://cec.wevox.cloud/application/confidentialite.html',
  );
  static final Uri _deletionUrl = Uri.parse(
    'https://cec.wevox.cloud/application/suppression-compte.html',
  );
  static final Uri termsUrl = Uri.parse(
    'https://cec.wevox.cloud/application/conditions-utilisation.html',
  );
  static final Uri _websiteUrl = Uri.parse(
    'https://cec.wevox.cloud/application/index.html',
  );
  static final Uri _supportEmail = Uri(
    scheme: 'mailto',
    path: 'contact@wevox.eu',
    queryParameters: {'subject': 'Assistance application CEC 2026'},
  );

  Future<void> _open(BuildContext context, Uri uri) async {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Impossible d'ouvrir ce lien.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CecGlassAppBar(title: Text('À propos et assistance')),
      body: CecBackground(
        child: ListView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 40),
          children: [
            CecContentWidth(
              maxWidth: 720,
              child: Column(
                children: [
                  CecReveal(
                    child: Container(
                      width: 104,
                      height: 104,
                      padding: const EdgeInsets.all(17),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(216),
                        borderRadius: BorderRadius.circular(26),
                        border: Border.all(
                          color: AppTheme.primaryColor.withAlpha(20),
                        ),
                        boxShadow: AppTheme.cardShadow,
                      ),
                      child: Image.asset(
                        'assets/logo_purple_nobg.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'CEC 2026',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'L’application du Club des Entrepreneurs du Cotentin.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 28),
                  CecReveal(
                    delay: const Duration(milliseconds: 80),
                    child: CecSurface(
                      glass: true,
                      padding: EdgeInsets.zero,
                      child: Column(
                        children: [
                          _InformationAction(
                            icon: Icons.language_rounded,
                            title: 'Site de présentation',
                            subtitle: 'Découvrir l’application et le Club',
                            onTap: () => _open(context, _websiteUrl),
                          ),
                          const Divider(height: 1),
                          _InformationAction(
                            icon: Icons.privacy_tip_outlined,
                            title: 'Politique de confidentialité',
                            subtitle:
                                'Données collectées, utilisation et conservation',
                            onTap: () => _open(context, _privacyUrl),
                          ),
                          const Divider(height: 1),
                          _InformationAction(
                            icon: Icons.gavel_outlined,
                            title: 'Conditions et règles d’utilisation',
                            subtitle:
                                'Usage du service, contenus et signalements',
                            onTap: () => _open(context, termsUrl),
                          ),
                          const Divider(height: 1),
                          _InformationAction(
                            icon: Icons.person_remove_outlined,
                            title: 'Suppression du compte et des données',
                            subtitle: 'Consulter la procédure de suppression',
                            onTap: () => _open(context, _deletionUrl),
                          ),
                          const Divider(height: 1),
                          _InformationAction(
                            icon: Icons.support_agent_rounded,
                            title: 'Contacter l’assistance',
                            subtitle: 'contact@wevox.eu',
                            onTap: () => _open(context, _supportEmail),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Club des Entrepreneurs du Cotentin\n'
                    '40 boulevard Schuman, BP 612\n'
                    '50100 Cherbourg-en-Cotentin',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      height: 1.55,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InformationAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _InformationAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      minTileHeight: 74,
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentSoft,
          borderRadius: BorderRadius.circular(AppTheme.radiusSmall),
        ),
        child: Icon(icon, color: AppTheme.primaryColor, size: 21),
      ),
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
      trailing: const Icon(Icons.open_in_new_rounded, size: 19),
    );
  }
}
