import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/budget_handler.dart';
import 'package:simple_spending_tracker/controller/dashboard_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/view/widget/chart_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final DashboardController dashbordcontroller =
      Get.find<DashboardController>();
  final SettingsController settingsController = Get.find<SettingsController>();
  final TextEditingController budgetController = TextEditingController();
  double monthlyBudget = 0.0;

  final MonthlyBudgetHandler monthlyBudgetHandler = MonthlyBudgetHandler();

  int? selectedPieIndex;

  @override
  void initState() {
    super.initState();

    dashbordcontroller.refreshDashboard();
    _loadMonthlyBudget();
  }

  Future<void> _loadMonthlyBudget() async {
    final now = DateTime.now();
    final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";

    final value = await monthlyBudgetHandler.getMonthlyBudget(yearMonth);
    monthlyBudget = value;
    budgetController.text = value == 0 ? "" : value.toString();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Obx(() {
          // reactive trigger
          settingsController.refreshTrigger.value;
          dashbordcontroller.dataRefreshTrigger.value;

          final monthlyExpense = dashbordcontroller.totalExpense.value;
          final top3Categories = dashbordcontroller.top3Categories;
          final recentTransactions = dashbordcontroller.recentTransactions;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top summary
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Expense',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatCurrency(monthlyExpense),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Monthly Budget",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 4),

                      GestureDetector(
                        onTap: () => _showBudgetDialog(),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            vertical: 12,
                            horizontal: 16,
                          ),
                          child: Text(
                            monthlyBudget == 0
                                ? "Set your monthly budget"
                                : _formatCurrency(monthlyBudget),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Row: PieChart + Top3 + Radar
              Obx(() {
                if (dashbordcontroller.categoryList.isEmpty) {
                  return const Center(
                    child: Text("NO data"),
                  );
                }

                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: ChartsWidget(
                        pieData: dashbordcontroller.makePieData(
                          selectedIndex: selectedPieIndex,
                        ),
                        onTapCategory: _onSelectCategory,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ...top3Categories.asMap().entries.map((entry) {
                            final index = entry.key;
                            final item = entry.value;
                            final color =
                                dashbordcontroller.categoryColors[index %
                                    dashbordcontroller.categoryColors.length];
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 4),
                              child: Text(
                                '${item['name']} - ${_formatCurrency(item['total'])}',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: color,
                                ),
                              ),
                            );
                          }),
                          const SizedBox(height: 8),
                          Obx(() {
                            final breakdown = Map<String, double>.from(
                              dashbordcontroller.selectedBreakdown,
                            );
                            if (breakdown.isEmpty || breakdown.isEmpty)
                              return const SizedBox.shrink();
                            return ChartsWidget(radarData: breakdown);
                          }),
                          // Obx(() {
                          //   final breakdown = Map<String, double>.from(
                          //     dashbordcontroller.selectedBreakdown,
                          //   );
                          //   if (breakdown.isEmpty) return const SizedBox.shrink();
                          //   return ChartsWidget(radarData: breakdown);
                          // }),
                        ],
                      ),
                    ),
                  ],
                );
        }),

              const SizedBox(height: 24),

              // Recent Transactions
              const Text(
                'Recent Transactions',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Column(
                children: recentTransactions.map((trx) {
                  return Card(
                    child: ListTile(
                      title: Text(trx['t_name']),
                      subtitle: Text(
                        settingsController.formatDate(
                              DateTime.parse(trx['date']),
                            ) ??
                            trx['date'],
                      ),
                      trailing: Text(
                        _formatCurrency(trx['amount']),
                        style: TextStyle(
                          color: trx['type'] == 'expense'
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          );
        }),
      ),
    );
  }

  // --- Functions ---
  String _formatCurrency(dynamic amount) {
    final value = (amount as num?)?.toDouble() ?? 0.0;
    return settingsController.formatCurrency(value) ?? value.toString();
  }

  void _onSelectCategory(int index) async {
    if (index < 0 || index >= dashbordcontroller.categoryList.length) {
      dashbordcontroller.selectedBreakdown.clear();
      selectedPieIndex = null;
      setState(() {});
      return;
    }

    selectedPieIndex = index;
    final selectedId = dashbordcontroller.categoryList[index]['id'] as int;
    await dashbordcontroller.loadBreakdown(selectedId);
    setState(() {});
  }

  // Monthly Budget Dialog
  Future<void> _showBudgetDialog() async {
    final TextEditingController dialogController = TextEditingController(
      text: monthlyBudget == 0 ? "" : monthlyBudget.toString(),
    );

    final result = await showDialog<double>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Set Monthly Budget"),
        content: TextField(
          controller: dialogController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter your budget"),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context), // 취소
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () {
              final value = double.tryParse(dialogController.text.trim());
              if (value != null) Navigator.pop(context, value);
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );

    if (result != null) {
      // DB에 저장
      final now = DateTime.now();
      final yearMonth = "${now.year}-${now.month.toString().padLeft(2, '0')}";
      await monthlyBudgetHandler.saveMonthlyBudget(yearMonth, result);

      setState(() {
        monthlyBudget = result;
      });
    }
  }
} // END
