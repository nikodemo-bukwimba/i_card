import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
  runApp(const IssubiApp());
}

// ── Brand Config (customizable) ──────────────────────────
class BrandConfig {
  String appName;
  String appBarTitle;
  String badgeText;
  String primaryColorHex;
  String accentColorHex;
  String goldColorHex;

  BrandConfig({
    this.appName       = 'i card',
    this.appBarTitle   = 'ISSUBI LIFE SYSTEM™',
    this.badgeText     = 'ISSUBI LIFE SYSTEM™',
    this.primaryColorHex = '#3C3489',
    this.accentColorHex  = '#1D9E75',
    this.goldColorHex    = '#C9A84C',
  });

  Color get primaryColor => _hexToColor(primaryColorHex);
  Color get accentColor  => _hexToColor(accentColorHex);
  Color get goldColor    => _hexToColor(goldColorHex);

  Color _hexToColor(String hex) {
    hex = hex.replaceAll('#', '');
    if (hex.length == 6) hex = 'FF$hex';
    return Color(int.parse(hex, radix: 16));
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('brand_appName',       appName);
    await p.setString('brand_appBarTitle',   appBarTitle);
    await p.setString('brand_badgeText',     badgeText);
    await p.setString('brand_primaryColor',  primaryColorHex);
    await p.setString('brand_accentColor',   accentColorHex);
    await p.setString('brand_goldColor',     goldColorHex);
  }

  static Future<BrandConfig> load() async {
    final p = await SharedPreferences.getInstance();
    return BrandConfig(
      appName:         p.getString('brand_appName')      ?? 'i card',
      appBarTitle:     p.getString('brand_appBarTitle')  ?? 'ISSUBI LIFE SYSTEM™',
      badgeText:       p.getString('brand_badgeText')    ?? 'ISSUBI LIFE SYSTEM™',
      primaryColorHex: p.getString('brand_primaryColor') ?? '#3C3489',
      accentColorHex:  p.getString('brand_accentColor')  ?? '#1D9E75',
      goldColorHex:    p.getString('brand_goldColor')    ?? '#C9A84C',
    );
  }
}

// ── Rangi za msingi (hazibadiliki) ───────────────────────
class IssubiColors {
  static const dark      = Color(0xFF0E0D1A);
  static const dark2     = Color(0xFF1A1828);
  static const purpleMid = Color(0xFF7F77DD);
  static const textLight = Color(0xFFF0EEFF);
  static const textMuted = Color(0xFF9B97C4);
}

// ── Model ya Contact ─────────────────────────────────────
class ContactInfo {
  String name;
  String title;
  String org;
  String phone;
  String phone2;      // ← NAMBA YA PILI
  String email;
  String whatsapp;
  String website;
  String linkedin;
  String address;
  String tagline;
  String photoBase64;

  ContactInfo({
    this.name        = 'Jina Lako Hapa',
    this.title       = 'Founder & Life Skills Educator',
    this.org         = 'ISSUBI LIFE SYSTEM',
    this.phone       = '+255700000000',
    this.phone2      = '',
    this.email       = 'jina@issubi.com',
    this.whatsapp    = 'https://whatsapp.com/channel/issubi',
    this.website     = 'https://issubi.com',
    this.linkedin    = 'https://linkedin.com/in/jinalako',
    this.address     = 'Mbeya, Tanzania',
    this.tagline     = 'Dhibiti akili yako. Jenga maisha yako.',
    this.photoBase64 = '',
  });

  // ── vCard kamili (na picha) ───────────────────────────
  String toVCard() {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCARD');
    buf.writeln('VERSION:3.0');
    buf.writeln('FN:$name');
    buf.writeln('N:${name.split(' ').reversed.join(';')}');
    buf.writeln('ORG:$org');
    buf.writeln('TITLE:$title');
    buf.writeln('TEL;TYPE=CELL:$phone');
    if (phone2.isNotEmpty) buf.writeln('TEL;TYPE=CELL:$phone2');
    buf.writeln('EMAIL:$email');
    if (website.isNotEmpty)  buf.writeln('URL;TYPE=WORK:$website');
    if (whatsapp.isNotEmpty) buf.writeln('URL;TYPE=WhatsApp:$whatsapp');
    if (linkedin.isNotEmpty) buf.writeln('URL;TYPE=LinkedIn:$linkedin');
    if (address.isNotEmpty)  buf.writeln('ADR;TYPE=WORK:;;$address;;;;');
    buf.writeln('NOTE:$tagline');
    if (photoBase64.isNotEmpty) {
      buf.writeln('PHOTO;ENCODING=BASE64;TYPE=JPEG:$photoBase64');
    }
    buf.write('END:VCARD');
    return buf.toString();
  }

