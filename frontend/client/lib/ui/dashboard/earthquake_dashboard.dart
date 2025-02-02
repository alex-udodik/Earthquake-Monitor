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
            return Row(
              children: [
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
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(38, 38, 38, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: EarthquakeCardList(
                      onCardTap: _moveCameraTo, // Pass function to cards
                    ),
                  ),
                ),
              ],
            );
          } else {
            return Column(
              children: [
                Expanded(
                  child: MapScreen(mapController: _mapController),
                ),
                Expanded(
                  child: EarthquakeCardList(
                    onCardTap: _moveCameraTo,
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
