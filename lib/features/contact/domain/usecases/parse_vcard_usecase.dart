import 'dart:convert';
import '../entities/contact_entity.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

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

    // ── Build a key→values map ─────────────────────────────────────────────
    // Key is everything before the first colon, uppercased.
    // We store ALL values per key because TEL can appear multiple times.
    final fields = <String, List<String>>{};

    for (final line in lines) {
      final colon = line.indexOf(':');
      if (colon < 0) continue;
      final rawKey = line.substring(0, colon).toUpperCase().trim();
      final value = line.substring(colon + 1).trim();
      if (value.isEmpty) continue;
      fields.putIfAbsent(rawKey, () => []).add(value);
    }

    // ── Flexible field reader ──────────────────────────────────────────────
    // Matches by prefix so "EMAIL", "EMAIL;TYPE=INTERNET", "EMAIL;TYPE=WORK"
    // all return the same value.
    String read(String prefix, [String fallback = '']) {
      prefix = prefix.toUpperCase();
      for (final entry in fields.entries) {
        if (entry.key == prefix || entry.key.startsWith('$prefix;')) {
          return entry.value.firstOrNull ?? fallback;
        }
      }
      return fallback;
    }

    List<String> readAll(String prefix) {
      prefix = prefix.toUpperCase();
      final result = <String>[];
      for (final entry in fields.entries) {
        if (entry.key == prefix || entry.key.startsWith('$prefix;')) {
          result.addAll(entry.value);
        }
      }
      return result;
    }

    // ── Phones ─────────────────────────────────────────────────────────────
    final phones = readAll('TEL');

    // ── URLs — check custom fields first, then URL entries ─────────────────
    String whatsapp = read('X-WHATSAPP');
    String linkedin = read('X-LINKEDIN');

    // Collect all URL entries and route them by type parameter
    String website = '';
    for (final entry in fields.entries) {
      if (!entry.key.startsWith('URL')) continue;
      for (final v in entry.value) {
        final keyLower = entry.key.toLowerCase();
        if (keyLower.contains('whatsapp') && whatsapp.isEmpty) {
          whatsapp = v;
        } else if (keyLower.contains('linkedin') && linkedin.isEmpty) {
          linkedin = v;
        } else if (website.isEmpty) {
          website = v;
        }
      }
    }

    // ── Address ────────────────────────────────────────────────────────────
    String address = '';
    final adrValues = readAll('ADR');
    if (adrValues.isNotEmpty) {
      // vCard ADR: PO box ; extended ; street ; city ; region ; postal ; country
      // Your encoder writes: ADR:;;Mbeya, Tanzania;;;;
      final parts = adrValues.first.split(';');
      address = parts
          .map(_unescape)
          .where((p) => p.trim().isNotEmpty)
          .join(', ');
    }

    // ── Photo ──────────────────────────────────────────────────────────────
    final photo = read('PHOTO');

    // ── Portfolio ──────────────────────────────────────────────────────────
    final portfolioItems = <PortfolioItem>[];
    final portfolioRaw = read('X-PORTFOLIO');
    if (portfolioRaw.isNotEmpty) {
      try {
        final list = jsonDecode(portfolioRaw) as List;
        for (final item in list) {
          final map = item as Map<String, dynamic>;
          portfolioItems.add(
            PortfolioItem(
              id: '${map['n']}_${map['u']}'.hashCode.abs().toString(),
              type: PortfolioItemType.values.byName(map['t'] as String),
              title: map['n'] as String,
              url: map['u'] as String,
              description: map['d'] as String? ?? '',
            ),
          );
        }
      } catch (_) {
        // Malformed JSON — skip portfolio, keep contact
      }
    }

    final contact = ContactEntity(
      name: _unescape(read('FN')),
      title: _unescape(read('TITLE')),
      org: _unescape(read('ORG')),
      phone: phones.isNotEmpty ? phones[0] : '',
      phone2: phones.length > 1 ? phones[1] : '',
      email: _unescape(read('EMAIL')),
      whatsapp: whatsapp,
      website: website,
      linkedin: linkedin,
      address: address,
      tagline: _unescape(read('NOTE')),
      photoBase64: photo,
    );

    return ScannedCardResult(contact: contact, portfolioItems: portfolioItems);
  }

  // ── vCard line unfolding ───────────────────────────────────────────────────
  // Continuation lines start with a space or tab after CRLF / LF.
  List<String> _unfoldLines(String raw) {
    final unfolded = raw
        .replaceAll('\r\n ', '')
        .replaceAll('\r\n\t', '')
        .replaceAll('\n ', '')
        .replaceAll('\n\t', '');
    return unfolded
        .split(RegExp(r'\r\n|\r|\n'))
        .where((l) => l.trim().isNotEmpty)
        .toList();
  }

  // ── vCard text unescaping ─────────────────────────────────────────────────
  String _unescape(String s) => s
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\,', ',')
      .replaceAll(r'\;', ';')
      .replaceAll(r'\\', r'\');
}
