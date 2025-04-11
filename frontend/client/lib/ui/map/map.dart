import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:client/services/socket_provider.dart';
import 'package:client/services/country_polygon_loader.dart';
import '../../models/earthquake.dart';
import 'pulsating_marker.dart';
import 'dart:math';
import 'package:turf/turf.dart' as turf;

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
                print(
                    '🛰️ Map tapped at: ${latlng.latitude}, ${latlng.longitude}');
                bool found = false;

                for (final polygon in _countryPolygons) {
                  if (!_isLatLngWithinBounds(latlng, polygon.points)) continue;

                  print('🧭 Tap is within bounds of: ${polygon.label}');

                  if (_pointInPolygonGeo(latlng, polygon.points)) {
                    print('✅ Inside country: ${polygon.label}');
                    if (polygon.label != _selectedCountryLabel) {
                      setState(() {
                        _selectedCountryLabel = polygon.label;
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
                icon: Icon(Icons.settings, color: Colors.white),
                onPressed: () => _showSettingsPopup(context),
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
        builder: (ctx) => PulsatingMarker(magnitude: quake.data.properties.mag),
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

    final turfPolygon = turf.Polygon(
      coordinates: [
        polygonPoints
            .map((p) => turf.Position(p.longitude, p.latitude))
            .toList()
      ],
    );

    return turf.booleanContains(turfPolygon, turfPoint);
  }

  void _showSettingsPopup(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.transparent,
      builder: (context) {
        return Stack(
          children: [
            Positioned(
              top: 80,
              right: 12,
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: MediaQuery.of(context).size.width * 0.9,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      )
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween),
                      const SizedBox(height: 12),
                      const Divider(color: Colors.grey),
                      SwitchListTile(
                        value: true,
                        onChanged: (val) {},
                        activeColor: Colors.tealAccent,
                        title: const Text("Earthquake Monitor",
                            style: TextStyle(color: Colors.white)),
                        subtitle: const Text(
                          "Tracking earthquakes in near real-time",
                          style:
                              TextStyle(color: Colors.tealAccent, fontSize: 12),
                        ),
                      ),
                      const Divider(color: Colors.grey),
                      ListTile(
                        title: const Text("Language",
                            style: TextStyle(color: Colors.white)),
                        trailing: const Text("English",
                            style: TextStyle(color: Colors.white70)),
                      ),
                      ListTile(
                        title: const Text("Change theme",
                            style: TextStyle(color: Colors.white)),
                        trailing: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.wb_sunny, color: Colors.white),
                            SizedBox(width: 8),
                            Icon(Icons.dark_mode, color: Colors.white),
                          ],
                        ),
                      ),
                      ListTile(
                        title: const Text("Color blind mode",
                            style: TextStyle(color: Colors.white)),
                        trailing: Switch(value: false, onChanged: (_) {}),
                      ),
                      const Divider(color: Colors.grey),
                      const ListTile(
                        title: Text("About Earthquake App",
                            style: TextStyle(color: Colors.white)),
                        trailing: Icon(Icons.expand_more, color: Colors.white),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