  // ── vCard ndogo (kwa QR — bila picha) ────────────────
  String toVCardQr() {
    final buf = StringBuffer();
    buf.writeln('BEGIN:VCARD');
    buf.writeln('VERSION:3.0');
    buf.writeln('FN:$name');
    buf.writeln('N:${name.split(' ').reversed.join(';')}');
    buf.writeln('ORG:$org');
    buf.writeln('TITLE:$title');
    buf.writeln('TEL;TYPE=CELL:$phone');
    if (phone2.isNotEmpty) buf.writeln('TEL;TYPE=CELL:$phone2');
    buf.writeln('EMAIL:$email');
    if (website.isNotEmpty)  buf.writeln('URL;TYPE=WORK:$website');
    if (whatsapp.isNotEmpty) buf.writeln('URL;TYPE=WhatsApp:$whatsapp');
    if (linkedin.isNotEmpty) buf.writeln('URL;TYPE=LinkedIn:$linkedin');
    if (address.isNotEmpty)  buf.writeln('ADR;TYPE=WORK:;;$address;;;;');
    buf.writeln('NOTE:$tagline');
    buf.write('END:VCARD');
    return buf.toString();
  }

  Future<void> save() async {
    final p = await SharedPreferences.getInstance();
    await p.setString('name',        name);
    await p.setString('title',       title);
    await p.setString('org',         org);
    await p.setString('phone',       phone);
    await p.setString('phone2',      phone2);
    await p.setString('email',       email);
    await p.setString('whatsapp',    whatsapp);
    await p.setString('website',     website);
    await p.setString('linkedin',    linkedin);
    await p.setString('address',     address);
    await p.setString('tagline',     tagline);
    await p.setString('photoBase64', photoBase64);
  }

  static Future<ContactInfo> load() async {
    final p = await SharedPreferences.getInstance();
    return ContactInfo(
      name:        p.getString('name')        ?? 'Jina Lako Hapa',
      title:       p.getString('title')       ?? 'Founder & Life Skills Educator',
      org:         p.getString('org')         ?? 'ISSUBI LIFE SYSTEM',
      phone:       p.getString('phone')       ?? '+255700000000',
      phone2:      p.getString('phone2')      ?? '',
      email:       p.getString('email')       ?? 'jina@issubi.com',
      whatsapp:    p.getString('whatsapp')    ?? 'https://whatsapp.com/channel/issubi',
      website:     p.getString('website')     ?? 'https://issubi.com',
      linkedin:    p.getString('linkedin')    ?? 'https://linkedin.com/in/jinalako',
      address:     p.getString('address')     ?? 'Mbeya, Tanzania',
      tagline:     p.getString('tagline')     ?? 'Dhibiti akili yako. Jenga maisha yako.',
      photoBase64: p.getString('photoBase64') ?? '',
    );
  }
}

// ── App Entry ─────────────────────────────────────────────
class IssubiApp extends StatefulWidget {
  const IssubiApp({super.key});
  @override
  State<IssubiApp> createState() => _IssubiAppState();
}

class _IssubiAppState extends State<IssubiApp> {
  BrandConfig _brand = BrandConfig();
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    BrandConfig.load().then((b) => setState(() {
      _brand = b;
      _loaded = true;
    }));
  }

  void _onBrandUpdated(BrandConfig b) => setState(() => _brand = b);

  @override
  Widget build(BuildContext context) {
    if (!_loaded) {
      return const MaterialApp(
        home: Scaffold(
          backgroundColor: IssubiColors.dark,
          body: Center(
            child: CircularProgressIndicator(color: IssubiColors.purpleMid),
          ),
        ),
      );
    }
    return MaterialApp(
      title: _brand.appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.dark(
          primary:   _brand.primaryColor,
          secondary: _brand.accentColor,
          surface:   IssubiColors.dark2,
        ),
        useMaterial3: true,
      ),
      home: CardHome(brand: _brand, onBrandUpdated: _onBrandUpdated),
    );
  }
}

