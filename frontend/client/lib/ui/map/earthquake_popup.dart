import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../../models/earthquake.dart';

class EarthquakeDetailPopup extends StatelessWidget {
  final Earthquake earthquake;
  final LatLng userLocation;

  const EarthquakeDetailPopup({
    Key? key,
    required this.earthquake,
    required this.userLocation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final props = earthquake.data.properties;
    final quakeLatLng = LatLng(props.lat, props.lon);
    final distance = const Distance()
        .as(LengthUnit.Kilometer, userLocation, quakeLatLng)
        .toStringAsFixed(1);
    final bounds = LatLngBounds.fromPoints([userLocation, quakeLatLng]);

    return Dialog(
      backgroundColor: Colors.grey[900],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(props.region.toUpperCase(),
                  style: const TextStyle(
                      fontSize: 20,
                      color: Colors.tealAccent,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 4),
              Text(props.displayName,
                  style: const TextStyle(color: Colors.white70)),
              const Divider(color: Colors.grey),
              _buildInfoRow("Magnitude", "${props.mag} (${props.magType})"),
              _buildInfoRow("Depth", "${props.depth.toStringAsFixed(1)} km"),
              _buildInfoRow("Coordinates",
                  "${props.lat.toStringAsFixed(3)}, ${props.lon.toStringAsFixed(3)}"),
              _buildInfoRow("Occured", _formatDate(context, props.time)),
              _buildInfoRow("Updated", _timeAgo(props.lastUpdate)),
              const Divider(color: Colors.grey),
              _buildInfoRow("Country", props.country),
              _buildInfoRow("State", props.state),
              _buildInfoRow("Authority", props.auth),
              _buildInfoRow("Event Type", props.evType),
              const Divider(color: Colors.grey),
              const SizedBox(height: 8),
              Text("Distance from you: $distance km",
                  style: const TextStyle(
                      color: Colors.tealAccent, fontWeight: FontWeight.w600)),
              const SizedBox(height: 8),
              Container(
                height: 200,
                margin: const EdgeInsets.only(top: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.black,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: FlutterMap(
                    options: MapOptions(
                      bounds: bounds,
                      boundsOptions: FitBoundsOptions(
                        padding: EdgeInsets.all(40),
                      ),
                      interactiveFlags: InteractiveFlag.none,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            "https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}.png",
                        subdomains: ['a', 'b', 'c'],
                      ),
                      MarkerLayer(markers: [
                        Marker(
                          point: quakeLatLng,
                          width: 10,
                          height: 10,
                          builder: (_) => const Icon(Icons.location_on,
                              color: Colors.red, size: 20),
                        ),
                        Marker(
                          point: userLocation,
                          width: 10,
                          height: 10,
                          builder: (_) => const Icon(Icons.person_pin_circle,
                              color: Colors.blue, size: 20),
                        ),
                      ]),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: interpolateGreatCircle(
                                userLocation, quakeLatLng, 100),
                            strokeWidth: 2.5,
                            color: Colors.tealAccent,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Close",
                      style: TextStyle(color: Colors.tealAccent)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70)),
          Text(value, style: const TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  String _formatDate(BuildContext context, String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final date = "${dt.month}/${dt.day}/${dt.year}";
      final time = TimeOfDay.fromDateTime(dt).format(context);
      return "$date – $time";
    } catch (_) {
      return "Unknown";
    }
  }

  String _timeAgo(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate).toLocal();
      final diff = DateTime.now().difference(dt);
      if (diff.inMinutes < 1) return "just now";
      if (diff.inMinutes < 60) return "${diff.inMinutes} minutes ago";
      if (diff.inHours < 24) return "${diff.inHours} hours ago";
      return "${diff.inDays} days ago";
    } catch (_) {
      return "Unknown";
    }
  }

  List<LatLng> interpolateGreatCircle(LatLng start, LatLng end, int segments) {
    final distance = Distance();
    final totalDistance = distance.as(LengthUnit.Kilometer, start, end);
    final initialBearing = distance.bearing(start, end);
    final points = <LatLng>[];

    for (int i = 0; i <= segments; i++) {
      final fraction = i / segments;
      final intermediateDistance = totalDistance * fraction;
      final point =
          distance.offset(start, intermediateDistance, initialBearing);
      points.add(point);
    }

    return points;
  }
}
