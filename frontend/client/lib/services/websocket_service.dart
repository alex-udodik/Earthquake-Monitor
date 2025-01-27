import 'package:web_socket_channel/web_socket_channel.dart';
import 'dart:convert';

class WebSocketService {
  final String url;
  late WebSocketChannel _channel;
  void Function(String)? onMessage;
  void Function()? onDone;
  void Function(dynamic)? onError;

  WebSocketService({required this.url});

  void connect() {
    _channel = WebSocketChannel.connect(Uri.parse(url));
    _channel.stream.listen(
      (message) => onMessage?.call(message),
      onDone: onDone,
      onError: onError,
    );
  }

  void sendMessage(Map<String, dynamic> message) {
    _channel.sink.add(json.encode(message));
  }

  void dispose() {
    _channel.sink.close();
  }
}