// ── Home Screen ───────────────────────────────────────────
class CardHome extends StatefulWidget {
  final BrandConfig brand;
  final ValueChanged<BrandConfig> onBrandUpdated;
  const CardHome({super.key, required this.brand, required this.onBrandUpdated});

  @override
  State<CardHome> createState() => _CardHomeState();
}

class _CardHomeState extends State<CardHome>
    with SingleTickerProviderStateMixin {
  ContactInfo _info = ContactInfo();
  late AnimationController _animCtrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnim = CurvedAnimation(parent: _animCtrl, curve: Curves.easeOut);
    _load();
  }

  Future<void> _load() async {
    final info = await ContactInfo.load();
    setState(() => _info = info);
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _animCtrl.dispose();
    super.dispose();
  }

  void _openEdit() async {
    final result = await Navigator.push<Map<String, dynamic>>(
      context,
      MaterialPageRoute(
        builder: (_) => EditScreen(info: _info, brand: widget.brand),
      ),
    );
    if (result != null) {
      final updatedInfo  = result['info']  as ContactInfo;
      final updatedBrand = result['brand'] as BrandConfig;
      await updatedInfo.save();
      await updatedBrand.save();
      setState(() => _info = updatedInfo);
      widget.onBrandUpdated(updatedBrand);
    }
  }

  @override
  Widget build(BuildContext context) {
    final brand = widget.brand;
    return Scaffold(
      backgroundColor: IssubiColors.dark,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: IssubiColors.dark,
              pinned: true,
              title: Text(
                brand.appBarTitle,
                style: TextStyle(
                  color: brand.primaryColor.withOpacity(0.9),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.5,
                ),
              ),
              actions: [
                IconButton(
                  onPressed: _openEdit,
                  icon: const Icon(Icons.edit_outlined,
                      color: IssubiColors.textMuted),
                  tooltip: 'Hariri / Edit',
                ),
              ],
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 40),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  _CardWidget(info: _info, brand: brand),
                  const SizedBox(height: 16),
                  _QrSection(info: _info, brand: brand),
                  const SizedBox(height: 16),
                  _QuickLinks(info: _info, brand: brand),
                  const SizedBox(height: 16),
                  _EditButton(onTap: _openEdit, brand: brand),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Kadi ya Juu ───────────────────────────────────────────
class _CardWidget extends StatelessWidget {
  final ContactInfo info;
  final BrandConfig brand;
  const _CardWidget({required this.info, required this.brand});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = info.photoBase64.isNotEmpty;
    return Container(
      decoration: BoxDecoration(
        color: IssubiColors.dark2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Accent bar
          Container(
            height: 4,
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [
                brand.primaryColor,
                brand.primaryColor.withOpacity(0.6),
                brand.accentColor,
              ]),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(20)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(22),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: brand.accentColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                              color: brand.accentColor.withOpacity(0.3)),
                        ),
                        child: Text(
                          brand.badgeText,
                          style: TextStyle(
                            color: brand.accentColor,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.8,
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        info.name,
                        style: const TextStyle(
                          color: IssubiColors.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.3,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        info.title,
                        style: TextStyle(
                          color: brand.goldColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        info.org,
                        style: const TextStyle(
                          color: IssubiColors.textMuted,
                          fontSize: 11,
                          letterSpacing: 0.4,
                        ),
                      ),
                      if (info.address.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Row(children: [
                          const Icon(Icons.location_on_outlined,
                              color: IssubiColors.textMuted, size: 11),
                          const SizedBox(width: 3),
                          Text(info.address,
                              style: const TextStyle(
                                  color: IssubiColors.textMuted,
                                  fontSize: 11)),
                        ]),
                      ],
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                // Picha
                Container(
                  width: 76,
                  height: 76,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: brand.primaryColor.withOpacity(0.5),
                        width: 2),
                    color: brand.primaryColor.withOpacity(0.2),
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.memory(
                            base64Decode(info.photoBase64),
                            fit: BoxFit.cover,
                          )
                        : Icon(Icons.person,
                            color: brand.primaryColor, size: 36),
                  ),
                ),
              ],
            ),
          ),
          // Tagline footer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
            decoration: BoxDecoration(
              color: brand.primaryColor.withOpacity(0.08),
              borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(20)),
              border: Border(
                  top: BorderSide(
                      color: brand.primaryColor.withOpacity(0.1))),
            ),
            child: Text(
              '"${info.tagline}"',
              style: const TextStyle(
                color: IssubiColors.textMuted,
                fontSize: 11,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── QR Section ────────────────────────────────────────────
class _QrSection extends StatelessWidget {
  final ContactInfo info;
  final BrandConfig brand;
  const _QrSection({required this.info, required this.brand});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: IssubiColors.dark2,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: brand.primaryColor.withOpacity(0.2)),
      ),
      padding: const EdgeInsets.all(22),
      child: Column(
        children: [
          const Text(
            'SCAN · HIFADHI CONTACT · TAP MOJA TU',
            style: TextStyle(
              color: IssubiColors.textMuted,
              fontSize: 9,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                  color: brand.primaryColor.withOpacity(0.35), width: 2.5),
            ),
            child: QrImageView(
              data: info.toVCardQr(),
              version: QrVersions.auto,
              size: 190,
              backgroundColor: Colors.white,
              eyeStyle: const QrEyeStyle(
                eyeShape: QrEyeShape.square,
                color: Color(0xFF1A1828),
              ),
              dataModuleStyle: const QrDataModuleStyle(
                dataModuleShape: QrDataModuleShape.square,
                color: Color(0xFF1A1828),
              ),
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
            decoration: BoxDecoration(
              color: brand.primaryColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
              border:
                  Border.all(color: brand.primaryColor.withOpacity(0.25)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.info_outline,
                    color: IssubiColors.purpleMid, size: 13),
                SizedBox(width: 7),
                Flexible(
                  child: Text(
                    'iPhone: Camera app  •  Android: Google Lens',
                    style: TextStyle(
                        color: IssubiColors.textMuted, fontSize: 11),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Quick Links ───────────────────────────────────────────
class _QuickLinks extends StatelessWidget {
  final ContactInfo info;
  final BrandConfig brand;
  const _QuickLinks({required this.info, required this.brand});

  Future<void> _launch(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final links = [
      (Icons.phone_outlined,    brand.primaryColor,           'Simu / Phone',       info.phone,   'tel:${info.phone}'),
      if (info.phone2.isNotEmpty)
        (Icons.phone_outlined,  brand.primaryColor,           'Simu 2 / Phone 2',   info.phone2,  'tel:${info.phone2}'),
      (Icons.email_outlined,    brand.accentColor,            'Barua Pepe / Email', info.email,   'mailto:${info.email}'),
      (Icons.chat_outlined,     const Color(0xFF25D366),      'WhatsApp Channel',   'WhatsApp',   info.whatsapp),
      (Icons.language_outlined, brand.goldColor,              'Website',            info.website, info.website),
      (Icons.work_outline,      const Color(0xFF0A66C2),      'LinkedIn',           'LinkedIn',   info.linkedin),
    ].where((e) => e.$5.isNotEmpty && e.$5 != 'https://').toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 10),
          child: Text(
            'MAWASILIANO YA HARAKA',
            style: TextStyle(
                color: IssubiColors.textMuted,
                fontSize: 9,
                letterSpacing: 2),
          ),
        ),
        ...links.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: _LinkTile(
                icon: e.$1,
                iconColor: e.$2,
                label: e.$3,
                value: e.$4,
                onTap: () => _launch(e.$5),
              ),
            )),
      ],
    );
  }
}

class _LinkTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _LinkTile({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: IssubiColors.dark2,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: IssubiColors.purpleMid.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, color: iconColor, size: 19),
              ),
              const SizedBox(width: 13),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: IssubiColors.textMuted,
                            fontSize: 10,
                            letterSpacing: 0.4)),
                    const SizedBox(height: 2),
                    Text(value,
                        style: const TextStyle(
                            color: IssubiColors.textLight, fontSize: 13),
                        overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right,
                  color: IssubiColors.textMuted, size: 17),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Edit Button ───────────────────────────────────────────
