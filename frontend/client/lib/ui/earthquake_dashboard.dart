import 'package:client/ui/latest_magnitude_card.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'stat_card.dart';
import 'chart_card.dart';
import 'map.dart';
import 'latest_earthquake_card.dart';
import 'latest_magnitude_card.dart';

class EarthquakeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earthquake Dashboard'),
      ),
      body: Column(
        children: [
          // Top Map Section
          Expanded(
            flex: 2,
            child: Stack(
              children: [
                // Map Container with rounded corners
                Container(
                  margin: EdgeInsets.all(
                      16), // Optional, for spacing around the container
                  decoration: BoxDecoration(
                    color: Colors.blueGrey[900], // Placeholder for the map
                    borderRadius: BorderRadius.circular(16), // Rounded corners
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(
                        16), // Clip the child to the rounded corners
                    child: Center(
                        child: MapScreen()), // MapScreen with rounded corners
                  ),
                ),
                // Overlays
                Positioned(
                  bottom: 10,
                  right: 10,
                  child: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      'Live Updates',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Bottom Panels (Stats and Graphs)
          Expanded(
            flex: 1,
            child: GridView.count(
              crossAxisCount: 8,
              padding: EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                LatestEarthquakeCard(title: "Latest Earthquake"),
                StatCard(title: 'Average Depth', value: '32 km'),
                LatestMagnitudeCard(title: "Latest Magnitude"),
                ChartCard(title: 'Recent Earthquakes'),
                ChartCard(title: 'Depth Distribution'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
