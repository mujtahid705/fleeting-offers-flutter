import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';

/// Service for fetching route directions using Valhalla routing engine.
class RoutingService {
  RoutingService._();

  /// Valhalla API base URL (free, no API key required)
  static const String _valhallaBaseUrl = 'https://valhalla1.openstreetmap.de';

  /// Gets route information including distance and duration.
  static Future<RouteInfo?> getRouteInfo(LatLng start, LatLng end) async {
    try {
      // Build Valhalla request JSON
      final requestJson = json.encode({
        'locations': [
          {'lat': start.latitude, 'lon': start.longitude},
          {'lat': end.latitude, 'lon': end.longitude},
        ],
        'costing': 'auto',
        'directions_options': {'units': 'kilometers'},
      });

      final url = Uri.parse('$_valhallaBaseUrl/route?json=$requestJson');

      debugPrint('Fetching route from Valhalla');

      final response = await http
          .get(url)
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw TimeoutException('Request timed out');
            },
          );

      debugPrint('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data['trip'] != null) {
          final trip = data['trip'];
          final legs = trip['legs'] as List?;

          if (legs != null && legs.isNotEmpty) {
            // Decode the polyline shape
            final shape = trip['legs'][0]['shape'] as String?;
            List<LatLng> points = [];

            if (shape != null) {
              points = _decodePolyline(shape);
            }

            // Get summary info
            final summary = trip['summary'];
            final distanceKm = (summary?['length'] as num?)?.toDouble() ?? 0;
            final durationSeconds = (summary?['time'] as num?)?.toDouble() ?? 0;

            return RouteInfo(
              points: points,
              distanceMeters: distanceKm * 1000, // Convert km to meters
              durationSeconds: durationSeconds,
            );
          }
        }

        debugPrint('Unexpected response format');
      } else {
        debugPrint('HTTP error: ${response.statusCode}');
        debugPrint('Response: ${response.body}');
      }

      return null;
    } catch (e, stackTrace) {
      debugPrint('Error fetching route info: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }

  /// Decodes a polyline encoded string into a list of LatLng points.
  /// Valhalla uses precision of 6 decimal places.
  static List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0;
    int lat = 0;
    int lng = 0;

    while (index < encoded.length) {
      // Decode latitude
      int shift = 0;
      int result = 0;
      int byte;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLat = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lat += deltaLat;

      // Decode longitude
      shift = 0;
      result = 0;

      do {
        byte = encoded.codeUnitAt(index++) - 63;
        result |= (byte & 0x1F) << shift;
        shift += 5;
      } while (byte >= 0x20);

      int deltaLng = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
      lng += deltaLng;

      // Valhalla uses 6 decimal precision
      points.add(LatLng(lat / 1e6, lng / 1e6));
    }

    return points;
  }
}

/// Route information including points, distance, and duration.
class RouteInfo {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteInfo({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });

  /// Distance in kilometers
  double get distanceKm => distanceMeters / 1000;

  /// Duration in minutes
  double get durationMinutes => durationSeconds / 60;

  /// Formatted distance string
  String get formattedDistance {
    if (distanceKm < 1) {
      return '${distanceMeters.round()} m';
    }
    return '${distanceKm.toStringAsFixed(1)} km';
  }

  /// Formatted duration string
  String get formattedDuration {
    final minutes = durationMinutes.round();
    if (minutes < 60) {
      return '$minutes min';
    }
    final hours = minutes ~/ 60;
    final remainingMinutes = minutes % 60;
    return '$hours hr $remainingMinutes min';
  }
}
