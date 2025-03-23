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
  int _filterIndex = 0; // Index for current filter selection

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
    final isMobile = MediaQuery.of(context).size.width < 600;

    if (earthquakes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    // New quake detection logic (no change)
    if (socketProvider.newEarthquakeReceived) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        setState(() {
          _newEarthquakeIndex = 0;
        });

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
        // 🔹 Filter Header

        // 🔹 Earthquake List
        Expanded(
          child: ListView.builder(
            itemCount: earthquakes.length.clamp(0, 100),
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 6 : 10),
            itemBuilder: (context, index) {
              final quake = earthquakes[index];
              final props = quake.data.properties;

              final parsedTime =
                  DateTime.tryParse(props.time)?.toLocal() ?? DateTime.now();
              final lastUpdateTime =
                  DateTime.tryParse(props.lastUpdate)?.toLocal() ??
                      DateTime.now();

              final relativeTime = timeago.format(parsedTime);
              final lastUpdateFormatted = timeago.format(lastUpdateTime);

              return GestureDetector(
                onTap: () {
                  widget.onCardTap(LatLng(props.lat, props.lon));
                },
                child: AnimatedContainer(
                  duration: Duration(milliseconds: 400),
                  margin: EdgeInsets.symmetric(vertical: isMobile ? 4 : 6),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    color: _getColorFromGradient(props.mag).withOpacity(0.5),
                    elevation: 3,
                    child: Padding(
                      padding: EdgeInsets.all(isMobile ? 10 : 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            props.flynnRegion,
                            style: TextStyle(
                              fontSize: isMobile ? 14 : 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: isMobile ? 4 : 8),
                          Text('Magnitude: ${props.mag}',
                              style: TextStyle(fontSize: isMobile ? 12 : 14)),
                          Text('Depth: ${props.depth} km',
                              style: TextStyle(fontSize: isMobile ? 12 : 14)),
                          Text('Occurred: $relativeTime',
                              style: TextStyle(fontSize: isMobile ? 12 : 14)),
                          Text('Last Updated: $lastUpdateFormatted',
                              style: TextStyle(fontSize: isMobile ? 12 : 14)),
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

    int index =
        (normalizedMagnitude.floor()).clamp(0, gradientColors.length - 1);
    return gradientColors[index];
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('assets/sounds/earthquake_alert.wav'));
  }
}
