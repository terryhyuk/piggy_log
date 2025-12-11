import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/controller/dashboard_controller.dart';
import 'package:simple_spending_tracker/VM/settings_handler.dart';
import 'package:simple_spending_tracker/model/settings.dart';
import 'package:simple_spending_tracker/view/widget/chart_widget.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  // ---------------- Properties ----------------
  final DashboardController dashbordcontroller = DashboardController();
  final SettingsHandler settingsHandler = SettingsHandler();

  double monthlyExpense = 0.0;
  double monthlyBudget = 0.0;
  List<Map<String, dynamic>> categoryExpenses = [];
  List<Map<String, dynamic>> top3Categories = [];
  List recentTransactions = [];
  Settings? settings;
  bool isLoading = true;
  

  // ---------------- Init ----------------
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  // ---------------- Build ----------------
  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Center(child: CircularProgressIndicator());

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top summary: expense & budget
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(monthlyExpense),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.redAccent)),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Monthly Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(_formatCurrency(monthlyBudget),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
      
            // Row: PieChart + Top3 + Radar
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 3,
                  child: ChartsWidget(
                    pieData: dashbordcontroller.makePieData(categoryExpenses),
                    onTapCategory: _onSelectCategory,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top3 text
                      ...top3Categories.asMap().entries.map((entry) {
                        final index = entry.key;
                        final item = entry.value;
                        // final color = dashbordcontroller.categoryColors[index % dashbordcontroller.categoryColors.length];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            '${item['name']} - ${_formatCurrency(item['total'])}',
                            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, ),
                          ),
                        );
                      }).toList(),
                      const SizedBox(height: 8),
                      if (dashbordcontroller.selectedBreakdown.isNotEmpty)
                        ChartsWidget(radarData: dashbordcontroller.selectedBreakdown),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
      
            // Recent Transactions
            const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Column(
              children: recentTransactions.map((trx) {
                return Card(
                  child: ListTile(
                    title: Text(trx.t_name),
                    subtitle: Text(trx.date),
                    trailing: Text(_formatCurrency(trx.amount)),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Functions ----------------
  String _formatCurrency(double amount) {
    final symbol = settings?.currency_symbol ?? '\$';
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  void _onSelectCategory(int index) async {
    if (index < 0 || index >= categoryExpenses.length) {
      dashbordcontroller.selectedBreakdown = {};
      setState(() {});
      return;
    }
    final selectedId = categoryExpenses[index]['id'] as int;
    await dashbordcontroller.loadBreakdown(selectedId);
    setState(() {});
  }

  Future<void> _loadData() async {
    setState(() => isLoading = true);
    final now = DateTime.now();
    final yearMonth = DateFormat('yyyy-MM').format(now);

    settings = await settingsHandler.getSettings();
    monthlyExpense = await dashbordcontroller.handler.getMonthlyTotalExpense(yearMonth);
    monthlyBudget = await dashbordcontroller.handler.getMonthlyBudget(yearMonth);
    categoryExpenses = await dashbordcontroller.handler.getCategoryExpense(yearMonth);
    top3Categories = await dashbordcontroller.handler.getTop3Categories(yearMonth);
    recentTransactions = await dashbordcontroller.handler.getRecentTransactions(limit: 4);

    setState(() => isLoading = false);
  }
}

// class Dashboard extends StatefulWidget {
//   const Dashboard({super.key});

//   @override
//   State<Dashboard> createState() => _DashboardState();
// }

// class _DashboardState extends State<Dashboard> {
//   final DashboardController dashbordcontroller = DashboardController();
//   final SettingsHandler settingsHandler = SettingsHandler();

//   double monthlyExpense = 0.0;
//   double monthlyBudget = 0.0;
//   List<Map<String, dynamic>> categoryExpenses = [];
//   List<Map<String, dynamic>> top3Categories = [];
//   List recentTransactions = [];
//   Settings? settings;

//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     _loadData();
//   }

//   Future<void> _loadData() async {
//     setState(() => isLoading = true);

//     final now = DateTime.now();
//     final yearMonth = DateFormat('yyyy-MM').format(now);

//     settings = await settingsHandler.getSettings();
//     monthlyExpense = await dashbordcontroller.handler.getMonthlyTotalExpense(yearMonth);
//     monthlyBudget = await dashbordcontroller.handler.getMonthlyBudget(yearMonth);
//     categoryExpenses = await dashbordcontroller.handler.getCategoryExpense(yearMonth);
//     top3Categories = await dashbordcontroller.handler.getTop3Categories(yearMonth);
//     recentTransactions = await dashbordcontroller.handler.getRecentTransactions(limit: 4);

//     isLoading = false;
//     setState(() {});
//   }

//   String _formatCurrency(double amount) {
//     final symbol = settings?.currency_symbol ?? '\$';
//     return '$symbol${amount.toStringAsFixed(2)}';
//   }

//   void _onSelectCategory(int index) async {
//     if (index < 0 || index >= categoryExpenses.length) return;

//     final selected = categoryExpenses[index];
//     final selectedId = selected['id'] as int;

//     await dashbordcontroller.loadBreakdown(selectedId);
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {
//     if (isLoading) return const Center(child: CircularProgressIndicator());

//     return SingleChildScrollView(
//       padding: const EdgeInsets.all(16),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // -----------------------------
//           // 상단: 총 지출 + 이번달 목표
//           // -----------------------------
//           Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Total Expense', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Text(_formatCurrency(monthlyExpense), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//               Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   const Text('Monthly Budget', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//                   const SizedBox(height: 4),
//                   Text(_formatCurrency(monthlyBudget), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
//                 ],
//               ),
//             ],
//           ),

//           const SizedBox(height: 24),

//           // -----------------------------
//           // PieChart + Top3 텍스트
//           // -----------------------------
//          Row(
//   crossAxisAlignment: CrossAxisAlignment.start,
//   children: [
//     // PieChart
//     Expanded(
//       flex: 3,
//       child: ChartsWidget(
//         pieData: dashbordcontroller.makePieData(categoryExpenses),
//         onTapCategory: _onSelectCategory,
//       ),
//     ),
//     const SizedBox(width: 12),
//     // Top3 + RadarChart
//     Expanded(
//       flex: 2,
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           // Top3 텍스트
//           ...top3Categories.map((item) => Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 4),
//                 child: Text(
//                   '${item['name']} - ${_formatCurrency(item['total'])}',
//                   style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
//                 ),
//               )),
//           const SizedBox(height: 8),
//           // RadarChart
//           if (dashbordcontroller.selectedBreakdown.isNotEmpty)
//             ChartsWidget(radarData: dashbordcontroller.selectedBreakdown),
//         ],
//       ),
//     ),
//   ],
// ),


//           const SizedBox(height: 24),

//           // -----------------------------
//           // Recent Transactions
//           // -----------------------------
//           const Text('Recent Transactions', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
//           const SizedBox(height: 8),
//           Column(
//             children: recentTransactions.map((trx) {
//               return Card(
//                 child: ListTile(
//                   title: Text(trx.t_name),
//                   subtitle: Text(trx.date),
//                   trailing: Text(_formatCurrency(trx.amount)),
//                 ),
//               );
//             }).toList(),
//           ),
//         ],
//       ),
//     );
//   }
// }

// // class Dashboard extends StatefulWidget {
// //   const Dashboard({super.key});

// //   @override
// //   State<Dashboard> createState() => _DashboardState();
// // }

// // class _DashboardState extends State<Dashboard> {

// //   // --------------------------
// //   // Properties
// //   // --------------------------
// //   final DashboardController dashbordcontroller = DashboardController();
// //   final SettingsHandler settingsHandler = SettingsHandler();
// //   final TabbarController tabController = Get.find();

// //   double monthlyExpense = 0.0;
// //   double monthlyBudget = 0.0;
// //   List<Map<String, dynamic>> categoryExpenses = [];
// //   List<Map<String, dynamic>> top3Categories = [];
// //   List recentTransactions = [];
// //   Settings? settings;

// //   bool isLoading = true;

// //   // --------------------------
// //   // Init
// //   // --------------------------
// //   @override
// //   void initState() {
// //     super.initState();
// //     _loadData();
// //   }

// //   // --------------------------
// //   // Build
// //   // --------------------------
// //   @override
// //   Widget build(BuildContext context) {
// //     if (isLoading) {
// //       return const Center(child: CircularProgressIndicator());
// //     }

// //     return SingleChildScrollView(
// //       padding: const EdgeInsets.all(16),
// //       child: Column(
// //         crossAxisAlignment: CrossAxisAlignment.start,
// //         children: [
          
// //           // Row: PieChart + Top3
// //           Row(
// //             children: [
// //               // PieChart
// //               Expanded(
// //   flex: 3,
// //   child: ChartsWidget(
// //     pieData: dashbordcontroller.makePieData(categoryExpenses),
// //     onTapCategory: _onSelectCategory,
// //   ),
// // ),


// //               const SizedBox(width: 12),

// //               // Top 3 Categories
// //               Expanded(
// //                 flex: 2,
// //                 child: Column(
// //                   children: top3Categories.map((item) {
// //                     return Card(
// //                       child: ListTile(
// //                         dense: true,
// //                         title: Text(item['name']),
// //                         trailing:
// //                             Text(_formatCurrency(item['total'])),
// //                       ),
// //                     );
// //                   }).toList(),
// //                 ),
// //               ),
// //             ],
// //           ),

// //           const SizedBox(height: 16),

// //           // RadarChart for selected category
// //           if (dashbordcontroller.selectedBreakdown.isNotEmpty)
// //             ChartsWidget(
// //               pieData: const [],
// //               radarData: dashbordcontroller.selectedBreakdown,
// //             ),

// //           const SizedBox(height: 24),

// //           // Recent Transactions
// //           const Text('Recent Transactions'),
// //           const SizedBox(height: 8),
// //           Column(
// //             children: recentTransactions.map((trx) {
// //               return Card(
// //                 child: ListTile(
// //                   title: Text(trx.t_name),
// //                   subtitle: Text(trx.date),
// //                   trailing: Text(_formatCurrency(trx.amount)),
// //                 ),
// //               );
// //             }).toList(),
// //           ),
// //         ],
// //       ),
// //     );
// //   }

// //   // --------------------------
// //   // Helpers
// //   // --------------------------
// //   String _formatCurrency(double amount) {
// //     final symbol = settings?.currency_symbol ?? '\$';
// //     return '$symbol${amount.toStringAsFixed(2)}';
// //   }

// //   // --------------------------
// //   // Functions
// //   // --------------------------
// // void _onSelectCategory(int index) async {
// //     if (index < 0 || index >= categoryExpenses.length) return;

// //   final selected = categoryExpenses[index];
// //   final selectedId = selected['id'] as int;

// //   await dashbordcontroller.loadBreakdown(selectedId);
// //   setState(() {});
// // }


// //   Future<void> _loadData() async {
// //     setState(() => isLoading = true);

// //     final now = DateTime.now();
// //     final yearMonth = DateFormat('yyyy-MM').format(now);

// //     settings = await settingsHandler.getSettings();
// //     monthlyExpense = await dashbordcontroller.handler.getMonthlyTotalExpense(yearMonth);
// //     monthlyBudget = await dashbordcontroller.handler.getMonthlyBudget(yearMonth);
// //     categoryExpenses = await dashbordcontroller.handler.getCategoryExpense(yearMonth);
// //     top3Categories = await dashbordcontroller.handler.getTop3Categories(yearMonth);
// //     recentTransactions =
// //         await dashbordcontroller.handler.getRecentTransactions(limit: 4);

// //     isLoading = false;
// //     setState(() {});
// //   }
// // }
