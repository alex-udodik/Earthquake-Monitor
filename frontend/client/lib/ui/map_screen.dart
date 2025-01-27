import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
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
      body: GoogleMap(
        initialCameraPosition: const CameraPosition(
          target: LatLng(0, 0),
          zoom: 2,
        ),
        markers: _markers.values.toSet(),
      ),
    );
  }

  void _updateMarkers(List<Earthquake> earthquakes) {
    _markers.clear();
    for (final earthquake in earthquakes) {
      final marker = Marker(
        markerId: MarkerId(earthquake.data.id),
        position: LatLng(
          earthquake.data.properties.lat,
          earthquake.data.properties.lon,
        ),
        infoWindow: InfoWindow(
          title: earthquake.data.properties.flynnRegion,
          snippet: earthquake.data.properties.mag.toString(),
        ),
      );
      _markers[earthquake.data.id] = marker;
    }
    setState(() {});
  }
}
