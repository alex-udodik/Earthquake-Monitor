import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'dart:async';

import 'package:client/data/models/earthquake.dart';

List<Earthquake> earthquakes = [];

// Logging function to log messages with timestamps
void logWithTimestamp(String message) {
  final now = DateTime.now();
  print('${now.toIso8601String()} $message');
}

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
  Timer? _pingTimer; // Timer to keep the WebSocket connection alive
  Timer? _reconnectionTimer; // Timer for reconnection attempts
  bool _isDisposed = false; // To track widget disposal

  @override
  void initState() {
    super.initState();
    _connectToWebSocket();
  }

  void _connectToWebSocket() {
    if (_isDisposed) return;

    final websocketUrl = dotenv.env['WEBSOCKET_URL'] ?? '';
    logWithTimestamp("Attempting to connect to AWS WebSocket...");

    try {
      channel = WebSocketChannel.connect(
        Uri.parse(websocketUrl),
      );

      // Start listening to the WebSocket stream
      channel.stream.listen(
        (message) {
          handleMessage(message);
        },
        onDone: _handleDisconnection,
        onError: (error) {
          logWithTimestamp("WebSocket connection error: $error");
          _handleDisconnection();
        },
      );

      // Fetch initial data and start ping timer
      fetchInitialEarthquakeData();
      _startPingTimer();
    } catch (e) {
      logWithTimestamp("Error connecting to WebSocket: $e");
      _scheduleReconnection();
    }
  }

  void _handleDisconnection() {
    logWithTimestamp("WebSocket connection closed.");
    _stopPingTimer();
    _scheduleReconnection();
  }

  void _scheduleReconnection() {
    if (_reconnectionTimer != null && _reconnectionTimer!.isActive) return;

    logWithTimestamp("Scheduling WebSocket reconnection...");
    _reconnectionTimer = Timer(const Duration(seconds: 2), () {
      logWithTimestamp("Reconnecting to AWS WebSocket...");
      _connectToWebSocket();
    });
  }

  void _startPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      try {
        channel.sink.add(json.encode({
          'action': 'ping',
          'source': 'flutter-client',
          'message': 'ping to keep socket connection alive',
        }));
        logWithTimestamp("Ping sent to AWS WebSocket.");
      } catch (e) {
        logWithTimestamp("Error sending ping: $e");
      }
    });
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  void fetchInitialEarthquakeData() {
    try {
      var message = {"action": "initData", "message": ""};
      logWithTimestamp("Sending message...");
      channel.sink.add(jsonEncode(message));
      logWithTimestamp("Message sent: $message");
    } catch (e) {
      logWithTimestamp("Error sending message: $e");
    }
  }

  void handleMessage(String rawMessage) {
    try {
      final decodedMessage = json.decode(rawMessage);

      if (decodedMessage is Map<String, dynamic>) {
        if (decodedMessage['action'] == 'ping') {
          logWithTimestamp(
              "Received message from AWS WebSocket: ${decodedMessage['message']}");
          return;
        } else if (decodedMessage['action'] == 'earthquake-event' ||
            decodedMessage['action'] == 'initData') {
          var message = decodedMessage['message'];
          List<dynamic> earthquakeList;

          if (message is String) {
            earthquakeList = json.decode(message);
          } else {
            earthquakeList = message;
          }

          List<Earthquake> tempEarthquakes = [];
          for (var item in earthquakeList) {
            if (item['details'] != null) {
              var details = item['details'];
              var earthquake = Earthquake.fromJson({
                'action': details['action'],
                'data': details['data'],
              });
              tempEarthquakes.add(earthquake);
            }
          }

          earthquakes = tempEarthquakes;

          if (decodedMessage['action'] == 'earthquake-event') {
            logWithTimestamp(
                "\nReceived message from AWS WebSocket: New Earthquake event");
            logWithTimestamp(
                "Location: ${earthquakes[0].data.properties.flynnRegion}");
            logWithTimestamp(
                "Magnitude: ${earthquakes[0].data.properties.mag} \n");
          } else {
            logWithTimestamp("Received initial earthquake data");
          }

          updateMarkers(earthquakes);
        }
      }
    } catch (e) {
      logWithTimestamp("Error handling message: $e");
    }
  }

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
    _isDisposed = true;
    _stopPingTimer();
    _reconnectionTimer?.cancel();
    channel.sink.close();
    super.dispose();
  }
}
