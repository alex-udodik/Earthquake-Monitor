import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:client/services/socket_provider.dart';
import 'package:client/services/country_polygon_loader.dart';
import '../../models/earthquake.dart';
import 'pulsating_marker.dart';
import 'dart:math';
import 'package:turf/turf.dart' as turf;
import 'settings_popup.dart';
import 'country_popup.dart';
import '../screens/country_detail_screen.dart';
import 'earthquake_popup.dart';

class MapScreen extends StatefulWidget {
  final MapController mapController;
  final bool isLive;

  const MapScreen({Key? key, required this.mapController, required this.isLive})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  List<Polygon> _countryPolygons = [];
  Earthquake? _selectedEarthquake;
  Offset? _tapPosition;

  LatLng? _userLocation; // 🧭 User location

  String? _selectedCountryLabel;

  double minMagnitude = 0.0;
  double maxMagnitude = 10.0;
  double minDepth = 0.0;
  double maxDepth = 700.0;
  double timeRange = 24.0;
  String selectedLocation = "Any";

  @override
  void initState() {
    super.initState();
    _loadPolygons();
    _loadUserLocation(); // 🧭 load location
  }

  Future<void> _loadUserLocation() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) return;

    final position = await Geolocator.getCurrentPosition();
    setState(() {
      _userLocation = LatLng(position.latitude, position.longitude);
    });
  }

  Future<void> _loadPolygons() async {
    final rawPolygons = await CountryPolygonLoader.loadPolygons();
    final highlightedLabel = _selectedCountryLabel;

    setState(() {
      _countryPolygons = rawPolygons.map((polygon) {
        final isSelected = polygon.label == highlightedLabel;

        return Polygon(
          points: polygon.points,
          label: polygon.label,
          color:
              isSelected ? Colors.tealAccent.withOpacity(0.2) : polygon.color,
          borderColor: isSelected ? Colors.tealAccent : polygon.borderColor,
          borderStrokeWidth: isSelected ? 2.0 : polygon.borderStrokeWidth,
        );
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes =
        widget.isLive ? socketProvider.earthquakes : _fetchHistoricalData();

    _updateMarkers(earthquakes);

    return Stack(
      children: [
        GestureDetector(
          onTapDown: (TapDownDetails details) {
            setState(() {
              _tapPosition = details.globalPosition;
            });
          },
          onTap: () {
            setState(() {
              _selectedEarthquake = null;
            });
          },
          child: FlutterMap(
            mapController: widget.mapController,
            options: MapOptions(
              center: LatLng(0, 0),
              zoom: 3.0,
              minZoom: 2.0,
              maxBounds: LatLngBounds(LatLng(-85, -200), LatLng(85, 200)),
              onTap: (tapPosition, latlng) {
                bool found = false;

                for (final polygon in _countryPolygons) {
                  if (!_isLatLngWithinBounds(latlng, polygon.points)) continue;

                  if (_pointInPolygonGeo(latlng, polygon.points)) {
                    if (polygon.label != _selectedCountryLabel) {
                      setState(() {
                        _selectedCountryLabel = polygon.label;
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => CountryDetailScreen(
                                countryName: '${polygon.label}'),
                          ),
                        );
                      });
                      _loadPolygons();
                    }
                    found = true;
                    break;
                  }
                }

                if (!found) {
                  print('❌ No polygon matched this tap.');
                }

                setState(() {
                  _selectedEarthquake = null;
                });
              },
            ),
            children: [
              TileLayer(
                urlTemplate:
                    "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png",
                subdomains: ['a', 'b', 'c'],
              ),
              PolygonLayer(polygons: _countryPolygons),
              MarkerLayer(markers: _markers.values.toList()),
            ],
          ),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: SafeArea(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[850],
                shape: BoxShape.rectangle,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(Icons.settings, color: Colors.white),
                onPressed: () => showSettingsPopup(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<Earthquake> _fetchHistoricalData() => [];

  void _updateMarkers(List<Earthquake> earthquakes) {
    _markers.clear();

    final filtered = earthquakes.where((quake) {
      final mag = quake.data.properties.mag;
      final depth = quake.data.properties.depth;
      final region = quake.data.properties.region.trim().toLowerCase();
      final selectedRegion = selectedLocation.trim().toLowerCase();
      final timeData = quake.data.properties.time;
      final quakeTime =
          DateTime.tryParse(timeData)?.toLocal() ?? DateTime.now();
      final timeDifference = DateTime.now().difference(quakeTime).inHours;

      return mag >= minMagnitude &&
          mag <= maxMagnitude &&
          depth >= minDepth &&
          depth <= maxDepth &&
          timeDifference <= timeRange &&
          (selectedRegion == "any" ||
              selectedRegion.isEmpty ||
              region.contains(selectedRegion));
    }).toList();

    for (final quake in filtered) {
      final marker = Marker(
        point: LatLng(quake.data.properties.lat, quake.data.properties.lon),
        width: 100.0,
        height: 100.0,
        builder: (ctx) => GestureDetector(
          onTap: () {
            if (_userLocation != null) {
              showDialog(
                context: context,
                builder: (_) => EarthquakeDetailPopup(
                  earthquake: quake,
                  userLocation: _userLocation!,
                ),
              );
            } else {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("User location not available")),
              );
            }
          },
          child: PulsatingMarker(
            magnitude: quake.data.properties.mag,
            animate: true,
          ),
        ),
      );
      _markers[quake.data.id] = marker;
    }

    setState(() {});
  }

  bool _isLatLngWithinBounds(LatLng point, List<LatLng> polygon) {
    final lats = polygon.map((p) => p.latitude);
    final lngs = polygon.map((p) => p.longitude);
    final minLat = lats.reduce(min);
    final maxLat = lats.reduce(max);
    final minLng = lngs.reduce(min);
    final maxLng = lngs.reduce(max);

    return point.latitude >= minLat &&
        point.latitude <= maxLat &&
        point.longitude >= minLng &&
        point.longitude <= maxLng;
  }

  bool _pointInPolygonGeo(LatLng point, List<LatLng> polygonPoints) {
    final turfPoint =
        turf.Point(coordinates: turf.Position(point.longitude, point.latitude));
    final turfPolygon = turf.Polygon(coordinates: [
      polygonPoints.map((p) => turf.Position(p.longitude, p.latitude)).toList()
    ]);
    return turf.booleanContains(turfPolygon, turfPoint);
  }
}
