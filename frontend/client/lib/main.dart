import 'package:client/src/data/models/earthquake.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

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
  late WebSocketChannel channel;

  @override
  void initState() {
    super.initState();

    // Log the connection attempt before initiating the connection
    print("Attempting to connect to AWS WebSocket...");

    // Connect to AWS WebSocket
    channel = WebSocketChannel.connect(
      Uri.parse(
          'wss://w0s7wouqu3.execute-api.us-west-2.amazonaws.com/production/'),
    );

    // Delay to ensure connection setup is active
    Future.delayed(Duration(milliseconds: 100), () {
      print("Connection setup should now be active.");
    });

    // Listen for incoming messages
    channel.stream.listen(
      (message) {
        print(
            "Connected to AWS WebSocket!"); // This will print upon receiving the first message

        // Print the entire object received from the WebSocket
        print("Received message: $handleMessage($message)");

        // Process the received message
        dynamic jsonData = json.decode(message);
        if (jsonData is List<dynamic>) {
          List<Map<String, dynamic>> jsonArray =
              jsonData.cast<Map<String, dynamic>>();
          earthquakes =
              jsonArray.map((jsonMap) => Earthquake.fromJson(jsonMap)).toList();

          updateMarkers(earthquakes);
        } else {
          print("Invalid JSON format. Expected a list.");
        }
      },
      onDone: () {
        print("WebSocket connection closed.");
      },
      onError: (error) {
        print("WebSocket connection error: $error");
      },
    );
  }

// Function to attempt JSON repair
  String attemptJsonRepair(String message) {
    // Remove any trailing commas and extra whitespace
    message = message.trim().replaceAll(RegExp(r',\s*$'), '');

    // Wrap it in a JSON array if it looks like it might contain multiple JSON objects
    if (!message.startsWith("[")) {
      message = "[$message]";
    }

    // Try to balance braces and brackets
    int openBraces = message.split('{').length - 1;
    int closeBraces = message.split('}').length - 1;
    int openBrackets = message.split('[').length - 1;
    int closeBrackets = message.split(']').length - 1;

    // Add missing closing braces and brackets
    while (closeBraces < openBraces) {
      message += '}';
      closeBraces++;
    }
    while (closeBrackets < openBrackets) {
      message += ']';
      closeBrackets++;
    }

    print("Repaired JSON: $message");
    return message;
  }

  void handleMessage(String rawMessage) {
    try {
      // Try to parse the raw message as JSON
      var decodedMessage = jsonDecode(rawMessage);
      print("Decoded JSON: $decodedMessage");
    } catch (e) {
      print("Failed to parse JSON directly. Attempting to repair...");
      String repairedJson = attemptJsonRepair(rawMessage);

      try {
        var decodedMessage = jsonDecode(repairedJson);
        print("Decoded repaired JSON: $decodedMessage");
      } catch (e) {
        print("Failed to parse even after repair. Error: $e");
      }
    }
  }

  void updateMarkers(List<Earthquake> newEarthquakes) {
    print("Setting state");
    print("Currently " + newEarthquakes.length.toString() + " earthquakes.");
    setState(() {
      _markers.clear();
      for (final earthquake in newEarthquakes) {
        final marker = Marker(
          markerId: MarkerId(earthquake.data.id),
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

  @override
  void dispose() {
    // Close the WebSocket connection when the widget is disposed
    channel.sink.close();
    super.dispose();
  }
}
