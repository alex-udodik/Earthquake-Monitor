import 'dart:convert';
import 'dart:async';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class WebSocketService {
  late WebSocketChannel channel;
  StreamController<dynamic> _messageController = StreamController.broadcast();
  Timer? _pingTimer;
  Timer? _reconnectionTimer;

  Stream<dynamic> get messages => _messageController.stream;

  void connect() {
    final websocketUrl = dotenv.env['WEBSOCKET_URL'] ?? '';
    channel = WebSocketChannel.connect(Uri.parse(websocketUrl));
    channel.stream.listen(
      (message) => _messageController.add(json.decode(message)),
      onDone: _handleDisconnection,
      onError: (error) => _handleDisconnection(),
    );
    _startPingTimer();
  }

  void send(dynamic message) {
    try {
      channel.sink.add(json.encode(message));
    } catch (e) {
      print("Error sending WebSocket message: $e");
    }
  }

  void _startPingTimer() {
    _pingTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      send({'action': 'ping', 'message': 'keepalive'});
    });
  }

  void _handleDisconnection() {
    _stopPingTimer();
    _scheduleReconnection();
  }

  void _stopPingTimer() {
    _pingTimer?.cancel();
  }

  void _scheduleReconnection() {
    _reconnectionTimer = Timer(const Duration(seconds: 2), connect);
  }

  void dispose() {
    _stopPingTimer();
    _reconnectionTimer?.cancel();
    channel.sink.close();
    _messageController.close();
  }
}
