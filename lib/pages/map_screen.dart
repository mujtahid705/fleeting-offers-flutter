import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/dummy_data.dart';
import '../models/offer.dart';
import '../widgets/map_markers.dart';
import '../widgets/offer_details_sheet.dart';

/// Main map screen displaying the map with offers and search functionality.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  // Constants
  static const String _appTitle = 'Fleeting Offers';
  static const String _searchHint = 'Search for offers...';
  static const String _tileUrlTemplate =
      'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png';
  static const List<String> _tileSubdomains = ['a', 'b', 'c', 'd'];
  static const String _userAgentPackageName = 'com.example.yourapp';

  // Map configuration
  static const double _initialZoom = 14;
  static const double _maxZoom = 20;

  // UI dimensions
  static const double _searchBarRadius = 30;
  static const double _searchBarBottomOffset = 40;
  static const double _searchBarHorizontalPadding = 20;

  // State
  final MapController _mapController = MapController();
  List<LatLng>? _routePoints;
  Offer? _selectedOffer;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(children: [_buildMap(), _buildSearchBar()]),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle.dark,
      title: const Text(
        _appTitle,
        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 20),
      ),
      centerTitle: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      actions: [_buildMenuButton()],
      flexibleSpace: _buildAppBarGradient(),
    );
  }

  Widget _buildMenuButton() {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: IconButton(
          icon: const Icon(Icons.menu, color: Colors.black87),
          onPressed: _onMenuPressed,
        ),
      ),
    );
  }

  Widget _buildAppBarGradient() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white.withOpacity(0.9),
            Colors.white.withOpacity(0.0),
          ],
        ),
      ),
    );
  }

  Widget _buildMap() {
    // Build offer markers
    final offerMarkers = MarkerBuilder.buildOfferMarkers(
      offers: DummyData.offers,
      onMarkerTap: _onOfferMarkerTapped,
    );

    // Build user location marker
    final userMarker = MarkerBuilder.buildUserLocationMarker(
      DummyData.userLocation,
    );

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: DummyData.userLocation,
        initialZoom: _initialZoom,
        onTap: (_, __) => _clearRoute(),
      ),
      children: [
        TileLayer(
          urlTemplate: _tileUrlTemplate,
          subdomains: _tileSubdomains,
          userAgentPackageName: _userAgentPackageName,
          maxZoom: _maxZoom,
        ),
        // Route polyline layer
        if (_routePoints != null)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints!,
                color: Colors.deepOrange,
                strokeWidth: 4,
              ),
            ],
          ),
        // Markers layer
        MarkerLayer(markers: [userMarker, ...offerMarkers]),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Positioned(
      left: _searchBarHorizontalPadding,
      right: _searchBarHorizontalPadding,
      bottom: _searchBarBottomOffset,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_searchBarRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: _searchHint,
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 16),
            prefixIcon: Icon(Icons.search, color: Colors.grey[500]),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 15,
            ),
          ),
          onSubmitted: _onSearchSubmitted,
        ),
      ),
    );
  }

  // Event handlers
  void _onMenuPressed() {
    // TODO: Handle menu action
  }

  void _onSearchSubmitted(String query) {
    // TODO: Handle search submission
  }

  void _onOfferMarkerTapped(Offer offer) {
    setState(() {
      _selectedOffer = offer;
    });

    OfferDetailsSheet.show(
      context,
      offer: offer,
      onGetDirections: () {
        Navigator.pop(context);
        _showDirections(offer);
      },
    );
  }

  void _showDirections(Offer offer) {
    // Calculate a simple straight-line route for now
    // In production, you would use a routing API like OSRM or Google Directions
    final points = _calculateSimpleRoute(
      DummyData.userLocation,
      offer.location,
    );

    setState(() {
      _routePoints = points;
    });

    // Fit the map to show the entire route
    _fitMapToRoute(points);
  }

  List<LatLng> _calculateSimpleRoute(LatLng start, LatLng end) {
    // Simple interpolation for a curved path effect
    // In a real app, this would be replaced with actual routing data
    final points = <LatLng>[];
    const steps = 20;

    for (int i = 0; i <= steps; i++) {
      final t = i / steps;
      // Add slight curve for visual effect
      final curve = (1 - (2 * t - 1).abs()) * 0.002;
      final lat = start.latitude + (end.latitude - start.latitude) * t;
      final lng =
          start.longitude + (end.longitude - start.longitude) * t + curve;
      points.add(LatLng(lat, lng));
    }

    return points;
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  void _clearRoute() {
    if (_routePoints != null) {
      setState(() {
        _routePoints = null;
        _selectedOffer = null;
      });
    }
  }
}
