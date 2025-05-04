import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:fl_chart/fl_chart.dart';

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
  List<Map<String, dynamic>> timeSeriesData = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    await fetchCountrySummary();
    timeSeriesData = await fetchTimeSeries("daily");
    setState(() => isLoading = false);
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
        });
      }
    } else {
      print("Failed to fetch Redis summary: ${response.statusCode}");
    }
  }

  Future<List<Map<String, dynamic>>> fetchTimeSeries(String interval) async {
    final key = "${widget.countryCode.toLowerCase()}_$interval";
    final url = Uri.parse("https://selected-bull-34594.upstash.io/get/$key");

    final response = await http.get(url, headers: {
      "Authorization": "Bearer ${dotenv.env['UPSTASH_REST_TOKEN']}",
    });

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      if (result['result'] != null) {
        final List<dynamic> parsed = jsonDecode(result['result']);
        return parsed.cast<Map<String, dynamic>>(); // Convert dynamic to Map
      }
    } else {
      print("Failed to fetch $interval data: ${response.statusCode}");
    }

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[900],
      body: SafeArea(
        child: Column(
          children: [
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

            // 📊 Scrollable stats
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
                              timeSeriesData.isEmpty
                                  ? _chartPlaceholder()
                                  : SizedBox(
                                      height: 180,
                                      child: _earthquakesOverTimeChart(
                                          timeSeriesData)),
                              const SizedBox(height: 20),
                              Text("Magnitude Distribution",
                                  style: _sectionTitleStyle()),
                              const SizedBox(height: 10),
                              SizedBox(
                                height: 180,
                                child: _magnitudeDistributionChart(
                                  timeSeriesData
                                      .map((e) => (e['avgMag'] ?? 0).toDouble())
                                      .toList()
                                      .cast<double>(),
                                ),
                              ),
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

  Widget _earthquakesOverTimeChart(List<Map<String, dynamic>> data) {
    final reversedData = List<Map<String, dynamic>>.from(data.reversed);

    final List<FlSpot> spots = [];
    final List<String> labels = [];

    for (int i = 0; i < reversedData.length; i++) {
      final item = reversedData[i];
      final timestamp = DateTime.parse(item['timestamp']);
      final count = item['count']?.toDouble() ?? 0;

      spots.add(FlSpot(i.toDouble(), count));
      labels.add('${timestamp.month}/${timestamp.year}');
    }

    // Get min/max Y for scaling
    final yValues = spots.map((s) => s.y).toList();
    final yMin = yValues.reduce((a, b) => a < b ? a : b);
    final yMax = yValues.reduce((a, b) => a > b ? a : b);
    final yInterval = ((yMax - yMin) / 4).clamp(1, double.infinity).toDouble();

    return LineChart(
      LineChartData(
        minY: yMin,
        maxY: yMax,
        lineBarsData: [
          LineChartBarData(
            spots: spots,
            isCurved: true,
            gradient: const LinearGradient(
              colors: [Colors.tealAccent, Colors.deepOrange],
            ),
            belowBarData: BarAreaData(show: false),
            dotData: FlDotData(show: false),
            barWidth: 3,
          ),
        ],
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 40,
              getTitlesWidget: (value, meta) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
                textAlign: TextAlign.right,
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval:
                  (spots.length / 6).floorToDouble().clamp(1, double.infinity),
              getTitlesWidget: (value, meta) {
                final index = value.toInt();
                if (index < 0 || index >= labels.length)
                  return const SizedBox.shrink();
                return Text(
                  labels[index],
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: yInterval,
          verticalInterval:
              (spots.length / 6).floorToDouble().clamp(1, double.infinity),
          getDrawingHorizontalLine: (_) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
          getDrawingVerticalLine: (_) =>
              const FlLine(color: Colors.white12, strokeWidth: 1),
        ),
      ),
    );
  }

  double safeInterval(double min, double max, int divisions) {
    final range = max - min;
    if (range <= 0 || divisions <= 0) return 1;
    final rawInterval = range / divisions;
    return rawInterval.isFinite && !rawInterval.isNaN ? rawInterval : 1;
  }

  Widget _magnitudeDistributionChart(List<double> magnitudes) {
    // 1. Create buckets
    final Map<int, int> histogram = {};
    for (final mag in magnitudes) {
      final bucket = mag.floor(); // e.g. 3.7 -> 3
      histogram[bucket] = (histogram[bucket] ?? 0) + 1;
    }

    // 2. Convert to bar chart data
    final barGroups = <BarChartGroupData>[];
    final sortedBuckets = histogram.keys.toList()..sort();

    for (final bucket in sortedBuckets) {
      barGroups.add(
        BarChartGroupData(
          x: bucket,
          barRods: [
            BarChartRodData(
              toY: histogram[bucket]!.toDouble(),
              width: 12,
              gradient: const LinearGradient(
                colors: [Colors.orangeAccent, Colors.redAccent],
              ),
            )
          ],
        ),
      );
    }

    final yValues = histogram.values.map((v) => v.toDouble()).toList();
    final yMin = 0.0;
    final yMax = yValues.isEmpty ? 1 : yValues.reduce((a, b) => a > b ? a : b);
    final yInterval = safeInterval(yMin, yMax.toDouble(), 4);

    return BarChart(
      BarChartData(
        maxY: yMax + yInterval, // slight padding
        barGroups: barGroups,
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              interval: yInterval,
              reservedSize: 40,
              getTitlesWidget: (value, _) => Text(
                value.toInt().toString(),
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, _) {
                final bucket = value.toInt();
                return Text(
                  "$bucket–${bucket + 1}",
                  style: const TextStyle(color: Colors.white, fontSize: 10),
                );
              },
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
      ),
    );
  }
}