class _EditButton extends StatelessWidget {
  final VoidCallback onTap;
  final BrandConfig brand;
  const _EditButton({required this.onTap, required this.brand});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: const Icon(Icons.edit_outlined, size: 17),
        label: const Text('Hariri Taarifa · Edit Info',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        style: ElevatedButton.styleFrom(
          backgroundColor: brand.primaryColor,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 15),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

// ── Edit Screen ───────────────────────────────────────────
class EditScreen extends StatefulWidget {
  final ContactInfo info;
  final BrandConfig brand;
  const EditScreen({super.key, required this.info, required this.brand});

  @override
  State<EditScreen> createState() => _EditScreenState();
}

class _EditScreenState extends State<EditScreen>
    with SingleTickerProviderStateMixin {
  late final Map<String, TextEditingController> _ctrl;
  late final Map<String, TextEditingController> _brandCtrl;
  String _photoBase64 = '';
  final _picker = ImagePicker();
  late TabController _tabCtrl;

  @override
  void initState() {
    super.initState();
    _tabCtrl = TabController(length: 3, vsync: this);
    _photoBase64 = widget.info.photoBase64;

    _ctrl = {
      'name':     TextEditingController(text: widget.info.name),
      'title':    TextEditingController(text: widget.info.title),
      'org':      TextEditingController(text: widget.info.org),
      'phone':    TextEditingController(text: widget.info.phone),
      'phone2':   TextEditingController(text: widget.info.phone2),
      'email':    TextEditingController(text: widget.info.email),
      'whatsapp': TextEditingController(text: widget.info.whatsapp),
      'website':  TextEditingController(text: widget.info.website),
      'linkedin': TextEditingController(text: widget.info.linkedin),
      'address':  TextEditingController(text: widget.info.address),
      'tagline':  TextEditingController(text: widget.info.tagline),
    };

    _brandCtrl = {
      'appName':     TextEditingController(text: widget.brand.appName),
      'appBarTitle': TextEditingController(text: widget.brand.appBarTitle),
      'badgeText':   TextEditingController(text: widget.brand.badgeText),
      'primaryColor':TextEditingController(text: widget.brand.primaryColorHex),
      'accentColor': TextEditingController(text: widget.brand.accentColorHex),
      'goldColor':   TextEditingController(text: widget.brand.goldColorHex),
    };
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    for (final c in _ctrl.values) c.dispose();
    for (final c in _brandCtrl.values) c.dispose();
    super.dispose();
  }

  Future<void> _pickPhoto() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 400,
      maxHeight: 400,
      imageQuality: 75,
    );
    if (picked == null) return;
    final bytes = await File(picked.path).readAsBytes();
    setState(() => _photoBase64 = base64Encode(bytes));
  }

