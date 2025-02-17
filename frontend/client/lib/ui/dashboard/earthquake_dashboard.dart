import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map/flutter_map.dart';
import '../map/map.dart';
import 'cardlist.dart';
import 'chart_card.dart';

class EarthquakeDashboard extends StatefulWidget {
  @override
  _EarthquakeDashboardState createState() => _EarthquakeDashboardState();
}

class _EarthquakeDashboardState extends State<EarthquakeDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _moveCameraTo(LatLng position) {
    _mapController.move(position, 8.0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Tab Bar at the top (replacing AppBar)
          Container(
            color:
                Color.fromARGB(48, 48, 48, 0), // Background color for the tabs
            child: TabBar(
              controller: _tabController,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.blue,
              tabs: [
                Tab(icon: Icon(Icons.public), text: "Live View"),
                Tab(icon: Icon(Icons.history), text: "History View"),
              ],
            ),
          ),

          // Expanded TabBarView (Main Content)
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMapScreen(isLive: true), // Live View
                _buildMapScreen(isLive: false), // History View
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMapScreen({required bool isLive}) {
    return LayoutBuilder(
      builder: (context, constraints) {
        bool isWideScreen = constraints.maxWidth > 600;

        if (isWideScreen) {
          return Column(
            children: [
              Expanded(
                child: Row(
                  children: [
                    // Map takes up full available space
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
                              isLive: isLive,
                            ),
                          ),
                        ),
                      ),
                    ),
                    // Card List takes up full available space
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

              // Only show additional widgets in History View
              if (!isLive) _buildAdditionalWidgets(),
            ],
          );
        } else {
          return Column(
            children: [
              Expanded(
                child: MapScreen(mapController: _mapController, isLive: isLive),
              ),
              Expanded(
                child: EarthquakeCardList(
                  onCardTap: _moveCameraTo,
                ),
              ),

              // Only show additional widgets in History View
              if (!isLive) _buildAdditionalWidgets(),
            ],
          );
        }
      },
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
