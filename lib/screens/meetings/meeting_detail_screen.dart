import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../models/meeting.dart';
import '../../providers/auth_provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class MeetingDetailScreen extends StatefulWidget {
  final Meeting meeting;
  const MeetingDetailScreen({super.key, required this.meeting});

  @override
  State<MeetingDetailScreen> createState() => _MeetingDetailScreenState();
}

class _MeetingDetailScreenState extends State<MeetingDetailScreen> {
  late Meeting _meeting;

  @override
  void initState() {
    super.initState();
    _meeting = widget.meeting;
  }

  String get _formattedDate {
    final date = DateTime.tryParse(_meeting.date);
    if (date == null) return _meeting.date;
    return DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
  }

  String get _formattedTime {
    final parts = _meeting.heure.split(':');
    if (parts.length >= 2) return '${parts[0]}h${parts[1]}';
    return _meeting.heure;
  }

  Future<void> _showAddGuestDialog(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (!auth.isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Connectez-vous pour inviter quelqu\'un.'),
        ),
      );
      return;
    }

    final formKey = GlobalKey<FormState>();
    final nomCtrl = TextEditingController();
    final prenomCtrl = TextEditingController();
    final entrepriseCtrl = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            child: Form(
              key: formKey,
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
                  const SizedBox(height: 24),
                  const Text(
                    'Ajouter un invité',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextFormField(
                    controller: prenomCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Prénom *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Champ requis'
                        : null,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: nomCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Nom *',
                      prefixIcon: Icon(Icons.person_outline_rounded),
                    ),
                    validator: (v) => (v == null || v.trim().isEmpty)
                        ? 'Champ requis'
                        : null,
                    textCapitalization: TextCapitalization.characters,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: entrepriseCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Entreprise',
                      prefixIcon: Icon(Icons.business_rounded),
                    ),
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (formKey.currentState!.validate()) {
                          try {
                            final api = ApiService(authToken: auth.token);
                            await api.addGuestToMeeting(
                              meetingId: _meeting.id,
                              nom: nomCtrl.text.trim(),
                              prenom: prenomCtrl.text.trim(),
                              nomEntreprise: entrepriseCtrl.text.trim().isEmpty
                                  ? null
                                  : entrepriseCtrl.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Invité ajouté avec succès.'),
                                  backgroundColor: AppTheme.successColor,
                                ),
                              );
                            }
                          } on ApiException catch (e) {
                            if (ctx.mounted) {
                              ScaffoldMessenger.of(ctx).showSnackBar(
                                SnackBar(content: Text(e.message)),
                              );
                            }
                          }
                        }
                      },
                      child: const Text('Ajouter l\'invité'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
    nomCtrl.dispose();
    prenomCtrl.dispose();
    entrepriseCtrl.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 100,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _formattedDate,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              titlePadding: const EdgeInsets.fromLTRB(56, 0, 16, 16),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.headerGradient,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Meeting info card
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(12),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        InfoRow(
                          icon: Icons.access_time_rounded,
                          label: 'HEURE',
                          value: _formattedTime,
                        ),
                        const Divider(),
                        InfoRow(
                          icon: Icons.location_on_rounded,
                          label: 'LIEU',
                          value: _meeting.adresse,
                        ),
                      ],
                    ),
                  ),

                  // Agenda
                  if (_meeting.ordreDuJour != null &&
                      _meeting.ordreDuJour!.isNotEmpty) ...[
                    const SizedBox(height: 24),
                    const Text(
                      'Ordre du jour',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withAlpha(20),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: AppTheme.accentColor.withAlpha(60),
                        ),
                      ),
                      child: Text(
                        _meeting.ordreDuJour!,
                        style: const TextStyle(
                          fontSize: 15,
                          color: AppTheme.textPrimary,
                          height: 1.6,
                        ),
                      ),
                    ),
                  ],

                  // Guests
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Invités (${_meeting.guests.length})',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (auth.isLoggedIn)
                        TextButton.icon(
                          onPressed: () => _showAddGuestDialog(context),
                          icon: const Icon(Icons.person_add_rounded, size: 16),
                          label: const Text('Inviter'),
                          style: TextButton.styleFrom(
                            foregroundColor: AppTheme.primaryColor,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (_meeting.guests.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'Aucun invité pour cette réunion.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    )
                  else
                    ..._meeting.guests.map(
                      (g) => _GuestTile(guest: g),
                    ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: auth.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => _showAddGuestDialog(context),
              backgroundColor: AppTheme.primaryColor,
              icon: const Icon(Icons.person_add_rounded, color: Colors.white),
              label: const Text(
                'Ajouter un invité',
                style: TextStyle(color: Colors.white),
              ),
            )
          : null,
    );
  }
}

class _GuestTile extends StatelessWidget {
  final Guest guest;
  const _GuestTile({required this.guest});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.dividerColor),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.primaryColor.withAlpha(20),
            child: Text(
              '${guest.prenom[0]}${guest.nom[0]}'.toUpperCase(),
              style: const TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.w700,
                fontSize: 13,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  guest.fullName,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (guest.nomEntreprise != null &&
                    guest.nomEntreprise!.isNotEmpty)
                  Text(
                    guest.nomEntreprise!,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          if (guest.invitedBy != null)
            Tooltip(
              message:
                  'Invité par ${guest.invitedBy!.fullName}',
              child: const Icon(
                Icons.person_rounded,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
        ],
      ),
    );
  }
}
