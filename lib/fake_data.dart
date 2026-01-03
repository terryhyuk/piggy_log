import 'dart:math';
import 'package:flutter/material.dart';
import 'package:piggy_log/VM/category_handler.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/model/category.dart';
import 'package:piggy_log/model/spending_transaction.dart';
import 'package:piggy_log/model/category_colors.dart';

/// ⚠️ DEBUG ONLY: For Video Recording and Graph Validation
class Fake_Data {
  /// Clears or just fills the database with realistic diverse data
  static Future<void> fill() async {
    final CategoryHandler catHandler = CategoryHandler();
    final TransactionHandler trxHandler = TransactionHandler();
    final Random random = Random();

    // ---------------------------------------------------------
    // 1. Fixed Categories (4 for better visual density)
    // ---------------------------------------------------------
    final List<Map<String, dynamic>> targetCategories = [
      {'name': 'Food', 'icon': Icons.restaurant_rounded},
      {'name': 'Coffee', 'icon': Icons.local_cafe_rounded},
      {'name': 'Music', 'icon': Icons.music_note_rounded},
      {'name': 'Shopping', 'icon': Icons.shopping_bag_rounded},
    ];

    final List<int> categoryIds = [];
    final List<String> categoryNames = [];

    for (int i = 0; i < targetCategories.length; i++) {
      final IconData iconData = targetCategories[i]['icon'] as IconData;
      final String name = targetCategories[i]['name'] as String;

      // Picking consistent colors from the palette
      final Color colorObj = CategoryColors.palette[i % CategoryColors.palette.length];
      final String hexColor = colorObj.value.toRadixString(16).padLeft(8, '0').toUpperCase();

      final Category newCategory = Category(
        c_name: name,
        iconCodePoint: iconData.codePoint,
        iconFontFamily: iconData.fontFamily,
        iconFontPackage: iconData.fontPackage,
        color: hexColor,
      );

      final int id = await catHandler.insertCategory(newCategory);
      categoryIds.add(id);
      categoryNames.add(name);
    }

    // ---------------------------------------------------------
    // 2. Generate Transactions (Last 60 days)
    // ---------------------------------------------------------
    final DateTime now = DateTime.now();

    for (int i = 59; i >= 0; i--) {
      final DateTime targetDate = now.subtract(Duration(days: i));

      // Weekend = more spending, Weekdays = moderate
      final bool isWeekend = targetDate.weekday >= DateTime.saturday;
      final int dailyCount = isWeekend ? random.nextInt(3) + 3 : random.nextInt(2) + 1;

      for (int j = 0; j < dailyCount; j++) {
        final int idx = random.nextInt(categoryIds.length);
        final String catName = categoryNames[idx];

        // Varied amount for dynamic Bar/Radar charts (5,000 ~ 55,000)
        final double amount = ((random.nextInt(50) + 5) * 1000).toDouble() + random.nextInt(900);

        final SpendingTransaction transaction = SpendingTransaction(
          c_id: categoryIds[idx],
          // 💡 Diversity: Picking random items to ensure Radar Chart vertices
          t_name: _getDiverseTitle(catName, random),
          amount: amount,
          date: '', 
          type: 'expense',
          memo: 'Auto-generated test data',
          isRecurring: false,
        );

        await trxHandler.insertTransaction(
          transaction,
          customDate: targetDate,
        );
      }
    }

    debugPrint('🐷 [Fake_Data] Successfully injected 60 days of diverse data.');
  }

  // ---------------------------------------------------------
  // Helpers: Diverse titles to make Radar Chart vertices look good
  // ---------------------------------------------------------
  static String _getDiverseTitle(String category, Random random) {
    final Map<String, List<String>> detailItems = {
      'Food': ['Chicken', 'Pizza', 'Sushi', 'Burger', 'Rice', 'Noodle', 'Salad', 'Steak'],
      'Coffee': ['Starbucks', 'Ediya', 'Latte', 'Dessert', 'Cake', 'Bakery', 'Espresso'],
      'Music': ['Melon', 'Spotify', 'LP Shop', 'Concert', 'Earphones', 'iTunes', 'Festival'],
      'Shopping': ['Amazon', 'Nike', 'Mall', 'Uniqlo', 'Groceries', 'Gift', 'Market'],
    };

    final List<String> items = detailItems[category] ?? [category];
    // Return a random item from the list for that category
    return items[random.nextInt(items.length)];
  }
}