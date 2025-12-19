import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../data/dummy_data.dart';
import '../models/offer.dart';
import '../services/routing_service.dart';
import '../widgets/explore_panel.dart';
import '../widgets/map_markers.dart';
import '../widgets/navigation_panel.dart';
import '../widgets/offer_details_sheet.dart';
import 'search_screen.dart';

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
  static const double _searchBarHorizontalPadding = 20;
  static const double _minSheetHeight = 0.12;
  static const double _maxSheetHeight = 0.7;

  // State
  final MapController _mapController = MapController();
  final DraggableScrollableController _sheetController =
      DraggableScrollableController();
  List<LatLng>? _routePoints;
  Offer? _selectedOffer;
  bool _isLoadingRoute = false;
  RouteInfo? _currentRouteInfo;
  double _mapRotation = 0;

  @override
  void initState() {
    super.initState();
    _mapController.mapEventStream.listen((event) {
      if (event is MapEventRotate || event is MapEventRotateEnd) {
        setState(() {
          _mapRotation = _mapController.camera.rotation;
        });
      }
    });
  }

  @override
  void dispose() {
    _sheetController.dispose();
    super.dispose();
  }

  /// Check if navigation is active
  bool get _isNavigating =>
      _routePoints != null &&
      _currentRouteInfo != null &&
      _selectedOffer != null;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          _buildMap(),
          if (_isNavigating)
            NavigationPanel(
              offer: _selectedOffer!,
              routeInfo: _currentRouteInfo!,
              onStopNavigation: _clearRoute,
            )
          else
            _buildExploreSheet(),
          if (_isLoadingRoute) _buildLoadingOverlay(),
        ],
      ),
    );
  }

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.3),
      child: const Center(
        child: CircularProgressIndicator(color: Colors.deepOrange),
      ),
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
    // Convert map rotation from degrees to radians and negate for counter-rotation
    final rotationRadians = -_mapRotation * (3.14159265359 / 180);

    // Build offer markers with rotation compensation
    final offerMarkers = MarkerBuilder.buildOfferMarkers(
      offers: DummyData.offers,
      onMarkerTap: _onOfferMarkerTapped,
      rotationCompensation: rotationRadians,
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
        onTap: (_, __) {
          if (!_isNavigating) {
            _clearRoute();
          }
        },
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

  // Explore sheet with search bar
  Widget _buildExploreSheet() {
    return DraggableScrollableSheet(
      controller: _sheetController,
      initialChildSize: _minSheetHeight,
      minChildSize: _minSheetHeight,
      maxChildSize: _maxSheetHeight,
      snap: true,
      snapSizes: const [_minSheetHeight, 0.4, _maxSheetHeight],
      builder: (context, scrollController) {
        return Stack(
          clipBehavior: Clip.none,
          children: [
            ExplorePanel(
              onOfferTap: _onOfferMarkerTapped,
              scrollController: scrollController,
            ),
            Positioned(
              top: -60,
              left: _searchBarHorizontalPadding,
              right: _searchBarHorizontalPadding,
              child: _buildSearchBar(),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSearchBar() {
    return GestureDetector(
      onTap: _openSearchScreen,
      child: Hero(
        tag: 'search_bar',
        child: Material(
          color: Colors.transparent,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              child: Row(
                children: [
                  Icon(Icons.search, color: Colors.grey[500]),
                  const SizedBox(width: 12),
                  Text(
                    _searchHint,
                    style: TextStyle(color: Colors.grey[400], fontSize: 16),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Event Handlers
  void _onMenuPressed() {
    // TODO: Handle menu action
  }

  void _openSearchScreen() async {
    final selectedOffer = await Navigator.push<Offer>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) =>
            const SearchScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          return FadeTransition(opacity: animation, child: child);
        },
        transitionDuration: const Duration(milliseconds: 300),
      ),
    );

    if (selectedOffer != null) {
      _onOfferMarkerTapped(selectedOffer);
    }
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

  void _showDirections(Offer offer) async {
    setState(() {
      _isLoadingRoute = true;
      _selectedOffer = offer;
    });

    // Fetch route from Valhalla API
    final routeInfo = await RoutingService.getRouteInfo(
      DummyData.userLocation,
      offer.location,
    );

    if (routeInfo != null) {
      setState(() {
        _routePoints = routeInfo.points;
        _currentRouteInfo = routeInfo;
        _isLoadingRoute = false;
      });

      // Fit the map to show the entire route
      _fitMapToRoute(routeInfo.points);
    } else {
      setState(() {
        _isLoadingRoute = false;
        _selectedOffer = null;
      });

      // Show error if route couldn't be fetched
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text(
              'Could not fetch directions. Please try again.',
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            margin: const EdgeInsets.only(bottom: 100, left: 20, right: 20),
          ),
        );
      }
    }
  }

  void _fitMapToRoute(List<LatLng> points) {
    if (points.isEmpty) return;

    final bounds = LatLngBounds.fromPoints(points);
    _mapController.fitCamera(
      CameraFit.bounds(bounds: bounds, padding: const EdgeInsets.all(80)),
    );
  }

  void _clearRoute() {
    setState(() {
      _routePoints = null;
      _selectedOffer = null;
      _currentRouteInfo = null;
    });
  }
}
