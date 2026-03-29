import 'package:flutter/material.dart';

import '../../models/member.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';
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
    _future = const ApiService().getCompanies();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Entreprises'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => setState(() => _load()),
          ),
        ],
      ),
      body: FutureBuilder<List<Company>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CecLoadingWidget(
              message: 'Chargement des entreprises…',
            );
          }
          if (snapshot.hasError) {
            return CecErrorWidget(
              message: snapshot.error.toString(),
              onRetry: () => setState(() => _load()),
            );
          }
          final all = snapshot.data ?? [];
          final items = _search.isEmpty
              ? all
              : all
                  .where(
                    (c) =>
                        c.nom.toLowerCase().contains(_search.toLowerCase()) ||
                        (c.activites ?? '')
                            .toLowerCase()
                            .contains(_search.toLowerCase()),
                  )
                  .toList();

          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Rechercher une entreprise…',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                  onChanged: (v) => setState(() => _search = v),
                ),
              ),
              Expanded(
                child: items.isEmpty
                    ? const CecEmptyWidget(
                        message: 'Aucune entreprise trouvée.',
                        icon: Icons.business_rounded,
                      )
                    : RefreshIndicator(
                        color: AppTheme.primaryColor,
                        onRefresh: () async => setState(() => _load()),
                        child: ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 24),
                          itemCount: items.length,
                          itemBuilder: (context, index) =>
                              _CompanyCard(company: items[index]),
                        ),
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _CompanyCard extends StatelessWidget {
  final Company company;
  const _CompanyCard({required this.company});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => CompanyDetailScreen(company: company),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CompanyLogo(
                logoUrl: company.logoUrl,
                companyName: company.nom,
                size: 56,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      company.nom,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    if (company.sousTitre != null &&
                        company.sousTitre!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        company.sousTitre!,
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (company.activites != null &&
                        company.activites!.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        company.activites!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.accentColor,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (company.members != null &&
                        company.members!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const Icon(
                            Icons.people_outline_rounded,
                            size: 13,
                            color: AppTheme.textSecondary,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${company.members!.length} membre${company.members!.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: AppTheme.textSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
