import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/earthquake.dart';
import 'package:client/services/socket_provider.dart';
import 'package:latlong2/latlong.dart';
import 'package:timeago/timeago.dart' as timeago;

class EarthquakeCardList extends StatefulWidget {
  final void Function(LatLng) onCardTap; // Callback function

  const EarthquakeCardList({Key? key, required this.onCardTap})
      : super(key: key);

  @override
  _EarthquakeCardListState createState() => _EarthquakeCardListState();
}

class _EarthquakeCardListState extends State<EarthquakeCardList> {
  late AudioPlayer _audioPlayer;
  int? _newEarthquakeIndex; // Track the latest earthquake index
  Timer? _timer; // Timer for periodic updates

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();

    // ✅ Auto-refresh the widget every 10 seconds (sync with LiveEarthquakeWidget)
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      setState(
          () {}); // Forces the widget to rebuild and update time dynamically
    });
  }

  @override
  void dispose() {
    _timer?.cancel(); // Stop the timer when the widget is destroyed
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    if (earthquakes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // Play sound and highlight the latest earthquake when a new one arrives
    if (socketProvider.newEarthquakeReceived) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _newEarthquakeIndex = 0; // Highlight the top card
        });

        _playSound();

        // Remove the highlight after 1 second
        Future.delayed(Duration(seconds: 1), () {
          setState(() {
            _newEarthquakeIndex = null;
          });
        });

        socketProvider.resetNewEarthquakeFlag();
      });
    }

    return Column(
      children: [
        // Sticky Header
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.cyan.shade700,
            borderRadius: BorderRadius.circular(12),
          ),
          margin: EdgeInsets.all(8),
          child: Text(
            "Last 100 Earthquakes",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),
        ),

        // List of Earthquakes
        Expanded(
          child: ListView.builder(
            itemCount: earthquakes.length.clamp(0, 100),
            itemBuilder: (context, index) {
              final earthquake = earthquakes[index];

              // Convert time to local timezone
              DateTime parsedTime =
                  DateTime.parse(earthquake.data.properties.time).toLocal();
              DateTime lastUpdateTime =
                  DateTime.parse(earthquake.data.properties.lastUpdate)
                      .toLocal();

              // ✅ Use timeago to format relative time (syncs with LiveEarthquakeWidget)
              String relativeTime = timeago.format(parsedTime, locale: 'en');
              String lastUpdateFormatted =
                  timeago.format(lastUpdateTime, locale: 'en');

              return GestureDetector(
                onTap: () {
                  widget.onCardTap(LatLng(
                    earthquake.data.properties.lat,
                    earthquake.data.properties.lon,
                  ));
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 500), // Smooth fade effect
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: _newEarthquakeIndex == index
                        ? [
                            BoxShadow(
                              color: Colors.yellow.withOpacity(0.8),
                              blurRadius: 15,
                              spreadRadius: 4,
                            )
                          ]
                        : [],
                  ),
                  child: Card(
                    margin: EdgeInsets.all(4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: _getColorFromGradient(earthquake.data.properties.mag)
                        .withOpacity(0.5),
                    elevation: 4,
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Location: ${earthquake.data.properties.flynnRegion}',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 8),
                          Text('Magnitude: ${earthquake.data.properties.mag}'),
                          Text('Depth: ${earthquake.data.properties.depth} km'),
                          Text(
                              'Occurred: $relativeTime'), // ✅ Auto-updating "X mins ago"
                          Text(
                              'Last Updated: $lastUpdateFormatted'), // ✅ Auto-updating "X mins ago"
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Color _getColorFromGradient(double magnitude) {
    double normalizedMagnitude = magnitude.clamp(0.0, 10.0);

    final List<Color> gradientColors = [
      Colors.green, // 0.0 - 2.9
      Colors.lightGreen, // 3.0 - 3.9
      Colors.yellow, // 4.0 - 4.9
      Colors.amber, // 5.0 - 5.9
      Colors.orange, // 6.0 - 6.9
      Colors.deepOrange, // 7.0 - 7.9
      Colors.red, // 8.0 - 8.9
      Colors.red.shade700, // 9.0 - 9.9
      Colors.brown, // 10.0
    ];

    // Determine index based on whole number magnitude tiers
    int index =
        (normalizedMagnitude.floor()).clamp(0, gradientColors.length - 1);

    return gradientColors[index];
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('assets/sounds/earthquake_alert.wav'));
  }
}
