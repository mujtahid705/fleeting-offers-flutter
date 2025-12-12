import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart' show LatLng;
import '../models/offer.dart';

/// Custom marker widget for displaying offers on the map.
class OfferMarker extends StatelessWidget {
  final Offer offer;
  final VoidCallback onTap;

  const OfferMarker({super.key, required this.offer, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.deepOrange, width: 3),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: ClipOval(
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Image.network(
                  offer.logoUrl,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        offer.brandName[0],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.deepOrange,
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
          // Pointer triangle
          CustomPaint(size: const Size(16, 10), painter: _TrianglePainter()),
        ],
      ),
    );
  }
}

/// Custom painter for the marker pointer triangle.
class _TrianglePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.deepOrange
      ..style = PaintingStyle.fill;

    final path = ui.Path()
      ..moveTo(0, 0)
      ..lineTo(size.width / 2, size.height)
      ..lineTo(size.width, 0)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// User location marker widget.
class UserLocationMarker extends StatelessWidget {
  const UserLocationMarker({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: Colors.blue,
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 3),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.3),
            blurRadius: 10,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }
}

/// Helper class to build markers for the map.
class MarkerBuilder {
  MarkerBuilder._();

  /// Creates a list of markers for the given offers.
  static List<Marker> buildOfferMarkers({
    required List<Offer> offers,
    required Function(Offer) onMarkerTap,
  }) {
    return offers.map((offer) {
      return Marker(
        point: offer.location,
        width: 50,
        height: 65,
        child: OfferMarker(offer: offer, onTap: () => onMarkerTap(offer)),
      );
    }).toList();
  }

  /// Creates a marker for the user's location.
  static Marker buildUserLocationMarker(LatLng location) {
    return Marker(
      point: location,
      width: 24,
      height: 24,
      child: const UserLocationMarker(),
    );
  }
}
