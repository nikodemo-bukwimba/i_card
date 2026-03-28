import '../entities/contact_entity.dart';

/// Generates a vCard 3.0 string suitable for QR codes and full NFC/share use.
///
/// Photo strategy:
///   QR  → uses [ContactEntity.photoQrBase64] (60×60 px, ~1–1.5 KB base64)
///           generated at pick time by EditPage via flutter_image_compress.
///   Full → uses [ContactEntity.photoBase64]  (full display photo, no limit).
class BuildVCardUseCase {
  const BuildVCardUseCase();

  /// QR-safe vCard — uses ultra-small thumbnail, strict CRLF, compact payload.
  /// Pass [includePhoto] true to embed the QR thumbnail (photoQrBase64).
  String call(
    ContactEntity contact, {
    bool includePhoto = true, // now ON by default — thumbnail is safe to embed
    bool qrSafe = true,
  }) {
    final embedPhoto = includePhoto && !qrSafe ||
        includePhoto && qrSafe && contact.photoQrBase64.isNotEmpty;
    return _build(contact, embedPhoto: embedPhoto, forQr: qrSafe);
  }

  /// Full vCard for NFC / share-sheet — uses full display photo.
  String full(ContactEntity contact) =>
      _build(contact, embedPhoto: true, forQr: false);

  // ── Core builder ──────────────────────────────────────────────────────────

  String _build(
    ContactEntity contact, {
    required bool embedPhoto,
    required bool forQr,
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

    if (embedPhoto) {
      // QR → use ultra-small thumbnail; Full → use display photo
      final photoData = forQr
          ? contact.photoQrBase64 // ← 60×60 px compressed thumbnail
          : contact.photoBase64; // ← full display photo

      if (photoData.isNotEmpty) {
        lines.add('PHOTO;ENCODING=b;TYPE=JPEG:');
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

  /// Fold base64 photo data into 75-char continuation lines.
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
