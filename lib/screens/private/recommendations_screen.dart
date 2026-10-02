import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/member.dart';
import '../../models/recommendation.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/content_visibility_service.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Recommendation>> _received;
  late Future<List<Recommendation>> _sent;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _load();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _load() {
    final token = context.read<AuthProvider>().token!;
    final api = ApiService(authToken: token);
    _received = _visibleRecommendations(api.getRecommendationsReceived());
    _sent = _visibleRecommendations(api.getRecommendationsSent());
  }

  Future<List<Recommendation>> _visibleRecommendations(
    Future<List<Recommendation>> request,
  ) async {
    final results = await Future.wait([
      request,
      ContentVisibilityService.hiddenIds('recommendation'),
    ]);
    final recommendations = results[0] as List<Recommendation>;
    final hiddenIds = results[1] as Set<int>;
    return recommendations
        .where((item) => !hiddenIds.contains(item.id))
        .toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CecGlassAppBar(title: Text('Recommandations')),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Text(
            'Les bonnes connexions.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Reçues'),
              Tab(text: 'Envoyées'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _RecommendationList(
                future: _received,
                isReceived: true,
                onHidden: () {
                  if (mounted) setState(_load);
                },
              ),
              _RecommendationList(
                future: _sent,
                isReceived: false,
                onHidden: () {
                  if (mounted) setState(_load);
                },
              ),
            ],
          ),
        ),
      ],
    ),
    bottomNavigationBar: SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
        child: ElevatedButton.icon(
          onPressed: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => Scaffold(
                appBar: const CecGlassAppBar(
                  title: Text('Nouvelle recommandation'),
                ),
                body: CreateRecommendationSheet(
                  onCreated: () {
                    if (mounted) setState(_load);
                  },
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text('Recommander un contact'),
        ),
      ),
    ),
  );
}

class _RecommendationList extends StatelessWidget {
  final Future<List<Recommendation>> future;
  final bool isReceived;
  final VoidCallback onHidden;

