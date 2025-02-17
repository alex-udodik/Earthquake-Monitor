import 'package:client/ui/dashboard/chart_card.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../map/map.dart';
import 'cardlist.dart';

class EarthquakeDashboard extends StatefulWidget {
  @override
  _EarthquakeDashboardState createState() => _EarthquakeDashboardState();
}

class _EarthquakeDashboardState extends State<EarthquakeDashboard> {
  final MapController _mapController = MapController();

  void _moveCameraTo(LatLng position) {
    _mapController.move(position, 8.0); // Adjust zoom as needed
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Earthquake Dashboard'),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          bool isWideScreen = constraints.maxWidth > 600;

          if (isWideScreen) {
            // For wider screens (desktop/tablet), using Row layout
            return SingleChildScrollView(
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        flex: 4,
                        child: Container(
                          margin: EdgeInsets.all(4),
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.blueGrey[900],
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(16),
                            child: Center(
                              child: MapScreen(
                                mapController: _mapController,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        flex: 1,
                        child: Container(
                          margin: EdgeInsets.all(4),
                          height: MediaQuery.of(context).size.height * 0.8,
                          decoration: BoxDecoration(
                            color: const Color.fromARGB(38, 38, 38, 1),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: EarthquakeCardList(
                            onCardTap: _moveCameraTo,
                          ),
                        ),
                      ),
                    ],
                  ),
                  _buildAdditionalWidgets(), // Add extra widgets below
                ],
              ),
            );
          } else {
            // For smaller screens (mobile), using Column layout with scroll
            return SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: MapScreen(mapController: _mapController),
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.4,
                    child: EarthquakeCardList(
                      onCardTap: _moveCameraTo,
                    ),
                  ),
                  _buildAdditionalWidgets(), // Add extra widgets below
                ],
              ),
            );
          }
        },
      ),
    );
  }

  // Method to add additional widgets under the map and card list
  Widget _buildAdditionalWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // Align items to the left
      children: [
        SizedBox(height: 20),
        // Constrain the ChartCard's height to prevent infinite height error
        SizedBox(
          height: 300, // Adjust height as needed
          child: ChartCard(title: "dist"),
        ),
        SizedBox(height: 20),
        Text(
          'Additional Data or Widgets',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'This section can display graphs, stats, or other widgets.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
