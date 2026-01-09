import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:piggy_log/features/dashboard/presentation/radar_chart_page.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';

class ChartsWidget extends StatelessWidget {
  const ChartsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DashboardProvider>();
    final settings = context.watch<SettingProvider>();
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;

    if (provider.categoryList.isEmpty) {
      return SizedBox(height: 250, child: Center(child: Text(l10n.noTransactions)));
    }

    final int? selectedIndex = provider.selectedPieIndex;
    // Current date range from provider
    final String dateRange = "${provider.startDate} ~ ${provider.endDate}";

    return AspectRatio(
      aspectRatio: 1.3,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PieChart(
            PieChartData(
              pieTouchData: PieTouchData(
                touchCallback: (event, response) {
                  if (event is FlTapUpEvent) {
                    if (response != null && response.touchedSection != null) {
                      int newIndex = response.touchedSection!.touchedSectionIndex;
                      // Error prevention: validate index range
                      if (newIndex >= 0 && newIndex < provider.categoryList.length) {
                        provider.selectCategoryForAnalysis(newIndex);
                      } else {
                        provider.selectCategoryForAnalysis(null);
                      }
                    } else {
                      provider.selectCategoryForAnalysis(null);
                    }
                  }
                },
              ),
              borderData: FlBorderData(show: false),
              sectionsSpace: 3,
              centerSpaceRadius: 95, 
              sections: _makePieData(selectedIndex, provider),
            ),
          ),
          
          // --- Center Information Display ---
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (selectedIndex != null && selectedIndex < provider.categoryList.length) ...[
                // 1. Display Category Name
                Text(
                  provider.categoryList[selectedIndex]['name'] ?? '',
                  style: TextStyle(
                    fontSize: 14, 
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                // 2. Display Date Range even when selected
                Text(
                  dateRange,
                  style: TextStyle(
                    fontSize: 10,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                // 3. Display Category Total
                Text(
                  settings.formatCurrency((provider.categoryList[selectedIndex]['total_expense'] as num).toDouble()),
                  style: TextStyle(
                    fontSize: 20, 
                    fontWeight: FontWeight.bold, 
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(height: 8),
                _buildAnalysisButton(context, l10n),
              ] else ...[
                // Default view (Total Expense)
                Text(l10n.totalExpense, style: const TextStyle(fontSize: 14)),
                Text(
                  dateRange,
                  style: TextStyle(
                    fontSize: 11,
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.4),
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  settings.formatCurrency(provider.totalExpense),
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAnalysisButton(BuildContext context, AppLocalizations l10n) {
    return ElevatedButton(
      onPressed: () => Navigator.push(
        context, 
        MaterialPageRoute(builder: (_) => const RadarChartPage()),
      ),
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(l10n.viewAnalysis, style: const TextStyle(fontSize: 11)),
    );
  }

  List<PieChartSectionData> _makePieData(int? selectedIndex, DashboardProvider provider) {
    return provider.categoryList.asMap().entries.map((entry) {
      int index = entry.key;
      double value = (entry.value['total_expense'] as num).toDouble();
      bool isSelected = selectedIndex == index;
      double percent = provider.totalExpense > 0 ? (value / provider.totalExpense) * 100 : 0;

      return PieChartSectionData(
        value: value,
        title: isSelected ? "${percent.toStringAsFixed(1)}%" : "",
        radius: isSelected ? 35 : 25,
        color: provider.categoryColors[index % provider.categoryColors.length],
        titleStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();
  }

}// END