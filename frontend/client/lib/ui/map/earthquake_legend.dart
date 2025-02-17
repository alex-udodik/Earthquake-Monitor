import 'package:flutter/material.dart';

class EarthquakeLegend extends StatelessWidget {
  const EarthquakeLegend({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Positioned(
      bottom: 20,
      left: 20,
      child: Container(
        padding: EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.8), // Dark theme semi-transparent
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: Colors.black26, blurRadius: 4, offset: Offset(2, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Magnitude Legend",
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            SizedBox(height: 5),
            _legendItem(Colors.green, "< 3.0"),
            _legendItem(Colors.yellow, "3.0 - 4.0"),
            _legendItem(Colors.orange, "4.0 - 5.0"),
            _legendItem(Colors.red, "5.0 - 6.0"),
            _legendItem(Colors.purple, "> 6.0"),
          ],
        ),
      ),
    );
  }

  Widget _legendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(6),
          ),
        ),
        SizedBox(width: 8),
        Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );
  }
}
