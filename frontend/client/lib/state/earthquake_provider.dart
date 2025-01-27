import 'package:flutter/material.dart';
import '../models/earthquake.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class EarthquakeProvider with ChangeNotifier {
  List<Earthquake> _earthquakes = [];
  Map<String, Marker> _markers = {};

  List<Earthquake> get earthquakes => _earthquakes;
  Map<String, Marker> get markers => _markers;

  void setEarthquakes(List<Earthquake> newEarthquakes) {
    _earthquakes = newEarthquakes;
    _updateMarkers();
    notifyListeners();
  }

  void _updateMarkers() {
    _markers.clear();
    for (final earthquake in _earthquakes) {
      _markers[earthquake.data.id] = Marker(
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
    }
  }
}
