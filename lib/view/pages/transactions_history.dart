import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/model/category.dart';
import 'package:piggy_log/view/widget/add_transaction_dialog.dart';
import 'package:piggy_log/view/widget/buildHeader.dart';
import 'package:piggy_log/view/widget/transaction_list.dart';

// -----------------------------------------------------------------------------
//  * TransactionsHistory - Category-Specific Transaction Ledger
//  * -----------------------------------------------------------------------------
//  * [Description]
//  * Displays the transaction history filtered by a specific category.
//  * -----------------------------------------------------------------------------

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  late final Category category;
  final SettingController settingsController = Get.find<SettingController>();

  @override
  void initState() {
    super.initState();
    
    // Retrieve the category object passed via navigation arguments
    final arg = Get.arguments;
    if (arg is Category) {
      category = arg;
    } else {
      // Emergency fallback to prevent null errors
      category = Category(
        iconCodePoint: Icons.category.codePoint,
        iconFontFamily: Icons.category.fontFamily,
        iconFontPackage: Icons.category.fontPackage,
        color: "FFFFFFFF",
        c_name: "Unknown",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: Category info and Add button
            BuildHeader(
              category: category,
              onAddTap: () => _openAddTransactionDialog(),
            ),
            
            // Body: Scrollable transaction list
            Expanded(
              child: TransactionList(
                categoryId: category.id!,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Opens the dialog to add a new transaction and refreshes the UI on close
  Future<void> _openAddTransactionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(c_id: category.id!),
    );
    
    if (mounted) setState(() {});
  }
}