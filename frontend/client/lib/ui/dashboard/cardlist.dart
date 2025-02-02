import 'package:flutter/material.dart';

class EarthquakeCardList extends StatelessWidget {
  final List<Earthquake> earthquakes = [
    Earthquake(
      location: 'California',
      magnitude: 5.6,
      depth: 10.2,
      time: DateTime.now().subtract(Duration(minutes: 10)),
      lat: 36.7783,
      long: -119.4179,
    ),
    Earthquake(
      location: 'Japan',
      magnitude: 7.2,
      depth: 15.4,
      time: DateTime.now().subtract(Duration(hours: 1)),
      lat: 35.6762,
      long: 139.6503,
    ),
    Earthquake(
      location: 'Chile',
      magnitude: 6.1,
      depth: 20.8,
      time: DateTime.now().subtract(Duration(days: 1)),
      lat: -33.4489,
      long: -70.6693,
    ),
    Earthquake(
      location: 'California',
      magnitude: 5.6,
      depth: 10.2,
      time: DateTime.now().subtract(Duration(minutes: 10)),
      lat: 36.7783,
      long: -119.4179,
    ),
    Earthquake(
      location: 'Japan',
      magnitude: 7.2,
      depth: 15.4,
      time: DateTime.now().subtract(Duration(hours: 1)),
      lat: 35.6762,
      long: 139.6503,
    ),
    Earthquake(
      location: 'Chile',
      magnitude: 6.1,
      depth: 20.8,
      time: DateTime.now().subtract(Duration(days: 1)),
      lat: -33.4489,
      long: -70.6693,
    ),
    Earthquake(
      location: 'California',
      magnitude: 5.6,
      depth: 10.2,
      time: DateTime.now().subtract(Duration(minutes: 10)),
      lat: 36.7783,
      long: -119.4179,
    ),
    Earthquake(
      location: 'Japan',
      magnitude: 7.2,
      depth: 15.4,
      time: DateTime.now().subtract(Duration(hours: 1)),
      lat: 35.6762,
      long: 139.6503,
    ),
    Earthquake(
      location: 'Chile',
      magnitude: 6.1,
      depth: 20.8,
      time: DateTime.now().subtract(Duration(days: 1)),
      lat: -33.4489,
      long: -70.6693,
    ),
    Earthquake(
      location: 'California',
      magnitude: 5.6,
      depth: 10.2,
      time: DateTime.now().subtract(Duration(minutes: 10)),
      lat: 36.7783,
      long: -119.4179,
    ),
    Earthquake(
      location: 'Japan',
      magnitude: 7.2,
      depth: 15.4,
      time: DateTime.now().subtract(Duration(hours: 1)),
      lat: 35.6762,
      long: 139.6503,
    ),
    Earthquake(
      location: 'Chile',
      magnitude: 6.1,
      depth: 20.8,
      time: DateTime.now().subtract(Duration(days: 1)),
      lat: -33.4489,
      long: -70.6693,
    ),
    // Add more earthquake data here
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: earthquakes.length,
      itemBuilder: (context, index) {
        final earthquake = earthquakes[index];
        return Card(
          margin: EdgeInsets.all(4),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 4,
          //color
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${earthquake.location}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Magnitude: ${earthquake.magnitude}'),
                Text('Depth: ${earthquake.depth} km'),
                Text('Time: ${earthquake.time}'),
                Text('Lat: ${earthquake.lat}, Long: ${earthquake.long}'),
              ],
            ),
          ),
        );
      },
    );
  }
}

class Earthquake {
  final String location;
  final double magnitude;
  final double depth;
  final DateTime time;
  final double lat;
  final double long;

  Earthquake({
    required this.location,
    required this.magnitude,
    required this.depth,
    required this.time,
    required this.lat,
    required this.long,
  });
}
