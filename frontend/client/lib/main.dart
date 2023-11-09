import 'package:client/src/data/models/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

import 'dart:convert';

List<Earthquake> earthquakes = [];

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  late StompClient stompClient;

  @override
  void initState() {
    super.initState();

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

            updateMarkers(earthquakes);
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

  void updateMarkers(List<Earthquake> newEarthquakes) {
    print("Setting state");
    print("Currently " + newEarthquakes.length.toString() + " earthquakes.");
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.green[700],
      ),
      home: Scaffold(
        body: GoogleMap(
          initialCameraPosition: const CameraPosition(
            target: LatLng(0, 0),
            zoom: 2,
          ),
          markers: _markers.values.toSet(),
        ),
      ),
    );
  }
}
