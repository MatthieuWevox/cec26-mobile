import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/app_theme.dart';
import 'api_service.dart';
import 'content_visibility_service.dart';

class ReportingService {
  const ReportingService._();

  static Future<bool> reportContent(
    BuildContext context, {
    required String contentType,
    required int contentId,
    required String contentName,
    String? authToken,
  }) async {
    final result = await showModalBottomSheet<_ReportResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _ReportSheet(
        contentType: contentType,
        contentId: contentId,
        contentName: contentName,
        authToken: authToken,
      ),
    );

    if (result == null || !context.mounted) return false;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Merci, le signalement a bien été transmis.'),
        backgroundColor: AppTheme.successColor,
      ),
    );
    return result.hidden;
  }

  static Future<bool> reportByEmail({
    required String contentType,
    required int contentId,
    required String contentName,
  }) {
    final uri = Uri(
      scheme: 'mailto',
      path: 'contact@wevox.eu',
      queryParameters: {
        'subject': 'Signalement dans l’application CEC 2026',
        'body':
            'Bonjour,\n\n'
            'Je souhaite signaler une information dans l’application CEC 2026.\n\n'
            'Type : $contentType\n'
            'Identifiant : $contentId\n'
            'Nom : $contentName\n\n'
            'Motif du signalement :\n',
      },
    );

    return launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _ReportResult {
  final bool hidden;

  const _ReportResult({required this.hidden});
}

class _ReportSheet extends StatefulWidget {
  final String contentType;
  final int contentId;
  final String contentName;
  final String? authToken;

  const _ReportSheet({
    required this.contentType,
    required this.contentId,
    required this.contentName,
    required this.authToken,
  });

  @override
  State<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends State<_ReportSheet> {
  static const _reasons = <String, String>{
    'inappropriate': 'Contenu inapproprié',
    'misleading': 'Information fausse ou trompeuse',
    'privacy': 'Atteinte à la vie privée',
    'rights': 'Droits d’auteur ou droit à l’image',
    'spam': 'Spam ou contenu commercial abusif',
    'other': 'Autre motif',
  };

  final _detailsController = TextEditingController();
  String? _reason;
  bool _hideContent = false;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _detailsController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_reason == null) {
      setState(() => _error = 'Sélectionnez un motif.');
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      await ApiService(authToken: widget.authToken).createContentReport(
        contentType: widget.contentType,
        contentId: widget.contentId,
        reason: _reason!,
        details: _detailsController.text.trim(),
      );
      if (_hideContent) {
        await ContentVisibilityService.hide(
          widget.contentType,
          widget.contentId,
        );
      }
      if (mounted) {
        Navigator.pop(context, _ReportResult(hidden: _hideContent));
      }
    } on ApiException catch (error) {
      setState(() {
        _loading = false;
        _error = error.message;
      });
    } catch (_) {
      setState(() {
        _loading = false;
        _error = 'Le signalement n’a pas pu être transmis.';
      });
    }
  }

  Future<void> _openEmail() async {
    final opened = await ReportingService.reportByEmail(
      contentType: widget.contentType,
      contentId: widget.contentId,
      contentName: widget.contentName,
    );
    if (!opened && mounted) {
      setState(() => _error = 'Impossible d’ouvrir votre messagerie.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppTheme.radius),
          ),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 28),
        child: SafeArea(
          top: false,
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
                Text(
                  'Signaler ce contenu',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  widget.contentName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 18),
                DropdownButtonFormField<String>(
                  initialValue: _reason,
                  decoration: const InputDecoration(
                    labelText: 'Motif du signalement',
                    prefixIcon: Icon(Icons.flag_outlined),
                  ),
                  items: _reasons.entries
                      .map(
                        (entry) => DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        ),
                      )
                      .toList(),
                  onChanged: _loading
                      ? null
                      : (value) => setState(() => _reason = value),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _detailsController,
                  enabled: !_loading,
                  maxLength: 2000,
                  maxLines: 3,
                  decoration: const InputDecoration(
                    labelText: 'Précisions facultatives',
                    alignLabelWithHint: true,
                  ),
                ),
                CheckboxListTile(
                  value: _hideContent,
                  onChanged: _loading
                      ? null
                      : (value) =>
                            setState(() => _hideContent = value ?? false),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text('Masquer ce contenu sur cet appareil'),
                  subtitle: const Text(
                    'Il ne sera plus affiché dans les listes de l’application.',
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    _error!,
                    style: const TextStyle(color: AppTheme.errorColor),
                  ),
                ],
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _loading ? null : _submit,
                    icon: _loading
                        ? const SizedBox.square(
                            dimension: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.send_rounded),
                    label: Text(
                      _loading ? 'Envoi...' : 'Envoyer le signalement',
                    ),
                  ),
                ),
                Center(
                  child: TextButton(
                    onPressed: _loading ? null : _openEmail,
                    child: const Text(
                      'Contacter plutôt l’assistance par email',
                    ),
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
