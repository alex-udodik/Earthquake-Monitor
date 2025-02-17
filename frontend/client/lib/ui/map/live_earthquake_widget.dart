import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:client/services/socket_provider.dart';
import '../../models/earthquake.dart';
import 'package:intl/intl.dart';

class LiveEarthquakeWidget extends StatelessWidget {
  const LiveEarthquakeWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    return Positioned(
      bottom: 20,
      right: 20,
      child: Container(
        width: 250, // Adjust width as needed
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Live Earthquakes",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            SizedBox(height: 10),
            Container(
              height: 150, // Set a scrollable height
              child: ListView.builder(
                shrinkWrap: true,
                itemCount:
                    earthquakes.length.clamp(0, 5), // Limit to 5 latest quakes
                itemBuilder: (context, index) {
                  final earthquake = earthquakes[index];
                  return _earthquakeItem(earthquake);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _earthquakeItem(Earthquake earthquake) {
    DateTime parsedTime = DateTime.parse(earthquake.data.properties.time);
    String formattedTime = DateFormat('yyyy-MM-dd HH:mm:ss').format(parsedTime);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "M ${earthquake.data.properties.mag} - ${earthquake.data.properties.flynnRegion}",
            style: TextStyle(
                color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
          ),
          Text(
            formattedTime,
            style: TextStyle(color: Colors.white60, fontSize: 10),
          ),
          Divider(color: Colors.white24),
        ],
      ),
    );
  }
}
