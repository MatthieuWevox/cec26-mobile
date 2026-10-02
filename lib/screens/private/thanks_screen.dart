import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../models/thanks.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../services/content_visibility_service.dart';
import '../../services/reporting_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class ThanksScreen extends StatefulWidget {
  const ThanksScreen({super.key});

  @override
  State<ThanksScreen> createState() => _ThanksScreenState();
}

class _ThanksScreenState extends State<ThanksScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late Future<List<Thanks>> _received;
  late Future<List<Thanks>> _sent;

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
    _received = _visibleThanks(api.getThanksReceived());
    _sent = _visibleThanks(api.getThanksSent());
  }

  Future<List<Thanks>> _visibleThanks(Future<List<Thanks>> request) async {
    final results = await Future.wait([
      request,
      ContentVisibilityService.hiddenIds('thanks'),
    ]);
    final thanks = results[0] as List<Thanks>;
    final hiddenIds = results[1] as Set<int>;
    return thanks.where((item) => !hiddenIds.contains(item.id)).toList();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CecGlassAppBar(title: Text('Remerciements')),
    body: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(22, 16, 22, 24),
          child: Text(
            'Un merci qui compte.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Reçus'),
              Tab(text: 'Envoyés'),
            ],
          ),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _ThanksList(
                future: _received,
                isReceived: true,
                onHidden: () {
                  if (mounted) setState(_load);
                },
              ),
              _ThanksList(
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
                  title: Text('Nouveau remerciement'),
                ),
                body: CreateThanksSheet(
                  onCreated: () {
                    if (mounted) setState(_load);
                  },
                ),
              ),
            ),
          ),
          icon: const Icon(Icons.add_rounded),
          label: Text('Remercier un membre'),
        ),
      ),
    ),
  );
}

class _ThanksList extends StatelessWidget {
  final Future<List<Thanks>> future;
  final bool isReceived;
  final VoidCallback onHidden;

  const _ThanksList({
    required this.future,
    required this.isReceived,
    required this.onHidden,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Thanks>>(
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
                ? 'Aucun remerciement reçu.'
                : 'Aucun remerciement envoyé.',
            icon: Icons.handshake_outlined,
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
                child: _ThanksCard(
                  thanks: items[index],
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

class _ThanksCard extends StatelessWidget {
  final Thanks thanks;
  final bool isReceived;
  final VoidCallback onHidden;

  const _ThanksCard({
    required this.thanks,
    required this.isReceived,
    required this.onHidden,
  });

  Future<void> _report(BuildContext context) async {
    final hidden = await ReportingService.reportContent(
      context,
      contentType: 'thanks',
      contentId: thanks.id,
      contentName: 'Remerciement de ${thanks.remerciant?.fullName ?? 'membre'}',
      authToken: context.read<AuthProvider>().token,
    );
    if (hidden) {
      onHidden();
      if (context.mounted) Navigator.pop(context);
    }
  }

  String get _date {
    final value = thanks.dateAffaire;
    final date = DateTime.tryParse(value);
    return date == null
        ? value
        : DateFormat('d MMM yyyy', 'fr_FR').format(date);
  }

  Member? get _otherMember => isReceived ? thanks.remerciant : thanks.remercie;
  String get _title => NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  ).format(double.tryParse(thanks.montantHt) ?? 0);

  Future<void> _open(BuildContext context) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (detailContext) => Scaffold(
          appBar: CecGlassAppBar(
            title: const Text('Remerciement'),
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
                label: isReceived ? 'REÇU' : 'ENVOYÉ',
                color: AppTheme.accentDark,
              ),
              const SizedBox(height: 20),
              Text(
                _title,
                style: Theme.of(detailContext).textTheme.headlineLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'Montant HT · Affaire du $_date',
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
                        ? 'Vous remercie'
                        : 'Destinataire de votre remerciement',
                  ),
                ),
              ],
              const SectionHeader(title: 'Le message'),
              Text(
                thanks.description?.isNotEmpty == true
                    ? thanks.description!
                    : 'Aucun message complémentaire.',
              ),
            ],
          ),
        ),
      ),
    );
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
                    isReceived ? 'Vous remercie' : 'Votre remerciement',
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
        Text(_title, style: Theme.of(context).textTheme.headlineMedium),
        Text('Montant HT', style: Theme.of(context).textTheme.bodySmall),
        if (thanks.description?.isNotEmpty == true) ...[
          const SizedBox(height: 8),
          Text(
            thanks.description!,
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

class CreateThanksSheet extends StatefulWidget {
  final VoidCallback onCreated;
  final Member? initialRecipient;
  const CreateThanksSheet({
    super.key,
    required this.onCreated,
    this.initialRecipient,
  });

  @override
  State<CreateThanksSheet> createState() => _CreateThanksSheetState();
}

class _CreateThanksSheetState extends State<CreateThanksSheet> {
  final _formKey = GlobalKey<FormState>();
  final _montantCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  DateTime? _selectedDate;
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
    _montantCtrl.dispose();
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
      setState(() => _error = 'Impossible de charger la liste des membres.');
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? today,
      firstDate: DateTime(2020),
      lastDate: today,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(primary: AppTheme.primaryColor),
        ),
        child: child!,
      ),
    );
    if (!mounted) return;
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _submit() async {
    if (_loading || !_formKey.currentState!.validate()) return;
    if (_selectedMember == null) {
      setState(() => _error = 'Sélectionnez un destinataire.');
      return;
    }
    if (_selectedDate == null) {
      setState(() => _error = "Sélectionnez la date de l'affaire.");
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final token = context.read<AuthProvider>().token!;
      await ApiService(authToken: token).createThanks(
        remercieId: _selectedMember!.id,
        montantHt: _montantCtrl.text.trim(),
        dateAffaire: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        description: _descCtrl.text.trim(),
      );
      if (mounted) {
        final messenger = ScaffoldMessenger.of(context);
        widget.onCreated();
        Navigator.pop(context);
        messenger.showSnackBar(
          const SnackBar(
            content: Text('Remerciement créé.'),
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
    final dateStr = _selectedDate != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDate!)
        : 'Date de l’affaire *';
    return SafeArea(
      top: false,
      child: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
          children: [
            Text(
              'Valorisons nos réussites.',
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
              controller: _montantCtrl,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Montant HT (€) *',
                prefixIcon: Icon(Icons.euro_rounded),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requis';
                final amount = double.tryParse(v.replaceAll(',', '.'));
                if (amount == null || !amount.isFinite || amount < 0) {
                  return 'Montant invalide';
                }
                return null;
              },
              onChanged: (v) {
                final normalized = v.replaceAll(',', '.');
                if (normalized != v) {
                  _montantCtrl
                    ..text = normalized
                    ..selection = TextSelection.collapsed(
                      offset: normalized.length,
                    );
                }
              },
            ),

            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_rounded),
              label: Text(dateStr),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 52),
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
                    : const Text('Envoyer le remerciement'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
