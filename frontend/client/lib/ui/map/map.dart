import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:client/services/socket_provider.dart';
import '../../models/earthquake.dart';
import 'pulsating_marker.dart';
import 'earthquake_filter_modal.dart'; // Import the filter modal
import 'earthquake_info_panel.dart'; // Import the info panel
import 'earthquake_legend.dart'; // Import the legend
import 'location_search.dart'; // Import the location search

class MapScreen extends StatefulWidget {
  final MapController mapController;

  const MapScreen({Key? key, required this.mapController}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};
  Earthquake? _selectedEarthquake;
  Offset? _tapPosition; // Store tap position

  double minMagnitude = 0.0;
  double maxMagnitude = 10.0;
  double minDepth = 0.0;
  double maxDepth = 700.0;
  double timeRange = 24.0;

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    _updateMarkers(earthquakes);

    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
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

          // Location Search Bar
          LocationSearch(mapController: widget.mapController),

          // Floating Filter Button
          Positioned(
            bottom: 20,
            right: 20,
            child: FloatingActionButton(
              backgroundColor: Colors.yellow,
              onPressed: () {
                _showFilterModal(context);
              },
              child: Icon(Icons.filter_list, color: Colors.black),
            ),
          ),

          // Floating Earthquake Info Panel (Appears Under Mouse)
          if (_selectedEarthquake != null && _tapPosition != null)
            Positioned(
              left: _tapPosition!.dx,
              top: _tapPosition!.dy - 50,
              child: EarthquakeInfoPanel(
                selectedEarthquake: _selectedEarthquake!,
                onClose: () {
                  setState(() {
                    _selectedEarthquake = null;
                  });
                },
              ),
            ),

          // Magnitude Legend
          EarthquakeLegend(),
        ],
      ),
    );
  }

  // Show Filter Modal
  void _showFilterModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      backgroundColor: Colors.grey[900],
      builder: (context) {
        return EarthquakeFilterModal(
          onApplyFilters: (double minMag, double maxMag, double minD,
              double maxD, double time) {
            setState(() {
              minMagnitude = minMag;
              maxMagnitude = maxMag;
              minDepth = minD;
              maxDepth = maxD;
              timeRange = time;
            });
            _updateMarkers(Provider.of<SocketProvider>(context, listen: false)
                .earthquakes);
          },
        );
      },
    );
  }

  // Update markers with onTap functionality
  void _updateMarkers(List<Earthquake> earthquakes) {
    _markers.clear();
    for (final earthquake in earthquakes) {
      double magnitude = earthquake.data.properties.mag;
      double depth = earthquake.data.properties.depth;
      if (magnitude >= minMagnitude &&
          magnitude <= maxMagnitude &&
          depth >= minDepth &&
          depth <= maxDepth) {
        final marker = Marker(
          point: LatLng(
            earthquake.data.properties.lat,
            earthquake.data.properties.lon,
          ),
          width: 100.0,
          height: 100.0,
          builder: (ctx) => GestureDetector(
            onTapDown: (TapDownDetails details) {
              setState(() {
                _tapPosition = details.globalPosition;
                _selectedEarthquake = earthquake;
              });
            },
            child: PulsatingMarker(
              magnitude: magnitude,
            ),
          ),
        );
        _markers[earthquake.data.id] = marker;
      }
    }
    setState(() {});
  }
}
