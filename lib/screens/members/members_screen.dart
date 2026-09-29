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
      body: CecBackground(
        child: Column(
          children: [
            CecPageHeader(
              eyebrow: 'Le réseau CEC',
              title: 'Membres',
              subtitle: 'Les personnes derrière les entreprises du territoire.',
              icon: Icons.people_alt_rounded,
              contentMaxWidth: 1040,
              trailing: CecGlassIconButton(
                icon: Icons.close_rounded,
                tooltip: 'Fermer',
                dark: false,
                onPressed: () => Navigator.pop(context),
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
                          return member.fullName.toLowerCase().contains(
                                query,
                              ) ||
                              (member.company?.nom ?? '')
                                  .toLowerCase()
                                  .contains(query) ||
                              (member.presentation ?? '')
                                  .toLowerCase()
                                  .contains(query);
                        }).toList();

                  return LayoutBuilder(
                    builder: (context, constraints) {
                      final wide = constraints.maxWidth >= 900;
                      final horizontalPadding = wide
                          ? (constraints.maxWidth - 1040).clamp(20.0, 80.0)
                          : 16.0;

                      return RefreshIndicator(
                        color: AppTheme.primaryColor,
                        onRefresh: _refresh,
                        child: CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            SliverToBoxAdapter(
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  16,
                                ),
                                child: CecReveal(
                                  child: Padding(
                                    padding: EdgeInsets.zero,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        CecSearchField(
                                          hintText:
                                              'Nom, entreprise ou expertise',
                                          onChanged: (value) {
                                            setState(() => _search = value);
                                          },
                                        ),
                                        const SizedBox(height: 9),
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            left: 4,
                                          ),
                                          child: Text(
                                            '${items.length} membre${items.length > 1 ? 's' : ''}',
                                            style: Theme.of(
                                              context,
                                            ).textTheme.bodySmall,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
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
                            else if (wide)
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  38,
                                ),
                                sliver: SliverGrid.builder(
                                  itemCount: items.length,
                                  gridDelegate:
                                      const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2,
                                        crossAxisSpacing: 14,
                                        mainAxisSpacing: 14,
                                        mainAxisExtent: 112,
                                      ),
                                  itemBuilder: (_, index) => CecReveal(
                                    delay: Duration(
                                      milliseconds: index.clamp(0, 5) * 40,
                                    ),
                                    child: _MemberCard(
                                      member: items[index],
                                      onHidden: () => setState(_load),
                                    ),
                                  ),
                                ),
                              )
                            else
                              SliverPadding(
                                padding: EdgeInsets.fromLTRB(
                                  horizontalPadding,
                                  0,
                                  horizontalPadding,
                                  38,
                                ),
                                sliver: SliverList.separated(
                                  itemCount: items.length,
                                  itemBuilder: (_, index) => CecReveal(
                                    delay: Duration(
                                      milliseconds: index.clamp(0, 5) * 40,
                                    ),
                                    child: _MemberCard(
                                      member: items[index],
                                      onHidden: () => setState(_load),
                                    ),
                                  ),
                                  separatorBuilder: (_, __) =>
                                      const SizedBox(height: 11),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
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
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'member-avatar-${member.id}',
            child: MemberAvatar(
              imageUrl: member.photoUrl,
              name: member.fullName,
              radius: 29,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
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
                if (member.company == null &&
                    (member.presentation?.isNotEmpty ?? false)) ...[
                  const SizedBox(height: 4),
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
          const SizedBox(width: 8),
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
