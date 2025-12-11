import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';

class ChartsWidget extends StatelessWidget {
  final List<PieChartSectionData>? pieData;
  final Map<String, double>? radarData;
  final void Function(int index)? onTapCategory;

  const ChartsWidget({super.key, this.pieData, this.radarData, this.onTapCategory});

  @override
  Widget build(BuildContext context) {
    // PieChart
    if (pieData != null) {
      return SizedBox(
        height: 250,
        child: PieChart(
          PieChartData(
            sections: pieData!,
            centerSpaceRadius: 40,
            sectionsSpace: 4,
            pieTouchData: PieTouchData(
              touchCallback: (event, response) {
                int index = -1;
                if (response?.touchedSection != null) {
                  index = response!.touchedSection!.touchedSectionIndex;
                }
                if (onTapCategory != null) onTapCategory!(index);
              },
            ),
          ),
        ),
      );
    }

    // RadarChart
    if (radarData != null) {
      final fixed = Map<String, double>.from(radarData!);
      while (fixed.length < 3) fixed[''] = 0.0;

      final values = fixed.values.toList();
      final labels = fixed.keys.toList();

      return SizedBox(
        height: 180,
        child: RadarChart(
          RadarChartData(
            dataSets: [
              RadarDataSet(
                dataEntries: values.map((v) => RadarEntry(value: v)).toList(),
                fillColor: Colors.blue.withOpacity(0.3),
                borderColor: Colors.blue,
                entryRadius: 2,
                borderWidth: 2,
              ),
            ],
            radarShape: RadarShape.polygon,
            radarBackgroundColor: Colors.transparent,
            borderData: FlBorderData(show: false),
            tickCount: 4,
            getTitle: (index, angle) {
              final name = labels[index];
              final value = values[index];
              return RadarChartTitle(
                text: name.isEmpty ? '' : '$name\n${value.toStringAsFixed(1)}',
                // textStyle: const TextStyle(fontSize: 10, color: Colors.black87),
              );
            },
          ),
        ),
      );
    }

    return const SizedBox.shrink();
  }
}

// class ChartsWidget extends StatelessWidget {
//   final List<PieChartSectionData>? pieData;
//   final Map<String, double>? radarData;
//   final void Function(int index)? onTapCategory; // Pie index callback

//   const ChartsWidget({
//     super.key,
//     this.pieData,
//     this.radarData,
//     this.onTapCategory,
//   });

//   @override
//   Widget build(BuildContext context) {
//     // --------------------------
//     // PieChart mode
//     // --------------------------
//     if (pieData != null) {
//       return SizedBox(
//         height: 200,
//         child: PieChart(
//           PieChartData(
//             sections: pieData!,
//             centerSpaceRadius: 40,
//             sectionsSpace: 4,
//             pieTouchData: PieTouchData(
//               touchCallback: (event, response) {
//                 if (!event.isInterestedForInteractions ||
//                     response?.touchedSection == null) return;

//                 final index = response!.touchedSection!.touchedSectionIndex;
//                 if (onTapCategory != null) {
//                   onTapCategory!(index);
//                 }
//               },
//             ),
//           ),
//         ),
//       );
//     }

//     // --------------------------
//     // RadarChart mode
//     // --------------------------
// if (radarData != null) {
//   final Map<String, double> fixed = Map.from(radarData!);
//   while (fixed.length < 3) {
//     fixed[''] = 0.0;
//   }

//   final fixedValues = fixed.values.toList();
//   final fixedLabels = fixed.keys.toList();

//   return SizedBox(
//     height: 180, // RadarChart 크기 조정
//     child: RadarChart(
//       RadarChartData(
//         dataSets: [
//           RadarDataSet(
//             dataEntries: fixedValues.map((v) => RadarEntry(value: v)).toList(),
//             fillColor: Colors.blue,
//             borderColor: Colors.blue,
//             entryRadius: 2,
//             borderWidth: 2,
//           ),
//         ],
//         radarShape: RadarShape.polygon,
//         radarBackgroundColor: Colors.transparent,
//         borderData: FlBorderData(show: false),
//         tickCount: 4,
//         getTitle: (index, angle) {
//           return RadarChartTitle(
//             text: fixedLabels[index],
//           );
//         },
//       ),
//     ),
//   );
// }


//     return const SizedBox.shrink();
//   }
// }