  void _removePhoto() => setState(() => _photoBase64 = '');

  void _save() {
    final updatedInfo = ContactInfo(
      name:        _ctrl['name']!.text.trim(),
      title:       _ctrl['title']!.text.trim(),
      org:         _ctrl['org']!.text.trim(),
      phone:       _ctrl['phone']!.text.trim(),
      phone2:      _ctrl['phone2']!.text.trim(),
      email:       _ctrl['email']!.text.trim(),
      whatsapp:    _ctrl['whatsapp']!.text.trim(),
      website:     _ctrl['website']!.text.trim(),
      linkedin:    _ctrl['linkedin']!.text.trim(),
      address:     _ctrl['address']!.text.trim(),
      tagline:     _ctrl['tagline']!.text.trim(),
      photoBase64: _photoBase64,
    );

    final updatedBrand = BrandConfig(
      appName:         _brandCtrl['appName']!.text.trim(),
      appBarTitle:     _brandCtrl['appBarTitle']!.text.trim(),
      badgeText:       _brandCtrl['badgeText']!.text.trim(),
      primaryColorHex: _brandCtrl['primaryColor']!.text.trim(),
      accentColorHex:  _brandCtrl['accentColor']!.text.trim(),
      goldColorHex:    _brandCtrl['goldColor']!.text.trim(),
    );

    Navigator.pop(context, {'info': updatedInfo, 'brand': updatedBrand});
  }

  // ── Helpers ───────────────────────────────────────────
  Widget _section(String label) => Padding(
        padding: const EdgeInsets.only(top: 8, bottom: 14),
        child: Text(label,
            style: const TextStyle(
                color: IssubiColors.textMuted,
                fontSize: 9,
                letterSpacing: 2.2,
                fontWeight: FontWeight.w500)),
      );

