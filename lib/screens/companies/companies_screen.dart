import 'package:flutter/material.dart';
import '../../models/member.dart';
import '../../services/api_service.dart';
import '../../services/content_visibility_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../members/member_detail_screen.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  final bool initiallyMembers;
  const CompaniesScreen({super.key, this.initiallyMembers = false});
  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _DirectoryData {
  final List<Company> companies;
  final List<Member> members;
  const _DirectoryData(this.companies, this.members);
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  late Future<_DirectoryData> _future;
  late bool _members;
  String _search = '';
  String? _activity;
  @override
  void initState() {
    super.initState();
    _members = widget.initiallyMembers;
    _load();
  }

  void _load() {
    _future = _fetch();
  }

  Future<_DirectoryData> _fetch() async {
    final results = await Future.wait([
      const ApiService().getCompanies(),
      const ApiService().getMembers(),
      ContentVisibilityService.hiddenIds('company'),
      ContentVisibilityService.hiddenIds('member'),
    ]);
    return _DirectoryData(
      (results[0] as List<Company>)
          .where((c) => !(results[2] as Set<int>).contains(c.id))
          .toList(),
      (results[1] as List<Member>)
          .where((m) => !(results[3] as Set<int>).contains(m.id))
          .toList(),
    );
  }

  Future<void> _refresh() async {
    setState(_load);
    try {
      await _future;
    } catch (_) {
      /* Rendered by FutureBuilder. */
    }
  }

  Future<void> _open(Widget screen) async {
    final hidden = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => screen),
    );
    if (hidden == true && mounted) setState(_load);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: LayoutBuilder(
      builder: (context, constraints) => Column(
        children: [
          if (constraints.maxHeight >= 520)
            const CecPageHeader(
              eyebrow: 'Entrepreneurs du Cotentin',
              title: 'Le bon contact.',
              subtitle: 'Des talents d’ici. Des projets en commun.',
              icon: Icons.people_outline,
            ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 22),
            child: Column(
              children: [
                SizedBox(
                  width: double.infinity,
                  child: SegmentedButton<bool>(
                    showSelectedIcon: false,
                    segments: const [
                      ButtonSegment(value: false, label: Text('Entreprises')),
                      ButtonSegment(value: true, label: Text('Membres')),
                    ],
                    selected: {_members},
                    onSelectionChanged: (v) =>
                        setState(() => _members = v.first),
                  ),
                ),
                const SizedBox(height: 16),
                CecSearchField(
                  hintText: 'Un nom, une entreprise, un métier…',
                  onChanged: (value) => setState(() => _search = value),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: FutureBuilder<_DirectoryData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const CecLoadingWidget();
                }
                if (snapshot.hasError) {
                  return CecErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_load),
                  );
                }
                final data = snapshot.data!;
                final activities =
                    data.companies
                        .map((c) => c.activites?.trim() ?? '')
                        .where((a) => a.isNotEmpty)
                        .toSet()
                        .toList()
                      ..sort();
                final activity = activities.contains(_activity)
                    ? _activity
                    : null;
                final query = _search.trim().toLowerCase();
                final companies = data.companies
                    .where(
                      (c) =>
                          (activity == null ||
                              c.activites?.trim() == activity) &&
                          '${c.nom} ${c.sousTitre ?? ''} ${c.activites ?? ''} ${c.members?.map((m) => m.fullName).join(' ') ?? ''}'
                              .toLowerCase()
                              .contains(query),
                    )
                    .toList();
                final members = data.members
                    .where(
                      (m) =>
                          (activity == null ||
                              m.company?.activites?.trim() == activity) &&
                          '${m.fullName} ${m.company?.nom ?? ''} ${m.presentation ?? ''}'
                              .toLowerCase()
                              .contains(query),
                    )
                    .toList();
                final count = _members ? members.length : companies.length;
                return RefreshIndicator(
                  onRefresh: _refresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.only(bottom: 126),
                    children: [
                      if (activities.isNotEmpty)
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 22,
                            vertical: 6,
                          ),
                          child: Row(
                            children: [
                              ChoiceChip(
                                showCheckmark: false,
                                label: Text(
                                  'Tous',
                                  style: TextStyle(
                                    color: activity == null
                                        ? Colors.white
                                        : AppTheme.primaryColor,
                                  ),
                                ),
                                selected: activity == null,
                                onSelected: (_) =>
                                    setState(() => _activity = null),
                              ),
                              for (final a in activities)
                                Padding(
                                  padding: const EdgeInsets.only(left: 8),
                                  child: ChoiceChip(
                                    showCheckmark: false,
                                    label: ConstrainedBox(
                                      constraints: const BoxConstraints(
                                        maxWidth: 180,
                                      ),
                                      child: Text(
                                        a,
                                        style: TextStyle(
                                          color: activity == a
                                              ? Colors.white
                                              : AppTheme.primaryColor,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    selected: activity == a,
                                    onSelected: (_) =>
                                        setState(() => _activity = a),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(22, 12, 22, 0),
                        child: Text(
                          '$count ${_members ? 'membre' : 'entreprise'}${count > 1 ? 's' : ''}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      if (count == 0)
                        const CecEmptyWidget(
                          message:
                              'Aucun résultat. Essayez une autre recherche.',
                          icon: Icons.search_off,
                        ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 22),
                        child: Column(
                          children: [
                            if (_members)
                              for (final m in members)
                                _DirectoryRow(
                                  leading: Hero(
                                    tag: 'member-avatar-${m.id}',
                                    child: MemberAvatar(
                                      name: m.fullName,
                                      imageUrl: m.photoUrl,
                                      radius: 25,
                                    ),
                                  ),
                                  title: m.fullName,
                                  subtitle: m.company?.nom ?? '',
                                  onTap: () =>
                                      _open(MemberDetailScreen(member: m)),
                                )
                            else
                              for (final c in companies)
                                _DirectoryRow(
                                  leading: Hero(
                                    tag: 'company-logo-${c.id}',
                                    child: CompanyLogo(
                                      companyName: c.nom,
                                      logoUrl: c.logoUrl,
                                      size: 56,
                                    ),
                                  ),
                                  title: c.nom,
                                  subtitle: c.activites ?? c.sousTitre ?? '',
                                  detail: c.members
                                      ?.map((m) => m.fullName)
                                      .join(', '),
                                  onTap: () =>
                                      _open(CompanyDetailScreen(company: c)),
                                ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    ),
  );
}

class _DirectoryRow extends StatelessWidget {
  final Widget leading;
  final String title, subtitle;
  final String? detail;
  final VoidCallback onTap;
  const _DirectoryRow({
    required this.leading,
    required this.title,
    required this.subtitle,
    this.detail,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) => InkWell(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.symmetric(vertical: 20),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: AppTheme.dividerColor)),
      ),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                if (subtitle.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
                if (detail?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 5),
                  Text(
                    detail!,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppTheme.accentDark,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.chevron_right_rounded,
            size: 20,
            color: AppTheme.textSecondary,
          ),
        ],
      ),
    ),
  );
}
