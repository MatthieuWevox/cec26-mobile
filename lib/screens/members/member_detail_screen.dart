import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/member.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../companies/company_detail_screen.dart';
import '../private/recommendations_screen.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;
  final Company? company;

  const MemberDetailScreen({super.key, required this.member, this.company});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Member get member => widget.member;
  Company? get company => widget.company ?? member.company;

  bool _isBlocked = false;
  bool _blockLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadBlockStatus());
  }

  Future<void> _loadBlockStatus() async {
    final auth = context.read<AuthProvider>();
    if (auth.token == null || auth.currentMember?.id == member.id) return;

    try {
      final ids = await ApiService(authToken: auth.token).getBlockedMemberIds();
      if (mounted) setState(() => _isBlocked = ids.contains(member.id));
    } catch (_) {}
  }

  Future<void> _sendEmail() async {
    await launchUrl(Uri(scheme: 'mailto', path: member.email));
  }

  Future<void> _call() async {
    final phone = member.telephone?.replaceAll(' ', '');
    if (phone != null && phone.isNotEmpty) {
      await launchUrl(Uri(scheme: 'tel', path: phone));
    }
  }

  Future<void> _report(BuildContext context) async {
    final authToken = context.read<AuthProvider>().token;
    final hidden = await ReportingService.reportContent(
      context,
      contentType: 'member',
      contentId: member.id,
      contentName: member.fullName,
      authToken: authToken,
    );
    if (hidden && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  Future<void> _toggleBlock() async {
    final auth = context.read<AuthProvider>();
    final token = auth.token;
    if (token == null) return;

    if (!_isBlocked) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Bloquer ce membre ?'),
          content: const Text(
            'Vous ne pourrez plus échanger de recommandations ou de '
            'remerciements avec cette personne. Vous pourrez la débloquer '
            'plus tard.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Annuler'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Bloquer'),
            ),
          ],
        ),
      );
      if (confirmed != true) return;
    }

    setState(() => _blockLoading = true);
    try {
      final api = ApiService(authToken: token);
      if (_isBlocked) {
        await api.unblockMember(member.id);
      } else {
        await api.blockMember(member.id);
      }
      if (!mounted) return;
      setState(() {
        _isBlocked = !_isBlocked;
        _blockLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _isBlocked ? 'Ce membre est bloqué.' : 'Ce membre est débloqué.',
          ),
          backgroundColor: AppTheme.successColor,
        ),
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() => _blockLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.message),
          backgroundColor: AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final canBlock = auth.isLoggedIn && auth.currentMember?.id != member.id;
    return Scaffold(
      appBar: const CecGlassAppBar(title: Text('Le membre')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 26, 22, 40),
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Hero(
              tag: 'member-avatar-${member.id}',
              child: MemberAvatar(
                name: member.fullName,
                imageUrl: member.photoUrl,
                radius: 40,
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            member.fullName,
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          if (company != null) ...[
            const SizedBox(height: 6),
            Text(
              company!.nom,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
          ],
          const SizedBox(height: 24),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: _sendEmail,
                icon: const Icon(Icons.mail_outline, size: 18),
                label: const Text('Écrire'),
              ),
              if (member.telephone?.isNotEmpty ?? false)
                OutlinedButton.icon(
                  onPressed: _call,
                  icon: const Icon(Icons.phone_outlined, size: 18),
                  label: const Text('Appeler'),
                ),
            ],
          ),
          if (member.presentation?.isNotEmpty ?? false) ...[
            const SectionHeader(title: 'Une expertise, une rencontre.'),
            Text(
              member.presentation!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          if (company != null) ...[
            const SectionHeader(title: 'Entreprise'),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: CompanyLogo(
                companyName: company!.nom,
                logoUrl: company!.logoUrl,
                size: 52,
              ),
              title: Text(company!.nom),
              trailing: const Icon(Icons.north_east_rounded, size: 18),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CompanyDetailScreen(company: company!),
                ),
              ),
            ),
          ],
          const SectionHeader(title: 'Coordonnées'),
          InfoRow(
            icon: Icons.mail_outline,
            label: 'Email',
            value: member.email,
          ),
          if (member.telephone?.isNotEmpty ?? false)
            InfoRow(
              icon: Icons.phone_outlined,
              label: 'Téléphone',
              value: member.telephone!,
            ),
          if (canBlock && !_isBlocked) ...[
            const SizedBox(height: 22),
            FilledButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => Scaffold(
                    appBar: const CecGlassAppBar(
                      title: Text('Nouvelle recommandation'),
                    ),
                    body: CreateRecommendationSheet(
                      initialRecipient: member,
                      onCreated: () {},
                    ),
                  ),
                ),
              ),
              icon: const Icon(Icons.send_outlined, size: 18),
              label: const Text('Faire une recommandation'),
            ),
          ],
          const SizedBox(height: 24),
          const Divider(),
          Wrap(
            spacing: 10,
            children: [
              TextButton.icon(
                onPressed: () => _report(context),
                icon: const Icon(Icons.flag_outlined, size: 18),
                label: const Text('Signaler'),
              ),
              if (canBlock)
                TextButton.icon(
                  onPressed: _blockLoading ? null : _toggleBlock,
                  icon: const Icon(Icons.block_outlined, size: 18),
                  label: Text(_isBlocked ? 'Débloquer' : 'Bloquer ce membre'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
