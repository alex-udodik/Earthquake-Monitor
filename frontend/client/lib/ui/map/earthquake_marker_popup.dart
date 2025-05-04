import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class EarthquakePopUpPanel extends StatelessWidget {
  final Marker marker;
  final String title;
  final double magnitude;
  final double depth;

  const EarthquakePopUpPanel({
    Key? key,
    required this.marker,
    required this.title,
    required this.magnitude,
    required this.depth,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      color: Colors.black87,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 6),
            Text('Magnitude: $magnitude',
                style: const TextStyle(color: Colors.white70)),
            Text('Depth: $depth km',
                style: const TextStyle(color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}
