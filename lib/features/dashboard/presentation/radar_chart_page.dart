import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/core/widget/mascot/animated_piggy_message.dart';
import 'package:piggy_log/features/dashboard/controller/dashboard_controller.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

/// RadarChartPage: Provides a detailed spending analysis for a specific category.
/// It features a Radar Chart for internal balance, an animated piggy guide,
/// and a Bar Chart for weekly spending trends.
class RadarChartPage extends StatefulWidget {
  const RadarChartPage({super.key});

  @override
  State<RadarChartPage> createState() => _RadarChartPageState();
}

class _RadarChartPageState extends State<RadarChartPage> {
  DashboardController get controller => Get.find<DashboardController>();
  SettingController get settingsController => Get.find<SettingController>();

  // Managing animation state for the piggy character
  String _currentPiggyMessage = "";
  bool _isAnimating = false;
  bool _hasFinishedTalking = false;

  /// Rotates analysis messages sequentially to create a conversational feel.
  void _startPiggyTalk(AppLocalizations l10n) async {
    if (_isAnimating || _hasFinishedTalking) return;
    _isAnimating = true;

    final messages = [
      l10n.analysisStep1,
      l10n.analysisStep2,
      l10n.analysisStep3,
    ];

    for (int i = 0; i < messages.length; i++) {
      if (mounted) {
        _currentPiggyMessage = messages[i];
        setState(() {});
      }
      // Delay to allow users to read each step
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    if (mounted) {
        _currentPiggyMessage = "";
        _hasFinishedTalking = true;
      setState(() {});
    }
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${controller.getSelectedCategoryName(controller.selectedPieIndex.value)} ${l10n.spendingAnalysis}",
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        final int? categoryId = controller.selectedPieIndex.value != null
            ? controller.categoryList[controller.selectedPieIndex.value!]['id']
            : null;

        if (categoryId == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.handler.getCategoryDetailedList(categoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final detailedList = snapshot.data!;
            if (detailedList.isEmpty) {
              return Center(child: Text(l10n.noTransactions));
            }

            // Calculate weekly spending totals for the Bar Chart
            List<double> daySums = List.filled(7, 0.0);
            for (var t in detailedList) {
              try {
                final date = DateTime.parse(t['date']);
                // DateTime.weekday returns 1 (Mon) to 7 (Sun)
                daySums[date.weekday - 1] += (t['amount'] as num).toDouble();
              } catch (e) {
                debugPrint("Date Parsing Error: ${t['date']} - $e");
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // Section 1: Radar Chart for Internal Balance
                  _buildSectionTitle(l10n.categoryBalance, theme),
                  const SizedBox(height: 12),
                  _buildRadarCard(theme),

                  const SizedBox(height: 20),

                  // Section 2: Animated Character Interaction
                  // Triggers analysis when there are enough data points (10+)
                  if (detailedList.length >= 10)
                    Builder(
                      builder: (context) {
                        if (_currentPiggyMessage.isEmpty &&
                            !_isAnimating &&
                            !_hasFinishedTalking) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _startPiggyTalk(l10n),
                          );
                        }
                        return AnimatedPiggyMessage(
                          message: _currentPiggyMessage,
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // Section 3: Bar Chart for Weekly Spending Trend
                  _buildSectionTitle(l10n.weeklySpendingTrend, theme),
                  const SizedBox(height: 12),
                  _buildBarChartCard(theme, daySums),

                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  /// Builds a Radar Chart Card with normalized scaling.
  Widget _buildRadarCard(ThemeData theme) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: AspectRatio(
          aspectRatio: 1.2,
          child: RadarChart(
            RadarChartData(
              isMinValueAtCenter: false, // Prevents tiny values from sticking to center
              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
              gridBorderData: BorderSide(color: theme.dividerColor.withAlpha(25), width: 1),
              radarBorderData: BorderSide(color: theme.colorScheme.primary.withAlpha(76), width: 1),
              dataSets: [
                // Background Guide: Forces the chart scale to 100
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  entryRadius: 0,
                  dataEntries: List.generate(5, (_) => const RadarEntry(value: 100)),
                ),
                // Main Data: The actual expense balance
                RadarDataSet(
                  dataEntries: controller.radarDataEntries,
                  borderColor: theme.colorScheme.primary,
                  borderWidth: 3,
                  entryRadius: 4,
                  fillColor: theme.colorScheme.primary.withAlpha(51),
                ),
              ],
              getTitle: (index, angle) {
                if (index >= controller.radarLabels.length) return const RadarChartTitle(text: '');
                String label = controller.radarLabels[index];
                // Truncate labels to ensure fit within the grid
                return RadarChartTitle(
                  text: label.length > 6 ? '${label.substring(0, 5)}..' : label,
                );
              },
              radarShape: RadarShape.polygon,
              tickCount: 3,
              tickBorderData: const BorderSide(color: Colors.transparent),
            ),
          ),
        ),
      ),
    );
  }

  /// Builds a Bar Chart Card representing weekly trends.
  Widget _buildBarChartCard(ThemeData theme, List<double> daySums) {
    double maxVal = daySums.reduce((a, b) => a > b ? a : b);
    double maxY = maxVal == 0 ? 10000 : maxVal * 1.3;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(top: 30, bottom: 20, left: 10, right: 10),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceAround,
              maxY: maxY,
              barTouchData: BarTouchData(
                touchTooltipData: BarTouchTooltipData(
                  getTooltipColor: (group) => theme.colorScheme.secondaryContainer,
                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                    return BarTooltipItem(
                      settingsController.formatCurrency(rod.toY),
                      TextStyle(
                        color: theme.colorScheme.onSecondaryContainer,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          days[value.toInt()],
                          style: TextStyle(
                            fontSize: 10,
                            color: theme.colorScheme.onSurface.withValues(alpha: 0.5),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              barGroups: List.generate(7, (i) {
                return BarChartGroupData(
                  x: i,
                  barRods: [
                    BarChartRodData(
                      toY: daySums[i],
                      color: theme.colorScheme.primary,
                      width: 16,
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxY,
                        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  /// Reusable section title widget for consistent UI.
  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
      ),
    );
  }
}