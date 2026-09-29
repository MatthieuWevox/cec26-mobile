import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
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
      backgroundColor: Colors.transparent,
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
              radius: 27,
            ),
          ),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final horizontalPadding = constraints.maxWidth > 800
                    ? (constraints.maxWidth - 760) / 2
                    : 16.0;

                return ListView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    0,
                    horizontalPadding,
                    126,
                  ),
                  children: [
                    CecReveal(child: _NetworkWelcome(member: member)),
                    const SectionHeader(
                      title: 'Mes échanges',
                      subtitle: 'Entretenez les relations qui font le réseau.',
                    ),
                    CecReveal(
                      delay: const Duration(milliseconds: 60),
                      child: _PrimaryAction(
                        icon: Icons.recommend_outlined,
                        title: 'Recommandations',
                        subtitle:
                            'Consultez les reçues, les envoyées ou créez-en une.',
                        accent: AppTheme.accentColor,
                        dark: true,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RecommendationsScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CecReveal(
                      delay: const Duration(milliseconds: 110),
                      child: _PrimaryAction(
                        icon: Icons.handshake_outlined,
                        title: 'Remerciements',
                        subtitle:
                            'Valorisez les affaires réalisées grâce au réseau.',
                        accent: AppTheme.accentDark,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const ThanksScreen(),
                          ),
                        ),
                      ),
                    ),
                    const SectionHeader(
                      title: 'Mon compte',
                      subtitle: 'Une présence claire, toujours à jour.',
                    ),
                    Row(
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
                        const SizedBox(width: 11),
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
                    if (member != null) ...[
                      const SectionHeader(
                        title: 'Visibilité du profil',
                        subtitle:
                            'Un profil complet facilite les mises en relation.',
                      ),
                      _ProfileSummary(member: member),
                    ],
                    const SizedBox(height: 22),
                    ValueListenableBuilder<PushRegistrationStatus>(
                      valueListenable: NotificationService.registrationStatus,
                      builder: (context, status, _) => ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.notifications_outlined),
                        title: const Text('Notifications'),
                        subtitle: Text(switch (status) {
                          PushRegistrationStatus.registered =>
                            'Appareil enregistré',
                          PushRegistrationStatus.registering =>
                            'Connexion en cours...',
                          PushRegistrationStatus.denied =>
                            'Autorisation à vérifier dans les réglages du téléphone',
                          PushRegistrationStatus.retryPending =>
                            'Enregistrement en attente',
                          PushRegistrationStatus.idle => 'À activer',
                        }),
                        trailing: IconButton(
                          tooltip: 'Vérifier les notifications',
                          icon: const Icon(Icons.refresh_rounded),
                          onPressed:
                              status == PushRegistrationStatus.registering
                              ? null
                              : () =>
                                    NotificationService.requestPermissionAndRegister(
                                      ApiService(authToken: auth.token),
                                    ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const LegalInformationScreen(),
                        ),
                      ),
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text('Confidentialité et assistance'),
                    ),
                    const SizedBox(height: 11),
                    TextButton.icon(
                      onPressed: () => _confirmLogout(context),
                      icon: const Icon(Icons.logout_rounded),
                      label: const Text('Se déconnecter'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.errorColor,
                      ),
                    ),
                  ],
                );
              },
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

class _NetworkWelcome extends StatelessWidget {
  final Member? member;

  const _NetworkWelcome({required this.member});

  @override
  Widget build(BuildContext context) {
    return CecGlassPanel(
      padding: const EdgeInsets.all(17),
      child: Row(
        children: [
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              gradient: AppTheme.accentGradient,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: const Icon(
              Icons.waving_hand_outlined,
              color: AppTheme.primaryDark,
              size: 22,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Heureux de vous revoir',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  member?.company?.nom ??
                      'Retrouvez toute l’activité de votre réseau.',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const CecBadge(
            label: 'MEMBRE',
            color: AppTheme.successColor,
            icon: Icons.verified_rounded,
          ),
        ],
      ),
    );
  }
}

class _PrimaryAction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color accent;
  final VoidCallback onTap;
  final bool dark;

  const _PrimaryAction({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.accent,
    required this.onTap,
    this.dark = false,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = dark ? Colors.white : AppTheme.textPrimary;
    final secondary = dark
        ? Colors.white.withAlpha(174)
        : AppTheme.textSecondary;

    return CecLayeredCard(
      child: CecSurface(
        onTap: onTap,
        color: dark ? AppTheme.primaryColor : Colors.white,
        borderColor: dark
            ? Colors.white.withAlpha(24)
            : AppTheme.primaryColor.withAlpha(18),
        boxShadow: AppTheme.softShadow,
        padding: const EdgeInsets.all(17),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withAlpha(18) : accent.withAlpha(18),
                borderRadius: BorderRadius.circular(AppTheme.radius),
                border: Border.all(
                  color: dark
                      ? Colors.white.withAlpha(26)
                      : accent.withAlpha(28),
                ),
              ),
              child: Icon(icon, color: accent, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(
                      context,
                    ).textTheme.titleLarge?.copyWith(color: foreground),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: secondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: dark ? Colors.white.withAlpha(16) : AppTheme.accentSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: dark ? Colors.white : AppTheme.primaryColor,
                size: 17,
              ),
            ),
          ],
        ),
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
      glass: true,
      padding: const EdgeInsets.all(15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(AppTheme.radius),
            ),
            child: Icon(icon, color: AppTheme.accentDark, size: 20),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  maxLines: 2,
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
      glass: true,
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
          const SizedBox(height: 13),
          ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 7,
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
