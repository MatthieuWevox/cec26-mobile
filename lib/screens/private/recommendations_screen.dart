import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CecGlassAppBar(
        title: const Text('Recommandations'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inbox_rounded), text: 'Reçues'),
            Tab(icon: Icon(Icons.send_rounded), text: 'Envoyées'),
          ],
        ),
      ),
      body: CecBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _RecommendationList(
              future: _received,
              isReceived: true,
              onHidden: () => setState(_load),
            ),
            _RecommendationList(
              future: _sent,
              isReceived: false,
              onHidden: () => setState(_load),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        icon: const Icon(Icons.add_rounded),
        label: const Text('Nouvelle recommandation'),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (ctx) =>
          CreateRecommendationSheet(onCreated: () => setState(() => _load())),
    );
  }
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
          return CecErrorWidget(message: snapshot.error.toString());
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
                : 16.0;
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 108),
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
    if (hidden) onHidden();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(rec.createdAt);
    final dateStr = date != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(date)
        : '';

    final otherMember = isReceived ? rec.recommandateur : rec.recommande;

    return CecSurface(
      glass: true,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radius),
                ),
                child: const Icon(
                  Icons.person_pin_outlined,
                  color: AppTheme.primaryColor,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      rec.contactFullName,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    if (rec.email?.isNotEmpty ?? false)
                      Text(
                        rec.email!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(dateStr, style: Theme.of(context).textTheme.bodySmall),
                  if (isReceived)
                    Tooltip(
                      message: 'Signaler cette recommandation',
                      child: IconButton(
                        onPressed: () => _report(context),
                        icon: const Icon(Icons.flag_outlined),
                        iconSize: 18,
                        visualDensity: VisualDensity.compact,
                      ),
                    ),
                ],
              ),
            ],
          ),
          if (rec.telephone?.isNotEmpty ?? false) ...[
            const SizedBox(height: 11),
            CecMeta(icon: Icons.phone_outlined, text: rec.telephone!),
          ],
          if (rec.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 11),
            Text(
              rec.description!,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
          if (otherMember != null) ...[
            const SizedBox(height: 13),
            CecBadge(
              label: '${isReceived ? 'DE' : 'À'} ${otherMember.fullName}',
              color: AppTheme.accentDark,
              icon: isReceived
                  ? Icons.person_outline_rounded
                  : Icons.send_rounded,
            ),
          ],
        ],
      ),
    );
  }
}

class CreateRecommendationSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const CreateRecommendationSheet({super.key, required this.onCreated});

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
      });
    } catch (_) {
      setState(() {
        _error = 'Impossible de charger la liste des membres.';
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
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
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Recommandation créée.'),
            backgroundColor: AppTheme.successColor,
          ),
        );
      }
    } on ApiException catch (e) {
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Erreur lors de la création.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: CecGlassPanel(
        color: Colors.white.withAlpha(240),
        blur: 24,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.dividerColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Nouvelle recommandation',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                // Recipient dropdown
                const Text(
                  'Destinataire *',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                if (_members == null)
                  const Center(child: CircularProgressIndicator())
                else
                  DropdownButtonFormField<Member>(
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
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _prenomCtrl,
                        textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(
                          labelText: 'Prénom contact *',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextFormField(
                        controller: _nomCtrl,
                        textCapitalization: TextCapitalization.characters,
                        decoration: const InputDecoration(
                          labelText: 'Nom contact *',
                        ),
                        validator: (v) =>
                            (v == null || v.trim().isEmpty) ? 'Requis' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
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
                  Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                ],
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _loading ? null : _submit,
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
        ),
      ),
    );
  }
}
