import 'package:flutter/material.dart';
import 'package:client/services/socket_provider.dart';
import 'package:provider/provider.dart';
import '../../models/earthquake.dart';

class LatestEarthquakeCard extends StatefulWidget {
  final String title;
  String region = "";
  LatestEarthquakeCard({required this.title});

  @override
  _LatestEarthquakeCardState createState() => _LatestEarthquakeCardState();
}

class _LatestEarthquakeCardState extends State<LatestEarthquakeCard> {
  late List<Earthquake> earthquakes;

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    earthquakes = socketProvider.earthquakes;

    // Safely update the value
    _updateValue(earthquakes);

    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            if (earthquakes.isNotEmpty)
              Text(
                widget.region,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              )
            else
              Text(
                'No earthquake data available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
          ],
        ),
      ),
    );
  }

  void _updateValue(List<Earthquake> earthquakes) {
    if (earthquakes.isNotEmpty) {
      Earthquake earthquake = earthquakes.first;
      print(earthquake.data.properties.flynnRegion);
      widget.region = earthquake.data.properties.flynnRegion;
    } else {
      print('No earthquake data available');
    }
  }
}
