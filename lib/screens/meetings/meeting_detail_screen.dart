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
  late final List<Guest> _guests = List.of(widget.meeting.guests);

  Future<void> _addGuest() async {
    final guest = await Navigator.push<Guest>(
      context,
      MaterialPageRoute(
        builder: (_) => _AddGuestScreen(meetingId: widget.meeting.id),
      ),
    );
    if (mounted && guest != null) {
      setState(() => _guests.add(guest));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invité ajouté avec succès.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final meeting = widget.meeting;
    final date = DateTime.tryParse(meeting.date);
    final dateLabel = date == null
        ? meeting.date
        : DateFormat('EEEE d MMMM yyyy', 'fr_FR').format(date);
    final timeParts = meeting.heure.split(':');
    final time = timeParts.length >= 2
        ? '${timeParts[0]}h${timeParts[1]}'
        : meeting.heure;

    return Scaffold(
      appBar: const CecGlassAppBar(title: Text('Réunion du Club')),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(22, 12, 22, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppTheme.accentSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.calendar_month_outlined,
                  color: AppTheme.accentDark,
                  size: 28,
                ),
                const SizedBox(height: 20),
                Text(
                  dateLabel,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  'Le rendez-vous du Club',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          InfoRow(icon: Icons.schedule_outlined, label: 'Heure', value: time),
          const Divider(),
          InfoRow(
            icon: Icons.place_outlined,
            label: 'Lieu',
            value: meeting.adresse,
          ),
          if (meeting.ordreDuJour?.isNotEmpty ?? false) ...[
            const SectionHeader(title: 'Ordre du jour'),
            Text(
              meeting.ordreDuJour!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          if (meeting.compteRendu?.isNotEmpty ?? false) ...[
            const SectionHeader(title: 'Compte rendu'),
            Text(
              meeting.compteRendu!,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          ],
          SectionHeader(title: 'Invités (${_guests.length})'),
          if (_guests.isEmpty)
            const Text(
              'Aucun invité pour cette réunion.',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          for (final guest in _guests)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: MemberAvatar(name: guest.fullName, radius: 22),
              title: Text(guest.fullName),
              subtitle: guest.nomEntreprise?.isNotEmpty == true
                  ? Text(guest.nomEntreprise!)
                  : null,
              trailing: guest.invitedBy == null
                  ? null
                  : Tooltip(
                      message: 'Invité par ${guest.invitedBy!.fullName}',
                      child: const Icon(
                        Icons.person_outline,
                        size: 18,
                        color: AppTheme.textSecondary,
                      ),
                    ),
            ),
        ],
      ),
      bottomNavigationBar: context.watch<AuthProvider>().isLoggedIn
          ? SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(22, 12, 22, 16),
                child: ElevatedButton.icon(
                  onPressed: _addGuest,
                  icon: const Icon(Icons.person_add_outlined),
                  label: const Text('Ajouter un invité'),
                ),
              ),
            )
          : null,
    );
  }
}

class _AddGuestScreen extends StatefulWidget {
  final int meetingId;
  const _AddGuestScreen({required this.meetingId});

  @override
  State<_AddGuestScreen> createState() => _AddGuestScreenState();
}

class _AddGuestScreenState extends State<_AddGuestScreen> {
  final _form = GlobalKey<FormState>();
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _company = TextEditingController();
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _first.dispose();
    _last.dispose();
    _company.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_saving || !_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final data =
          await ApiService(
            authToken: context.read<AuthProvider>().token,
          ).addGuestToMeeting(
            meetingId: widget.meetingId,
            nom: _last.text.trim(),
            prenom: _first.text.trim(),
            nomEntreprise: _company.text.trim().isEmpty
                ? null
                : _company.text.trim(),
          );
      if (mounted) Navigator.pop(context, Guest.fromJson(data));
    } catch (error) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = error is ApiException
              ? error.message
              : 'Impossible d’ajouter cet invité. Réessayez.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: const CecGlassAppBar(title: Text('Ajouter un invité')),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(22, 20, 22, 32),
        children: [
          Text(
            'Élargissons le cercle.',
            style: Theme.of(context).textTheme.headlineLarge,
          ),
          const SizedBox(height: 28),
          TextFormField(
            controller: _first,
            decoration: const InputDecoration(labelText: 'Prénom *'),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _last,
            decoration: const InputDecoration(labelText: 'Nom *'),
            textCapitalization: TextCapitalization.words,
            textInputAction: TextInputAction.next,
            validator: _required,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _company,
            decoration: const InputDecoration(labelText: 'Entreprise'),
            textCapitalization: TextCapitalization.words,
          ),
          if (_error != null) ...[
            const SizedBox(height: 20),
            Text(_error!, style: const TextStyle(color: AppTheme.errorColor)),
          ],
          const SizedBox(height: 28),
          ElevatedButton.icon(
            onPressed: _saving ? null : _submit,
            icon: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.person_add_outlined),
            label: Text(_saving ? 'Ajout en cours…' : 'Ajouter l’invité'),
          ),
        ],
      ),
    ),
  );

  String? _required(String? value) =>
      value == null || value.trim().isEmpty ? 'Champ requis' : null;
}
