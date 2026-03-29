import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/member.dart';
import '../../models/thanks.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
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
    _received = api.getThanksReceived();
    _sent = api.getThanksSent();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Remerciements'),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.accentColor,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white60,
          tabs: const [
            Tab(icon: Icon(Icons.inbox_rounded), text: 'Reçus'),
            Tab(icon: Icon(Icons.send_rounded), text: 'Envoyés'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _ThanksList(future: _received, isReceived: true),
          _ThanksList(future: _sent, isReceived: false),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateDialog(context),
        backgroundColor: AppTheme.accentColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nouveau remerciement',
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
      builder: (ctx) => CreateThanksSheet(
        onCreated: () => setState(() => _load()),
      ),
    );
  }
}

class _ThanksList extends StatelessWidget {
  final Future<List<Thanks>> future;
  final bool isReceived;

  const _ThanksList({required this.future, required this.isReceived});

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
        return ListView.builder(
          padding: const EdgeInsets.only(top: 8, bottom: 100),
          itemCount: items.length,
          itemBuilder: (context, index) =>
              _ThanksCard(thanks: items[index], isReceived: isReceived),
        );
      },
    );
  }
}

class _ThanksCard extends StatelessWidget {
  final Thanks thanks;
  final bool isReceived;

  const _ThanksCard({required this.thanks, required this.isReceived});

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
                    color: AppTheme.accentColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.handshake_rounded,
                    color: AppTheme.accentColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formattedAmount,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryColor,
                        ),
                      ),
                      Text(
                        'Affaire du $dateStr',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (thanks.description != null &&
                thanks.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              const Divider(),
              const SizedBox(height: 8),
              Text(
                thanks.description!,
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
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? now,
      firstDate: DateTime(2020),
      lastDate: now,
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primaryColor,
          ),
        ),
        child: child!,
      ),
    );
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
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                    ),
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
