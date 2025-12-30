import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class RadarChartPage extends StatefulWidget {
  const RadarChartPage({super.key});

  @override
  State<RadarChartPage> createState() => _RadarChartPageState();
}

class _RadarChartPageState extends State<RadarChartPage>
    with SingleTickerProviderStateMixin {
  final DashboardController controller = Get.find<DashboardController>();
  final SettingController settingsController = Get.find<SettingController>();

  late AnimationController _pigController;
  late Animation<Offset> _pigAnimation;

  // State for sequential message control
  String _currentPiggyMessage = "";
  bool _isAnimating = false;
  bool _hasFinishedTalking = false;

  @override
  void initState() {
    super.initState();
    // Bouncy animation for the piggy
    _pigController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pigAnimation =
        Tween<Offset>(
          begin: const Offset(0, 0),
          end: const Offset(0, -0.2),
        ).animate(
          CurvedAnimation(parent: _pigController, curve: Curves.easeOutQuad),
        );
  }

  @override
  void dispose() {
    _pigController.dispose();
    super.dispose();
  }

  // Logic to rotate messages and then clear everything
  void _startPiggyTalk(AppLocalizations l10n) async {
    if (_isAnimating || _hasFinishedTalking) return;
    _isAnimating = true;

    final messages = [
      l10n.analysisStep1,
      l10n.analysisStep2,
      l10n.analysisStep3,
    ];

    for (var msg in messages) {
      if (mounted) {
        setState(() {
          _currentPiggyMessage = msg;
        });
      }
      // Duration to read each message
      await Future.delayed(const Duration(milliseconds: 2500));
    }

    // After all messages, clear the message to trigger the exit animation
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

        if (categoryId == null)
          return const Center(child: CircularProgressIndicator());

        return FutureBuilder<List<Map<String, dynamic>>>(
          future: controller.handler.getCategoryDetailedList(categoryId),
          builder: (context, snapshot) {
            if (!snapshot.hasData)
              return const Center(child: CircularProgressIndicator());

            final detailedList = snapshot.data!;
            if (detailedList.isEmpty)
              return Center(child: Text(l10n.noTransactions));

            // Weekly data processing
            List<double> daySums = List.filled(7, 0.0);
            for (var t in detailedList) {
              try {
                final date = DateTime.parse(t['date']);
                daySums[date.weekday - 1] += (t['amount'] as num).toDouble();
              } catch (e) {}
            }
            final List<FlSpot> weeklySpots = List.generate(
              7,
              (i) => FlSpot(i.toDouble(), daySums[i]),
            );

            bool showPiggy = detailedList.length >= 10;

            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  // --- 1. Radar Chart ---
                  _buildSectionTitle(l10n.categoryBalance, theme),
                  const SizedBox(height: 12),
                  _buildRadarCard(theme),

                  const SizedBox(height: 20),

                  // --- 2. Animated Piggy & Bubble (Disappears together) ---
                  if (showPiggy)
                    Builder(
                      builder: (context) {
                        // 💡 빌드가 끝난 '후'에 애니메이션을 시작하도록 예약!
                        // Starting the animation AFTER the build phase to avoid setState errors.
                        if (_currentPiggyMessage.isEmpty &&
                            !_isAnimating &&
                            !_hasFinishedTalking) {
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _startPiggyTalk(l10n);
                          });
                        }
                        return _buildAnimatedPiggySection(
                          _currentPiggyMessage,
                          theme,
                        );
                      },
                    ),

                  const SizedBox(height: 20),

                  // --- 3. Line Chart ---
                  _buildSectionTitle(l10n.weeklySpendingTrend, theme),
                  const SizedBox(height: 12),
                  _buildLineChartCard(theme, weeklySpots),

                  const SizedBox(height: 50),
                ],
              ),
            );
          },
        );
      }),
    );
  }

  // --- Helper Widget: Piggy + Bubble with Exit Animation ---
  Widget _buildAnimatedPiggySection(String message, ThemeData theme) {
    bool isVisible = message.isNotEmpty;

    return AnimatedSize(
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOut,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 500),
        opacity: isVisible ? 1.0 : 0.0,
        child: isVisible
            ? Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SlideTransition(
                      position: _pigAnimation,
                      child: Image.asset(
                        'images/pig_happy.png',
                        width: 60,
                        height: 60,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: Container(
                          key: ValueKey<String>(message),
                          margin: const EdgeInsets.only(left: 10, top: 10),
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primaryContainer,
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(4),
                              topRight: Radius.circular(20),
                              bottomRight: Radius.circular(20),
                              bottomLeft: Radius.circular(20),
                            ),
                          ),
                          child: Text(
                            message,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              )
            : const SizedBox(width: double.infinity, height: 0),
      ),
    );
  }

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
              ticksTextStyle: const TextStyle(
                color: Colors.transparent,
                fontSize: 0,
              ),
              gridBorderData: BorderSide(
                color: theme.dividerColor.withAlpha(25),
                width: 1,
              ),
              radarBorderData: BorderSide(
                color: theme.colorScheme.primary.withAlpha(76),
                width: 1,
              ),
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
                if (index >= controller.radarLabels.length)
                  return const RadarChartTitle(text: '');
                String label = controller.radarLabels[index];
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

  Widget _buildLineChartCard(ThemeData theme, List<FlSpot> spots) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: theme.dividerColor.withAlpha(25)),
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 30,
          bottom: 20,
          left: 10,
          right: 25,
        ),
        child: AspectRatio(
          aspectRatio: 1.5,
          child: LineChart(
            LineChartData(
              gridData: const FlGridData(show: false),
              titlesData: FlTitlesData(
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, _) {
                      const days = [
                        'Mon',
                        'Tue',
                        'Wed',
                        'Thu',
                        'Fri',
                        'Sat',
                        'Sun',
                      ];
                      if (value >= 0 && value < 7) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            days[value.toInt()],
                            style: const TextStyle(fontSize: 10),
                          ),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                leftTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
              ),
              borderData: FlBorderData(show: false),
              lineBarsData: [
                LineChartBarData(
                  spots: spots,
                  isCurved: true,
                  color: theme.colorScheme.primary,
                  barWidth: 4,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    color: theme.colorScheme.primary.withAlpha(25),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 4),
        child: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
      ),
    );
  }
}
