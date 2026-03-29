import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:image_picker/image_picker.dart';

import '../../../../config/theme/app_colors.dart';
import '../../../../core/config/brand_config.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../contact/domain/entities/contact_entity.dart';
import '../widgets/color_preview_widget.dart';

import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../portfolio/presentation/bloc/portfolio_bloc.dart';
import '../../../portfolio/presentation/pages/portfolio_edit_page.dart';

class EditPage extends StatefulWidget {
  final ContactEntity contact;
  final BrandConfig brand;

  const EditPage({
    super.key,
    required this.contact,
    required this.brand,
  });

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage>
    with SingleTickerProviderStateMixin {
  late final Map<String, TextEditingController> _c;
  late final Map<String, TextEditingController> _b;

  String _photoBase64 = '';
  String _photoQrBase64 = ''; // ← new
  bool _compressing = false; // ← shows loading while compressing
  final _picker = ImagePicker();
  late TabController _tabCtrl;

  // ── Init ──────────────────────────────────────────────────────────────────
  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 4, vsync: this);
    _photoBase64 = widget.contact.photoBase64;
    _photoQrBase64 = widget.contact.photoQrBase64; // ← new

    final ct = widget.contact;
    _c = {
      'name': TextEditingController(text: ct.name),
      'title': TextEditingController(text: ct.title),
      'org': TextEditingController(text: ct.org),
      'phone': TextEditingController(text: ct.phone),
      'phone2': TextEditingController(text: ct.phone2),
      'email': TextEditingController(text: ct.email),
      'whatsapp': TextEditingController(text: ct.whatsapp),
      'website': TextEditingController(text: ct.website),
      'linkedin': TextEditingController(text: ct.linkedin),
      'address': TextEditingController(text: ct.address),
      'tagline': TextEditingController(text: ct.tagline),
    };

