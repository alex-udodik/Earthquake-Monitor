import 'package:flutter/material.dart';
import 'package:client/services/socket_provider.dart';
import 'package:provider/provider.dart';
import '../models/earthquake.dart';

/// An abstract base class for stat cards.
/// Child classes must implement the `calculateValue` method.
abstract class BaseStatCard extends StatefulWidget {
  final String title;

  const BaseStatCard({required this.title, Key? key}) : super(key: key);

  /// Each child class must override this method to define how the value is calculated.
  String calculateValue(List<Earthquake> earthquakes);

  @override
  _BaseStatCardState createState() => _BaseStatCardState();
}

class _BaseStatCardState extends State<BaseStatCard> {
  late List<Earthquake> earthquakes;
  String value = '';

  @override
  void initState() {
    super.initState();
    // Perform any necessary initialization
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    earthquakes = socketProvider.earthquakes;

    _updateValue(earthquakes);

    return Card(
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Spacer(),
            Text(
              value,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _updateValue(List<Earthquake> earthquakes) {
    setState(() {
      value = widget.calculateValue(earthquakes);
    });
  }
}
