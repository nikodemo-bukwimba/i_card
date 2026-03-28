import '../../domain/entities/contact_entity.dart';

class ContactModel extends ContactEntity {
  const ContactModel({
    required super.name,
    required super.title,
    required super.org,
    required super.phone,
    required super.phone2,
    required super.email,
    required super.whatsapp,
    required super.website,
    required super.linkedin,
    required super.address,
    required super.tagline,
    required super.photoBase64,
  });

  factory ContactModel.fromEntity(ContactEntity e) => ContactModel(
        name:        e.name,
        title:       e.title,
        org:         e.org,
        phone:       e.phone,
        phone2:      e.phone2,
        email:       e.email,
        whatsapp:    e.whatsapp,
        website:     e.website,
        linkedin:    e.linkedin,
        address:     e.address,
        tagline:     e.tagline,
        photoBase64: e.photoBase64,
      );

  factory ContactModel.fromPrefs(Map<String, String?> p) => ContactModel(
        name:        p['name']        ?? ContactEntity.empty.name,
        title:       p['title']       ?? ContactEntity.empty.title,
        org:         p['org']         ?? ContactEntity.empty.org,
        phone:       p['phone']       ?? ContactEntity.empty.phone,
        phone2:      p['phone2']      ?? '',
        email:       p['email']       ?? ContactEntity.empty.email,
        whatsapp:    p['whatsapp']    ?? ContactEntity.empty.whatsapp,
        website:     p['website']     ?? ContactEntity.empty.website,
        linkedin:    p['linkedin']    ?? ContactEntity.empty.linkedin,
        address:     p['address']     ?? ContactEntity.empty.address,
        tagline:     p['tagline']     ?? ContactEntity.empty.tagline,
        photoBase64: p['photoBase64'] ?? '',
      );

  Map<String, String> toPrefs() => {
        'name':        name,
        'title':       title,
        'org':         org,
        'phone':       phone,
        'phone2':      phone2,
        'email':       email,
        'whatsapp':    whatsapp,
        'website':     website,
        'linkedin':    linkedin,
        'address':     address,
        'tagline':     tagline,
        'photoBase64': photoBase64,
      };
}