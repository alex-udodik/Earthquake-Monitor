import 'package:flutter/material.dart';
import 'package:client/services/socket_provider.dart';
import 'package:provider/provider.dart';
import '../../models/earthquake.dart';

class StatCard extends StatefulWidget {
  final String title;
  String value;

  StatCard({required this.title, required this.value});

  @override
  _StatCardState createState() => _StatCardState();
}

class _StatCardState extends State<StatCard> {
  late List<Earthquake> earthquakes;

  @override
  void initState() {
    super.initState();
    // Initialize any state here if necessary
  }

  @override
  Widget build(BuildContext context) {
    final socketProvider = Provider.of<SocketProvider>(context, listen: true);
    earthquakes = socketProvider.earthquakes;

    _updateValue(earthquakes);
    return Card(
      margin: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.title,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Text(
              widget.value,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  void _updateValue(List<Earthquake> earthquakes) {
    double sum = 0;

    for (Earthquake earthquake in earthquakes) {
      sum += earthquake.data.properties.mag;
    }
    print(earthquakes.length);
    print("number: " + sum.toString());
    setState(() {
      widget.value = (sum / earthquakes.length).toStringAsFixed(2);
    });
  }
}
