import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common_widgets.dart';

class _PickedMedia {
  final String path;
  final String name;

  const _PickedMedia({required this.path, required this.name});
}

Future<_PickedMedia?> _pickFromGallery() async {
  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    imageQuality: 88,
  );
  if (picked == null) return null;
  return _PickedMedia(path: picked.path, name: picked.name);
}

Future<_PickedMedia?> _pickFromFiles() async {
  final result = await FilePicker.pickFiles(
    type: FileType.custom,
    allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
    allowMultiple: false,
  );
  final file = result?.files.single;
  if (file == null || file.path == null) return null;
  return _PickedMedia(path: file.path!, name: file.name);
}

enum ProfileTab { profile, company, password }

class ProfileScreen extends StatefulWidget {
  final ProfileTab initialTab;
  const ProfileScreen({super.key, this.initialTab = ProfileTab.profile});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: widget.initialTab.index,
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CecGlassAppBar(
        title: const Text('Mon profil'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.person_outline_rounded), text: 'Profil'),
            Tab(icon: Icon(Icons.business_outlined), text: 'Entreprise'),
            Tab(icon: Icon(Icons.lock_outline_rounded), text: 'Mot de passe'),
          ],
        ),
      ),
      body: CecBackground(
        child: TabBarView(
          controller: _tabController,
          children: const [
            _EditProfileTab(),
            _EditCompanyTab(),
            _ChangePasswordTab(),
          ],
        ),
      ),
    );
  }
}

// ─── Edit Profile Tab ─────────────────────────────────────────────────────────

class _EditProfileTab extends StatefulWidget {
  const _EditProfileTab();

  @override
  State<_EditProfileTab> createState() => _EditProfileTabState();
}

