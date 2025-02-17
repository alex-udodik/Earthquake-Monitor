import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:client/models/earthquake.dart';

class SocketProvider with ChangeNotifier {
  late WebSocketChannel _channel;
  Timer? _pingTimer;
  bool _isConnected = false;

  List<Earthquake> _earthquakes = [];
  List<Earthquake> get earthquakes => _earthquakes;

  bool _newEarthquakeReceived = false;
  bool get newEarthquakeReceived => _newEarthquakeReceived;

  SocketProvider() {
    connect();
  }

  void connect() {
    final websocketUrl = dotenv.env['WEBSOCKET_URL'] ?? '';

    _channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    _isConnected = true;

    // Listen for incoming messages
    _channel.stream.listen(
      (message) => _handleMessage(message),
      onDone: () => _reconnect(),
      onError: (error) {
        print("WebSocket error: $error");
        _reconnect();
      },
    );

    // Start a ping timer to keep the connection alive
    _startPingTimer();

    var message = {"action": "initData", "message": ""};
    print("Requesting initial data from socket");
    sendMessage(message);
  }

  void sendMessage(dynamic message) {
    _channel.sink.add(jsonEncode(message));
  }

  void _handleMessage(String rawMessage) {
    try {
      final decodedMessage = json.decode(rawMessage);

      // Check if the decoded message is a Map<String, dynamic>
      if (decodedMessage is Map<String, dynamic>) {
        if (decodedMessage['action'] == 'ping') {
          print(
              "Received message from AWS WebSocket: ${decodedMessage['message']}");
          return; // Exit early if it's just a pong message
        }

        // Check if the decoded message has the action 'earthquake-event'
        else if (decodedMessage['action'] == 'earthquake-event' ||
            decodedMessage['action'] == 'initData') {
          // Check if the message is a stringified JSON array
          var message = decodedMessage['message'];
          List<dynamic> earthquakeList;

          if (message is String) {
            // If message is a stringified JSON array, decode it
            earthquakeList = json.decode(message);
          } else {
            earthquakeList = message;
          }

          List<Earthquake> tempEarthquakes = [];

          // Iterate over the decoded list and extract earthquake details
          for (var item in earthquakeList) {
            if (item['details'] != null) {
              var details = item['details'];
              var earthquake = Earthquake.fromJson({
                'action': details['action'],
                'data': details['data'], // Pass the 'data' part as it is
              });
              tempEarthquakes.add(earthquake);
            }
          }

          _earthquakes = tempEarthquakes;

          // If it's a new earthquake event, set the flag
          if (decodedMessage['action'] == 'earthquake-event') {
            print(
                "\nReceived message from AWS WebSocket: New Earthquake event");
            print("Location: ${earthquakes[0].data.properties.flynnRegion}");
            print("Magnitude: ${earthquakes[0].data.properties.mag} \n");

            _newEarthquakeReceived = true;
          } else {
            print("Received initial earthquake data");
          }

          notifyListeners();
        }
      }
    } catch (e) {
      print("Error handling message: $e");
    }
  }

  void resetNewEarthquakeFlag() {
    _newEarthquakeReceived = false;
    notifyListeners();
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isConnected) {
        _channel.sink.add(json.encode({
          'action': 'ping',
          'source': 'flutter-client',
          'message': 'ping to keep connection alive',
        }));
        print("Ping sent to WebSocket.");
      }
    });
  }

  void _reconnect() {
    print("Attempting to reconnect...");
    _isConnected = false;
    _pingTimer?.cancel();
    Future.delayed(const Duration(seconds: 5), () {
      connect(); // Retry connection
    });
  }

  void disconnect() {
    _pingTimer?.cancel();
    _channel.sink.close();
    _isConnected = false;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
