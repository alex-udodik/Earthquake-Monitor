import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // Import Flutter Map
import 'package:provider/provider.dart';
import 'package:latlong2/latlong.dart'; // For LatLng class
import 'package:client/services/socket_provider.dart';
import '../models/earthquake.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

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
        width: 80.0,
        height: 80.0,
        builder: (ctx) => Icon(
          Icons.location_on,
          color: Colors.red,
          size: 40,
        ),
      );

      _markers[earthquake.data.id] = marker;
    }
    setState(() {});
  }
}
