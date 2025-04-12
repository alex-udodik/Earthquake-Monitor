import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

class CountryPolygonLoader {
  static Future<List<Polygon>> loadPolygons({
    String assetPath = 'assets/geo/custom_geo.json',
  }) async {
    final String geojsonStr = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> geojson = json.decode(geojsonStr);

    final List<Polygon> polygons = [];

    for (final feature in geojson['features']) {
      final geometry = feature['geometry'];
      final properties = feature['properties'];
      final label = properties['name'] ?? 'Unknown';

      if (geometry['type'] == 'Polygon') {
        for (final coords in geometry['coordinates']) {
          final points = coords
              .map<LatLng>((c) =>
                  LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          polygons.add(Polygon(
            points: points,
            label: label,
            color: Colors.red.withOpacity(0.2),
            borderColor: Colors.red.withAlpha(50), // 0 to 255

            borderStrokeWidth: 1.0,
          ));
        }
      }

      if (geometry['type'] == 'MultiPolygon') {
        for (final polygon in geometry['coordinates']) {
          for (final coords in polygon) {
            final points = coords
                .map<LatLng>((c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                .toList();

            polygons.add(Polygon(
              points: points,
              label: label,
              color: Colors.red.withOpacity(0.2),
              borderColor: Colors.red.withAlpha(50),
              borderStrokeWidth: 1.0,
            ));
          }
        }
      }
    }

    return polygons;
  }
}
