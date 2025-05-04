import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LabeledPolygon extends Polygon {
  final String label;
  final String countryCode;

  LabeledPolygon({
    required List<LatLng> points,
    required this.label,
    required this.countryCode,
    Color color = Colors.red,
    Color borderColor = Colors.red,
    double borderStrokeWidth = 1.0,
  }) : super(
          points: points,
          color: color,
          borderColor: borderColor,
          borderStrokeWidth: borderStrokeWidth,
        );
}

class CountryPolygonLoader {
  static Future<List<LabeledPolygon>> loadPolygons({
    String assetPath = 'assets/geo/country_polygons_geo_low.json',
  }) async {
    final String geojsonStr = await rootBundle.loadString(assetPath);
    final Map<String, dynamic> geojson = json.decode(geojsonStr);

    final List<LabeledPolygon> polygons = [];

    for (final feature in geojson['features']) {
      final geometry = feature['geometry'];
      final properties = feature['properties'];
      final label = properties['name'] ?? 'Unknown';
      final code = properties['iso_a2'] ?? 'XX'; // 🌍 ISO country code

      if (geometry['type'] == 'Polygon') {
        for (final coords in geometry['coordinates']) {
          final points = coords
              .map<LatLng>((c) =>
                  LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
              .toList();

          polygons.add(LabeledPolygon(
              points: points,
              label: label,
              countryCode: code,
              color: Colors.red.withOpacity(0.2),
              borderColor: Colors.red.withAlpha(50)));
        }
      }

      if (geometry['type'] == 'MultiPolygon') {
        for (final polygon in geometry['coordinates']) {
          for (final coords in polygon) {
            final points = coords
                .map<LatLng>((c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()))
                .toList();

            polygons.add(LabeledPolygon(
                points: points,
                label: label,
                countryCode: code,
                color: Colors.red.withOpacity(0.2),
                borderColor: Colors.red.withAlpha(50)));
          }
        }
      }
    }

    return polygons;
  }
}
