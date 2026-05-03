import 'dart:convert';
import '../entities/contact_entity.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

/// Generates vCard strings for different purposes.
///
/// QR code (external scanners):
///   → Plain text only. No photo. No X-PORTFOLIO.
///   → Stays under 500 bytes so any scanner on any phone reads it instantly.
///
/// In-app scan (ParseVCardUseCase reads X-PORTFOLIO):
///   → Same minimal vCard. Portfolio transfer via in-app scanner only.
///
/// Full / NFC / share-sheet:
///   → Full photo + all fields, no size limit.
class BuildVCardUseCase {
  const BuildVCardUseCase();

  /// Minimal vCard for QR — readable by any scanner on any phone.
  /// No photo, no X-PORTFOLIO, no custom fields.
  /// Stays under ~400 bytes for maximum scanner compatibility.
  String callMinimal(ContactEntity contact) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${_escape(contact.name)}',
      'N:${_nameField(contact.name)}',
      if (contact.org.isNotEmpty) 'ORG:${_escape(contact.org)}',
      if (contact.title.isNotEmpty) 'TITLE:${_escape(contact.title)}',
      'TEL;TYPE=CELL:${contact.phone}',
      if (contact.phone2.isNotEmpty) 'TEL;TYPE=CELL:${contact.phone2}',
      if (contact.email.isNotEmpty) 'EMAIL:${contact.email}',
      if (contact.website.isNotEmpty) 'URL:${contact.website}',
      if (contact.address.isNotEmpty) 'ADR:;;${contact.address};;;;',
      'END:VCARD',
    ];
    return lines.join('\r\n');
  }

  /// In-app vCard — includes X-PORTFOLIO so the i card scanner
  /// can save portfolio items. Still no photo (keeps QR scannable).
  String callWithPortfolio(
    ContactEntity contact, {
    List<PortfolioItem> portfolioItems = const [],
  }) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${_escape(contact.name)}',
      'N:${_nameField(contact.name)}',
      if (contact.org.isNotEmpty) 'ORG:${_escape(contact.org)}',
      if (contact.title.isNotEmpty) 'TITLE:${_escape(contact.title)}',
      'TEL;TYPE=CELL:${contact.phone}',
      if (contact.phone2.isNotEmpty) 'TEL;TYPE=CELL:${contact.phone2}',
      if (contact.email.isNotEmpty) 'EMAIL:${contact.email}',
      if (contact.website.isNotEmpty) 'URL:${contact.website}',
      if (contact.whatsapp.isNotEmpty) 'X-WHATSAPP:${contact.whatsapp}',
      if (contact.linkedin.isNotEmpty) 'X-LINKEDIN:${contact.linkedin}',
      if (contact.address.isNotEmpty) 'ADR:;;${contact.address};;;;',
      if (contact.tagline.isNotEmpty) 'NOTE:${_escape(contact.tagline)}',
    ];

    // Portfolio — compact, title+type+url only
    if (portfolioItems.isNotEmpty) {
      final compact =
          portfolioItems
              .map((e) => {'t': e.type.name, 'n': e.title, 'u': e.url})
              .toList();
      lines.add('X-PORTFOLIO:${jsonEncode(compact)}');
    }

    lines.add('END:VCARD');
    return lines.join('\r\n');
  }

  /// Full vCard for NFC / share-sheet — full photo, all fields, no limits.
  String callFull(
    ContactEntity contact, {
    List<PortfolioItem> portfolioItems = const [],
  }) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${_escape(contact.name)}',
      'N:${_nameField(contact.name)}',
      if (contact.org.isNotEmpty) 'ORG:${_escape(contact.org)}',
      if (contact.title.isNotEmpty) 'TITLE:${_escape(contact.title)}',
      'TEL;TYPE=CELL:${contact.phone}',
      if (contact.phone2.isNotEmpty) 'TEL;TYPE=CELL:${contact.phone2}',
      if (contact.email.isNotEmpty) 'EMAIL:${contact.email}',
      if (contact.website.isNotEmpty) 'URL:${contact.website}',
      if (contact.whatsapp.isNotEmpty) 'X-WHATSAPP:${contact.whatsapp}',
      if (contact.linkedin.isNotEmpty) 'X-LINKEDIN:${contact.linkedin}',
      if (contact.address.isNotEmpty) 'ADR:;;${contact.address};;;;',
      if (contact.tagline.isNotEmpty) 'NOTE:${_escape(contact.tagline)}',
    ];

    if (portfolioItems.isNotEmpty) {
      final compact =
          portfolioItems
              .map((e) => {'t': e.type.name, 'n': e.title, 'u': e.url})
              .toList();
      lines.add('X-PORTFOLIO:${jsonEncode(compact)}');
    }

    if (contact.photoBase64.isNotEmpty) {
      lines.add('PHOTO;ENCODING=b;TYPE=JPEG:');
      lines.addAll(_foldPhoto(contact.photoBase64));
    }

    lines.add('END:VCARD');
    return lines.join('\r\n');
  }

  // Keep `call()` working for any existing callers — routes to minimal.
  String call(
    ContactEntity contact, {
    List<PortfolioItem> portfolioItems = const [],
    bool includePhoto = false,
    bool qrSafe = true,
  }) => callMinimal(contact);

  // ── Helpers ───────────────────────────────────────────────────────────────
  String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');

  String _nameField(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return '${_escape(parts[0])};;;;';
    return '${_escape(parts.last)};${_escape(parts.sublist(0, parts.length - 1).join(' '))};;;';
  }

  List<String> _foldPhoto(String b64) {
    const maxLen = 74;
    final result = <String>[];
    var offset = 0;
    while (offset < b64.length) {
      final end = (offset + maxLen).clamp(0, b64.length);
      result.add(
        offset == 0 ? b64.substring(0, end) : ' ${b64.substring(offset, end)}',
      );
      offset = end;
    }
    return result;
  }
}
