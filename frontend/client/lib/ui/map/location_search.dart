import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationSearch extends StatefulWidget {
  final MapController mapController;

  const LocationSearch({Key? key, required this.mapController})
      : super(key: key);

  @override
  _LocationSearchState createState() => _LocationSearchState();
}

class _LocationSearchState extends State<LocationSearch> {
  final TextEditingController _controller = TextEditingController();
  bool _isLoading = false;

  // Function to search for a location
  void _searchLocation(String query) async {
    if (query.isEmpty) return;

    setState(() {
      _isLoading = true;
    });

    try {
      List<Location> locations = await locationFromAddress(query);
      if (locations.isNotEmpty) {
        Location location = locations.first;
        widget.mapController
            .move(LatLng(location.latitude, location.longitude), 10.0);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Location not found")),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 20,
      left: 20, // Positioning it to the left
      child: Container(
        width: 250, // Fixed width to keep it compact
        padding: EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.yellow.withOpacity(0.2), // Dark theme
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: TextField(
                controller: _controller,
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search location...",
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
                onSubmitted: _searchLocation,
              ),
            ),
            if (_isLoading)
              Padding(
                padding: EdgeInsets.only(left: 8),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
