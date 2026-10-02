import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../legal_information_screen.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'recommendations_screen.dart';
import 'thanks_screen.dart';

class PrivateHomeScreen extends StatelessWidget {
  const PrivateHomeScreen({super.key});
  @override
  Widget build(BuildContext context) => context.watch<AuthProvider>().isLoggedIn
      ? const Scaffold(body: _MemberDashboard())
      : const LoginScreen();
}

class _MemberDashboard extends StatelessWidget {
  const _MemberDashboard();

  @override
  Widget build(BuildContext context) {
    final member = context.watch<AuthProvider>().currentMember;
    void open(Widget page) =>
        Navigator.push(context, MaterialPageRoute(builder: (_) => page));
    return ListView(
      padding: const EdgeInsets.fromLTRB(22, 16, 22, 126),
      children: [
        const SafeArea(bottom: false, child: SizedBox(height: 12)),
        Text('Mon espace.', style: Theme.of(context).textTheme.headlineLarge),
        const SizedBox(height: 12),
        Row(
          children: [
            MemberAvatar(
              imageUrl: member?.photoUrl,
              name: member?.fullName ?? 'Membre',
              radius: 32,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member?.fullName ?? 'Membre',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (member?.company != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      member!.company!.nom,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SectionHeader(title: 'Mes échanges'),
        _AccountRow(
          icon: Icons.north_east_rounded,
          title: 'Recommandations',
          subtitle: 'Les opportunités de votre réseau',
          onTap: () => open(const RecommendationsScreen()),
        ),
        _AccountRow(
          icon: Icons.handshake_outlined,
          title: 'Remerciements',
          subtitle: 'Les affaires concrétisées ensemble',
          onTap: () => open(const ThanksScreen()),
        ),
        const SectionHeader(title: 'Mon compte'),
        _AccountRow(
          icon: Icons.person_outline,
          title: 'Mon profil',
          onTap: () => open(const ProfileScreen()),
        ),
        _AccountRow(
          icon: Icons.apartment_outlined,
          title: 'Mon entreprise',
          onTap: () =>
              open(const ProfileScreen(initialTab: ProfileTab.company)),
        ),
        _AccountRow(
          icon: Icons.lock_outline,
          title: 'Sécurité',
          onTap: () =>
              open(const ProfileScreen(initialTab: ProfileTab.password)),
        ),
        _AccountRow(
          icon: Icons.notifications_outlined,
          title: 'Notifications',
          onTap: () => open(const NotificationSettingsScreen()),
        ),
        const SectionHeader(title: 'À propos'),
        _AccountRow(
          icon: Icons.help_outline,
          title: 'Confidentialité et assistance',
          onTap: () => open(const LegalInformationScreen()),
        ),
        const SizedBox(height: 20),
        TextButton.icon(
          onPressed: () => _confirmLogout(context),
          icon: const Icon(Icons.logout_rounded),
          label: const Text('Se déconnecter'),
          style: TextButton.styleFrom(foregroundColor: AppTheme.errorColor),
        ),
      ],
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.logout_rounded, color: AppTheme.errorColor),
        title: const Text('Se déconnecter ?'),
        content: const Text(
          'Vous devrez saisir à nouveau vos identifiants pour accéder à votre espace.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton.icon(
            onPressed: () => Navigator.pop(dialogContext, true),
            icon: const Icon(Icons.logout_rounded, size: 18),
            label: const Text('Se déconnecter'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }
}

class _AccountRow extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  const _AccountRow({
    required this.icon,
    required this.title,
    this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => Column(
    children: [
      ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5),
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentSoft,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 21, color: AppTheme.accentDark),
        ),
        title: Text(title, style: Theme.of(context).textTheme.titleMedium),
        subtitle: subtitle == null
            ? null
            : Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
        trailing: const Icon(
          Icons.chevron_right_rounded,
          size: 20,
          color: AppTheme.textSecondary,
        ),
        onTap: onTap,
      ),
      const Divider(height: 1),
    ],
  );
}

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CecGlassAppBar(title: Text('Notifications')),
    body: ListView(
      padding: const EdgeInsets.all(22),
      children: [
        Text(
          'Gardons le lien.',
          style: Theme.of(context).textTheme.headlineLarge,
        ),
        const SizedBox(height: 24),
        ValueListenableBuilder<PushRegistrationStatus>(
          valueListenable: NotificationService.registrationStatus,
          builder: (context, status, _) => Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              InfoRow(
                icon: status == PushRegistrationStatus.registered
                    ? Icons.notifications_active_outlined
                    : Icons.notifications_outlined,
                label: 'Cet appareil',
                value: switch (status) {
                  PushRegistrationStatus.registered => 'Appareil enregistré',
                  PushRegistrationStatus.registering => 'Connexion en cours…',
                  PushRegistrationStatus.denied =>
                    'Autorisation à vérifier dans les réglages du téléphone',
                  PushRegistrationStatus.retryPending =>
                    'Enregistrement en attente',
                  PushRegistrationStatus.idle => 'À activer',
                },
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: status == PushRegistrationStatus.registering
                    ? null
                    : () => NotificationService.requestPermissionAndRegister(
                        ApiService(
                          authToken: context.read<AuthProvider>().token,
                        ),
                      ),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Vérifier les notifications'),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
