import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'package:client/src/data/models/earthquake.dart';

List<Earthquake> earthquakes = [];

Future<void> main() async {
  await dotenv.load(fileName: ".env");
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, Marker> _markers = {};
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();

    // Fetch initial data from the API
    fetchInitialEarthquakeData().then((_) {
      // After fetching, connect to the WebSocket
      print("Attempting to connect to AWS WebSocket...");
      final websocketUrl = dotenv.env['WEBSOCKET_URL'] ?? '';

      channel = WebSocketChannel.connect(
        Uri.parse(websocketUrl),
      );

      Future.delayed(const Duration(milliseconds: 100), () {
        print("Connection setup should now be active.");
      });

      channel.stream.listen(
        (message) {
          print("Received new earthquake");
          handleMessage(message);
        },
        onDone: () {
          print("WebSocket connection closed.");
        },
        onError: (error) {
          print("WebSocket connection error: $error");
        },
      );

      updateMarkers(earthquakes);
    });
  }

  Future<void> fetchInitialEarthquakeData() async {
    final apiUrl = dotenv.env['API_URL'] ?? '';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      print("Response status code: ${response.statusCode}");

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonData = json.decode(response.body);

        // Extract the 'body' field
        if (jsonData['body'] is List) {
          final List<dynamic> bodyData = jsonData['body'];

          // Iterate over the 'body' list and access the 'details' field
          for (var item in bodyData) {
            if (item['details'] != null) {
              // Extract 'details' for each item
              var details = item['details'];

              // Convert 'details' into an Earthquake object
              var earthquake = Earthquake.fromJson({
                'action': details['action'],
                'data': details['data'], // Pass the 'data' part as it is
              });

              earthquakes.add(earthquake);
            }
          }
        } else {
          print("Error: 'body' field is not a list or is missing");
        }
      } else {
        print("Failed to fetch data. Status code: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching data: $e");
    }

    print("EQ length: ${earthquakes.length}");
  }

  // Handle WebSocket messages
  void handleMessage(String rawMessage) {
    final List<dynamic> bodyData = json.decode(rawMessage);

    List<Earthquake> tempEarthquakes = [];
    // Iterate over the 'body' list and access the 'details' field
    for (var item in bodyData) {
      if (item['details'] != null) {
        // Extract 'details' for each item
        var details = item['details'];

        // Convert 'details' into an Earthquake object
        var earthquake = Earthquake.fromJson({
          'action': details['action'],
          'data': details['data'], // Pass the 'data' part as it is
        });
        tempEarthquakes.add(earthquake);
      }
    }

    earthquakes = tempEarthquakes;
    updateMarkers(earthquakes);
  }

  // Update markers on the map
  void updateMarkers(List<Earthquake> newEarthquakes) {
    setState(() {
      _markers.clear();
      for (final earthquake in newEarthquakes) {
        final marker = Marker(
          markerId: MarkerId(earthquake.data.id),
          position: LatLng(
            earthquake.data.properties.lat,
            earthquake.data.properties.lon,
          ),
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

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    channel.sink.close();
    super.dispose();
  }
}