  const _RecommendationList({
    required this.future,
    required this.isReceived,
    required this.onHidden,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Recommendation>>(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CecLoadingWidget();
        }
        if (snapshot.hasError) {
          return CecErrorWidget(
            message: snapshot.error.toString(),
            onRetry: onHidden,
          );
        }
        final items = snapshot.data ?? [];
        if (items.isEmpty) {
          return CecEmptyWidget(
            message: isReceived
                ? 'Aucune recommandation reçue.'
                : 'Aucune recommandation envoyée.',
            icon: Icons.thumb_up_outlined,
          );
        }
        return LayoutBuilder(
          builder: (context, constraints) {
            final horizontal = constraints.maxWidth > 760
                ? (constraints.maxWidth - 720) / 2
                : 22.0;
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 20, horizontal, 28),
              itemCount: items.length,
              itemBuilder: (context, index) => CecReveal(
                delay: Duration(milliseconds: index.clamp(0, 5) * 45),
                child: _RecommendationCard(
                  rec: items[index],
                  isReceived: isReceived,
                  onHidden: onHidden,
                ),
              ),
              separatorBuilder: (_, __) => const SizedBox(height: 11),
            );
          },
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  final bool isReceived;
  final VoidCallback onHidden;

  const _RecommendationCard({
    required this.rec,
    required this.isReceived,
    required this.onHidden,
  });

  Future<void> _report(BuildContext context) async {
    final hidden = await ReportingService.reportContent(
      context,
      contentType: 'recommendation',
      contentId: rec.id,
      contentName:
          'Recommandation de ${rec.recommandateur?.fullName ?? 'membre'}',
      authToken: context.read<AuthProvider>().token,
    );
    if (hidden) {
      onHidden();
      if (context.mounted) Navigator.pop(context);
    }
  }

  String get _date {
    final value = rec.createdAt;
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : DateFormat('d MMM yyyy', 'fr_FR').format(date);
  }

  Member? get _otherMember => isReceived ? rec.recommandateur : rec.recommande;
  String get _title => rec.contactFullName;

  Future<void> _open(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (detailContext) => Scaffold(
          appBar: CecGlassAppBar(
            title: const Text('Recommandation'),
            actions: [
              if (isReceived)
                IconButton(
                  tooltip: 'Signaler',
                  onPressed: () async {
                    await _report(detailContext);
                  },
                  icon: const Icon(Icons.flag_outlined),
                ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
            children: [
              CecBadge(
                label: isReceived ? 'REÇUE' : 'ENVOYÉE',
                color: AppTheme.accentDark,
              ),
              const SizedBox(height: 20),
              Text(
                _title,
                style: Theme.of(detailContext).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Le $_date',
                style: Theme.of(detailContext).textTheme.bodySmall,
              ),
              if (_otherMember != null) ...[
                const SizedBox(height: 28),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: MemberAvatar(
                    name: _otherMember!.fullName,
                    imageUrl: _otherMember!.photoUrl,
                    radius: 24,
                  ),
                  title: Text(_otherMember!.fullName),
                  subtitle: Text(
                    isReceived
                        ? 'Vous recommande ce contact'
                        : 'Destinataire de votre recommandation',
                  ),
                ),
              ],
              const SectionHeader(title: 'Le contexte'),
              Text(
                rec.description?.isNotEmpty == true
                    ? rec.description!
                    : 'Aucun message complémentaire.',
              ),

              if (rec.email?.isNotEmpty == true ||
                  rec.telephone?.isNotEmpty == true)
                const SectionHeader(title: 'Coordonnées du contact'),
              if (rec.email?.isNotEmpty == true)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.mail_outline),
                  title: Text(rec.email!),
                  onTap: () => _contact(
                    detailContext,
                    Uri(scheme: 'mailto', path: rec.email!),
                  ),
                ),
              if (rec.telephone?.isNotEmpty == true)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.phone_outlined),
                  title: Text(rec.telephone!),
                  onTap: () => _contact(
                    detailContext,
                    Uri(
                      scheme: 'tel',
                      path: rec.telephone!.replaceAll(' ', ''),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _contact(BuildContext context, Uri uri) async {
    try {
      if (await launchUrl(uri)) return;
    } catch (_) {}
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Aucune application disponible pour cette action.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) => CecSurface(
    onTap: () => _open(context),
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            MemberAvatar(
              name: _otherMember?.fullName ?? 'Membre',
              imageUrl: _otherMember?.photoUrl,
              radius: 18,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _otherMember?.fullName ?? 'Membre',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    isReceived
                        ? 'Vous recommande un contact'
                        : 'Votre recommandation',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.north_east_rounded,
              size: 17,
              color: AppTheme.textSecondary,
            ),
          ],
        ),
        const SizedBox(height: 20),
        Text(_title, style: Theme.of(context).textTheme.titleLarge),

        if (rec.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            rec.description!,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
        const SizedBox(height: 18),
        const Divider(),
        const SizedBox(height: 12),
        Text(_date, style: Theme.of(context).textTheme.bodySmall),
      ],
    ),
  );
}

class CreateRecommendationSheet extends StatefulWidget {
  final VoidCallback onCreated;
  final Member? initialRecipient;
  const CreateRecommendationSheet({
    super.key,
    required this.onCreated,
    this.initialRecipient,
  });

  @override
  State<CreateRecommendationSheet> createState() =>
      _CreateRecommendationSheetState();
}

class _CreateRecommendationSheetState extends State<CreateRecommendationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nomCtrl = TextEditingController();
  final _prenomCtrl = TextEditingController();
  final _telCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  Member? _selectedMember;
  List<Member>? _members;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadMembers();
  }

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _emailCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    try {
      final list = await const ApiService().getMembers();
      if (!mounted) return;
      final myId = context.read<AuthProvider>().currentMember?.id;
      setState(() {
        _members = list.where((m) => m.id != myId).toList();
        _selectedMember = _members!
            .where((m) => m.id == widget.initialRecipient?.id)
            .firstOrNull;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _error = 'Impossible de charger la liste des membres.';
      });
    }
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      setState(() => _error = 'Sélectionnez un destinataire.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      await ApiService(authToken: token).createRecommendation(
        recommandeId: _selectedMember!.id,
        nomContact: _nomCtrl.text.trim(),
        prenomContact: _prenomCtrl.text.trim(),
        telephone: _telCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        description: _descCtrl.text.trim(),
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        widget.onCreated();
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Recommandation créée.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Erreur lors de la création.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          children: [
            Text(
              'Une rencontre commence ici.',
              style: Theme.of(context).textTheme.headlineLarge,
            ),
            const SizedBox(height: 28),
            const Text(
              'Destinataire *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            if (_members == null && _error == null)
              const Center(child: CircularProgressIndicator())
            else if (_members == null)
              TextButton.icon(
                onPressed: () {
                  setState(() => _error = null);
                  _loadMembers();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Réessayer'),
              )
            else
              DropdownButtonFormField<Member>(
                isExpanded: true,
                initialValue: _selectedMember,
                decoration: const InputDecoration(
                  hintText: 'Sélectionner un membre',
                  prefixIcon: Icon(Icons.person_rounded),
                ),
                items: _members!
                    .map(
                      (m) => DropdownMenuItem(
                        value: m,
                        child: Text(
                          '${m.fullName}${m.company != null ? ' – ${m.company!.nom}' : ''}',
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (v) => setState(() => _selectedMember = v),
                validator: (v) =>
                    v == null ? 'Sélectionnez un destinataire' : null,
              ),

            const SizedBox(height: 12),

            TextFormField(
              controller: _prenomCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Prénom du contact *',
              ),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nomCtrl,
              textCapitalization: TextCapitalization.words,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(labelText: 'Nom du contact *'),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Champ requis' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _telCtrl,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                labelText: 'Téléphone',
                prefixIcon: Icon(Icons.phone_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: const InputDecoration(
                labelText: 'Email',
                prefixIcon: Icon(Icons.email_outlined),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _descCtrl,
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(
                labelText: 'Description',
                prefixIcon: Icon(Icons.text_snippet_outlined),
                alignLabelWithHint: true,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
            ],
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _loading || _members == null ? null : _submit,
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Envoyer la recommandation'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
