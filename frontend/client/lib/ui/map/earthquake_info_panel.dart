import 'package:flutter/material.dart';
import '../../models/earthquake.dart';

class EarthquakeInfoPanel extends StatelessWidget {
  final Earthquake selectedEarthquake;
  final VoidCallback onClose;

  const EarthquakeInfoPanel(
      {Key? key, required this.selectedEarthquake, required this.onClose})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[900], // Dark theme
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, blurRadius: 6, offset: Offset(2, 2)),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Close Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "Earthquake Details",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: Colors.white),
                    onPressed: onClose,
                  ),
                ],
              ),

              // Earthquake Info
              Text(
                "Magnitude: ${selectedEarthquake.data.properties.mag}",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Location: ${selectedEarthquake.data.properties.flynnRegion}",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Depth: ${selectedEarthquake.data.properties.depth} km",
                style: TextStyle(color: Colors.white),
              ),
              Text(
                "Time: ${selectedEarthquake.data.properties.time}",
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
