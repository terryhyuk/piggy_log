import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/widget/animated_piggy_message.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Advanced analytical dashboard utilizing multi-dimensional charts.
//    Implements a 'Storytelling UX' via a sequential messaging system 
//    (PiggyTalk) and minimalist data visualization for high readability.
//
//  * TODO: 
//    - Export chart as Image/PDF for user sharing features.
//    - Add a comparison layer (e.g., Previous Month vs Current) on the Radar Chart.
// -----------------------------------------------------------------------------

class RadarChartPage extends StatefulWidget {
  const RadarChartPage({super.key});

  @override
  State<RadarChartPage> createState() => _RadarChartPageState();
}

class _RadarChartPageState extends State<RadarChartPage> {
  final DashboardController controller = Get.find<DashboardController>();
  final SettingController settingsController = Get.find<SettingController>();

  // State Management for Character Animation
  String _currentPiggyMessage = "";
  bool _isAnimating = false;
  bool _hasFinishedTalking = false;

  /// PiggyTalk Engine: Orchestrates a multi-step analysis commentary.
  void _startPiggyTalk(AppLocalizations l10n) async {
    // Prevent overlapping animation sequences.
    if (_isAnimating || _hasFinishedTalking) return;
    
    _isAnimating = true;

    final messages = [
      l10n.analysisStep1,
      l10n.analysisStep2,
      l10n.analysisStep3,
    ];

    for (int i = 0; i < messages.length; i++) {
      if (mounted) {
        setState(() => _currentPiggyMessage = messages[i]);
      }
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    if (mounted) {
      setState(() {
        _currentPiggyMessage = "";
        _hasFinishedTalking = true;
      });
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

        if (categoryId == null) return const Center(child: CircularProgressIndicator());

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.handler.getCategoryDetailedList(categoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());

            final detailedList = snapshot.data!;
            if (detailedList.isEmpty) return Center(child: Text(l10n.noTransactions));

            // Data Transformation: Aggregates expenditure per weekday.
            List<double> daySums = List.filled(7, 0.0);
            for (var t in detailedList) {
              try {
                final date = DateTime.parse(t['date']);
                daySums[date.weekday - 1] += (t['amount'] as num).toDouble();
              } catch (e) {
                // Ignore parsing errors for corrupted date strings.
              }
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildSectionTitle(l10n.categoryBalance, theme),
                  const SizedBox(height: 12),
                  _buildRadarCard(theme),

                  const SizedBox(height: 20),

                  // Mascot Interaction: Triggered automatically upon reaching data threshold.
                  if (detailedList.length >= 10)
                    Builder(
                      builder: (context) {
                        if (_currentPiggyMessage.isEmpty && !_isAnimating && !_hasFinishedTalking) {
                          WidgetsBinding.instance.addPostFrameCallback((_) => _startPiggyTalk(l10n));
                        }
                        return AnimatedPiggyMessage(message: _currentPiggyMessage);
                      },
                    ),

                  const SizedBox(height: 20),

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

  // --- UI Architecture Components ---

  Widget _buildRadarCard(ThemeData theme) {
    /// Minimalist Radar Configuration: Ticks and default labels removed for cleaner UX.
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
              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
              gridBorderData: BorderSide(color: theme.dividerColor.withAlpha(25), width: 1),
              radarBorderData: BorderSide(color: theme.colorScheme.primary.withAlpha(76), width: 1),
              dataSets: [
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
                return RadarChartTitle(text: label.length > 6 ? '${label.substring(0, 5)}..' : label);
              },
              radarShape: RadarShape.polygon,
              tickCount: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartCard(ThemeData theme, List<double> daySums) {
    /// Adaptive Scaling: Dynamically adjusts maxY to prevent bar overflow.
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
                      TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
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
                          style: TextStyle(fontSize: 10, color: theme.colorScheme.onSurface.withValues(alpha: 0.5)),
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

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
    );
  }
}