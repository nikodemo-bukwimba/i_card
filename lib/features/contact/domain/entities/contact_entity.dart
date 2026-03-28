import '../../../../core/constants/app_constants.dart';

/// Pure domain entity — zero Flutter / package imports.
class ContactEntity {
  final String name;
  final String title;
  final String org;
  final String phone;
  final String phone2;
  final String email;
  final String whatsapp;
  final String website;
  final String linkedin;
  final String address;
  final String tagline;

  /// Base64-encoded JPEG used for display AND embedded in the vCard QR photo.
  /// The photo is resized to ≤400 px before encoding, keeping the string small
  /// enough for vCard 3.0 PHOTO field usage in most contact apps.
  /// NOTE: QR photo embedding uses a down-scaled 120 px copy — see
  /// [BuildVCardUseCase] for details.
  final String photoBase64;

  const ContactEntity({
    required this.name,
    required this.title,
    required this.org,
    required this.phone,
    required this.phone2,
    required this.email,
    required this.whatsapp,
    required this.website,
    required this.linkedin,
    required this.address,
    required this.tagline,
    required this.photoBase64,
  });

  static const empty = ContactEntity(
    name:        AppConstants.defaultName,
    title:       AppConstants.defaultTitle,
    org:         AppConstants.defaultOrg,
    phone:       AppConstants.defaultPhone,
    phone2:      '',
    email:       AppConstants.defaultEmail,
    whatsapp:    AppConstants.defaultWa,
    website:     AppConstants.defaultWebsite,
    linkedin:    AppConstants.defaultLi,
    address:     AppConstants.defaultAddress,
    tagline:     AppConstants.defaultTagline,
    photoBase64: '',
  );

  ContactEntity copyWith({
    String? name,
    String? title,
    String? org,
    String? phone,
    String? phone2,
    String? email,
    String? whatsapp,
    String? website,
    String? linkedin,
    String? address,
    String? tagline,
    String? photoBase64,
  }) =>
      ContactEntity(
        name:        name        ?? this.name,
        title:       title       ?? this.title,
        org:         org         ?? this.org,
        phone:       phone       ?? this.phone,
        phone2:      phone2      ?? this.phone2,
        email:       email       ?? this.email,
        whatsapp:    whatsapp    ?? this.whatsapp,
        website:     website     ?? this.website,
        linkedin:    linkedin    ?? this.linkedin,
        address:     address     ?? this.address,
        tagline:     tagline     ?? this.tagline,
        photoBase64: photoBase64 ?? this.photoBase64,
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContactEntity &&
          name        == other.name &&
          title       == other.title &&
          org         == other.org &&
          phone       == other.phone &&
          phone2      == other.phone2 &&
          email       == other.email &&
          whatsapp    == other.whatsapp &&
          website     == other.website &&
          linkedin    == other.linkedin &&
          address     == other.address &&
          tagline     == other.tagline &&
          photoBase64 == other.photoBase64;

  @override
  int get hashCode => Object.hash(
        name, title, org, phone, phone2,
        email, whatsapp, website, linkedin,
        address, tagline, photoBase64,
      );
}