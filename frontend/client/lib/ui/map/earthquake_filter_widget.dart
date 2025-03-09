import 'package:flutter/material.dart';

class EarthquakeFilterWidget extends StatefulWidget {
  final double minMagnitude;
  final double maxMagnitude;
  final double minDepth;
  final double maxDepth;
  final double timeRange;
  final String selectedLocation;
  final Function(double, double, double, double, double, String)
      onFilterApplied;

  const EarthquakeFilterWidget({
    Key? key,
    required this.minMagnitude,
    required this.maxMagnitude,
    required this.minDepth,
    required this.maxDepth,
    required this.timeRange,
    required this.selectedLocation,
    required this.onFilterApplied,
  }) : super(key: key);

  @override
  _EarthquakeFilterWidgetState createState() => _EarthquakeFilterWidgetState();
}

class _EarthquakeFilterWidgetState extends State<EarthquakeFilterWidget> {
  late double _minMagnitude;
  late double _maxMagnitude;
  late double _minDepth;
  late double _maxDepth;
  late double _timeRange;
  late String _selectedLocation;

  final List<String> _locations = [
    "Any",
    "North America",
    "South America",
    "Europe",
    "Asia",
    "Africa",
    "Oceania",
  ];

  @override
  void initState() {
    super.initState();
    _minMagnitude = widget.minMagnitude;
    _maxMagnitude = widget.maxMagnitude;
    _minDepth = widget.minDepth;
    _maxDepth = widget.maxDepth;
    _timeRange = widget.timeRange;
    _selectedLocation = widget.selectedLocation;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Filter Earthquakes",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            // Time Range Filter
            _buildSlider(
              title: "Time Range (Hours)",
              value: _timeRange,
              min: 1,
              max: 48,
              divisions: 47,
              label: "${_timeRange.toInt()}h",
              onChanged: (value) {
                setState(() {
                  _timeRange = value;
                });
              },
            ),

            // Magnitude Filter
            _buildRangeSlider(
              title: "Magnitude",
              values: RangeValues(_minMagnitude, _maxMagnitude),
              min: 0.0,
              max: 10.0,
              divisions: 20,
              onChanged: (values) {
                setState(() {
                  _minMagnitude = values.start;
                  _maxMagnitude = values.end;
                });
              },
            ),

            // Depth Filter
            _buildRangeSlider(
              title: "Depth (km)",
              values: RangeValues(_minDepth, _maxDepth),
              min: 0,
              max: 700,
              divisions: 14,
              onChanged: (values) {
                setState(() {
                  _minDepth = values.start;
                  _maxDepth = values.end;
                });
              },
            ),

            // Location Filter (Dropdown)
            DropdownButtonFormField<String>(
              value: _selectedLocation,
              decoration: const InputDecoration(labelText: "Location"),
              items: _locations.map((location) {
                return DropdownMenuItem(
                  value: location,
                  child: Text(location),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedLocation = value!;
                });
              },
            ),

            const SizedBox(height: 16),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onFilterApplied(
                      _minMagnitude,
                      _maxMagnitude,
                      _minDepth,
                      _maxDepth,
                      _timeRange,
                      _selectedLocation,
                    );
                    Navigator.pop(context);
                  },
                  child: const Text("Apply"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSlider({
    required String title,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required String label,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          label: label,
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildRangeSlider({
    required String title,
    required RangeValues values,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<RangeValues> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title),
        RangeSlider(
          values: values,
          min: min,
          max: max,
          divisions: divisions,
          labels: RangeLabels(
            values.start.toStringAsFixed(1),
            values.end.toStringAsFixed(1),
          ),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
