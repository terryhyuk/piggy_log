import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/radar_chart_page.dart'; 

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
      // 💡 데이터가 없을 때의 처리
      if (dashbordcontroller.categoryList.isEmpty) {
        return SizedBox(
          height: 250,
          child: Center(
            child: Text(l10n.noTransactions),
          ),
        );
      }

      return Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // 1. Pie Chart Layer
              AspectRatio(
                aspectRatio: 1.3,
                child: PieChart(
                  PieChartData(
                    sections: _makePieData(selectedPieIndex),
                    centerSpaceRadius: 85, // 💡 중앙 버튼과 텍스트를 위한 공간
                    sectionsSpace: 3,
                    pieTouchData: PieTouchData(
                      // 터치 인식 범위를 늘려 시뮬레이터 클릭 미스 방지
                      // touchExtraThreshold: 10,
                      touchCallback: (FlTouchEvent event, pieTouchResponse) {
                        if (event is FlTapUpEvent) {
                          int? newIndex;
                          if (pieTouchResponse != null && pieTouchResponse.touchedSection != null) {
                            newIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                          } else {
                            newIndex = null;
                          }
                          // 로컬 상태 업데이트
                          setState(() {
                            selectedPieIndex = newIndex;
                          });
                        }
                      },
                    ),
                  ),
                ),
              ),

              // 2. Center Information Layer (Name, Amount, and Button)
              // 💡 버튼을 중앙 레이어에 배치하여 터치 충돌을 원천 차단합니다.
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
                        dashbordcontroller.getSelectedCategoryAmount(selectedPieIndex)!
                      ),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold, 
                        color: theme.colorScheme.primary
                      ),
                    ),
                    const SizedBox(height: 12),
                    
                    // 💡 분석보기 버튼을 중앙에 고정
                    _buildAnalysisButton(),
                  ] else ...[
                    // 💡 아무것도 선택되지 않았을 때 안내 문구 (선택 사항)
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
        ],
      );
    });
  }

  /// Generates the visual slices of the Pie Chart.
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
        titleStyle: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        // 💡 Badge를 제거하여 터치 레이어 간섭 방지
        badgeWidget: null,
      );
    }).toList();
  }

  /// Builds the "View Analysis" button located in the center of the chart.
  Widget _buildAnalysisButton() {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () async {
          if (selectedPieIndex != null) {
            // 컨트롤러에 선택 정보 동기화 및 데이터 로드
            dashbordcontroller.selectedPieIndex.value = selectedPieIndex;
            await dashbordcontroller.loadRadarData(selectedPieIndex!);
            
            // 레이더 차트 페이지로 이동
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
              Icon(Icons.chevron_right, size: 14, color: theme.colorScheme.onPrimaryContainer),
            ],
          ),
        ),
      ),
    );
  }
}
