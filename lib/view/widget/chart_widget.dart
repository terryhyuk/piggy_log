import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class ChartsWidget extends StatelessWidget {
  final List top3;
  final int? selectedPieIndex;
  final void Function(int index) onTapCategory;
  final String Function(dynamic) formatCurrency;
  
  final DashboardController dashbordcontroller;

  const ChartsWidget({
    super.key,
    required this.top3,
    required this.selectedPieIndex,
    required this.onTapCategory,
    required this.formatCurrency,
    required this.dashbordcontroller
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (dashbordcontroller.categoryList.isEmpty) {
      return Center(child: Text(AppLocalizations.of(context)!.noTransactions));
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. 왼쪽 파이 차트 (기존 로직 그대로)
        Expanded(
          flex: 3,
          child: AspectRatio(
            aspectRatio: 1,
            child: PieChart(
              PieChartData(
                sections: dashbordcontroller.makePieData(selectedIndex: selectedPieIndex),
                centerSpaceRadius: 40,
                sectionsSpace: 4,
                pieTouchData: PieTouchData(
                  touchCallback: (event, response) {
                    if (event is! FlTapUpEvent) return;
                    final index = response?.touchedSection?.touchedSectionIndex ?? -1;
                    onTapCategory(index);
                  },
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // 2. 오른쪽 Top 3 & 레이더 차트 (대시보드에서 이사 온 놈들)
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...top3.asMap().entries.map((entry) {
                final item = entry.value;
                final color = dashbordcontroller.categoryColors[entry.key % dashbordcontroller.categoryColors.length];
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    '${item['name']}\n${formatCurrency(item['total'])}',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: color),
                  ),
                );
              }),
              const SizedBox(height: 12),
              
              Obx(() {
                final radarData = Map<String, double>.from(dashbordcontroller.selectedBreakdown);
                if (radarData.isEmpty) return const SizedBox.shrink();

                final labels = radarData.keys.toList();
                final values = radarData.values.toList();
                while (values.length < 3) {
                  values.add(0);
                  labels.add("");
                }

                return SizedBox(
                  height: 150,
                  child: RadarChart(
                    RadarChartData(
                      // === 여기서부터는 테리님 기존 RadarChart 설정 복붙! ===
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
                        String label = labels[index];
                        if (label.length > 6) {
                          label = '${label.substring(0, 5)}..';
                        }
                        return RadarChartTitle(text: label, angle: 0);
                      },
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
              }),
            ],
          ),
        ),
      ],
    );
  }
}
// import 'package:flutter/material.dart';
// import 'package:fl_chart/fl_chart.dart';

// class ChartsWidget extends StatelessWidget {
//   final List<PieChartSectionData>? pieData;
//   final Map<String, double>? radarData;
//   final void Function(int index)? onTapCategory;

//   const ChartsWidget({
//     super.key,
//     this.pieData,
//     this.radarData,
//     this.onTapCategory,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);

//     if (pieData != null) {
//       return AspectRatio(
//         aspectRatio: 1,
//         child: PieChart(
//           PieChartData(
//             sections: pieData!,
//             centerSpaceRadius: 40,
//             sectionsSpace: 4,
//             pieTouchData: PieTouchData(
//               touchCallback: (event, response) {
//                 if (event is! FlTapUpEvent) return;
//                 final index = response?.touchedSection?.touchedSectionIndex ?? -1;
//                 onTapCategory?.call(index);
//               },
//             ),
//           ),
//         ),
//       );
//     }

//     if (radarData != null) {
//       final labels = radarData!.keys.toList();
//       final values = radarData!.values.toList();

//       while (values.length < 3) {
//         values.add(0);
//         labels.add("");
//       }

//       return SizedBox(
//         height: 180,
//         child: RadarChart(
//           RadarChartData(
//             ticksTextStyle: TextStyle(color: theme.colorScheme.surface),
//             gridBorderData: BorderSide(
//               color: Color.lerp(theme.colorScheme.surface, theme.colorScheme.shadow, 0.24)!,
//               width: 1.2,
//             ),
//             radarBorderData: BorderSide(
//               color: Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.7)!,
//               width: 1.2,
//             ),
//             borderData: FlBorderData(show: false),
//             radarBackgroundColor: Colors.transparent,
//             getTitle: (index, angle) {
//               // 라벨 텍스트 가져오기
//               String label = labels[index];
              
//               // 6자가 넘어가면 잘라내고 '...' 추가 (숫자는 앱 디자인에 맞춰 조절하세요)
//               if (label.length > 6) {
//                 label = '${label.substring(0, 5)}..';
//               }

//               return RadarChartTitle(
//                 text: label, 
//                 angle: 0,
//               );
//             },
//             // getTitle: (index, angle) => RadarChartTitle(
//             //   text: labels[index],
//             //   angle: 0),
//             dataSets: [
//               RadarDataSet(
//                 dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
//                 borderColor: theme.colorScheme.primary,
//                 borderWidth: 2,
//                 entryRadius: 0,
//                 fillColor: Color.lerp(theme.colorScheme.surface, theme.colorScheme.primary, 0.1)!,
//               ),
//             ],
//             radarShape: RadarShape.polygon,
//           ),
//         ),
//       );
//     }

//     return const SizedBox.shrink();
//   }
// }