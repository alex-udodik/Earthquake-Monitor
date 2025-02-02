import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'stat_card.dart';
import 'chart_card.dart';
import '../map/map.dart';
import 'latest_earthquake_card.dart';
import 'latest_magnitude_card.dart';

class EarthquakeDashboard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earthquake Dashboard'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600; // Adaptive layout
          return Column(
            children: [
              // Top Map Section
              Expanded(
                flex: 2,
                child: Stack(
                  children: [
                    // Map Container with rounded corners
                    Container(
                      margin: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blueGrey[900],
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Center(child: MapScreen()),
                      ),
                    ),
                    // Live Updates Overlay
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
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          isWideScreen ? 4 : 2, // Adjust for mobile/web
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 2, // Adjust for better scaling
                    ),
                    itemCount: 5,
                    itemBuilder: (context, index) {
                      // Dynamically assign widgets
                      switch (index) {
                        case 0:
                          return LatestEarthquakeCard(
                              title: "Latest Earthquake");
                        case 1:
                          return StatCard(
                              title: 'Average Depth', value: '32 km');
                        case 2:
                          return LatestMagnitudeCard(title: "Latest Magnitude");
                        case 3:
                          return ChartCard(title: 'Recent Earthquakes');
                        case 4:
                          return ChartCard(title: 'Depth Distribution');
                        default:
                          return Container();
                      }
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
