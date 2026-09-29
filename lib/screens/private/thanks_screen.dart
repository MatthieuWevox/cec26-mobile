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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CecGlassAppBar(
        title: const Text('Remerciements'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.inbox_rounded), text: 'Reçus'),
            Tab(icon: Icon(Icons.send_rounded), text: 'Envoyés'),
          ],
        ),
      ),
      body: CecBackground(
        child: TabBarView(
          controller: _tabController,
          children: [
            _ThanksList(
              future: _received,
              isReceived: true,
              onHidden: () => setState(_load),
            ),
            _ThanksList(
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
        label: const Text('Nouveau remerciement'),
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
          CreateThanksSheet(onCreated: () => setState(() => _load())),
    );
  }
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
          return CecErrorWidget(message: snapshot.error.toString());
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
                : 16.0;
            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(horizontal, 18, horizontal, 108),
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
    if (hidden) onHidden();
  }

  @override
  Widget build(BuildContext context) {
    final date = DateTime.tryParse(thanks.dateAffaire);
    final dateStr = date != null
        ? DateFormat('d MMM yyyy', 'fr_FR').format(date)
        : thanks.dateAffaire;
    final amount = double.tryParse(thanks.montantHt) ?? 0.0;
    final formattedAmount = NumberFormat.currency(
      locale: 'fr_FR',
      symbol: '€',
      decimalDigits: 2,
    ).format(amount);

    final otherMember = isReceived ? thanks.remerciant : thanks.remercie;

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
                  Icons.handshake_outlined,
                  color: AppTheme.accentDark,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedAmount,
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(color: AppTheme.primaryColor),
                    ),
                    Text(
                      'Affaire du $dateStr',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              if (isReceived)
                Tooltip(
                  message: 'Signaler ce remerciement',
                  child: IconButton(
                    onPressed: () => _report(context),
                    icon: const Icon(Icons.flag_outlined),
                    iconSize: 18,
                    visualDensity: VisualDensity.compact,
                  ),
                ),
            ],
          ),
          if (thanks.description?.isNotEmpty ?? false) ...[
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 11),
            Text(
              thanks.description!,
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

class CreateThanksSheet extends StatefulWidget {
  final VoidCallback onCreated;
  const CreateThanksSheet({super.key, required this.onCreated});

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
      });
    } catch (_) {
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
    if (!_formKey.currentState!.validate()) return;
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
        Navigator.pop(context);
        widget.onCreated();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Remerciement créé.'),
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
    final dateStr = _selectedDate != null
        ? DateFormat('d MMMM yyyy', 'fr_FR').format(_selectedDate!)
        : 'Choisir une date';

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
                  'Nouveau remerciement',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 20),

                // Recipient
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
                    if (double.tryParse(v.replaceAll(',', '.')) == null) {
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
                        : const Text('Envoyer le remerciement'),
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
