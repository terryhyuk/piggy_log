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
    final theme = Theme.of(context);

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
            ticksTextStyle: TextStyle(color: theme.colorScheme.surface),
            gridBorderData: BorderSide(
              color: Color.lerp(theme.colorScheme.surface, theme.colorScheme.shadow, 0.24)!,
              width: 1.2,
            ),
            radarBorderData: BorderSide(
              color: Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.7)!,
              width: 1.2,
            ),
            borderData: FlBorderData(show: false),
            radarBackgroundColor: Colors.transparent,
            getTitle: (index, angle) {
              // 라벨 텍스트 가져오기
              String label = labels[index];
              
              // 6자가 넘어가면 잘라내고 '...' 추가 (숫자는 앱 디자인에 맞춰 조절하세요)
              if (label.length > 6) {
                label = '${label.substring(0, 5)}..';
              }

              return RadarChartTitle(
                text: label, 
                angle: 0,
              );
            },
            // getTitle: (index, angle) => RadarChartTitle(
            //   text: labels[index],
            //   angle: 0),
            dataSets: [
              RadarDataSet(
                dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                borderColor: theme.colorScheme.primary,
                borderWidth: 2,
                entryRadius: 0,
                fillColor: Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.1)!,
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