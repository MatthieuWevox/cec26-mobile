import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../models/recommendation.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
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
    _received = api.getRecommendationsReceived();
    _sent = api.getRecommendationsSent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recommandations'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.inbox_rounded), text: 'Reçues'),
            Tab(icon: Icon(Icons.send_rounded), text: 'Envoyées'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _RecommendationList(future: _received, isReceived: true),
          _RecommendationList(future: _sent, isReceived: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppTheme.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouvelle recommandation',
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _showCreateDialog(BuildContext context) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => CreateRecommendationSheet(
        onCreated: () => setState(() => _load()),
      ),
    );
  }
}

class _RecommendationList extends StatelessWidget {
  final Future<List<Recommendation>> future;
  final bool isReceived;

  const _RecommendationList({
    required this.future,
    required this.isReceived,
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
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _RecommendationCard(rec: items[index], isReceived: isReceived),
        );
      },
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  final Recommendation rec;
  final bool isReceived;

  const _RecommendationCard({required this.rec, required this.isReceived});

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(rec.createdAt);
    final dateStr = date != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(date)
        : '';

    final otherMember = isReceived ? rec.recommandateur : rec.recommande;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(15),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.person_pin_rounded,
                    color: AppTheme.primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rec.contactFullName,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (rec.email != null && rec.email!.isNotEmpty)
                        Text(
                          rec.email!,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                    ],
                  ),
                ),
                Text(
                  dateStr,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
            if (rec.telephone != null && rec.telephone!.isNotEmpty) ...[
              const SizedBox(height: 10),
              Row(
                children: [
                  const Icon(
                    Icons.phone_outlined,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    rec.telephone!,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
            if (rec.description != null && rec.description!.isNotEmpty) ...[
              const SizedBox(height: 10),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                rec.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary,
                  height: 1.5,
                ),
              ),
            ],
            if (otherMember != null) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentColor.withAlpha(20),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isReceived
                          ? Icons.person_outline_rounded
                          : Icons.send_rounded,
                      size: 14,
                      color: AppTheme.accentColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${isReceived ? 'De' : 'À'}: ${otherMember.fullName}',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.primaryColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
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

class _CreateRecommendationSheetState
    extends State<CreateRecommendationSheet> {
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
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
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
                    value: _selectedMember,
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
