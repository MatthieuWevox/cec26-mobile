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
      body: Column(
        children: [
          CecPageHeader(
            eyebrow: 'Annuaire professionnel',
            title: 'Entreprises',
            subtitle: 'Découvrez les savoir-faire qui font vivre le Cotentin.',
            icon: Icons.apartment_rounded,
            trailing: Tooltip(
              message: 'Voir les membres',
              child: IconButton.filled(
                onPressed: _openMembers,
                icon: const Icon(Icons.people_alt_outlined),
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

                return RefreshIndicator(
                  color: AppTheme.primaryColor,
                  onRefresh: _refresh,
                  child: CustomScrollView(
                    slivers: [
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(16, 18, 16, 10),
                          child: Column(
                            children: [
                              CecSearchField(
                                hintText: 'Nom, activité ou spécialité',
                                onChanged: (value) {
                                  setState(() => _search = value);
                                },
                              ),
                              const SizedBox(height: 13),
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${items.length} entreprise${items.length > 1 ? 's' : ''}',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.bodySmall,
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
                      if (items.isEmpty)
                        const SliverFillRemaining(
                          hasScrollBody: false,
                          child: CecEmptyWidget(
                            message:
                                'Aucune entreprise ne correspond à la recherche.',
                            icon: Icons.search_off_rounded,
                          ),
                        )
                      else
                        SliverPadding(
                          padding: const EdgeInsets.fromLTRB(16, 0, 16, 28),
                          sliver: SliverList.separated(
                            itemCount: items.length,
                            itemBuilder: (_, index) {
                              return _CompanyCard(
                                company: items[index],
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

class _CompanyCard extends StatelessWidget {
  final Company company;
  final VoidCallback onHidden;

  const _CompanyCard({required this.company, required this.onHidden});

  @override
  Widget build(BuildContext context) {
    final memberCount = company.members?.length ?? 0;

    return CecSurface(
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
          if (company.photoUrl != null && company.photoUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 5.5,
              child: Image.network(
                company.photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => const ColoredBox(
                  color: AppTheme.surfaceMuted,
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Hero(
                  tag: 'company-logo-${company.id}',
                  child: CompanyLogo(
                    logoUrl: company.logoUrl,
                    companyName: company.nom,
                    size: 58,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        company.nom,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      if (company.sousTitre?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 4),
                        Text(
                          company.sousTitre!,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                      if (company.activites?.isNotEmpty ?? false) ...[
                        const SizedBox(height: 9),
                        CecBadge(
                          label: company.activites!,
                          color: AppTheme.accentDark,
                          icon: Icons.sell_outlined,
                        ),
                      ],
                      const SizedBox(height: 11),
                      Row(
                        children: [
                          Expanded(
                            child: CecMeta(
                              icon: Icons.people_outline_rounded,
                              text:
                                  '$memberCount membre${memberCount > 1 ? 's' : ''}',
                            ),
                          ),
                          const Icon(
                            Icons.arrow_forward_rounded,
                            color: AppTheme.primaryColor,
                            size: 18,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
