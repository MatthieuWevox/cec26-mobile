import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../providers/auth_provider.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../members/member_detail_screen.dart';

class CompanyDetailScreen extends StatelessWidget {
  final Company company;

  const CompanyDetailScreen({super.key, required this.company});

  Future<void> _report(BuildContext context) async {
    final hidden = await ReportingService.reportContent(
      context,
      contentType: 'company',
      contentId: company.id,
      contentName: company.nom,
      authToken: context.read<AuthProvider>().token,
    );
    if (hidden && context.mounted) {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = company.photoUrl?.isNotEmpty ?? false;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: hasPhoto ? 250 : 150,
            pinned: true,
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            iconTheme: const IconThemeData(color: Colors.white),
            surfaceTintColor: Colors.transparent,
            systemOverlayStyle: SystemUiOverlayStyle.light,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (hasPhoto)
                    CachedNetworkImage(
                      imageUrl: company.photoUrl!,
                      fit: BoxFit.cover,
                      errorWidget: (_, __, ___) =>
                          const ColoredBox(color: AppTheme.primaryDark),
                    )
                  else
                    const ColoredBox(color: AppTheme.primaryDark),
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x10000000), Color(0xE617143E)],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Transform.translate(
                    offset: const Offset(0, -28),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Hero(
                          tag: 'company-logo-${company.id}',
                          child: CompanyLogo(
                            logoUrl: company.logoUrl,
                            companyName: company.nom,
                            size: 76,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 3),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  company.nom,
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineMedium,
                                ),
                                if (company.sousTitre?.isNotEmpty ?? false) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    company.sousTitre!,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(
                                      context,
                                    ).textTheme.bodySmall,
                                  ),
                                ],
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (company.activites?.isNotEmpty ?? false) ...[
                    CecBadge(
                      label: company.activites!,
                      color: AppTheme.accentDark,
                      icon: Icons.sell_outlined,
                    ),
                    const SizedBox(height: 22),
                  ],
                  if (company.description?.isNotEmpty ?? false) ...[
                    Text(
                      'À propos',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 10),
                    CecSurface(
                      padding: const EdgeInsets.all(18),
                      child: Text(
                        company.description!,
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                  if (company.members?.isNotEmpty ?? false) ...[
                    SectionHeader(
                      title: 'Équipe',
                      subtitle:
                          '${company.members!.length} membre${company.members!.length > 1 ? 's' : ''} dans le réseau.',
                    ),
                    for (final member in company.members!) ...[
                      _MemberTile(member: member),
                      const SizedBox(height: 9),
                    ],
                  ],
                  const SizedBox(height: 24),
                  Align(
                    alignment: Alignment.center,
                    child: TextButton.icon(
                      onPressed: () => _report(context),
                      icon: const Icon(Icons.flag_outlined, size: 18),
                      label: const Text('Signaler une information'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MemberTile extends StatelessWidget {
  final Member member;

  const _MemberTile({required this.member});

  @override
  Widget build(BuildContext context) {
    return CecSurface(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
      ),
      padding: const EdgeInsets.all(13),
      child: Row(
        children: [
          Hero(
            tag: 'member-avatar-${member.id}',
            child: MemberAvatar(
              imageUrl: member.photoUrl,
              name: member.fullName,
              radius: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                if (member.presentation?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 3),
                  Text(
                    member.presentation!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_rounded,
            color: AppTheme.primaryColor,
            size: 18,
          ),
        ],
      ),
    );
  }
}
