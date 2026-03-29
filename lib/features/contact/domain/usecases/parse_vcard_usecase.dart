import 'dart:convert';
import '../entities/contact_entity.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

/// Result returned after parsing a scanned vCard QR string.
class ScannedCardResult {
  final ContactEntity contact;
  final List<PortfolioItem> portfolioItems;

  const ScannedCardResult({
    required this.contact,
    required this.portfolioItems,
  });
}

class ParseVCardUseCase {
  const ParseVCardUseCase();

  ScannedCardResult call(String rawVCard) {
    final lines = _unfoldLines(rawVCard);
    final fields = <String, List<String>>{};

    for (final line in lines) {
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      final key = line.substring(0, colon).toUpperCase();
      final value = line.substring(colon + 1).trim();
      fields.putIfAbsent(key, () => []).add(value);
    }

    String field(String key, [String fallback = '']) =>
        fields[key]?.firstOrNull ?? fallback;

    // ── Parse phones ──────────────────────────────────────────────────────
    final phones = fields.entries
        .where((e) => e.key.startsWith('TEL'))
        .expand((e) => e.value)
        .toList();

    // ── Parse URLs ────────────────────────────────────────────────────────
    // Our encoder uses X-WHATSAPP and X-LINKEDIN custom fields
    String website = field('URL;TYPE=WORK');
    String whatsapp = field('X-WHATSAPP');
    String linkedin = field('X-LINKEDIN');

    // Fallback: parse old-style URL;TYPE=xxx fields for backwards compat
    if (website.isEmpty && whatsapp.isEmpty && linkedin.isEmpty) {
      for (final entry in fields.entries) {
        if (!entry.key.startsWith('URL')) continue;
        for (final v in entry.value) {
          final kLower = entry.key.toLowerCase();
          if (kLower.contains('whatsapp'))
            whatsapp = v;
          else if (kLower.contains('linkedin'))
            linkedin = v;
          else
            website = v;
        }
      }
    }

    // ── Parse photo ───────────────────────────────────────────────────────
    String photo = '';
    for (final entry in fields.entries) {
      if (entry.key.startsWith('PHOTO')) {
        photo = entry.value.firstOrNull ?? '';
        break;
      }
    }

    // ── Parse address ─────────────────────────────────────────────────────
    // vCard ADR format: ;;street;city;region;postal;country
    // vCard escaping: \; \, \\ \n — must be unescaped after splitting
    String address = '';
    final adrEntries = fields.entries
        .where((e) => e.key.startsWith('ADR'))
        .expand((e) => e.value)
        .toList();
    if (adrEntries.isNotEmpty) {
      final parts = adrEntries.first.split(';');
      address = parts
          .map(_unescapeVCard) // unescape each part first
          .where((p) => p.trim().isNotEmpty)
          .join(', '); // join cleanly — no backslashes
    }

    // ── Parse portfolio (X-PORTFOLIO custom field) ────────────────────────
    final portfolioItems = <PortfolioItem>[];
    final portfolioRaw = field('X-PORTFOLIO');
    if (portfolioRaw.isNotEmpty) {
      try {
        final list = jsonDecode(portfolioRaw) as List;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          portfolioItems.add(PortfolioItem(
            id: '${map['n']}_${map['u']}'.hashCode.abs().toString(),
            type: PortfolioItemType.values.byName(map['t'] as String),
            title: map['n'] as String,
            url: map['u'] as String,
            description: map['d'] as String? ?? '', // optional field
          ));
        }
      } catch (_) {
        // Malformed JSON — skip portfolio, keep contact data
      }
    }

    final contact = ContactEntity(
      name: _unescapeVCard(field('FN')),
      title: _unescapeVCard(field('TITLE')),
      org: _unescapeVCard(field('ORG')),
      phone: phones.isNotEmpty ? phones[0] : '',
      phone2: phones.length > 1 ? phones[1] : '',
      email: field('EMAIL;TYPE=INTERNET').isNotEmpty
          ? field('EMAIL;TYPE=INTERNET')
          : field('EMAIL'),
      whatsapp: whatsapp,
      website: website,
      linkedin: linkedin,
      address: address,
      tagline: _unescapeVCard(field('NOTE')),
      photoBase64: photo,
    );

    return ScannedCardResult(
      contact: contact,
      portfolioItems: portfolioItems,
    );
  }

  // ── Unescape vCard encoded text ───────────────────────────────────────────
  // Reverses the _escape() in BuildVCardUseCase:
  //   \\ → \    \; → ;    \, → ,    \n → newline
  String _unescapeVCard(String s) => s
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', r'\');

  // ── vCard line unfolding (CRLF + space/tab = continuation line) ───────────
  List<String> _unfoldLines(String raw) {
    final unfolded = raw
        .replaceAll('\r\n ', '')
        .replaceAll('\r\n\t', '')
        .replaceAll('\n ', '')
        .replaceAll('\n\t', '');
    return unfolded
        .split(RegExp(r'\r\n|\r|\n'))
        .where((l) => l.isNotEmpty)
        .toList();
  }
}
