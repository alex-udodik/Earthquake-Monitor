import 'package:flutter/material.dart';
import 'package:client/services/socket_provider.dart';
import 'package:provider/provider.dart';
import '../../models/earthquake.dart';
import 'package:audioplayers/audioplayers.dart';

class LatestEarthquakeCard extends StatefulWidget {
  final String title;

  LatestEarthquakeCard({required this.title});

  @override
  _LatestEarthquakeCardState createState() => _LatestEarthquakeCardState();
}

class _LatestEarthquakeCardState extends State<LatestEarthquakeCard> {
  late List<Earthquake> earthquakes;
  String region = "Loading..."; // Use local variable instead of widget.region
  AudioPlayer _audioPlayer = AudioPlayer(); // Declare the audio player

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    earthquakes = socketProvider.earthquakes;

    _updateValue(earthquakes);

    double screenWidth = MediaQuery.of(context).size.width;
    double textSize =
        screenWidth < 400 ? 18 : 24; // Adjust font size based on width

    return Card(
      margin: EdgeInsets.all(4),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
            ),
            Flexible(
              child: Text(
                earthquakes.isNotEmpty
                    ? region
                    : 'No earthquake data available',
                style:
                    TextStyle(fontSize: textSize, fontWeight: FontWeight.bold),
                maxLines: 1, // Prevents text from taking multiple lines
                overflow:
                    TextOverflow.ellipsis, // Adds "..." if text is too long
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateValue(List<Earthquake> earthquakes) {
    if (earthquakes.isNotEmpty) {
      Earthquake earthquake = earthquakes.first;
      setState(() {
        region = earthquake.data.properties.flynnRegion;
      });

      _playSound();
    } else {
      setState(() {
        region = "No data available";
      });
    }
  }

  void _playSound() async {
    // Use a local sound file or network URL for the sound
    // Here I'm using a local sound asset (make sure to add the sound file in your assets folder)
    await _audioPlayer.play(AssetSource('assets/sounds/earthquake_alert.wav'));
  }
}
