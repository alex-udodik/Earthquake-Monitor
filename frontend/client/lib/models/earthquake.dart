import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:json_annotation/json_annotation.dart';

class Earthquake {
  String action;
  Data data;

  Earthquake({required this.action, required this.data});

  factory Earthquake.fromJson(Map<String, dynamic> json) {
    return Earthquake(
      action: json['action'],
      data: Data.fromJson(json['data']),
    );
  }
}

class Data {
  String type;
  Geometry geometry;
  String id;
  Properties properties;

  Data({
    required this.type,
    required this.geometry,
    required this.id,
    required this.properties,
  });

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      type: json['type'],
      geometry: Geometry.fromJson(json['geometry']),
      id: json['id'],
      properties: Properties.fromJson(json['properties']),
    );
  }
}

class Geometry {
  String type;
  List<double> coordinates;

  Geometry({required this.type, required this.coordinates});

  factory Geometry.fromJson(Map<String, dynamic> json) {
    return Geometry(
      type: json['type'],
      coordinates: (json['coordinates'] as List<dynamic>).cast<double>(),
    );
  }
}

class Properties {
  String sourceId;
  String sourceCatalog;
  String lastUpdate;
  String time;
  String flynnRegion;
  double lat;
  double lon;
  double depth;
  String evType;
  String auth;
  double mag;
  String magType;
  String unid;
  String displayName; // Location name
  String state; // State/region
  String country; // Country
  String countryCode; // Country code
  String region; // New field for continent
  String subregion; // New field for subregion

  Properties({
    required this.sourceId,
    required this.sourceCatalog,
    required this.lastUpdate,
    required this.time,
    required this.flynnRegion,
    required this.lat,
    required this.lon,
    required this.depth,
    required this.evType,
    required this.auth,
    required this.mag,
    required this.magType,
    required this.unid,
    required this.displayName, // Location name
    required this.state, // State/region
    required this.country, // Country
    required this.countryCode, // Country code
    required this.region, // New field
    required this.subregion, // New field
  });

  factory Properties.fromJson(Map<String, dynamic> json) {
    return Properties(
      sourceId: json['source_id'],
      sourceCatalog: json['source_catalog'],
      lastUpdate: json['lastupdate'],
      time: json['time'],
      flynnRegion: json['flynn_region'],
      lat: (json['lat'] as num).toDouble(), // ✅ Ensures conversion to double
      lon: (json['lon'] as num).toDouble(), // ✅ Ensures conversion to double
      depth:
          (json['depth'] as num).toDouble(), // ✅ Ensures conversion to double
      evType: json['evtype'],
      auth: json['auth'],
      mag: (json['mag'] as num).toDouble(), // ✅ Ensures conversion to double
      magType: json['magtype'],
      unid: json['unid'],
      displayName: json['display_name'] ?? "Unknown", // Handle null safety
      state: json['state'] ?? "Unknown", // Handle null safety
      country: json['country'] ?? "Unknown", // Handle null safety
      countryCode: json['country_code'] ?? "Unknown", // Handle null safety
      region: json['region'] ?? "Unknown", // ✅ New field (continent)
      subregion: json['subregion'] ?? "Unknown", // ✅ New field (subregion)
    );
  }
}
