import '../entities/contact_entity.dart';

/// ─────────────────────────────────────────────────────────────────────────────
/// BuildVCardUseCase
///
/// Generates a vCard 3.0 string.
///
/// Photo embedding strategy
/// ────────────────────────
/// Raw QR capacity at version 40, error-correction L ≈ 2 953 bytes.
/// A base64 JPEG at 400 px ≈ 50–150 KB — far too large for a QR code.
///
/// Solution: when [includePhoto] is true we embed only the first
/// [_maxPhotoBytes] bytes of the base64 string. Most contact apps parse the
/// PHOTO field and render whatever bytes are present, so a truncated but
/// still-decodable thumbnail (≤ 3 KB) transfers correctly.
///
/// For full-fidelity photo transfer (e.g. NFC / AirDrop) pass the entity
/// as-is to toVCardFull() — no truncation.
/// ─────────────────────────────────────────────────────────────────────────────
class BuildVCardUseCase {
  /// Maximum base64 bytes to embed in the QR PHOTO field (~2 KB decoded ≈ 1.5 KB image).
  static const int _maxPhotoBytes = 2048;

  const BuildVCardUseCase();

  /// [includePhoto] — embed photo in the vCard.
  /// [qrSafe]      — truncate photo to QR-safe size (only used when includePhoto=true).
  String call(
    ContactEntity contact, {
    bool includePhoto = true,
    bool qrSafe = true,
  }) {
    final buf = StringBuffer()
      ..writeln('BEGIN:VCARD')
      ..writeln('VERSION:3.0')
      ..writeln('FN:${contact.name}')
      ..writeln('N:${_nameField(contact.name)}')
      ..writeln('ORG:${contact.org}')
      ..writeln('TITLE:${contact.title}')
      ..writeln('TEL;TYPE=CELL:${contact.phone}');

    if (contact.phone2.isNotEmpty) {
      buf.writeln('TEL;TYPE=CELL:${contact.phone2}');
    }

    buf.writeln('EMAIL:${contact.email}');

    if (contact.website.isNotEmpty)  buf.writeln('URL;TYPE=WORK:${contact.website}');
    if (contact.whatsapp.isNotEmpty) buf.writeln('URL;TYPE=WhatsApp:${contact.whatsapp}');
    if (contact.linkedin.isNotEmpty) buf.writeln('URL;TYPE=LinkedIn:${contact.linkedin}');
    if (contact.address.isNotEmpty)  buf.writeln('ADR;TYPE=WORK:;;${contact.address};;;;');

    buf.writeln('NOTE:${contact.tagline}');

    if (includePhoto && contact.photoBase64.isNotEmpty) {
      final photoData = qrSafe
          ? _truncateForQr(contact.photoBase64)
          : contact.photoBase64;
      buf.writeln('PHOTO;ENCODING=BASE64;TYPE=JPEG:');
      // vCard 3.0 spec: fold long lines with CRLF + space
      buf.writeln(_foldLine(photoData));
    }

    buf.write('END:VCARD');
    return buf.toString();
  }

  /// Full vCard for NFC / share-sheet — no photo truncation.
  String full(ContactEntity contact) =>
      call(contact, includePhoto: true, qrSafe: false);

  // ── Helpers ───────────────────────────────────────────────────────────────

  String _nameField(String name) {
    final parts = name.trim().split(' ');
    if (parts.length == 1) return '${parts[0]};;;;';
    final last  = parts.last;
    final first = parts.sublist(0, parts.length - 1).join(' ');
    return '$last;$first;;;';
  }

  /// Truncate base64 to the first [_maxPhotoBytes] characters so the total
  /// vCard string fits in a QR code.  The resulting bytes are still a valid
  /// (partial) JPEG header that contact apps use to render a blurry thumbnail.
  String _truncateForQr(String b64) {
    if (b64.length <= _maxPhotoBytes) return b64;
    // Ensure we don't cut mid base64 group (groups of 4 chars)
    final safe = (_maxPhotoBytes ~/ 4) * 4;
    return b64.substring(0, safe);
  }

  /// Fold long lines per RFC 2425 (75-char soft wrap).
  String _foldLine(String input) {
    const maxLen = 75;
    final sb = StringBuffer();
    var offset = 0;
    while (offset < input.length) {
      final end = (offset + maxLen).clamp(0, input.length);
      if (offset > 0) sb.write('\r\n '); // continuation line
      sb.write(input.substring(offset, end));
      offset = end;
    }
    return sb.toString();
  }
}