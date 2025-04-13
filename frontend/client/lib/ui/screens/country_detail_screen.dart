import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;

class CountryDetailScreen extends StatefulWidget {
  final String countryName;
  final String countryCode;

  const CountryDetailScreen({
    Key? key,
    required this.countryName,
    required this.countryCode,
  }) : super(key: key);

  @override
  State<CountryDetailScreen> createState() => _CountryDetailScreenState();
}

class _CountryDetailScreenState extends State<CountryDetailScreen> {
  Map<String, dynamic>? countryData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCountrySummary();
  }

  Future<void> fetchCountrySummary() async {
    final url = Uri.parse(
        "https://selected-bull-34594.upstash.io/get/country_summary_${widget.countryCode.toLowerCase()}");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${dotenv.env['UPSTASH_REST_TOKEN']}",
    });

    if (response.statusCode == 200) {
      final body = jsonDecode(response.body);
      if (body['result'] != null) {
        setState(() {
          countryData = jsonDecode(body['result']);
          isLoading = false;
        });
      }
    } else {
      print("Failed to fetch Redis summary: ${response.statusCode}");
      setState(() => isLoading = false);
    }
  }

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
                    'assets/flags/${widget.countryCode.toLowerCase()}.svg',
                    width: 32,
                    height: 24,
                    placeholderBuilder: (_) =>
                        const SizedBox(width: 32, height: 24),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.countryName,
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
              child: isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : countryData == null
                      ? const Center(
                          child: Text("No data found",
                              style: TextStyle(color: Colors.white)))
                      : SingleChildScrollView(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _statBlock("Total Earthquakes",
                                  countryData!['count'].toString()),
                              _statBlock("Average Magnitude",
                                  countryData!['avgMag'].toString()),
                              _statBlock("Strongest Recorded",
                                  countryData!['maxMag'].toString()),
                              _statBlock("Most Recent Quake",
                                  formatTimeAgo(countryData!['mostRecent'])),
                              const SizedBox(height: 20),
                              Text("Earthquakes Over Time",
                                  style: _sectionTitleStyle()),
                              const SizedBox(height: 10),
                              _chartPlaceholder(),
                              const SizedBox(height: 20),
                              Text("Magnitude Distribution",
                                  style: _sectionTitleStyle()),
                              const SizedBox(height: 10),
                              _chartPlaceholder(),
                              const SizedBox(height: 20),
                              Text("Monthly Activity (Last Year)",
                                  style: _sectionTitleStyle()),
                              const SizedBox(height: 10),
                              _chartPlaceholder(),
                              const SizedBox(height: 20),
                              Text("Heatmap of Activity",
                                  style: _sectionTitleStyle()),
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

  String formatTimeAgo(String isoTime) {
    try {
      final dt = DateTime.parse(isoTime).toLocal();
      return timeago.format(dt);
    } catch (e) {
      return "Unknown";
    }
  }
}
