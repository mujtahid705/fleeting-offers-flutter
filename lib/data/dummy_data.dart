import 'package:latlong2/latlong.dart';
import '../models/offer.dart';

/// Static dummy data for testing purposes.
/// This will be replaced with API data later.
class DummyData {
  DummyData._();

  /// List of dummy offers around Dhaka
  static final List<Offer> offers = [
    Offer(
      id: '1',
      brandName: 'Starbucks',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/d/d3/Starbucks_Corporation_Logo_2011.svg/1200px-Starbucks_Corporation_Logo_2011.svg.png',
      offerTitle: 'Buy 1 Get 1 Free',
      offerDescription:
          'Get a free beverage when you purchase any handcrafted drink. Valid for all sizes and flavors. Perfect for sharing with a friend!',
      discountPercentage: 50,
      location: const LatLng(23.8103, 90.4125),
      address: 'Gulshan 2, Dhaka 1212',
      validUntil: DateTime.now().add(const Duration(days: 7)),
      category: 'Food & Beverage',
    ),
    Offer(
      id: '2',
      brandName: 'Pizza Hut',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/sco/thumb/d/d2/Pizza_Hut_logo.svg/1200px-Pizza_Hut_logo.svg.png',
      offerTitle: '30% Off on Large Pizzas',
      offerDescription:
          'Enjoy 30% discount on all large pizzas. Choose from our wide variety of flavors including Pepperoni, BBQ Chicken, and more!',
      discountPercentage: 30,
      location: const LatLng(23.8145, 90.4075),
      address: 'Banani, Dhaka 1213',
      validUntil: DateTime.now().add(const Duration(days: 5)),
      category: 'Food & Beverage',
    ),
    Offer(
      id: '3',
      brandName: 'Nike',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/a/a6/Logo_NIKE.svg/1200px-Logo_NIKE.svg.png',
      offerTitle: 'Seasonal Sale - Up to 40% Off',
      offerDescription:
          'Huge discounts on selected footwear and apparel. Limited stock available. Grab your favorite Nike gear now!',
      discountPercentage: 40,
      location: const LatLng(23.8050, 90.4180),
      address: 'Jamuna Future Park, Dhaka',
      validUntil: DateTime.now().add(const Duration(days: 14)),
      category: 'Fashion',
    ),
    Offer(
      id: '4',
      brandName: 'Samsung',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/24/Samsung_Logo.svg/1200px-Samsung_Logo.svg.png',
      offerTitle: '20% Off on Galaxy Phones',
      offerDescription:
          'Special discount on Samsung Galaxy S series and A series phones. Free screen protector with every purchase!',
      discountPercentage: 20,
      location: const LatLng(23.8200, 90.4050),
      address: 'Bashundhara City, Dhaka',
      validUntil: DateTime.now().add(const Duration(days: 10)),
      category: 'Electronics',
    ),
    Offer(
      id: '5',
      brandName: 'KFC',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/en/thumb/b/bf/KFC_logo.svg/1200px-KFC_logo.svg.png',
      offerTitle: 'Family Bucket Deal',
      offerDescription:
          'Get our famous family bucket with 12 pieces of crispy chicken, 4 drinks, and 2 large fries at 25% off!',
      discountPercentage: 25,
      location: const LatLng(23.8080, 90.4200),
      address: 'Gulshan 1, Dhaka 1212',
      validUntil: DateTime.now().add(const Duration(days: 3)),
      category: 'Food & Beverage',
    ),
    Offer(
      id: '6',
      brandName: 'Adidas',
      logoUrl:
          'https://upload.wikimedia.org/wikipedia/commons/thumb/2/20/Adidas_Logo.svg/1200px-Adidas_Logo.svg.png',
      offerTitle: 'Clearance Sale - 50% Off',
      offerDescription:
          'End of season clearance! Get 50% off on selected Adidas shoes, clothing, and accessories. While stocks last!',
      discountPercentage: 50,
      location: const LatLng(23.8020, 90.4100),
      address: 'Dhanmondi 27, Dhaka',
      validUntil: DateTime.now().add(const Duration(days: 21)),
      category: 'Fashion',
    ),
  ];

  /// Fixed user location for emulator testing (Gulshan area, Dhaka)
  static const LatLng userLocation = LatLng(23.7925, 90.4078);
}
