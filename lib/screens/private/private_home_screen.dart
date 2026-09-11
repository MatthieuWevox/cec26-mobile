import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../providers/auth_provider.dart';
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
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return auth.isLoggedIn ? const _MemberDashboard() : const LoginScreen();
  }
}

class _MemberDashboard extends StatelessWidget {
  const _MemberDashboard();

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final member = auth.currentMember;

    return Scaffold(
      body: Column(
        children: [
          CecPageHeader(
            eyebrow: 'Espace membre',
            title: 'Bonjour, ${member?.prenom ?? 'membre'}',
            subtitle:
                member?.company?.nom ?? 'Club des Entrepreneurs du Cotentin',
            icon: Icons.verified_user_outlined,
            trailing: MemberAvatar(
              imageUrl: member?.photoUrl,
              name: member?.fullName ?? 'Membre CEC',
              radius: 25,
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.only(bottom: 28),
              children: [
                const SectionHeader(
                  title: 'Échanges',
                  subtitle: 'Suivez et développez les relations du réseau.',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _PrimaryAction(
                        icon: Icons.recommend_outlined,
                        title: 'Recommandations',
                        subtitle:
                            'Consulter les reçues, les envoyées ou en créer une',
                        accent: AppTheme.primaryColor,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecommendationsScreen(),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      _PrimaryAction(
                        icon: Icons.handshake_outlined,
                        title: 'Remerciements',
                        subtitle:
                            'Valoriser une affaire réalisée grâce au réseau',
                        accent: AppTheme.accentDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ThanksScreen(),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SectionHeader(
                  title: 'Mon compte',
                  subtitle: 'Gardez vos informations à jour.',
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _AccountAction(
                          icon: Icons.person_outline_rounded,
                          label: 'Mon profil',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _AccountAction(
                          icon: Icons.apartment_outlined,
                          label: 'Mon entreprise',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const ProfileScreen(
                                initialTab: ProfileTab.company,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (member != null) ...[
                  const SectionHeader(
                    title: 'Profil',
                    subtitle:
                        'Un profil complet facilite les mises en relation.',
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: _ProfileSummary(member: member),
                  ),
                ],
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 0),
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const LegalInformationScreen(),
                      ),
                    ),
                    icon: const Icon(Icons.info_outline_rounded),
                    label: const Text('À propos, confidentialité et aide'),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 22, 16, 0),
                  child: OutlinedButton.icon(
                    onPressed: () => _confirmLogout(context),
                    icon: const Icon(Icons.logout_rounded),
                    label: const Text('Se déconnecter'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.errorColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
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

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;

  const _PrimaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CecSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: accent.withAlpha(20),
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryColor,
            size: 19,
          ),
        ],
      ),
    );
  }
}

class _AccountAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AccountAction({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CecSurface(
      onTap: onTap,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.accentDark, size: 24),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const Icon(
                Icons.arrow_forward_rounded,
                color: AppTheme.primaryColor,
                size: 17,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ProfileSummary extends StatelessWidget {
  final Member member;

  const _ProfileSummary({required this.member});

  @override
  Widget build(BuildContext context) {
    final completed = [
      member.nom.isNotEmpty,
      member.prenom.isNotEmpty,
      member.email.isNotEmpty,
      member.telephone?.isNotEmpty ?? false,
      member.presentation?.isNotEmpty ?? false,
      member.photoUrl?.isNotEmpty ?? false,
      member.company != null,
    ].where((value) => value).length;
    final progress = completed / 7;

    return CecSurface(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'Profil complété à ${(progress * 100).round()} %',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              const CecBadge(
                label: 'VISIBLE',
                color: AppTheme.successColor,
                icon: Icons.visibility_outlined,
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: AppTheme.surfaceMuted,
              valueColor: const AlwaysStoppedAnimation(AppTheme.accentColor),
            ),
          ),
          const SizedBox(height: 14),
          InfoRow(
            icon: Icons.email_outlined,
            label: 'Email',
            value: member.email,
          ),
          if (member.telephone?.isNotEmpty ?? false) ...[
            const Divider(),
            InfoRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: member.telephone!,
            ),
          ],
        ],
      ),
    );
  }
}
