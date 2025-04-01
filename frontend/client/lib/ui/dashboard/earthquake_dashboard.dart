import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../map/map.dart';
import 'cardlist.dart';
import 'chart_card.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

class EarthquakeDashboard extends StatefulWidget {
  @override
  _EarthquakeDashboardState createState() => _EarthquakeDashboardState();
}

class _EarthquakeDashboardState extends State<EarthquakeDashboard> {
  final MapController _mapController = MapController();
  bool _showDragHandle = true;

  void _moveCameraTo(LatLng position) {
    _mapController.move(position, 8.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: _buildDrawer(context),
      body: Stack(
        children: [
          _buildLiveView(),

          // FAB to open the drawer manually (top-left)
          Positioned(
            top: 32,
            left: 16,
            child: Builder(
              builder: (context) => FloatingActionButton(
                mini: true,
                backgroundColor: Colors.black.withOpacity(0.7),
                onPressed: () => Scaffold.of(context).openDrawer(),
                child: Icon(Icons.menu, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveView() {
    final isMobile = !kIsWeb && (Platform.isAndroid || Platform.isIOS);

    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen && !isMobile) {
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Map
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
                          child: Center(
                            child: MapScreen(
                              mapController: _mapController,
                              isLive: true,
                            ),
                          ),
                        ),
                      ),
                    ),

                    // Earthquake card list
                    Expanded(
                      flex: 1,
                      child: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(38, 38, 38, 1),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: EarthquakeCardList(
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
              DraggableScrollableSheet(
                initialChildSize: 0.2,
                minChildSize: 0.1,
                maxChildSize: 0.85,
                builder: (context, scrollController) {
                  return Container(
                    decoration: BoxDecoration(
                      color: Colors.black87,
                      borderRadius:
                          BorderRadius.vertical(top: Radius.circular(20)),
                    ),
                    child: ListView(
                      controller: scrollController,
                      children: [
                        AnimatedOpacity(
                          opacity: _showDragHandle ? 1.0 : 0.0,
                          duration: Duration(milliseconds: 300),
                          child: Center(
                            child: Container(
                              width: 40,
                              height: 6,
                              decoration: BoxDecoration(
                                color: Colors.grey[700],
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: 8),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * 0.8,
                          child: EarthquakeCardList(
                            onCardTap: _moveCameraTo,
                            scrollController: scrollController,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
          );
        }
      },
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(color: Colors.blueGrey[800]),
            child: Text(
              'Earthquake Menu',
              style: TextStyle(color: Colors.white, fontSize: 24),
            ),
          ),
          ListTile(
            leading: Icon(Icons.map),
            title: Text('Live View'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.history),
            title: Text('History (Coming Soon)'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: Icon(Icons.settings),
            title: Text('Settings'),
            onTap: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalWidgets() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        SizedBox(
          height: 300,
          child: ChartCard(title: "dist"),
        ),
        SizedBox(height: 20),
        Text(
          'Additional Data or Widgets',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 10),
        Container(
          margin: EdgeInsets.all(8),
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blueGrey[700],
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            'This section can display graphs, stats, or other widgets.',
            style: TextStyle(fontSize: 16),
          ),
        ),
      ],
    );
  }
}
