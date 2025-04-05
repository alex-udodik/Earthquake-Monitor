import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'cardlist.dart';

class EarthquakeScrollSheet extends StatelessWidget {
  final Function(LatLng) onCardTap;

  const EarthquakeScrollSheet({
    Key? key,
    required this.onCardTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.2,
      minChildSize: 0.1,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              // 👇 This stays visible, always at the top
              Center(
                child: Container(
                  margin: EdgeInsets.symmetric(vertical: 8),
                  width: 40,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.grey[700],
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),

              // 👇 Scrollable content below it
              Expanded(
                child: EarthquakeCardList(
                  onCardTap: onCardTap,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
