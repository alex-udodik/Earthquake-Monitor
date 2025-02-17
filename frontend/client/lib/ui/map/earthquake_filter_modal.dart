import 'package:flutter/material.dart';

class EarthquakeFilterModal extends StatefulWidget {
  final Function(double, double, double, double, double) onApplyFilters;

  const EarthquakeFilterModal({Key? key, required this.onApplyFilters})
      : super(key: key);

  @override
  _EarthquakeFilterModalState createState() => _EarthquakeFilterModalState();
}

class _EarthquakeFilterModalState extends State<EarthquakeFilterModal> {
  double minMagnitude = 0.0;
  double maxMagnitude = 10.0;
  double minDepth = 0.0;
  double maxDepth = 700.0;
  double timeRange = 24.0; // Hours

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Title
          Text(
            "Filter Earthquakes",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 20),

          // Magnitude Filter
          Text("Magnitude", style: TextStyle(color: Colors.white)),
          RangeSlider(
            values: RangeValues(minMagnitude, maxMagnitude),
            min: 0.0,
            max: 10.0,
            divisions: 20,
            labels: RangeLabels("${minMagnitude.toStringAsFixed(1)}",
                "${maxMagnitude.toStringAsFixed(1)}"),
            onChanged: (RangeValues values) {
              setState(() {
                minMagnitude = values.start;
                maxMagnitude = values.end;
              });
            },
          ),

          // Depth Filter
          Text("Depth (km)", style: TextStyle(color: Colors.white)),
          RangeSlider(
            values: RangeValues(minDepth, maxDepth),
            min: 0.0,
            max: 700.0,
            divisions: 20,
            labels: RangeLabels("${minDepth.toStringAsFixed(1)} km",
                "${maxDepth.toStringAsFixed(1)} km"),
            onChanged: (RangeValues values) {
              setState(() {
                minDepth = values.start;
                maxDepth = values.end;
              });
            },
          ),

          // Time Range Filter
          Text("Time Range (Last Hours)",
              style: TextStyle(color: Colors.white)),
          Slider(
            value: timeRange,
            min: 1,
            max: 72,
            divisions: 24,
            label: "${timeRange.toInt()} hrs",
            onChanged: (value) {
              setState(() {
                timeRange = value;
              });
            },
          ),

          // Apply Filter Button
          SizedBox(height: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              foregroundColor: Colors.white,
            ),
            onPressed: () {
              widget.onApplyFilters(
                  minMagnitude, maxMagnitude, minDepth, maxDepth, timeRange);
              Navigator.pop(context);
            },
            child: Text("Apply Filters"),
          ),

          // Reset Filters
          TextButton(
            onPressed: () {
              setState(() {
                minMagnitude = 0.0;
                maxMagnitude = 10.0;
                minDepth = 0.0;
                maxDepth = 700.0;
                timeRange = 24.0;
              });
            },
            child: Text("Reset Filters", style: TextStyle(color: Colors.white)),
          ),

          SizedBox(height: 10),
        ],
      ),
    );
  }
}
