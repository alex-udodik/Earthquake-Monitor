import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'stat_card.dart';
import 'chart_card.dart';
import 'map.dart'; // Import the StatCard widget

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
                Container(
                  color: Colors.blueGrey[900], // Placeholder for the map
                  child: Center(child: MapScreen()),
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
            flex: 3,
            child: GridView.count(
              crossAxisCount: 2,
              padding: EdgeInsets.all(8),
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
              children: [
                StatCard(title: 'Average Magnitude', value: '2.9'),
                StatCard(title: 'Average Depth', value: '32 km'),
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
