import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/transactions_detail.dart';
import 'package:piggy_log/view/widget/add_transaction_dialog.dart';

/// TransactionList - Category Transaction List View
///
/// Displays all transactions for a specific category with swipe-to-edit/delete.
/// Core list component for Simple Spending Tracker (Canada Edition).
///
/// Features:
/// ✅ Swipe right → Edit transaction (AddTransactionDialog)
/// ✅ Swipe right → Delete with confirmation dialog
/// ✅ Real-time reactive updates via Obx() + refreshTrigger
/// ✅ Currency formatting (CAD support via SettingsController)
/// ✅ Material 3 colors (error/primary for expense/income)
/// ✅ Slidable actions with smooth DrawerMotion animation
///
/// Data flow:
/// CategoryId → TransactionHandler.getTransactionsByCategory() → ListView
///
/// Auto-refreshes: Dashboard + Category lists on delete/edit

class TransactionList extends StatelessWidget {
  final int categoryId;
  final TransactionHandler transactionHandler = TransactionHandler();
  final SettingsController settingsController = Get.find<SettingsController>();

  TransactionList({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      settingsController.refreshTrigger.value;

      return FutureBuilder(
        future: transactionHandler.getTransactionsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noTransactionsFound,
                style: TextStyle(fontSize: 16),
                textAlign: TextAlign.center,
              ),
            );
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
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      foregroundColor: theme.colorScheme.primary,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) async {
                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(
                              AppLocalizations.of(context)!.confirmDelete,
                            ),
                            content: Text(
                              "'${trx.t_name}' ${AppLocalizations.of(context)!.deleteConfirm}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(
                                  AppLocalizations.of(context)!.cancel,
                                ),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  AppLocalizations.of(context)!.delete,
                                  style: TextStyle(
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await TransactionHandler().deleteTransaction(
                            trx.t_id!,
                          );

                          settingsController.refreshTrigger.value++;

                          final dashboardController =
                              Get.find<DashboardController>();
                          await dashboardController.refreshDashboard();

                          Get.snackbar(
                            AppLocalizations.of(context)!.deleted,
                            "'${trx.t_name}' ${AppLocalizations.of(context)!.wasRemoved}",
                            snackPosition: SnackPosition.top,
                            backgroundColor: theme.colorScheme.errorContainer,
                            colorText: theme.colorScheme.onErrorContainer,
                          );
                        }
                      },
                      backgroundColor: theme.colorScheme.errorContainer,
                      foregroundColor: theme.colorScheme.onErrorContainer,
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
                      color: trx.type == 'expense'
                          ? theme.colorScheme.error
                          : theme.colorScheme.primary,
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
