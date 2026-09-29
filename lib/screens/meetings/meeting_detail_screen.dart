import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  final _guestFormKey = GlobalKey<FormState>();
  final _guestNomCtrl = TextEditingController();
  final _guestPrenomCtrl = TextEditingController();
  final _guestEntrepriseCtrl = TextEditingController();

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
        const SnackBar(content: Text('Connectez-vous pour inviter quelqu’un.')),
      );
      return;
    }

    _guestFormKey.currentState?.reset();
    _guestNomCtrl.clear();
    _guestPrenomCtrl.clear();
    _guestEntrepriseCtrl.clear();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: CecGlassPanel(
            color: Colors.white.withAlpha(238),
            blur: 24,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            child: SafeArea(
              top: false,
              child: Form(
                key: _guestFormKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Center(
                        child: Container(
                          width: 42,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppTheme.surfaceStrong,
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        'Ajouter un invité',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: 5),
                      Text(
                        'Ajoutez une personne à cette rencontre.',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      const SizedBox(height: 22),
                      TextFormField(
                        controller: _guestPrenomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Prénom *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Champ requis'
                            : null,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _guestNomCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Nom *',
                          prefixIcon: Icon(Icons.person_outline_rounded),
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? 'Champ requis'
                            : null,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _guestEntrepriseCtrl,
                        decoration: const InputDecoration(
                          labelText: 'Entreprise',
                          prefixIcon: Icon(Icons.business_rounded),
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            if (!_guestFormKey.currentState!.validate()) return;
                            try {
                              final api = ApiService(authToken: auth.token);
                              final guestData = await api.addGuestToMeeting(
                                meetingId: _meeting.id,
                                nom: _guestNomCtrl.text.trim(),
                                prenom: _guestPrenomCtrl.text.trim(),
                                nomEntreprise:
                                    _guestEntrepriseCtrl.text.trim().isEmpty
                                    ? null
                                    : _guestEntrepriseCtrl.text.trim(),
                              );
                              if (!mounted) return;
                              setState(() {
                                _meeting.guests.add(Guest.fromJson(guestData));
                              });
                              if (sheetContext.mounted) {
                                Navigator.pop(sheetContext);
                              }
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Invité ajouté avec succès.'),
                                    backgroundColor: AppTheme.successColor,
                                  ),
                                );
                              }
                            } on ApiException catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.message)),
                                );
                              }
                            }
                          },
                          icon: const Icon(Icons.person_add_rounded, size: 19),
                          label: const Text('Ajouter l’invité'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _guestNomCtrl.dispose();
    _guestPrenomCtrl.dispose();
    _guestEntrepriseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      body: CecBackground(
        accentTop: false,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverAppBar(
              expandedHeight: 210,
              pinned: true,
              stretch: true,
              toolbarHeight: 64,
              backgroundColor: AppTheme.primaryDark,
              foregroundColor: Colors.white,
              automaticallyImplyLeading: false,
              leadingWidth: 68,
              leading: Padding(
                padding: const EdgeInsets.only(left: 12, top: 8, bottom: 8),
                child: CecGlassIconButton(
                  icon: Icons.arrow_back_rounded,
                  tooltip: 'Retour',
                  dark: true,
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              surfaceTintColor: Colors.transparent,
              systemOverlayStyle: SystemUiOverlayStyle.light,
              flexibleSpace: FlexibleSpaceBar(
                collapseMode: CollapseMode.parallax,
                background: DecoratedBox(
                  decoration: const BoxDecoration(
                    gradient: AppTheme.primaryGradient,
                  ),
                  child: SafeArea(
                    child: Stack(
                      children: [
                        Positioned(
                          right: -28,
                          bottom: -24,
                          child: Icon(
                            Icons.calendar_month_rounded,
                            size: 150,
                            color: AppTheme.accentColor.withAlpha(22),
                          ),
                        ),
                        Positioned(
                          left: 20,
                          right: 20,
                          bottom: 24,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const CecBadge(
                                label: 'RENCONTRE CEC',
                                color: AppTheme.accentDark,
                                icon: Icons.groups_rounded,
                                inverted: true,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                _formattedDate,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium
                                    ?.copyWith(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: CecContentWidth(
                maxWidth: 760,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(18, 20, 18, 104),
                  child: CecReveal(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CecSurface(
                          glass: true,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 5,
                          ),
                          child: Column(
                            children: [
                              InfoRow(
                                icon: Icons.access_time_rounded,
                                label: 'Heure',
                                value: _formattedTime,
                              ),
                              const Divider(),
                              InfoRow(
                                icon: Icons.location_on_rounded,
                                label: 'Lieu',
                                value: _meeting.adresse,
                              ),
                            ],
                          ),
                        ),
                        if (_meeting.ordreDuJour != null &&
                            _meeting.ordreDuJour!.isNotEmpty) ...[
                          const SectionHeader(
                            title: 'Ordre du jour',
                            subtitle: 'Les points prévus pour cette rencontre.',
                          ),
                          CecSurface(
                            color: AppTheme.accentSoft,
                            padding: const EdgeInsets.all(18),
                            borderColor: AppTheme.accentColor.withAlpha(44),
                            child: Text(
                              _meeting.ordreDuJour!,
                              style: Theme.of(context).textTheme.bodyLarge,
                            ),
                          ),
                        ],
                        SectionHeader(
                          title: 'Invités',
                          subtitle:
                              '${_meeting.guests.length} personne${_meeting.guests.length > 1 ? 's' : ''} annoncée${_meeting.guests.length > 1 ? 's' : ''}.',
                          trailing: auth.isLoggedIn
                              ? TextButton.icon(
                                  onPressed: () => _showAddGuestDialog(context),
                                  icon: const Icon(
                                    Icons.person_add_rounded,
                                    size: 17,
                                  ),
                                  label: const Text('Inviter'),
                                )
                              : null,
                        ),
                        if (_meeting.guests.isEmpty)
                          const CecSurface(
                            glass: true,
                            child: Row(
                              children: [
                                Icon(
                                  Icons.people_outline_rounded,
                                  color: AppTheme.textSecondary,
                                ),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    'Aucun invité pour cette réunion.',
                                  ),
                                ),
                              ],
                            ),
                          )
                        else
                          for (final guest in _meeting.guests)
                            _GuestTile(guest: guest),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: auth.isLoggedIn
          ? FloatingActionButton.extended(
              onPressed: () => _showAddGuestDialog(context),
              icon: const Icon(Icons.person_add_rounded),
              label: const Text('Ajouter un invité'),
            )
          : null,
    );
  }
}

class _GuestTile extends StatelessWidget {
  final Guest guest;

  const _GuestTile({required this.guest});

  String get _initials {
    final first = guest.prenom.isEmpty ? '?' : guest.prenom[0];
    final last = guest.nom.isEmpty ? '' : guest.nom[0];
    return '$first$last'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: CecSurface(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppTheme.accentSoft,
              child: Text(
                _initials,
                style: const TextStyle(
                  color: AppTheme.primaryColor,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  letterSpacing: 0,
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
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (guest.nomEntreprise?.isNotEmpty ?? false) ...[
                    const SizedBox(height: 2),
                    Text(
                      guest.nomEntreprise!,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            if (guest.invitedBy != null)
              Tooltip(
                message: 'Invité par ${guest.invitedBy!.fullName}',
                child: const Icon(
                  Icons.person_rounded,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
