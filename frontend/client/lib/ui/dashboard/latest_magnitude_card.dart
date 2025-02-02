import 'base_stat_card.dart';
import '../../models/earthquake.dart';

class LatestMagnitudeCard extends BaseStatCard {
  LatestMagnitudeCard({required String title}) : super(title: title);

  @override
  String calculateValue(List<Earthquake> earthquakes) {
    if (earthquakes.isEmpty) return "0.00";

    return (earthquakes.first.data.properties.mag).toStringAsFixed(2);
  }
}
