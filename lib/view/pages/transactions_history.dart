import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/model/category.dart';
import 'package:piggy_log/view/widget/add_transaction_dialog.dart';
import 'package:piggy_log/view/widget/buildHeader.dart';
import 'package:piggy_log/view/widget/transaction_list.dart';

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
    final arg = Get.arguments;
    if (arg is Category) {
      category = arg;
    } else {
      category = Category(
        iconCodePoint: Icons.category.codePoint,
        iconFontFamily: Icons.category.fontFamily,
        iconFontPackage: Icons.category.fontPackage,
        color: "FFFFFFFF",
        c_name: "Unknow",
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
            BuildHeader(
              category: category,
              onAddTap: () => _openAddTransactionDialog(),
            ),
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

  _openAddTransactionDialog() async {
    await showDialog(
      context: context,
      builder: (context) => AddTransactionDialog(c_id: category.id!),
    );
    setState(() {});
  }
}