// // class ChartsWidget extends StatelessWidget {
// //   // --------------------------
// //   // Properties
// //   // --------------------------
// //   final List<PieChartSectionData>? pieData;
// //   final Map<String, double>? radarData;
// //   final void Function(int index)? onTapCategory; // Pie index callback

// //   const ChartsWidget({
// //     super.key,
// //     this.pieData,
// //     this.radarData,
// //     this.onTapCategory,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     // --------------------------
// //     // PieChart mode
// //     // --------------------------
// //     if (pieData != null) {
// //       return SizedBox(
// //         height: 200,
// //         child: PieChart(
// //           PieChartData(
// //             sections: pieData!,
// //             centerSpaceRadius: 40,
// //             sectionsSpace: 4,
// //             pieTouchData: PieTouchData(
// //               touchCallback: (event, response) {
// //                 // ignore pointer-up without a valid touched section
// //                 if (!event.isInterestedForInteractions ||
// //                     response?.touchedSection == null) return;

// //                 final index = response!.touchedSection!.touchedSectionIndex;
// //                 if (onTapCategory != null) {
// //                   onTapCategory!(index); // return section index to caller
// //                 }
// //               },
// //             ),
// //           ),
// //         ),
// //       );
// //     }

// //     // --------------------------
// //     // RadarChart mode
// //     // --------------------------
// //     if (radarData != null) {
// //       final values = radarData!.values.toList();
// //       final labels = radarData!.keys.toList();

// //       // protect radar from <3 entries - ensure minimum of 3 entries
// //       final Map<String, double> fixed = Map.from(radarData!);
// //       int dummy = 1;
// //       while (fixed.length < 3) {
// //         fixed['dummy$dummy'] = 0.0;
// //         dummy++;
// //       }

// //       final fixedValues = fixed.values.toList();
// //       final fixedLabels = fixed.keys.toList();

// //       SizedBox(
// //   height: 220,
// //   child: RadarChart(
// //     RadarChartData(
// //       dataSets: [
// //         RadarDataSet(
// //           dataEntries:
// //               fixedValues.map((v) => RadarEntry(value: v)).toList(),
// //           fillColor: Colors.blue,
// //           borderColor: Colors.blue,
// //           entryRadius: 2,
// //           borderWidth: 2,
// //         ),
// //       ],
// //       radarShape: RadarShape.polygon,
// //       radarBackgroundColor: Colors.transparent,
// //       borderData: FlBorderData(show: false),
// //       tickCount: 4,
// //      getTitle: (index, angle) {
// //   return RadarChartTitle(
// //     text: fixedLabels[index],
// //     // textStyle: const TextStyle(
// //     //   color: Colors.black87,
// //     //   fontSize: 11,
// //     // ),
// //   );
// // },
// //     ),
// //   ),
// // );

// //     }

// //     return const SizedBox.shrink();
// //   }
// // }

// // // lib/widgets/charts_widget.dart

// // import 'package:flutter/material.dart';
// // import 'package:fl_chart/fl_chart.dart';

// // class ChartsWidget extends StatelessWidget {
// //   final List<PieChartSectionData> pieData;
// //   final Map<String, double> radarData;

// //   const ChartsWidget({
// //     super.key,
// //     required this.pieData,
// //     required this.radarData,
// //   });

// //   @override
// //   Widget build(BuildContext context) {
// //     final titles = radarData.keys.toList();
// //     final values = radarData.values.toList();

// //     return Column(
// //       children: [
// //         // PieChart
// //         SizedBox(
// //           height: 200,
// //           child: PieChart(
// //             PieChartData(
// //               sections: pieData,
// //               centerSpaceRadius: 45,
// //             ),
// //           ),
// //         ),

// //         const SizedBox(height: 24),

// //         // RadarChart
// //         SizedBox(
// //           height: 220,
// //           child: RadarChart(
// //             RadarChartData(
// //               dataSets: [
// //                 RadarDataSet(
// //                   dataEntries:
// //                       values.map((v) => RadarEntry(value: v)).toList(),
// //                   fillColor: Colors.blue,
// //                   borderColor: Colors.blue,
// //                   borderWidth: 2,
// //                 )
// //               ],
// //               radarShape: RadarShape.polygon,
// //               radarBackgroundColor: Colors.transparent,
// //               borderData: FlBorderData(show: false),
// //               tickCount: 4,
// //               titleTextStyle:
// //                   const TextStyle(color: Colors.white, fontSize: 11),
// //             ),
// //           ),
// //         ),
// //       ],
// //     );
// //   }
// // }
