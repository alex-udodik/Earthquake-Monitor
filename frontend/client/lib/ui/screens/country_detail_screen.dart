import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CountryDetailScreen extends StatelessWidget {
  final String countryName;
  final String countryCode;

  const CountryDetailScreen({
    Key? key,
    required this.countryName,
    required this.countryCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
            // 🔙 Top App Bar
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  SvgPicture.asset(
                    'assets/flags/${countryCode.toLowerCase()}.svg',
                    width: 32,
                    height: 24,
                    placeholderBuilder: (_) =>
                        const SizedBox(width: 32, height: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    countryName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // 📊 Scrollable stats content
            Expanded(
              child: SingleChildScrollView(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _statBlock("Total Earthquakes", "12,340"),
                    _statBlock("Average Magnitude", "4.2"),
                    _statBlock("Strongest Recorded", "6.8 on Mar 2, 2024"),
                    _statBlock("Last 24 Hours", "36 earthquakes"),
                    _statBlock("Deadliest Event", "Oct 12, 2017 – 452 deaths"),
                    const SizedBox(height: 20),
                    Text("Magnitude Distribution", style: _sectionTitleStyle()),
                    const SizedBox(height: 10),
                    _chartPlaceholder(),
                    const SizedBox(height: 20),
                    Text("Monthly Activity (Last Year)",
                        style: _sectionTitleStyle()),
                    const SizedBox(height: 10),
                    _chartPlaceholder(),
                    const SizedBox(height: 20),
                    Text("Heatmap of Activity", style: _sectionTitleStyle()),
                    const SizedBox(height: 10),
                    _chartPlaceholder(height: 180),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // 🔹 Stat Card
  Widget _statBlock(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.grey[850],
          borderRadius: BorderRadius.circular(10),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(color: Colors.white70, fontSize: 16)),
            Text(value,
                style: const TextStyle(
                    color: Colors.tealAccent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

  // 📊 Placeholder for charts
  Widget _chartPlaceholder({double height = 150}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          "Chart Placeholder",
          style: TextStyle(color: Colors.white54),
        ),
      ),
    );
  }

  TextStyle _sectionTitleStyle() => const TextStyle(
        fontSize: 18,
        color: Colors.white,
        fontWeight: FontWeight.w600,
      );
}
