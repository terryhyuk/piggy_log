import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:piggy_log/core/widget/mascot/animated_piggy_message.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class RadarChartPage extends StatefulWidget {
  const RadarChartPage({super.key});

  @override
  State<RadarChartPage> createState() => _RadarChartPageState();
}

class _RadarChartPageState extends State<RadarChartPage> {
  String _currentPiggyMessage = "";
  bool _isAnimating = false;
  bool _hasFinishedTalking = false;

  /// Handles the piggy's sequential talk and graceful exit.
  void _startPiggyTalk(AppLocalizations l10n) async {
    if (_isAnimating || _hasFinishedTalking) return;
    _isAnimating = true;

    final messages = [
      l10n.analysisStep1,
      l10n.analysisStep2,
      l10n.analysisStep3,
    ];

    // [Step 1] Sequential Messaging
    for (int i = 0; i < messages.length; i++) {
      if (mounted) {
        _currentPiggyMessage = messages[i];
        setState(() {});
      }
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    // [Step 2] Speech bubble disappears first
    // Setting to empty string triggers the bubble's fade-out in AnimatedPiggyMessage.
    if (mounted) {
      _currentPiggyMessage = "";
      setState(() {});
    }

    // [Step 3] Lingering Time
    // Piggy continues bouncing alone without the speech bubble for 2 seconds.
    await Future.delayed(const Duration(milliseconds: 2000));

    // [Step 4] Final Clean-up
    // Piggy finally disappears from the screen.
    if (mounted) {
        _hasFinishedTalking = true;
      setState(() {});
    }
    _isAnimating = false;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    final provider = context.watch<DashboardProvider>();
    final settings = context.watch<SettingProvider>(); 

    final int? selectedIndex = provider.selectedPieIndex;
    final String categoryName = (selectedIndex != null && selectedIndex < provider.categoryList.length)
        ? provider.categoryList[selectedIndex]['name'] ?? ""
        : "";

    // Assuming we use the category-specific list for the data point check
    final detailedList = provider.recentTransactions;

    return Scaffold(
      appBar: AppBar(
        title: Text("$categoryName ${l10n.spendingAnalysis}"),
        centerTitle: true,
      ),
      body: provider.radarDataEntries.isEmpty 
          ? Center(child: Text(l10n.noTransactions))
          : SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  _buildSectionTitle(l10n.categoryBalance, theme),
                  const SizedBox(height: 12),
                  _buildRadarCard(theme, provider),

                  const SizedBox(height: 20),
                  
                  // --- [Piggy Mascot Layer] ---
                  // Show if data is sufficient (5+) and not completely finished.
                  if (detailedList.length >= 5 && !_hasFinishedTalking)
                    Builder(
                      builder: (context) {
                        // Start talking once if it hasn't started and no message is currently set.
                        if (_currentPiggyMessage.isEmpty && !_isAnimating) {
                          WidgetsBinding.instance.addPostFrameCallback(
                            (_) => _startPiggyTalk(l10n)
                          );
                        }
                        
                        return AnimatedPiggyMessage(
                          message: _currentPiggyMessage,
                        );
                      },
                    ),

                  const SizedBox(height: 20),
                  _buildSectionTitle(l10n.weeklySpendingTrend, theme),
                  const SizedBox(height: 12),
                  _buildBarChartCard(theme, provider.weeklySpendingTrend, settings),
                  const SizedBox(height: 50),
                ],
              ),
            ),
    );
  }

  // --- Chart Building Logic ---

  Widget _buildRadarCard(ThemeData theme, DashboardProvider provider) {
    final entries = provider.radarDataEntries;
    final labels = provider.radarLabels;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 15),
        child: AspectRatio(
          aspectRatio: 1.2,
          child: RadarChart(
            RadarChartData(
              isMinValueAtCenter: false,
              ticksTextStyle: const TextStyle(color: Colors.transparent, fontSize: 0),
              tickBorderData: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.3),
                width: 1,
              ),
              gridBorderData: BorderSide(
                color: theme.dividerColor.withValues(alpha: 0.25), 
                width: 1,
                ),
              radarBorderData: BorderSide(
                color: theme.colorScheme.primary.withValues(alpha: 0.4), 
                width: 1,
                ),
              dataSets: [
                RadarDataSet(
                  fillColor: Colors.transparent,
                  borderColor: Colors.transparent,
                  entryRadius: 0,
                  dataEntries: List.generate(entries.length, (_) => const RadarEntry(value: 100)),
                ),
                RadarDataSet(
                  dataEntries: entries,
                  borderColor: theme.colorScheme.primary,
                  borderWidth: 3,
                  entryRadius: 4,
                  fillColor: theme.colorScheme.primary.withValues(alpha: 0.2),
                ),
              ],
              getTitle: (index, angle) {
                if (index >= labels.length) return const RadarChartTitle(text: '');
                String label = labels[index];
                return RadarChartTitle(
                  text: label.length > 6 ? '${label.substring(0, 5)}..' : label,
                );
              },
              radarShape: RadarShape.polygon,
              tickCount: 3,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBarChartCard(ThemeData theme, List<double> daySums, SettingProvider settings) {
    double maxVal = daySums.isEmpty ? 0 : daySums.reduce((a, b) => a > b ? a : b);
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
                      settings.formatCurrency(rod.toY),
                      TextStyle(color: theme.colorScheme.onSecondaryContainer, fontWeight: FontWeight.bold),
                    );
                  },
                ),
              ),
              titlesData: FlTitlesData(
                show: true,
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                      return Text(days[value.toInt()], style: const TextStyle(fontSize: 10));
                    },
                  ),
                ),
                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              gridData: const FlGridData(show: false),
              borderData: FlBorderData(show: false),
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