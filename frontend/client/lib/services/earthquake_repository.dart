import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/earthquake.dart';

class EarthquakeRepository {
  final String apiUrl;

  EarthquakeRepository({required this.apiUrl});

  Future<List<Earthquake>> fetchInitialEarthquakeData() async {
    try {
      final response = await http.get(Uri.parse(apiUrl));
      if (response.statusCode == 200) {
        final List<dynamic> body = json.decode(response.body)['body'];
        return body.map((item) {
          return Earthquake.fromJson({
            'action': item['details']['action'],
            'data': item['details']['data'],
          });
        }).toList();
      } else {
        throw Exception('Failed to fetch earthquake data');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }
}