  Widget _field(Map<String, TextEditingController> controllers,
      String key, String label,
      {IconData? icon, TextInputType? keyboard, String? hint}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controllers[key],
        keyboardType: keyboard,
        style: const TextStyle(color: IssubiColors.textLight, fontSize: 14),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          hintStyle: const TextStyle(
              color: IssubiColors.textMuted, fontSize: 12),
          labelStyle: const TextStyle(
              color: IssubiColors.textMuted, fontSize: 12),
          prefixIcon: icon != null
              ? Icon(icon, color: IssubiColors.purpleMid, size: 19)
              : null,
          filled: true,
          fillColor: IssubiColors.dark2,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: IssubiColors.purpleMid.withOpacity(0.2)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(
                color: IssubiColors.purpleMid.withOpacity(0.2)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(
                color: IssubiColors.purpleMid, width: 1.5),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
        ),
      ),
    );
  }

  // ── Tab 1: Contact Info ───────────────────────────────
  Widget _buildContactTab() {
    final hasPhoto = _photoBase64.isNotEmpty;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('PICHA YAKO / YOUR PHOTO'),
          Center(
            child: Column(
              children: [
                Container(
                  width: 100, height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: IssubiColors.purpleMid.withOpacity(0.5),
                        width: 2),
                    color: IssubiColors.purpleMid.withOpacity(0.15),
                  ),
                  child: ClipOval(
                    child: hasPhoto
                        ? Image.memory(base64Decode(_photoBase64),
                            fit: BoxFit.cover)
                        : const Icon(Icons.person,
                            color: IssubiColors.purpleMid, size: 44),
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickPhoto,
                      icon: const Icon(Icons.photo_library_outlined, size: 16),
                      label: const Text('Chagua Picha',
                          style: TextStyle(fontSize: 13)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: IssubiColors.purpleMid,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 10),
                      ),
                    ),
                    if (hasPhoto) ...[
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
              ],
            ),
          ),
          const SizedBox(height: 8),

          _section('TAARIFA ZA MSINGI / BASIC INFO'),
          _field(_ctrl, 'name',  'Jina Kamili / Full Name', icon: Icons.person_outline),
          _field(_ctrl, 'title', 'Cheo / Title',             icon: Icons.work_outline),
          _field(_ctrl, 'org',   'Shirika / Organization',   icon: Icons.business_outlined),

          _section('MAWASILIANO / CONTACT'),
          _field(_ctrl, 'phone',  'Simu 1 / Phone 1',   icon: Icons.phone_outlined,   keyboard: TextInputType.phone),
          _field(_ctrl, 'phone2', 'Simu 2 / Phone 2',   icon: Icons.phone_outlined,   keyboard: TextInputType.phone,
              hint: 'Hiari / Optional'),
          _field(_ctrl, 'email',  'Barua Pepe / Email', icon: Icons.email_outlined,   keyboard: TextInputType.emailAddress),
          _field(_ctrl, 'address','Anwani / Address',   icon: Icons.location_on_outlined),

          _section('MITANDAO / SOCIAL & WEB'),
          _field(_ctrl, 'whatsapp', 'WhatsApp Channel Link', icon: Icons.chat_outlined,     keyboard: TextInputType.url),
          _field(_ctrl, 'website',  'Website',               icon: Icons.language_outlined, keyboard: TextInputType.url),
          _field(_ctrl, 'linkedin', 'LinkedIn URL',           icon: Icons.work_outline,      keyboard: TextInputType.url),

          _section('KAULI MBIU / TAGLINE'),
          _field(_ctrl, 'tagline', 'Tagline', icon: Icons.format_quote_outlined),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Tab 2: Brand / App Customization ─────────────────
  Widget _buildBrandTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _section('JINA LA APP / APP NAME'),
          _field(_brandCtrl, 'appName',     'Jina la App',          icon: Icons.apps_outlined),
          _field(_brandCtrl, 'appBarTitle', 'Kichwa cha Juu (AppBar)', icon: Icons.title_outlined),
          _field(_brandCtrl, 'badgeText',   'Maandishi ya Badge',    icon: Icons.badge_outlined),

          _section('RANGI / COLORS  (hex e.g. #3C3489)'),
          _field(_brandCtrl, 'primaryColor', 'Rangi Kuu / Primary Color',
              icon: Icons.palette_outlined, hint: '#3C3489'),
          _field(_brandCtrl, 'accentColor',  'Rangi Nyingine / Accent Color',
              icon: Icons.palette_outlined, hint: '#1D9E75'),
          _field(_brandCtrl, 'goldColor',    'Rangi ya Cheo / Title Color',
              icon: Icons.palette_outlined, hint: '#C9A84C'),

          // Color preview
          const SizedBox(height: 8),
          _section('ONYESHO LA RANGI / COLOR PREVIEW'),
          _ColorPreview(ctrl: _brandCtrl),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  // ── Tab 3: About ──────────────────────────────────────
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
                color: IssubiColors.dark2,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: IssubiColors.purpleMid.withOpacity(0.2)),
              ),
              child: const Column(
                children: [
                  Icon(Icons.credit_card_outlined,
                      color: IssubiColors.purpleMid, size: 48),
                  SizedBox(height: 12),
                  Text('i card',
                      style: TextStyle(
                          color: IssubiColors.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w700)),
                  SizedBox(height: 6),
                  Text('v1.0.0',
                      style: TextStyle(
                          color: IssubiColors.textMuted, fontSize: 12)),
                  SizedBox(height: 12),
                  Text(
                    'Digital Business Card App\nPowered by ISSUBI LIFE SYSTEM™',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: IssubiColors.textMuted, fontSize: 12, height: 1.6),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          _infoRow('Mtengenezaji', 'ISSUBI LIFE SYSTEM™'),
          _infoRow('Teknolojia', 'Flutter · Dart'),
          _infoRow('QR Format', 'vCard 3.0'),
          _infoRow('Hifadhi', 'SharedPreferences (Local)'),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: IssubiColors.dark2,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                  color: IssubiColors.purpleMid.withOpacity(0.15)),
            ),
            child: const Text(
              'App hii ni ya kibinafsi — data yako yote '
              'inahifadhiwa kwenye simu yako tu. '
              'Hakuna data inayotumwa kwenye seva yoyote.',
              style: TextStyle(
                  color: IssubiColors.textMuted,
                  fontSize: 12,
                  height: 1.6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: Row(
          children: [
            Text(label,
                style: const TextStyle(
                    color: IssubiColors.textMuted, fontSize: 12)),
            const Spacer(),
            Text(value,
                style: const TextStyle(
                    color: IssubiColors.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: IssubiColors.dark,
      appBar: AppBar(
        backgroundColor: IssubiColors.dark,
        foregroundColor: IssubiColors.textLight,
        title: const Text('Hariri · Edit',
            style: TextStyle(color: IssubiColors.textLight, fontSize: 16)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, size: 17),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: TabBar(
          controller: _tabCtrl,
          indicatorColor: IssubiColors.purpleMid,
          labelColor: IssubiColors.textLight,
          unselectedLabelColor: IssubiColors.textMuted,
          labelStyle:
              const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(icon: Icon(Icons.person_outline, size: 18), text: 'Contact'),
            Tab(icon: Icon(Icons.palette_outlined, size: 18), text: 'Brand'),
            Tab(icon: Icon(Icons.info_outline, size: 18), text: 'About'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabCtrl,
        children: [
          _buildContactTab(),
          _buildBrandTab(),
          _buildAboutTab(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: ElevatedButton.icon(
            onPressed: _save,
            icon: const Icon(Icons.check, size: 18),
            label: const Text('Hifadhi Mabadiliko · Save Changes',
                style:
                    TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
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

// ── Color Preview Widget ──────────────────────────────────
class _ColorPreview extends StatefulWidget {
  final Map<String, TextEditingController> ctrl;
  const _ColorPreview({required this.ctrl});

  @override
  State<_ColorPreview> createState() => _ColorPreviewState();
}

class _ColorPreviewState extends State<_ColorPreview> {
  Color _parse(String key) {
    try {
      String hex = widget.ctrl[key]!.text.replaceAll('#', '');
      if (hex.length == 6) hex = 'FF$hex';
      return Color(int.parse(hex, radix: 16));
    } catch (_) {
      return Colors.grey;
    }
  }

  @override
  void initState() {
    super.initState();
    for (final c in widget.ctrl.values) {
      c.addListener(() => setState(() {}));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _swatch('Primary', _parse('primaryColor')),
        const SizedBox(width: 10),
        _swatch('Accent', _parse('accentColor')),
        const SizedBox(width: 10),
        _swatch('Title', _parse('goldColor')),
      ],
    );
  }

  Widget _swatch(String label, Color color) => Expanded(
        child: Column(
          children: [
            Container(
              height: 40,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const SizedBox(height: 4),
            Text(label,
                style: const TextStyle(
                    color: IssubiColors.textMuted, fontSize: 10)),
          ],
        ),
      );
}