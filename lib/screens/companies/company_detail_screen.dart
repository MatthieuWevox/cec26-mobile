import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
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
    if (hidden && context.mounted) Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = company.photoUrl?.isNotEmpty ?? false;
    return Scaffold(
      appBar: const CecGlassAppBar(title: Text('L’entreprise')),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          SizedBox(
            height: hasPhoto ? 198 : 130,
            child: Stack(
              children: [
                Positioned(
                  left: 0,
                  right: 0,
                  top: 0,
                  bottom: 32,
                  child: SizedBox(
                    key: const Key('company-banner'),
                    child: hasPhoto
                        ? CachedNetworkImage(
                            imageUrl: company.photoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, _, _) =>
                                const ColoredBox(color: AppTheme.accentSoft),
                          )
                        : const ColoredBox(color: AppTheme.accentSoft),
                  ),
                ),
                // The opaque logo is a foreground sibling, never part of the banner.
                Positioned(
                  left: 22,
                  bottom: 0,
                  child: Hero(
                    tag: 'company-logo-${company.id}',
                    child: CompanyLogo(
                      key: const Key('company-logo-foreground'),
                      logoUrl: company.logoUrl,
                      companyName: company.nom,
                      size: 80,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(22, 20, 22, 0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  company.nom,
                  style: Theme.of(context).textTheme.headlineLarge,
                ),
                if (company.sousTitre?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 8),
                  Text(
                    company.sousTitre!,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
                if (company.activites?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 16),
                  CecBadge(
                    label: company.activites!,
                    color: AppTheme.accentDark,
                  ),
                ],
                const SizedBox(height: 24),
                const Divider(),
                if (company.description?.isNotEmpty ?? false) ...[
                  const SectionHeader(title: 'À propos'),
                  Text(
                    company.description!,
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
                if (company.members?.isNotEmpty ?? false) ...[
                  const SectionHeader(title: 'Les visages de l’entreprise'),
                  for (final m in company.members!)
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(vertical: 8),
                      leading: Hero(
                        tag: 'member-avatar-${m.id}',
                        child: MemberAvatar(
                          name: m.fullName,
                          imageUrl: m.photoUrl,
                        ),
                      ),
                      title: Text(m.fullName),
                      subtitle: m.presentation?.isNotEmpty == true
                          ? Text(
                              m.presentation!,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            )
                          : null,
                      trailing: const Icon(
                        Icons.chevron_right_rounded,
                        size: 20,
                      ),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              MemberDetailScreen(member: m, company: company),
                        ),
                      ),
                    ),
                ],
                const SizedBox(height: 20),
                const Divider(),
                TextButton.icon(
                  onPressed: () => _report(context),
                  icon: const Icon(Icons.flag_outlined, size: 18),
                  label: const Text('Signaler une information'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
