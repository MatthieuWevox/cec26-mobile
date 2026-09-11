import 'package:flutter/material.dart';

import '../../models/member.dart';
import '../../services/api_service.dart';
import '../../services/content_visibility_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import 'member_detail_screen.dart';

class MembersScreen extends StatefulWidget {
  const MembersScreen({super.key});

  @override
  State<MembersScreen> createState() => _MembersScreenState();
}

class _MembersScreenState extends State<MembersScreen> {
  late Future<List<Member>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _getVisibleMembers();
  }

  Future<List<Member>> _getVisibleMembers() async {
    final results = await Future.wait([
      const ApiService().getMembers(),
      ContentVisibilityService.hiddenIds('member'),
    ]);
    final members = results[0] as List<Member>;
    final hiddenIds = results[1] as Set<int>;
    return members.where((member) => !hiddenIds.contains(member.id)).toList();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          CecPageHeader(
            eyebrow: 'Le réseau CEC',
            title: 'Membres',
            subtitle: 'Retrouvez les entrepreneurs et entrepreneuses du club.',
            icon: Icons.people_alt_rounded,
            trailing: Tooltip(
              message: 'Fermer',
              child: IconButton.filled(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.close_rounded),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppTheme.primaryColor,
                  fixedSize: const Size(46, 46),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Member>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CecLoadingWidget(
                    message: 'Chargement des membres...',
                  );
                }
                if (snapshot.hasError) {
                  return CecErrorWidget(
                    message: snapshot.error.toString(),
                    onRetry: () => setState(_load),
                  );
                }

                final all = snapshot.data ?? [];
                final query = _search.trim().toLowerCase();
                final items = query.isEmpty
                    ? all
                    : all.where((member) {
                        return member.fullName.toLowerCase().contains(query) ||
                            (member.company?.nom ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (member.presentation ?? '').toLowerCase().contains(
                              query,
                            );
                      }).toList();

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 14),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              CecSearchField(
                                hintText: 'Nom, entreprise ou expertise',
                                onChanged: (value) {
                                  setState(() => _search = value);
                                },
                              ),
                              const SizedBox(height: 13),
                              Text(
                                '${items.length} membre${items.length > 1 ? 's' : ''}',
                                style: Theme.of(context).textTheme.bodySmall,
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (items.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: CecEmptyWidget(
                            message:
                                'Aucun membre ne correspond à la recherche.',
                            icon: Icons.person_search_rounded,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          sliver: SliverList.separated(
                            itemCount: items.length,
                            itemBuilder: (_, index) {
                              return _MemberCard(
                                member: items[index],
                                onHidden: () => setState(_load),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
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
    );
  }
}

class _MemberCard extends StatelessWidget {
  final Member member;
  final VoidCallback onHidden;

  const _MemberCard({required this.member, required this.onHidden});

  @override
  Widget build(BuildContext context) {
    return CecSurface(
      onTap: () async {
        final hidden = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => MemberDetailScreen(member: member)),
        );
        if (hidden == true) onHidden();
      },
      padding: const EdgeInsets.all(15),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          MemberAvatar(
            imageUrl: member.photoUrl,
            name: member.fullName,
            radius: 29,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  member.fullName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                if (member.company != null) ...[
                  const SizedBox(height: 4),
                  CecMeta(
                    icon: Icons.apartment_rounded,
                    text: member.company!.nom,
                    color: AppTheme.accentDark,
                  ),
                ],
                if (member.presentation?.isNotEmpty ?? false) ...[
                  const SizedBox(height: 7),
                  Text(
                    member.presentation!,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
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
