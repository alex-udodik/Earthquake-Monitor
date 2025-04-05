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
      initialChildSize: 0.1,
      minChildSize: 0.05,
      maxChildSize: 0.85,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.black87,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              SizedBox(height: 10),
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[600],
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
              SizedBox(height: 6),

              // ⬇️ Make the inner scrollable widget fixed-height
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
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
