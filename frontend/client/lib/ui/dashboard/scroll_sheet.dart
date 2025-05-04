import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'cardlist.dart';

class EarthquakeScrollSheet extends StatefulWidget {
  final Function(LatLng) onCardTap;

  const EarthquakeScrollSheet({
    Key? key,
    required this.onCardTap,
  }) : super(key: key);

  @override
  _EarthquakeScrollSheetState createState() => _EarthquakeScrollSheetState();
}

class _EarthquakeScrollSheetState extends State<EarthquakeScrollSheet> {
  String _selectedTimeRange = '24 Hours';

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
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
          ),
          child: ListView(
            controller: scrollController,
            padding: EdgeInsets.zero,
            children: [
              const SizedBox(height: 8),
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
              const SizedBox(height: 0),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[900],
                      ),
                      child: Text(
                        _formattedNow(),
                        style: const TextStyle(
                          color: Colors.tealAccent,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Container(
                      height: 26,
                    ),
                    Container(
                      height: 26,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.grey[900],
                      ),
                      child: DropdownButton<String>(
                        dropdownColor: Colors.grey[900],
                        value: _selectedTimeRange,
                        underline: const SizedBox(),
                        iconEnabledColor: Colors.white,
                        items: [
                          '1 Hour',
                          '6 Hours',
                          '24 Hours',
                          '7 Days',
                          '30 Days',
                          '90 Days',
                        ].map((value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value,
                                style: const TextStyle(color: Colors.white)),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            setState(() {
                              _selectedTimeRange = value;
                              // TODO: Use this value to adjust filters if needed
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.75,
                child: EarthquakeCardList(
                  onCardTap: widget.onCardTap,
                  scrollController: scrollController,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  String _formattedNow() {
    final now = DateTime.now();
    return "${_pad(now.month)}/${_pad(now.day)}/${now.year}, ${_pad(now.hour)}:${_pad(now.minute)} ${now.timeZoneName}";
  }

  String _pad(int value) => value.toString().padLeft(2, '0');
}
