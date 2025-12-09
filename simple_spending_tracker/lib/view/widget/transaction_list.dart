import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';

class TransactionList extends StatelessWidget {
  final int categoryId;
  final TransactionHandler transactionHandler = TransactionHandler();
  final SettingsController settingsController = Get.find<SettingsController>();

  TransactionList({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: transactionHandler.getTransactionsByCategory(categoryId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        }
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Text(AppLocalizations.of(context)!.noTransactionsFound);
        }
        return Obx(() {
          settingsController.refreshTrigger.value; // changes trigger rebuild
          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final trx = snapshot.data![index];
              final date = DateTime.parse(trx.date);
              return ListTile(
                title: Text(trx.t_name),
                subtitle: Text(
                  settingsController.formatDate(date) ??
                      DateFormat.yMMMd().format(date),
                ),
                trailing: Text(
                  settingsController.formatCurrency(trx.amount) ??
                      trx.amount.toString(),
                  style: TextStyle(
                    color: trx.type == 'expense'
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              );
            },
          );
        });
      },
    );
  }
}
