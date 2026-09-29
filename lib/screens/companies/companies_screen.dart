import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/member.dart';
import '../../services/api_service.dart';
import '../../services/content_visibility_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
import '../members/members_screen.dart';
import 'company_detail_screen.dart';

class CompaniesScreen extends StatefulWidget {
  const CompaniesScreen({super.key});

  @override
  State<CompaniesScreen> createState() => _CompaniesScreenState();
}

class _CompaniesScreenState extends State<CompaniesScreen> {
  late Future<List<Company>> _future;
  String _search = '';

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _future = _getVisibleCompanies();
  }

  Future<List<Company>> _getVisibleCompanies() async {
    final results = await Future.wait([
      const ApiService().getCompanies(),
      ContentVisibilityService.hiddenIds('company'),
    ]);
    final companies = results[0] as List<Company>;
    final hiddenIds = results[1] as Set<int>;
    return companies
        .where((company) => !hiddenIds.contains(company.id))
        .toList();
  }

  Future<void> _refresh() async {
    setState(_load);
    await _future;
  }

  void _openMembers() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MembersScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          CecPageHeader(
            eyebrow: 'Annuaire professionnel',
            title: 'Entreprises',
            subtitle: 'Les savoir-faire et les talents du Cotentin.',
            icon: Icons.apartment_rounded,
            contentMaxWidth: 1040,
            trailing: CecGlassIconButton(
              icon: Icons.people_alt_outlined,
              tooltip: 'Voir les membres',
              dark: false,
              onPressed: _openMembers,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Company>>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const CecLoadingWidget(
                    message: 'Chargement des entreprises...',
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
                    : all.where((company) {
                        return company.nom.toLowerCase().contains(query) ||
                            (company.sousTitre ?? '').toLowerCase().contains(
                              query,
                            ) ||
                            (company.activites ?? '').toLowerCase().contains(
                              query,
                            );
                      }).toList();

                return LayoutBuilder(
                  builder: (context, constraints) {
                    final wide = constraints.maxWidth >= 900;
                    final horizontalPadding = wide
                        ? (constraints.maxWidth - 1040).clamp(20.0, 80.0)
                        : 16.0;
                    final companyCardExtent = wide
                        ? ((constraints.maxWidth -
                                          (horizontalPadding * 2) -
                                          14) /
                                      2) *
                                  (5.8 / 16) +
                              140
                        : null;

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
                                    children: [
                                      CecSearchField(
                                        hintText: 'Nom, activité ou spécialité',
                                        onChanged: (value) {
                                          setState(() => _search = value);
                                        },
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: const EdgeInsets.only(
                                                left: 4,
                                              ),
                                              child: Text(
                                                '${items.length} entreprise${items.length > 1 ? 's' : ''}',
                                                style: Theme.of(
                                                  context,
                                                ).textTheme.bodySmall,
                                              ),
                                            ),
                                          ),
                                          TextButton.icon(
                                            onPressed: _openMembers,
                                            icon: const Icon(
                                              Icons.people_alt_outlined,
                                              size: 17,
                                            ),
                                            label: const Text('Membres'),
                                          ),
                                        ],
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
                                    'Aucune entreprise ne correspond à la recherche.',
                                icon: Icons.search_off_rounded,
                              ),
                            )
                          else if (wide)
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(
                                horizontalPadding,
                                0,
                                horizontalPadding,
                                126,
                              ),
                              sliver: SliverGrid.builder(
                                itemCount: items.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 14,
                                      mainAxisSpacing: 14,
                                      mainAxisExtent: companyCardExtent,
                                    ),
                                itemBuilder: (_, index) => CecReveal(
                                  delay: Duration(
                                    milliseconds: index.clamp(0, 5) * 45,
                                  ),
                                  child: _CompanyCard(
                                    company: items[index],
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
                                126,
                              ),
                              sliver: SliverList.separated(
                                itemCount: items.length,
                                itemBuilder: (_, index) => CecReveal(
                                  delay: Duration(
                                    milliseconds: index.clamp(0, 5) * 45,
                                  ),
                                  child: _CompanyCard(
                                    company: items[index],
                                    onHidden: () => setState(_load),
                                  ),
                                ),
                                separatorBuilder: (_, __) =>
                                    const SizedBox(height: 12),
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
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onHidden;

  const _CompanyCard({required this.company, required this.onHidden});

  @override
  Widget build(BuildContext context) {
    final memberCount = company.members?.length ?? 0;
    final hasPhoto = company.photoUrl?.isNotEmpty ?? false;

    return CecLayeredCard(
      child: CecSurface(
        padding: EdgeInsets.zero,
        onTap: () async {
          final hidden = await Navigator.push<bool>(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDetailScreen(company: company),
            ),
          );
          if (hidden == true) onHidden();
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 28),
                  child: SizedBox(
                    height: 112,
                    width: double.infinity,
                    child: hasPhoto
                        ? CachedNetworkImage(
                            imageUrl: company.photoUrl!,
                            fit: BoxFit.cover,
                            errorWidget: (_, __, ___) =>
                                const _CompanyFallback(),
                          )
                        : const _CompanyFallback(),
                  ),
                ),
                Positioned(
                  left: 18,
                  bottom: 0,
                  child: Hero(
                    tag: 'company-logo-${company.id}',
                    child: CompanyLogo(
                      logoUrl: company.logoUrl,
                      companyName: company.nom,
                      size: 64,
                    ),
                  ),
                ),
                Positioned(
                  right: 18,
                  top: 15,
                  child: CecBadge(
                    label: '$memberCount membre${memberCount > 1 ? 's' : ''}',
                    color: AppTheme.primaryColor,
                    icon: Icons.people_outline_rounded,
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    company.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  if (company.sousTitre?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 5),
                    Text(
                      company.sousTitre!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 18),
                  const Divider(height: 1),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          'Découvrir l’entreprise',
                          style: Theme.of(context).textTheme.labelLarge
                              ?.copyWith(color: AppTheme.primaryColor),
                        ),
                      ),
                      const Icon(
                        Icons.arrow_forward_rounded,
                        size: 19,
                        color: AppTheme.primaryColor,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CompanyFallback extends StatelessWidget {
  const _CompanyFallback();

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: AppTheme.accentSoft,
      child: Align(
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Icon(
            Icons.apartment_outlined,
            color: AppTheme.accentDark.withAlpha(100),
            size: 42,
          ),
        ),
      ),
    );
  }
}
