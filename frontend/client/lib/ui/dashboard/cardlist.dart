import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/earthquake.dart'; // Make sure to import the Earthquake model
import 'package:client/services/socket_provider.dart'; // Import your SocketProvider

class EarthquakeCardList extends StatefulWidget {
  @override
  _EarthquakeCardListState createState() => _EarthquakeCardListState();
}

class _EarthquakeCardListState extends State<EarthquakeCardList> {
  late AudioPlayer _audioPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
  }

  @override
  Widget build(BuildContext context) {
    // Access the SocketProvider to get earthquake data
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    // If no earthquakes are available, show a loading indicator or message
    if (earthquakes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Trigger sound playback and reset the flag asynchronously after build
    if (socketProvider.newEarthquakeReceived) {
      // Schedule the sound to play after the build phase
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _playSound();
        socketProvider
            .resetNewEarthquakeFlag(); // Reset the flag after the sound plays
      });
    }

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
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location: ${earthquake.data.properties.flynnRegion}',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text('Magnitude: ${earthquake.data.properties.mag}'),
                Text('Depth: ${earthquake.data.properties.depth} km'),
                Text('Time: ${earthquake.data.properties.time}'),
                Text(
                    'Lat: ${earthquake.data.properties.lat}, Long: ${earthquake.data.properties.lon}'),
              ],
            ),
          ),
        );
      },
    );
  }

  void _playSound() async {
    // Play sound (make sure you have a sound file in your assets)
    await _audioPlayer.play('assets/sounds/earthquake_alert.wav');
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
