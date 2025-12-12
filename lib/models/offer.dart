import 'package:latlong2/latlong.dart';

/// Model class representing an offer from a brand/store.
class Offer {
  final String id;
  final String brandName;
  final String logoUrl;
  final String offerTitle;
  final String offerDescription;
  final double discountPercentage;
  final LatLng location;
  final String address;
  final DateTime validUntil;
  final String category;

  const Offer({
    required this.id,
    required this.brandName,
    required this.logoUrl,
    required this.offerTitle,
    required this.offerDescription,
    required this.discountPercentage,
    required this.location,
    required this.address,
    required this.validUntil,
    required this.category,
  });

  /// Check if the offer is still valid
  bool get isValid => DateTime.now().isBefore(validUntil);

  /// Formatted discount string
  String get discountText => '${discountPercentage.toInt()}% OFF';
}
