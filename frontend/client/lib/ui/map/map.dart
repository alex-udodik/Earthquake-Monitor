import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:client/services/socket_provider.dart';
import '../../models/earthquake.dart';
import 'pulsating_marker.dart';
import 'earthquake_info_panel.dart';
import 'earthquake_legend.dart';
import 'live_earthquake_widget.dart';
import 'earthquake_filter_widget.dart'; // Import the Filter Widget
import 'earthquake_filter_fab.dart'; // Import the new FAB Widget
import 'package:flutter_map_geojson/flutter_map_geojson.dart';

class MapScreen extends StatefulWidget {
  final MapController mapController;
  final bool isLive; // Determines whether it's live or history

  const MapScreen({Key? key, required this.mapController, required this.isLive})
      : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  Earthquake? _selectedEarthquake;
  Offset? _tapPosition;

  // Filtering parameters
  double minMagnitude = 0.0;
  double maxMagnitude = 10.0;
  double minDepth = 0.0;
  double maxDepth = 700.0;
  double timeRange = 24.0;
  String selectedLocation = "Any"; // Default location filter

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = widget.isLive
        ? socketProvider.earthquakes // Live Data
        : _fetchHistoricalData(); // Historical Data

    _updateMarkers(earthquakes); // Update markers based on filters

    return Scaffold(
      body: Stack(
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
                onTap: (_, __) {
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
                MarkerLayer(
                  markers: _markers.values.toList(),
                ),
              ],
            ),
          ),

          // Live Earthquake Widget (Only in Live View)
          //if (widget.isLive) const LiveEarthquakeWidget(),

          // Magnitude Legend
          //const EarthquakeLegend(),
        ],
      ),

      /*// 🔹 Use the new EarthquakeFilterFAB instead of direct FAB
      floatingActionButton: EarthquakeFilterFAB(
        minMagnitude: minMagnitude,
        maxMagnitude: maxMagnitude,
        minDepth: minDepth,
        maxDepth: maxDepth,
        timeRange: timSeRange,
        selectedLocation: selectedLocation,
        onFilterApplied: (newMinMag, newMaxMag, newMinDepth, newMaxDepth,
            newTimeRange, newLocation) {
          setState(() {
            minMagnitude = newMinMag;
            maxMagnitude = newMaxMag;
            minDepth = newMinDepth;
            maxDepth = newMaxDepth;
            timeRange = newTimeRange;
            selectedLocation = newLocation;
          });
        },
      ),*/
    );
  }

  // Fetch historical earthquake data (replace with real API)
  List<Earthquake> _fetchHistoricalData() {
    return []; // Implement historical data fetching here
  }

  // Update Markers based on filters
  void _updateMarkers(List<Earthquake> earthquakes) {
    _markers.clear();

    final filteredEarthquakes = earthquakes.where((earthquake) {
      final mag = earthquake.data.properties.mag;
      final depth = earthquake.data.properties.depth;

      // ✅ Ensure timeData is correctly parsed as a String
      String timeData = earthquake.data.properties.time;
      DateTime earthquakeTime =
          DateTime.tryParse(timeData)?.toLocal() ?? DateTime.now();

      final timeDifference = DateTime.now().difference(earthquakeTime).inHours;

      return mag >= minMagnitude &&
          mag <= maxMagnitude &&
          depth >= minDepth &&
          depth <= maxDepth &&
          timeDifference <= timeRange;
    }).toList();

    for (final earthquake in filteredEarthquakes) {
      final marker = Marker(
        point: LatLng(
            earthquake.data.properties.lat, earthquake.data.properties.lon),
        width: 100.0,
        height: 100.0,
        builder: (ctx) => PulsatingMarker(
          magnitude: earthquake.data.properties.mag,
        ),
      );
      _markers[earthquake.data.id] = marker;
    }

    setState(() {});
  }
}
