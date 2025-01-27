import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:client/features/earthquake/data/models/earthquake.dart';

class EarthquakesMap extends StatelessWidget {
  final Map<String, Marker> markers;

  const EarthquakesMap({Key? key, required this.markers}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      initialCameraPosition: const CameraPosition(
        target: LatLng(0, 0),
        zoom: 2,
      ),
      markers: markers.values.toSet(),
    );
  }
}
