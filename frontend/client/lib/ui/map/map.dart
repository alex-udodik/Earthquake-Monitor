import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:client/services/socket_provider.dart';
import '../../models/earthquake.dart';
import 'pulsating_marker.dart';

class MapScreen extends StatefulWidget {
  final MapController mapController; // Accept a MapController

  const MapScreen({Key? key, required this.mapController}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final Map<String, Marker> _markers = {};

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    _updateMarkers(earthquakes);

    return Scaffold(
      body: FlutterMap(
        mapController: widget.mapController, // Use the passed MapController
        options: MapOptions(
          center: LatLng(0, 0),
          zoom: 3.0,
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
    );
  }

  void _updateMarkers(List<Earthquake> earthquakes) {
    _markers.clear();
    for (final earthquake in earthquakes) {
      final marker = Marker(
        point: LatLng(
          earthquake.data.properties.lat,
          earthquake.data.properties.lon,
        ),
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

  // Method to move the map came
}
