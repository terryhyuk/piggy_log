import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:simple_spending_tracker/VM/dashboard_handler.dart';

class DashboardController {
  final DashboardHandler handler = DashboardHandler();
  int? selectedCategoryId;
  Map<String, double> selectedBreakdown = {};
  List<Map<String, dynamic>> categoryList = [];

  // Colors for PieChart & Top3 text
  final List<Color> categoryColors = [
    Colors.orange, Colors.blue, Colors.green, Colors.red, Colors.purple
  ];

  // ---------------- Functions ----------------
  List<PieChartSectionData> makePieData(List<Map<String, dynamic>> categoryExpenses) {
    categoryList = categoryExpenses;
    return categoryExpenses.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final value = (item['total'] as num?)?.toDouble() ?? 0.0;
      final color = categoryColors[index % categoryColors.length];
      return PieChartSectionData(
        value: value,
        title: item['name'] ?? '',
        color: color,
        radius: 55,
        titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
      );
    }).toList();
  }

  Future<void> loadBreakdown(int categoryId) async {
    selectedCategoryId = categoryId;
    final data = await handler.getCategoryBreakdown(categoryId);
    while (data.length < 3) data[''] = 0.0;
    selectedBreakdown = data;
  }
}

// class DashboardController {
//   // --------------------------
//   // Properties
//   // --------------------------
//   final DashboardHandler handler = DashboardHandler();

//   int? selectedCategoryId;
//   Map<String, double> selectedBreakdown = {}; // radar data for selected category
//   List<Map<String, dynamic>> categoryList = [];

//   // --------------------------
//   // Convert category totals → PieChart data
//   // --------------------------
//   List<PieChartSectionData> makePieData(List<Map<String, dynamic>> categoryExpenses) {
//     // Keep categoryList in sync so we can map index -> id
//     categoryList = categoryExpenses;

//     return categoryExpenses.asMap().entries.map((entry) {
//       final index = entry.key;
//       final item = entry.value;

//       final value = (item['total'] as num?)?.toDouble() ?? 0.0;
//       final title = item['name'] ?? '';

//       return PieChartSectionData(
//         value: value,
//         title: title,
//         radius: 50,
//         titleStyle: const TextStyle(
//           color: Colors.white,
//           fontWeight: FontWeight.bold,
//         ),
//       );
//     }).toList();
//   }

//   // --------------------------
//   // Load breakdown for a category (by id)
//   // --------------------------
//   Future<void> loadBreakdown(int categoryId) async {
//     selectedCategoryId = categoryId;

//     final data = await handler.getCategoryBreakdown(categoryId);

//     // ensure at least 3 entries (dummy fill)
//     while (data.length < 3) {
//       data['dummy${data.length + 1}'] = 0.0;
//     }

//     selectedBreakdown = data;
//   }
// }


// // import 'package:fl_chart/fl_chart.dart';
// // import 'package:flutter/material.dart';
// // import 'package:simple_spending_tracker/VM/dashboard_handler.dart';

// // class DashboardController {
// //   final DashboardHandler handler = DashboardHandler();

// //   // Properties
// //   int? selectedCategoryId;
// //   Map<String, double> selectedBreakdown = {};
// //   List<Map<String, dynamic>> categoryList = [];

// //   // --------------------------
// //   // PieChart data 변환
// //   // --------------------------
// //   List<PieChartSectionData> makePieData(List<Map<String, dynamic>> categoryExpenses) {
// //     return categoryExpenses.map((item) {
// //       final value = (item['total'] as num?)?.toDouble() ?? 0.0;
// //       final title = item['name'] ?? '';

// //       return PieChartSectionData(
// //         value: value,
// //         title: title,
// //         radius: 50,
// //         titleStyle: const TextStyle(
// //           color: Colors.white,
// //           fontWeight: FontWeight.bold,
// //         ),
// //       );
// //     }).toList();
// //   }

// //   // --------------------------
// //   // 카테고리 Breakdown 불러오기
// //   // --------------------------
// //   Future<void> loadBreakdown(int categoryId) async {
// //     selectedCategoryId = categoryId;

// //     final data = await handler.getCategoryBreakdown(categoryId);

// //     // 최소 3개 유지
// //     while (data.length < 3) {
// //       data["dummy${data.length + 1}"] = 0.0;
// //     }

// //     selectedBreakdown = data;
// //   }
// // }
