import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'dart:io' show Platform;
import 'package:flutter_map/flutter_map.dart';

import '../map/map.dart';
import 'chart_card.dart';
import 'mobile_bottom_nav.dart';
import 'scroll_sheet.dart';

class EarthquakeDashboard extends StatefulWidget {
  @override
  _EarthquakeDashboardState createState() => _EarthquakeDashboardState();
}

class _EarthquakeDashboardState extends State<EarthquakeDashboard> {
  final MapController _mapController = MapController();
  int _selectedIndex = 0;

  void _moveCameraTo(LatLng position) {
    _mapController.move(position, 8.0);
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return Scaffold(
      body: _buildBody(_selectedIndex, isMobile),
      bottomNavigationBar: isMobile
          ? MobileBottomNav(
              currentIndex: _selectedIndex,
              onTap: (index) => setState(() => _selectedIndex = index),
            )
          : null,
    );
  }

  Widget _buildBody(int index, bool isMobile) {
    switch (index) {
      case 0:
        return _buildLiveView(isMobile);
      case 1:
        return _buildHistoryView();
      case 2:
        return _buildSettingsView();
      default:
        return _buildLiveView(isMobile);
    }
  }

  Widget _buildLiveView(bool isMobile) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen && !isMobile) {
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    Expanded(
                      flex: 4,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Colors.blueGrey[900],
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: MapScreen(
                            mapController: _mapController,
                            isLive: true,
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(38, 38, 38, 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: EarthquakeScrollSheet(
                          onCardTap: _moveCameraTo,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        } else {
          return Stack(
            children: [
              Positioned.fill(
                child: MapScreen(
                  mapController: _mapController,
                  isLive: true,
                ),
              ),
              EarthquakeScrollSheet(
                onCardTap: _moveCameraTo,
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildHistoryView() {
    return Center(
      child: Text(
        'History (Coming Soon)',
        style: TextStyle(fontSize: 20),
      ),
    );
  }

  Widget _buildSettingsView() {
    return Center(
      child: Text(
        'Settings',
        style: TextStyle(fontSize: 20),
      ),
    );
  }
}
