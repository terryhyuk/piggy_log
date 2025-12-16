import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/controller/dashboard_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/view/pages/transactions_%20detail.dart';
import 'package:simple_spending_tracker/view/widget/add_transaction_dialog.dart';

class TransactionList extends StatelessWidget {
  final int categoryId;
  final TransactionHandler transactionHandler = TransactionHandler();
  final SettingsController settingsController = Get.find<SettingsController>();

  TransactionList({super.key, required this.categoryId});
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      settingsController.refreshTrigger.value; // 👈 트리거

      return FutureBuilder(
        future: transactionHandler.getTransactionsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Text(AppLocalizations.of(context)!.noTransactionsFound);
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              final trx = snapshot.data![index];
              final date = DateTime.parse(trx.date);

              return Slidable(
                key: ValueKey(trx.t_id),
                endActionPane: ActionPane(
                  motion: const DrawerMotion(),
                  children: [
                    SlidableAction(
                      onPressed: (_) {
                        showModalBottomSheet(
                          context: context,
                          isScrollControlled: true,
                          builder: (_) => AddTransactionDialog(
                            c_id: categoryId,
                            transactionToEdit: trx,
                          ),
                        ).then(
                          (_) => settingsController.refreshTrigger.value++,
                        );
                      },
                      backgroundColor: Colors.transparent,
                      foregroundColor: Theme.of(context).colorScheme.primary,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) async {
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Confirm Delete'),
                            content: Text("Delete '${trx.t_name}'?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  "Delete",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await TransactionHandler().deleteTransaction(
                            trx.t_id!,
                          );

                          // 1️⃣ 카테고리 리스트 갱신
                          settingsController.refreshTrigger.value++;

                          // 2️⃣ 대시보드 갱신
                          final dashboardController =
                              Get.find<DashboardController>();
                          await dashboardController.refreshDashboard();

                          // 3️⃣ 알림
                          Get.snackbar(
                            'Deleted',
                            "'${trx.t_name}' was removed.",
                            snackPosition: SnackPosition.top,
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                        }
                      },
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      icon: Icons.delete,
                      label: 'Delete',
                    ),
                  ],
                ),
                child: ListTile(
                  title: Text(trx.t_name),
                  subtitle: Text(
                    settingsController.formatDate(date) ??
                        DateFormat.yMMMd().format(date),
                  ),
                  trailing: Text(
                    settingsController.formatCurrency(trx.amount) ??
                        trx.amount.toString(),
                    style: TextStyle(
                      color: trx.type == 'expense' ? Colors.red : Colors.green,
                    ),
                  ),
                  onTap: () {
                    Get.to(
                      () => const TransactionsDetail(),
                      arguments: trx,
                    )?.then((result) {
                      if (result == true)
                        settingsController.refreshTrigger.value++;
                    });
                  },
                ),
              );
            },
          );
        },
      );
    });
  }
}
