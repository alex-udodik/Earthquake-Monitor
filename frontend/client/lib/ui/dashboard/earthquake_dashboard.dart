import 'package:client/ui/dashboard/cardlist.dart';
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
          // Check if the screen width is larger than 600 (tablet size or larger)
          bool isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            // Desktop or tablet layout (Row)
            return Row(
              children: [
                // Map Section takes up 4/5 of the screen horizontally
                Expanded(
                  flex: 4,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Center(child: MapScreen()), // Your Map widget
                    ),
                  ),
                ),
                // Widgets Section takes up 1/5 of the screen horizontally
                Expanded(
                  flex: 1,
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(38, 38, 38, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: EarthquakeCardList(), // Your list of cards
                  ),
                ),
              ],
            );
          } else {
            // Mobile/web layout (Column)
            return Column(
              children: [
                // Map Section takes up the full width
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.blueGrey[900],
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Center(child: MapScreen()), // Your Map widget
                    ),
                  ),
                ),
                // Widgets Section takes up the full width
                Expanded(
                  child: Container(
                    margin: EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(38, 38, 38, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: EarthquakeCardList(), // Your list of cards
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
