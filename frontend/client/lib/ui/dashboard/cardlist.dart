import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../../models/earthquake.dart';
import 'package:client/services/socket_provider.dart';
import 'package:latlong2/latlong.dart';

class EarthquakeCardList extends StatefulWidget {
  final void Function(LatLng) onCardTap; // Callback function

  const EarthquakeCardList({Key? key, required this.onCardTap})
      : super(key: key);

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
    final socketProvider = Provider.of<SocketProvider>(context);
    final earthquakes = socketProvider.earthquakes;

    if (earthquakes.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    if (socketProvider.newEarthquakeReceived) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        _playSound();
        socketProvider.resetNewEarthquakeFlag();
      });
    }

    return ListView.builder(
      itemCount: earthquakes.length,
      itemBuilder: (context, index) {
        final earthquake = earthquakes[index];

        return GestureDetector(
          onTap: () {
            widget.onCardTap(LatLng(
              earthquake.data.properties.lat,
              earthquake.data.properties.lon,
            ));
          },
          child: Card(
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
          ),
        );
      },
    );
  }

  void _playSound() async {
    await _audioPlayer.play(AssetSource('assets/sounds/earthquake_alert.wav'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
