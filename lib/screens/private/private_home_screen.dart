import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'login_screen.dart';
import 'profile_screen.dart';
import 'recommendations_screen.dart';
import 'thanks_screen.dart';

class PrivateHomeScreen extends StatelessWidget {
  const PrivateHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    if (!auth.isLoggedIn) {
      return const LoginScreen();
    }

    return _MemberDashboard();
  }
}

class _MemberDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final member = auth.currentMember;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mon espace'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: 'Déconnexion',
            onPressed: () => _confirmLogout(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Profile header
            Container(
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primaryColor, Color(0xFF3A3690)],
                ),
              ),
              padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
              child: Row(
                children: [
                  MemberAvatar(
                    name: member?.fullName ?? 'Membre',
                    radius: 36,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Bonjour, ${member?.prenom ?? ''}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (member?.company != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            member!.company!.nom,
                            style: TextStyle(
                              color: Colors.white.withAlpha(200),
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Quick access
            const SectionHeader(title: 'Mes actions'),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _ActionTile(
                    icon: Icons.thumb_up_outlined,
                    label: 'Recommandations',
                    subtitle: 'Reçues & envoyées',
                    color: AppTheme.primaryColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const RecommendationsScreen(),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.handshake_outlined,
                    label: 'Remerciements',
                    subtitle: 'Reçus & envoyés',
                    color: AppTheme.accentColor,
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ThanksScreen(),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.person_outline_rounded,
                    label: 'Mon profil',
                    subtitle: 'Modifier mes infos',
                    color: const Color(0xFF8B5CF6),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(),
                      ),
                    ),
                  ),
                  _ActionTile(
                    icon: Icons.business_outlined,
                    label: 'Mon entreprise',
                    subtitle: "Modifier l'entreprise",
                    color: const Color(0xFFEA580C),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const ProfileScreen(
                          initialTab: ProfileTab.company,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // Member info summary
            if (member != null) ...[
              const SectionHeader(title: 'Mes informations'),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(10),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      InfoRow(
                        icon: Icons.person_rounded,
                        label: 'NOM COMPLET',
                        value: member.fullName,
                      ),
                      const Divider(),
                      InfoRow(
                        icon: Icons.email_outlined,
                        label: 'EMAIL',
                        value: member.email,
                      ),
                      if (member.telephone != null &&
                          member.telephone!.isNotEmpty) ...[
                        const Divider(),
                        InfoRow(
                          icon: Icons.phone_outlined,
                          label: 'TÉLÉPHONE',
                          value: member.telephone!,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Déconnexion'),
        content: const Text('Voulez-vous vraiment vous déconnecter ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorColor,
            ),
            child: const Text('Déconnexion'),
          ),
        ],
      ),
    );
    if (confirm == true && context.mounted) {
      await context.read<AuthProvider>().logout();
    }
  }
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      elevation: 2,
      shadowColor: Colors.black.withAlpha(15),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withAlpha(25),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 22),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
