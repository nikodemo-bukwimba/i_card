import '../../../contact/domain/entities/contact_entity.dart';
import '../../../portfolio/domain/entities/portfolio_item.dart';

/// A contact saved from scanning someone else's QR card.
class SavedContact {
  final String id;              // uuid assigned at scan time
  final ContactEntity contact;
  final List<PortfolioItem> portfolioItems;
  final DateTime scannedAt;

  const SavedContact({
    required this.id,
    required this.contact,
    required this.portfolioItems,
    required this.scannedAt,
  });
}