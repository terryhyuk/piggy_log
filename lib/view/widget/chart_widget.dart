import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/radar_chart_page.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Visualizing expenditure distribution via an interactive Pie Chart.
//    Integrates touch feedback to provide contextual information and 
//    shortcuts to detailed analytics (Radar Chart).
//
//  * TODO: 
//    - Extract the 'Center Information Window' into a separate stateless widget.
//    - Implement animations for smoother transitions between selected slices.
// -----------------------------------------------------------------------------

class ChartsWidget extends StatefulWidget {
  const ChartsWidget({super.key});

  @override
  State<ChartsWidget> createState() => _ChartsWidgetState();
}

class _ChartsWidgetState extends State<ChartsWidget> {
  final DashboardController dashbordcontroller = Get.find<DashboardController>();
  final SettingController settingsController = Get.find<SettingController>();

  int? selectedPieIndex;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Obx(() {
      if (dashbordcontroller.categoryList.isEmpty) {
        return SizedBox(
          height: 250,
          child: Center(child: Text(l10n.noTransactions)),
        );
      }

      return Column(
        children: [
          // --- [Pie Chart Section] ---
          Stack(
            alignment: Alignment.center,
            children: [
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: _makePieData(selectedPieIndex),
                    centerSpaceRadius: 85,
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent) {
                          int? newIndex;
                          if (pieTouchResponse != null &&
                              pieTouchResponse.touchedSection != null) {
                            newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          } else {
                            newIndex = null;
                          }
                          setState(() {
                            selectedPieIndex = newIndex;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),
              
              // Center Information Panel
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (selectedPieIndex != null &&
                      dashbordcontroller.getSelectedCategoryName(selectedPieIndex).isNotEmpty) ...[
                    Text(
                      dashbordcontroller.getSelectedCategoryName(selectedPieIndex),
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                      ),
                    ),
                    const SizedBox(height: 4),
                  ],
                  if (selectedPieIndex != null &&
                      dashbordcontroller.getSelectedCategoryAmount(selectedPieIndex) != null) ...[
                    Text(
                      settingsController.formatCurrency(
                          dashbordcontroller.getSelectedCategoryAmount(selectedPieIndex)!),
                      style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(height: 12),
                    _buildAnalysisButton(), 
                  ] else ...[
                    Text(
                      AppLocalizations.of(context)!.selectCategory,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          
          const SizedBox(height: 20),
        ],
      );
    });
  }

  /// Builds the "View Analysis" button located in the center of the pie chart.
  Widget _buildAnalysisButton() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (selectedPieIndex != null) {
            dashbordcontroller.selectedPieIndex.value = selectedPieIndex;
            await dashbordcontroller.loadRadarData(selectedPieIndex!);
            Get.to(() => const RadarChartPage());
          }
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.viewAnalysis,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: theme.colorScheme.onPrimaryContainer,
                ),
              ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_right,
                  size: 14, color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }

  /// Generates segments for the Pie Chart based on dynamic data.
  List<PieChartSectionData> _makePieData(int? selectedIndex) {
    double total = dashbordcontroller.totalExpense.value;

    return dashbordcontroller.categoryList.asMap().entries.map((entry) {
      int index = entry.key;
      var data = entry.value;
      double value = (data['total_expense'] as num).toDouble();
      bool isSelected = selectedIndex == index;

      final double percentage = total > 0 ? (value / total) * 100 : 0;

      return PieChartSectionData(
        value: value,
        title: isSelected ? "${percentage.toStringAsFixed(1)}%" : "",
        radius: isSelected ? 35 : 25,
        color: dashbordcontroller.categoryColors[index % dashbordcontroller.categoryColors.length],
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }
}