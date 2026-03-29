import 'dart:convert';
import '../entities/contact_entity.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

/// Generates a vCard 3.0 string suitable for QR codes and full NFC/share use.
///
/// Photo strategy:
///   QR  → uses [ContactEntity.photoQrBase64] (60×60 px, ~1–1.5 KB base64)
///           generated at pick time by EditPage via flutter_image_compress.
///   Full → uses [ContactEntity.photoBase64]  (full display photo, no limit).
///
/// Portfolio strategy:
///   Items are embedded as a compact JSON array in a custom X-PORTFOLIO field.
///   Only type + title + url are stored (no descriptions/thumbnails) to stay
///   within QR capacity. The ParseVCardUseCase reads this field on scan.
class BuildVCardUseCase {
  const BuildVCardUseCase();

  /// QR-safe vCard — uses ultra-small thumbnail, strict CRLF, compact payload.
  /// [portfolioItems] — pass current list from PortfolioBloc state.
  /// [includePhoto]   — embed QR thumbnail (photoQrBase64).
  String call(
    ContactEntity contact, {
    List<PortfolioItem> portfolioItems = const [],
    bool includePhoto = true,
    bool qrSafe = true,
  }) {
    // Only embed photo if QR thumbnail exists AND is small enough
    final qrPhoto = contact.photoQrBase64;
    final canEmbed = includePhoto &&
        qrPhoto.isNotEmpty &&
        qrPhoto.length <= 2048; // hard cap: ~1.5 KB decoded

    return _build(
      contact,
      portfolioItems: portfolioItems,
      embedPhoto: canEmbed,
      forQr: true,
    );
  }

  /// Full vCard for NFC / share-sheet — uses full display photo, no truncation.
  String full(
    ContactEntity contact, {
    List<PortfolioItem> portfolioItems = const [],
  }) =>
      _build(
        contact,
        portfolioItems: portfolioItems,
        embedPhoto: true,
        forQr: false,
      );

  // ── Core builder ──────────────────────────────────────────────────────────

  String _build(
    ContactEntity contact, {
    required bool embedPhoto,
    required bool forQr,
    List<PortfolioItem> portfolioItems = const [],
  }) {
    final lines = <String>[
      'BEGIN:VCARD',
      'VERSION:3.0',
      'FN:${_escape(contact.name)}',
      'N:${_nameField(contact.name)}',
      if (contact.org.isNotEmpty) 'ORG:${_escape(contact.org)}',
      if (contact.title.isNotEmpty) 'TITLE:${_escape(contact.title)}',
      'TEL;TYPE=CELL,VOICE:${contact.phone}',
      if (contact.phone2.isNotEmpty) 'TEL;TYPE=CELL,VOICE:${contact.phone2}',
      if (contact.email.isNotEmpty) 'EMAIL;TYPE=INTERNET:${contact.email}',
      if (contact.website.isNotEmpty) 'URL;TYPE=WORK:${contact.website}',
      if (contact.whatsapp.isNotEmpty) 'X-WHATSAPP:${contact.whatsapp}',
      if (contact.linkedin.isNotEmpty) 'X-LINKEDIN:${contact.linkedin}',
      if (contact.address.isNotEmpty)
        'ADR;TYPE=WORK:;;${_escape(contact.address)};;;;',
      if (contact.tagline.isNotEmpty) 'NOTE:${_escape(contact.tagline)}',
    ];

    // ── Portfolio — compact JSON, title+type+url only to stay QR-safe ────────
    if (portfolioItems.isNotEmpty) {
      final compact = portfolioItems
          .map((e) => {'t': e.type.name, 'n': e.title, 'u': e.url})
          .toList();
      lines.add('X-PORTFOLIO:${jsonEncode(compact)}');
    }

    // ── Photo ─────────────────────────────────────────────────────────────────
    if (embedPhoto) {
      // QR → use ultra-small thumbnail; Full → use display photo
      final photoData = forQr
          ? contact.photoQrBase64 // 60×60 px compressed thumbnail
          : contact.photoBase64; // full display photo

      if (photoData.isNotEmpty) {
        lines.add(
            'PHOTO;ENCODING=b;TYPE=JPEG:'); // vCard 3.0: ENCODING=b not BASE64
        lines.addAll(_foldPhoto(photoData));
      }
    }

    lines.add('END:VCARD');

    // vCard 3.0 / RFC 6350 REQUIRES \r\n line endings — not just \n
    return lines.join('\r\n');
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _escape(String s) => s
      .replaceAll(r'\', r'\\')
      .replaceAll(';', r'\;')
      .replaceAll(',', r'\,')
      .replaceAll('\n', r'\n');

  String _nameField(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return '${_escape(parts[0])};;;;';
    final last = _escape(parts.last);
    final first = _escape(parts.sublist(0, parts.length - 1).join(' '));
    return '$last;$first;;;';
  }

  /// Fold base64 photo data into 75-char continuation lines per RFC 2425.
  List<String> _foldPhoto(String b64) {
    const maxLen = 74;
    final result = <String>[];
    var offset = 0;
    while (offset < b64.length) {
      final end = (offset + maxLen).clamp(0, b64.length);
      result.add(offset == 0
          ? b64.substring(0, end)
          : ' ${b64.substring(offset, end)}');
      offset = end;
    }
    return result;
  }
}
