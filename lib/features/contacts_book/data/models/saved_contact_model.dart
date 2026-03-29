import 'dart:convert';
import '../../../contact/domain/entities/contact_entity.dart';
import '../../../contact/data/models/contact_model.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';
import '../../domain/entities/saved_contact.dart';

class SavedContactModel extends SavedContact {
  const SavedContactModel({
    required super.id,
    required super.contact,
    required super.portfolioItems,
    required super.scannedAt,
  });

  factory SavedContactModel.fromJson(Map<String, dynamic> j) {
    final cp = j['contact'] as Map<String, dynamic>;
    final contact = ContactModel.fromPrefs(
        cp.map((k, v) => MapEntry(k, v as String?)));

    final items = (j['portfolio'] as List? ?? [])
        .map((e) => PortfolioItem(
              id:    e['id']   as String,
              type:  PortfolioItemType.values.byName(e['type'] as String),
              title: e['title'] as String,
              url:   e['url']   as String,
              description: e['desc'] as String? ?? '',
            ))
        .toList();

    return SavedContactModel(
      id:             j['id']          as String,
      contact:        contact,
      portfolioItems: items,
      scannedAt:      DateTime.parse(j['scannedAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id':        id,
        'scannedAt': scannedAt.toIso8601String(),
        'contact': {
          'name':        contact.name,
          'title':       contact.title,
          'org':         contact.org,
          'phone':       contact.phone,
          'phone2':      contact.phone2,
          'email':       contact.email,
          'whatsapp':    contact.whatsapp,
          'website':     contact.website,
          'linkedin':    contact.linkedin,
          'address':     contact.address,
          'tagline':     contact.tagline,
          'photoBase64': contact.photoBase64,
        },
        'portfolio': portfolioItems
            .map((e) => {
                  'id':    e.id,
                  'type':  e.type.name,
                  'title': e.title,
                  'url':   e.url,
                  'desc':  e.description,
                })
            .toList(),
      };

  static String encodeList(List<SavedContact> items) => jsonEncode(
        items.map((e) => SavedContactModel.fromDomain(e).toJson()).toList(),
      );

  static List<SavedContactModel> decodeList(String raw) =>
      (jsonDecode(raw) as List)
          .map((j) => SavedContactModel.fromJson(j as Map<String, dynamic>))
          .toList();

  factory SavedContactModel.fromDomain(SavedContact s) => SavedContactModel(
        id:             s.id,
        contact:        s.contact,
        portfolioItems: s.portfolioItems,
        scannedAt:      s.scannedAt,
      );
}