    final br = widget.brand;
    _b = {
      'appName': TextEditingController(text: br.appName),
      'appBarTitle': TextEditingController(text: br.appBarTitle),
      'badgeText': TextEditingController(text: br.badgeText),
      'primaryColor': TextEditingController(text: br.primaryColorHex),
      'accentColor': TextEditingController(text: br.accentColorHex),
      'goldColor': TextEditingController(text: br.goldColorHex),
    };
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in _c.values) c.dispose();
    for (final c in _b.values) c.dispose();
    super.dispose();
  }

  // ── Photo ─────────────────────────────────────────────────────────────────

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: AppConstants.photoMaxWidth,
      maxHeight: AppConstants.photoMaxHeight,
      imageQuality: AppConstants.photoQuality,
    );
    if (picked == null) return;

    setState(() => _compressing = true);

    try {
      // Full display photo — always read as-is
      final bytes = await File(picked.path).readAsBytes();
      final displayBase64 = base64Encode(bytes);

      String qrBase64 = '';

      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        // Mobile only: flutter_image_compress not supported on desktop/web
        final compressed = await FlutterImageCompress.compressWithFile(
          picked.path,
          minWidth: 60,
          minHeight: 60,
          quality: 25,
          format: CompressFormat.jpeg,
        );
        qrBase64 = compressed != null ? base64Encode(compressed) : '';
      }
      // Desktop/Web: qrBase64 stays '' — QR renders without photo (still scannable)

      setState(() {
        _photoBase64 = displayBase64;
        _photoQrBase64 = qrBase64;
        _compressing = false;
      });
    } catch (e) {
      debugPrint('Photo pick error: $e');
      setState(() => _compressing = false);
    }
  }

  void _removePhoto() => setState(() {
        _photoBase64 = '';
        _photoQrBase64 = '';
      });

  // ── Save ──────────────────────────────────────────────────────────────────
  void _save() {
    final updatedContact = ContactEntity(
      name: _c['name']!.text.trim(),
      title: _c['title']!.text.trim(),
      org: _c['org']!.text.trim(),
      phone: _c['phone']!.text.trim(),
      phone2: _c['phone2']!.text.trim(),
      email: _c['email']!.text.trim(),
      whatsapp: _c['whatsapp']!.text.trim(),
      website: _c['website']!.text.trim(),
      linkedin: _c['linkedin']!.text.trim(),
      address: _c['address']!.text.trim(),
      tagline: _c['tagline']!.text.trim(),
      photoBase64: _photoBase64,
      photoQrBase64: _photoQrBase64, // ← new
    );

    final updatedBrand = BrandConfig(
      appName: _b['appName']!.text.trim(),
      appBarTitle: _b['appBarTitle']!.text.trim(),
      badgeText: _b['badgeText']!.text.trim(),
      primaryColorHex: _b['primaryColor']!.text.trim(),
      accentColorHex: _b['accentColor']!.text.trim(),
      goldColorHex: _b['goldColor']!.text.trim(),
    );

    Navigator.pop(context, {
      'contact': updatedContact,
      'brand': updatedBrand,
    });
  }

  // ── Shared builders ───────────────────────────────────────────────────────
  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: Text(label,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 9,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w500,
            )),
      );

  Widget _field(
    Map<String, TextEditingController> controllers,
    String key,
    String label, {
    IconData? icon,
    TextInputType? keyboard,
    String? hint,
  }) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: TextField(
          controller: controllers[key],
          keyboardType: keyboard,
          style: const TextStyle(color: AppColors.textLight, fontSize: 14),
          decoration: InputDecoration(
            labelText: label,
            hintText: hint,
            hintStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 12),
            labelStyle:
                const TextStyle(color: AppColors.textMuted, fontSize: 12),
            prefixIcon: icon != null
                ? Icon(icon, color: AppColors.purpleMid, size: 19)
                : null,
            filled: true,
            fillColor: AppColors.darkSurface2,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.purpleMid.withOpacity(0.2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  BorderSide(color: AppColors.purpleMid.withOpacity(0.2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.purpleMid, width: 1.5),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
          ),
        ),
      );

  // ── Tab 1: Contact ────────────────────────────────────────────────────────
  Widget _buildContactTab() {
    final hasPhoto = _photoBase64.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('PICHA YAKO / YOUR PHOTO'),
          Center(
            child: Column(children: [
              // ── Avatar ──────────────────────────────────────────────────
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                          color: AppColors.purpleMid.withOpacity(0.5),
                          width: 2),
                      color: AppColors.purpleMid.withOpacity(0.15),
                    ),
                    child: ClipOval(
                      child: hasPhoto
                          ? Image.memory(base64Decode(_photoBase64),
                              fit: BoxFit.cover)
                          : const Icon(Icons.person,
                              color: AppColors.purpleMid, size: 44),
                    ),
                  ),
                  // Compression spinner overlays the avatar
                  if (_compressing)
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.55),
                      ),
                      child: const CircularProgressIndicator(
                        color: AppColors.purpleMid,
                        strokeWidth: 2.5,
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (hasPhoto && !_compressing) ...[
                Text(
                  'Picha itajumuishwa kwenye QR',
                  style: TextStyle(
                    color: AppColors.purpleMid.withOpacity(0.8),
                    fontSize: 10,
                  ),
                ),
                // Show compressed QR size as feedback
                if (_photoQrBase64.isNotEmpty)
                  Text(
                    'QR thumbnail: ${(_photoQrBase64.length * 0.75 / 1024).toStringAsFixed(1)} KB',
                    style: TextStyle(
                      color: AppColors.textMuted.withOpacity(0.7),
                      fontSize: 9,
                    ),
                  ),
              ],
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: _compressing ? null : _pickPhoto,
                    icon: const Icon(Icons.photo_library_outlined, size: 16),
                    label: const Text('Chagua Picha',
                        style: TextStyle(fontSize: 13)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.purpleMid,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                    ),
                  ),
                  if (hasPhoto && !_compressing) ...[
                    const SizedBox(width: 10),
                    IconButton(
                      onPressed: _removePhoto,
                      icon: const Icon(Icons.delete_outline,
                          color: Colors.redAccent),
                      tooltip: 'Futa Picha',
                    ),
                  ],
                ],
              ),
            ]),
          ),
          const SizedBox(height: 8),
          _section('TAARIFA ZA MSINGI / BASIC INFO'),
          _field(_c, 'name', 'Jina Kamili / Full Name',
              icon: Icons.person_outline),
          _field(_c, 'title', 'Cheo / Title', icon: Icons.work_outline),
          _field(_c, 'org', 'Shirika / Organization',
              icon: Icons.business_outlined),
          _section('MAWASILIANO / CONTACT'),
          _field(_c, 'phone', 'Simu 1 / Phone 1',
              icon: Icons.phone_outlined, keyboard: TextInputType.phone),
          _field(_c, 'phone2', 'Simu 2 / Phone 2',
              icon: Icons.phone_outlined,
              keyboard: TextInputType.phone,
              hint: 'Hiari / Optional'),
          _field(_c, 'email', 'Barua Pepe / Email',
              icon: Icons.email_outlined, keyboard: TextInputType.emailAddress),
          _field(_c, 'address', 'Anwani / Address',
              icon: Icons.location_on_outlined),
          _section('MITANDAO / SOCIAL & WEB'),
          _field(_c, 'whatsapp', 'WhatsApp Channel Link',
              icon: Icons.chat_outlined, keyboard: TextInputType.url),
          _field(_c, 'website', 'Website',
              icon: Icons.language_outlined, keyboard: TextInputType.url),
          _field(_c, 'linkedin', 'LinkedIn URL',
              icon: Icons.work_outline, keyboard: TextInputType.url),
          _section('KAULI MBIU / TAGLINE'),
          _field(_c, 'tagline', 'Tagline', icon: Icons.format_quote_outlined),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Tab 2: Brand ──────────────────────────────────────────────────────────
  Widget _buildBrandTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('JINA LA APP / APP NAME'),
          _field(_b, 'appName', 'Jina la App', icon: Icons.apps_outlined),
          _field(_b, 'appBarTitle', 'Kichwa cha Juu (AppBar)',
              icon: Icons.title_outlined),
          _field(_b, 'badgeText', 'Maandishi ya Badge',
              icon: Icons.badge_outlined),
          _section('RANGI / COLORS  (hex e.g. #3C3489)'),
          _field(_b, 'primaryColor', 'Rangi Kuu / Primary Color',
              icon: Icons.palette_outlined, hint: '#3C3489'),
          _field(_b, 'accentColor', 'Rangi Nyingine / Accent Color',
              icon: Icons.palette_outlined, hint: '#1D9E75'),
          _field(_b, 'goldColor', 'Rangi ya Cheo / Title Color',
              icon: Icons.palette_outlined, hint: '#C9A84C'),
          _section('ONYESHO LA RANGI / COLOR PREVIEW'),
          ColorPreviewWidget(
            primaryCtrl: _b['primaryColor']!,
            accentCtrl: _b['accentColor']!,
            goldCtrl: _b['goldColor']!,
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Tab 3: About ──────────────────────────────────────────────────────────
  Widget _buildAboutTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Center(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.darkSurface2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.purpleMid.withOpacity(0.2)),
              ),
              child: const Column(children: [
                Icon(Icons.credit_card_outlined,
                    color: AppColors.purpleMid, size: 48),
                SizedBox(height: 12),
                Text('i card',
                    style: TextStyle(
                        color: AppColors.textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.w700)),
                SizedBox(height: 6),
                Text('v${AppConstants.appVersion}',
                    style: TextStyle(color: AppColors.textMuted, fontSize: 12)),
                SizedBox(height: 12),
                Text(
                  'Digital Business Card App\nPowered by ISSUBI LIFE SYSTEM™',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: AppColors.textMuted, fontSize: 12, height: 1.6),
                ),
              ]),
            ),
          ),
          const SizedBox(height: 24),
          _infoRow('Mtengenezaji', 'ISSUBI LIFE SYSTEM™'),
          _infoRow('Teknolojia', 'Flutter · Dart'),
          _infoRow('QR Format', 'vCard 3.0 + PHOTO'),
          _infoRow('Hifadhi', 'SharedPreferences (Local)'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.purpleMid.withOpacity(0.15)),
            ),
            child: const Text(
              'App hii ni ya kibinafsi — data yako yote '
              'inahifadhiwa kwenye simu yako tu. '
              'Hakuna data inayotumwa kwenye seva yoyote.',
              style: TextStyle(
                  color: AppColors.textMuted, fontSize: 12, height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(children: [
          Text(label,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 12)),
          const Spacer(),
          Text(value,
              style: const TextStyle(
                  color: AppColors.textLight,
                  fontSize: 12,
                  fontWeight: FontWeight.w500)),
        ]),
      );

  // ── Build ─────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkSurface,
      appBar: AppBar(
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.textLight,
        title: const Text('Hariri · Edit',
            style: TextStyle(color: AppColors.textLight, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: AppColors.purpleMid,
          labelColor: AppColors.textLight,
          unselectedLabelColor: AppColors.textMuted,
          labelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Contact'),
            Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Brand'),
            Tab(icon: Icon(Icons.info_outline, size: 18), text: 'About'),
            Tab(icon: Icon(Icons.folder_outlined, size: 18), text: 'Portfolio'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildContactTab(),
          _buildBrandTab(),
          _buildAboutTab(),
          BlocProvider.value(
            value: context.read<PortfolioBloc>(),
            child: const PortfolioEditPage(),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton.icon(
            onPressed:
                _compressing ? null : _save, // disabled while compressing
            icon: const Icon(Icons.check, size: 18),
            label: const Text(
              'Hifadhi Mabadiliko · Save Changes',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1D9E75),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 15),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ),
      ),
    );
  }
}
