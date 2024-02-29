import 'package:client/src/data/models/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map_animations/flutter_map_animations.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';
import 'package:flutter_map/flutter_map.dart';

import 'package:latlong2/latlong.dart' as latLng;

import 'dart:convert';

late AnimationController animationController;
late final _animatedMapController;

List<Earthquake> earthquakes = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with TickerProviderStateMixin {
  //final Map<String, Marker> _markers = {};
  late StompClient stompClient;
  late Animation animation;

  @override
  void initState() {
    super.initState();

    _animatedMapController = AnimatedMapController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
      curve: Curves.easeInOut,
    );

    animationController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );

    animationController.repeat(reverse: true);

    void onConnect(StompFrame frame) {
      print("Connected!");
      stompClient.subscribe(
        destination: '/topic/greetings',
        callback: (frame) {
          String jsonString = frame.body.toString();
          dynamic jsonData = json.decode(jsonString);
          if (jsonData is List<dynamic>) {
            List<Map<String, dynamic>> jsonArray =
                jsonData.cast<Map<String, dynamic>>();
            earthquakes = jsonArray
                .map((jsonMap) => Earthquake.fromJson(jsonMap))
                .toList();

            //updateMarkers(earthquakes);
          } else {
            print("Invalid JSON format. Expected a list.");
          }
        },
      );

      stompClient.send(
        destination: '/app/hello',
        body: "2134234",
      );
    }

    final config = StompConfig(
        url: 'ws://localhost:8081/topic',
        onConnect: onConnect,
        beforeConnect: () async {
          print('waiting to connect...');
          await Future.delayed(const Duration(milliseconds: 200));
          print('connecting...');
        },
        onWebSocketError: (error) => print(error));

    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Call your function here
      stompClient = StompClient(config: config);
      stompClient.activate();
    });
  }

/*
  void updateMarkers(List<Earthquake> newEarthquakes) {
    print("Setting state");
    print("Currently ${newEarthquakes.length} earthquakes.");
    setState(() {
      _markers.clear();
      for (final earthquake in newEarthquakes) {
        final marker = Marker(
          markerId: MarkerId(
              earthquake.data.id), // Use a unique identifier for the marker
          position: LatLng(
              earthquake.data.properties.lat, earthquake.data.properties.lon),
          infoWindow: InfoWindow(
            title: earthquake.data.properties.flynnRegion,
            snippet: earthquake.data.properties.mag.toString(),
          ),
        );
        _markers[earthquake.data.id] = marker;
      }
    });
  }
*/
  @override
  void dispose() {
    animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.green[700],
        ),
        home: Scaffold(
          body: Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  initialCenter: latLng.LatLng(51.509364, -0.128928),
                  zoom: 3.2,
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    userAgentPackageName: 'com.example.app',
                  ),
                  AnimatedMarkerLayer(
                    markers: [
                      AnimatedMarker(
                        point: latLng.LatLng(52.2677, 5.1689),
                        builder: (_, animationController) {
                          final size = 50.0 * animationController.value;
                          return Container(
                            width: size,
                            height: size,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.red
                                  .withOpacity(0.5), // Adjust opacity as needed
                            ),
                          );
                        },
                      ),
                    ],
                  )
                  /*CircleLayer(
                    circles: [
                      CircleMarker(
                        point:
                            latLng.LatLng(52.2677, 5.1689), // center of 't Gooi
                        radius: 50 * (5 + animationController!.value),
                        useRadiusInMeter: false,
                        color: Colors.red.withOpacity(0.3),
                        borderColor: Colors.red.withOpacity(0.7),
                        borderStrokeWidth: 2,
                      )
                    ],
                  )*/
                ],
              ),
            ],
          ),
        ));
  }
}
