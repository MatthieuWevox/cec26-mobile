import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/member.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MemberDetailScreen extends StatefulWidget {
  final Member member;

  const MemberDetailScreen({super.key, required this.member});

  @override
  State<MemberDetailScreen> createState() => _MemberDetailScreenState();
}

class _MemberDetailScreenState extends State<MemberDetailScreen> {
  Member get member => widget.member;

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
      body: CecBackground(
        accentTop: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 258,
              pinned: true,
              stretch: true,
              toolbarHeight: 64,
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leadingWidth: 68,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                child: CecGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Retour',
                  dark: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                stretchModes: const [StretchMode.zoomBackground],
                background: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Positioned(
                          right: -42,
                          top: 36,
                          child: Icon(
                            Icons.people_alt_rounded,
                            size: 150,
                            color: AppTheme.accentColor.withAlpha(18),
                          ),
                        ),
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(20, 54, 20, 18),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Hero(
                                  tag: 'member-avatar-${member.id}',
                                  child: MemberAvatar(
                                    imageUrl: member.photoUrl,
                                    name: member.fullName,
                                    radius: 44,
                                  ),
                                ),
                                const SizedBox(height: 13),
                                Text(
                                  member.fullName,
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(color: Colors.white),
                                ),
                                if (member.company != null) ...[
                                  const SizedBox(height: 5),
                                  Text(
                                    member.company!.nom,
                                    textAlign: TextAlign.center,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodySmall
                                        ?.copyWith(
                                          color: AppTheme.accentColor,
                                          fontWeight: FontWeight.w600,
                                        ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CecContentWidth(
                maxWidth: 760,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 48),
                  child: CecReveal(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: _sendEmail,
                                icon: const Icon(
                                  Icons.email_outlined,
                                  size: 19,
                                ),
                                label: const Text('Écrire'),
                              ),
                            ),
                            if (member.telephone?.isNotEmpty ?? false) ...[
                              const SizedBox(width: 10),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: _call,
                                  icon: const Icon(
                                    Icons.phone_outlined,
                                    size: 19,
                                  ),
                                  label: const Text('Appeler'),
                                ),
                              ),
                            ],
                          ],
                        ),
                        if (member.company != null) ...[
                          const SectionHeader(
                            title: 'Entreprise',
                            subtitle: 'Structure représentée dans le réseau.',
                          ),
                          CecSurface(
                            glass: true,
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                CompanyLogo(
                                  logoUrl: member.company!.logoUrl,
                                  companyName: member.company!.nom,
                                  size: 54,
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        member.company!.nom,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleLarge,
                                      ),
                                      if (member
                                              .company!
                                              .sousTitre
                                              ?.isNotEmpty ??
                                          false) ...[
                                        const SizedBox(height: 4),
                                        Text(
                                          member.company!.sousTitre!,
                                          style: Theme.of(
                                            context,
                                          ).textTheme.bodySmall,
                                        ),
                                      ],
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        const SectionHeader(
                          title: 'Coordonnées',
                          subtitle: 'Informations de contact professionnelles.',
                        ),
                        CecSurface(
                          glass: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          child: Column(
                            children: [
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
                        ),
                        if (member.presentation?.isNotEmpty ?? false) ...[
                          const SectionHeader(
                            title: 'Présentation',
                            subtitle: 'Parcours, activité et expertises.',
                          ),
                          CecSurface(
                            color: AppTheme.accentSoft,
                            padding: const EdgeInsets.all(18),
                            child: Text(
                              member.presentation!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        Wrap(
                          alignment: WrapAlignment.center,
                          runAlignment: WrapAlignment.center,
                          spacing: 8,
                          runSpacing: 4,
                          children: [
                            TextButton.icon(
                              onPressed: () => _report(context),
                              icon: const Icon(Icons.flag_outlined, size: 18),
                              label: const Text('Signaler'),
                            ),
                            if (canBlock)
                              TextButton.icon(
                                onPressed: _blockLoading ? null : _toggleBlock,
                                icon: _blockLoading
                                    ? const SizedBox.square(
                                        dimension: 17,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : Icon(
                                        _isBlocked
                                            ? Icons.person_add_alt_1_outlined
                                            : Icons.block_outlined,
                                        size: 18,
                                      ),
                                label: Text(
                                  _isBlocked
                                      ? 'Débloquer'
                                      : 'Bloquer ce membre',
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
