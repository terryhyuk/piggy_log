import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartsWidget extends StatelessWidget {
  final List<PieChartSectionData>? pieData;
  final Map<String, double>? radarData;
  final void Function(int index)? onTapCategory;

  const ChartsWidget({
    super.key,
    this.pieData,
    this.radarData,
    this.onTapCategory,
  });

  @override
  Widget build(BuildContext context) {
    if (pieData != null) {
      return AspectRatio(
        aspectRatio: 1,
        child: PieChart(
          PieChartData(
            sections: pieData!,
            centerSpaceRadius: 40,
            sectionsSpace: 4,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                if (event is! FlTapUpEvent) return;
                final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                onTapCategory?.call(index);
              },
            ),
          ),
        ),
      );
    }

    if (radarData != null) {
      final labels = radarData!.keys.toList();
      final values = radarData!.values.toList();

      while (values.length < 3) {
        values.add(0);
        labels.add("");
      }

      return SizedBox(
        height: 180,
        child: RadarChart(
          RadarChartData(
            ticksTextStyle: const TextStyle(color: Colors.transparent),
            gridBorderData: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white24
            : Colors.black26,
              width: 1.2,
              ),
            radarBorderData: BorderSide(
              color: Theme.of(context).brightness == Brightness.dark
            ? Colors.white70
            : Colors.black87, 
              width: 1.2,
              ),
            borderData: FlBorderData(show: false),
            radarBackgroundColor: Colors.transparent,
            getTitle: (index, angle) => RadarChartTitle(
              text: labels[index], 
              angle: 0),
            dataSets: [
              RadarDataSet(
                dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                borderColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.lightBlueAccent
              : Colors.blueAccent,
                borderWidth: 2,
                entryRadius: 0,
                fillColor: (Theme.of(context).brightness == Brightness.dark
                  ? Colors.lightBlueAccent
                  : Colors.blueAccent)
              .withAlpha(40),
              ),
            ],
            radarShape: RadarShape.polygon,
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}