class _EditProfileTabState extends State<_EditProfileTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl;
  late TextEditingController _prenomCtrl;
  late TextEditingController _telCtrl;
  late TextEditingController _presentationCtrl;
  _PickedMedia? _photo;
  bool _initialized = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _prenomCtrl.dispose();
    _telCtrl.dispose();
    _presentationCtrl.dispose();
    super.dispose();
  }

  void _init(AuthProvider auth) {
    if (_initialized) return;
    final m = auth.currentMember;
    _nomCtrl = TextEditingController(text: m?.nom ?? '');
    _prenomCtrl = TextEditingController(text: m?.prenom ?? '');
    _telCtrl = TextEditingController(text: m?.telephone ?? '');
    _presentationCtrl = TextEditingController(text: m?.presentation ?? '');
    _initialized = true;
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await auth.updateProfile(
      nom: _nomCtrl.text.trim(),
      prenom: _prenomCtrl.text.trim(),
      telephone: _telCtrl.text.trim(),
      presentation: _presentationCtrl.text.trim(),
      photoPath: _photo?.path,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Profil mis à jour.' : auth.error ?? 'Erreur.'),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _init(auth);

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
      child: CecContentWidth(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Informations personnelles',
                subtitle: 'Ces informations apparaissent dans l’annuaire.',
              ),
              TextFormField(
                controller: _prenomCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Prénom',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _nomCtrl,
                textCapitalization: TextCapitalization.characters,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  prefixIcon: Icon(Icons.person_outline_rounded),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Requis' : null,
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
                controller: _presentationCtrl,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Présentation',
                  prefixIcon: Icon(Icons.text_snippet_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              _MediaPickerTile(
                title: 'Photo de profil',
                currentUrl: auth.currentMember?.photoUrl,
                selectedName: _photo?.name,
                icon: Icons.account_circle_outlined,
                onGallery: () async {
                  final media = await _pickFromGallery();
                  if (media != null && mounted) setState(() => _photo = media);
                },
                onFiles: () async {
                  final media = await _pickFromFiles();
                  if (media != null && mounted) setState(() => _photo = media);
                },
                onClearSelection: _photo == null
                    ? null
                    : () => setState(() => _photo = null),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () => _save(auth),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Edit Company Tab ─────────────────────────────────────────────────────────

class _EditCompanyTab extends StatefulWidget {
  const _EditCompanyTab();

  @override
  State<_EditCompanyTab> createState() => _EditCompanyTabState();
}

class _MediaPickerTile extends StatelessWidget {
  final String title;
  final String? currentUrl;
  final String? selectedName;
  final IconData icon;
  final VoidCallback onGallery;
  final VoidCallback onFiles;
  final VoidCallback? onClearSelection;

  const _MediaPickerTile({
    required this.title,
    required this.currentUrl,
    required this.selectedName,
    required this.icon,
    required this.onGallery,
    required this.onFiles,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    final hasCurrent = currentUrl != null && currentUrl!.isNotEmpty;
    final hasSelection = selectedName != null && selectedName!.isNotEmpty;

    return CecSurface(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: AppTheme.accentColor),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          if (hasCurrent || hasSelection) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                if (hasCurrent)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radius),
                    child: Image.network(
                      currentUrl!,
                      width: 58,
                      height: 58,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        width: 58,
                        height: 58,
                        color: AppTheme.backgroundLight,
                        child: const Icon(Icons.broken_image_outlined),
                      ),
                    ),
                  ),
                if (hasCurrent) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    hasSelection ? selectedName! : 'Media actuel',
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (onClearSelection != null)
                  IconButton(
                    onPressed: onClearSelection,
                    icon: const Icon(Icons.close_rounded),
                    tooltip: 'Annuler la selection',
                  ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onGallery,
                  icon: const Icon(Icons.photo_library_outlined),
                  label: const Text('Galerie'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onFiles,
                  icon: const Icon(Icons.folder_open_outlined),
                  label: const Text('Fichiers'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EditCompanyTabState extends State<_EditCompanyTab> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nomCtrl;
  late TextEditingController _sousTitreCtrl;
  late TextEditingController _activitesCtrl;
  late TextEditingController _descriptionCtrl;
  _PickedMedia? _logo;
  _PickedMedia? _banner;
  bool _initialized = false;

  @override
  void dispose() {
    _nomCtrl.dispose();
    _sousTitreCtrl.dispose();
    _activitesCtrl.dispose();
    _descriptionCtrl.dispose();
    super.dispose();
  }

  void _init(AuthProvider auth) {
    if (_initialized) return;
    final c = auth.currentMember?.company;
    _nomCtrl = TextEditingController(text: c?.nom ?? '');
    _sousTitreCtrl = TextEditingController(text: c?.sousTitre ?? '');
    _activitesCtrl = TextEditingController(text: c?.activites ?? '');
    _descriptionCtrl = TextEditingController(text: c?.description ?? '');
    _initialized = true;
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await auth.updateCompany(
      nom: _nomCtrl.text.trim(),
      sousTitre: _sousTitreCtrl.text.trim(),
      activites: _activitesCtrl.text.trim(),
      description: _descriptionCtrl.text.trim(),
      logoPath: _logo?.path,
      photoPath: _banner?.path,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            ok ? 'Entreprise mise à jour.' : auth.error ?? 'Erreur.',
          ),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    _init(auth);

    if (auth.currentMember?.company == null) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            "Aucune entreprise associée à votre compte.",
            textAlign: TextAlign.center,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 15),
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
      child: CecContentWidth(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Identité de l’entreprise',
                subtitle: 'Présentez clairement votre activité aux membres.',
              ),
              TextFormField(
                controller: _nomCtrl,
                textCapitalization: TextCapitalization.words,
                decoration: const InputDecoration(
                  labelText: 'Nom de l\'entreprise',
                  prefixIcon: Icon(Icons.business_outlined),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _sousTitreCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Sous-titre / accroche',
                  prefixIcon: Icon(Icons.title_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _activitesCtrl,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Activités',
                  prefixIcon: Icon(Icons.work_outline_rounded),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _descriptionCtrl,
                maxLines: 4,
                textCapitalization: TextCapitalization.sentences,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.text_snippet_outlined),
                  alignLabelWithHint: true,
                ),
              ),
              const SizedBox(height: 12),
              _MediaPickerTile(
                title: 'Logo',
                currentUrl: auth.currentMember?.company?.logoUrl,
                selectedName: _logo?.name,
                icon: Icons.image_outlined,
                onGallery: () async {
                  final media = await _pickFromGallery();
                  if (media != null && mounted) setState(() => _logo = media);
                },
                onFiles: () async {
                  final media = await _pickFromFiles();
                  if (media != null && mounted) setState(() => _logo = media);
                },
                onClearSelection: _logo == null
                    ? null
                    : () => setState(() => _logo = null),
              ),
              const SizedBox(height: 12),
              _MediaPickerTile(
                title: 'Banniere / photo',
                currentUrl: auth.currentMember?.company?.photoUrl,
                selectedName: _banner?.name,
                icon: Icons.photo_outlined,
                onGallery: () async {
                  final media = await _pickFromGallery();
                  if (media != null && mounted) setState(() => _banner = media);
                },
                onFiles: () async {
                  final media = await _pickFromFiles();
                  if (media != null && mounted) setState(() => _banner = media);
                },
                onClearSelection: _banner == null
                    ? null
                    : () => setState(() => _banner = null),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () => _save(auth),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Change Password Tab ──────────────────────────────────────────────────────

class _ChangePasswordTab extends StatefulWidget {
  const _ChangePasswordTab();

  @override
  State<_ChangePasswordTab> createState() => _ChangePasswordTabState();
}

class _ChangePasswordTabState extends State<_ChangePasswordTab> {
  final _formKey = GlobalKey<FormState>();
  final _currentCtrl = TextEditingController();
  final _newCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _currentCtrl.dispose();
    _newCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  Future<void> _save(AuthProvider auth) async {
    if (!_formKey.currentState!.validate()) return;
    final ok = await auth.updatePassword(
      currentPassword: _currentCtrl.text,
      newPassword: _newCtrl.text,
      confirmation: _confirmCtrl.text,
    );
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(ok ? 'Mot de passe modifié.' : auth.error ?? 'Erreur.'),
          backgroundColor: ok ? AppTheme.successColor : AppTheme.errorColor,
        ),
      );
      if (ok) {
        _currentCtrl.clear();
        _newCtrl.clear();
        _confirmCtrl.clear();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 40),
      child: CecContentWidth(
        maxWidth: 720,
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SectionHeader(
                title: 'Sécurité du compte',
                subtitle:
                    'Utilisez au moins 8 caractères pour votre mot de passe.',
              ),
              TextFormField(
                controller: _currentCtrl,
                obscureText: _obscureCurrent,
                decoration: InputDecoration(
                  labelText: 'Mot de passe actuel',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureCurrent
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureCurrent = !_obscureCurrent),
                  ),
                ),
                validator: (v) => (v == null || v.isEmpty) ? 'Requis' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _newCtrl,
                obscureText: _obscureNew,
                decoration: InputDecoration(
                  labelText: 'Nouveau mot de passe',
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNew
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () => setState(() => _obscureNew = !_obscureNew),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v.length < 8) return '8 caractères minimum';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _confirmCtrl,
                obscureText: _obscureConfirm,
                decoration: InputDecoration(
                  labelText: 'Confirmer le mot de passe',
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirm
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                    ),
                    onPressed: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                  ),
                ),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Requis';
                  if (v != _newCtrl.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: auth.isLoading ? null : () => _save(auth),
                  child: auth.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Text('Modifier le mot de passe'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
