import 'package:flutter/material.dart';
import 'earthquake_filter_widget.dart'; // Import the filter widget

class EarthquakeFilterFAB extends StatelessWidget {
  final double minMagnitude;
  final double maxMagnitude;
  final double minDepth;
  final double maxDepth;
  final double timeRange;
  final String selectedLocation;
  final Function(double, double, double, double, double, String)
      onFilterApplied;

  const EarthquakeFilterFAB({
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
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () {
        showDialog(
          context: context,
          builder: (context) {
            return EarthquakeFilterWidget(
              minMagnitude: minMagnitude,
              maxMagnitude: maxMagnitude,
              minDepth: minDepth,
              maxDepth: maxDepth,
              timeRange: timeRange,
              selectedLocation: selectedLocation,
              onFilterApplied: onFilterApplied,
            );
          },
        );
      },
      child: const Icon(Icons.filter_list),
    );
  }
}
