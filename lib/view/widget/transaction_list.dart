import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/pages/transactions_detail.dart';
import 'package:piggy_log/view/widget/add_transaction_dialog.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Reactive UI component for category-specific transaction listings. 
//    Integrates Slidable actions for intuitive mobile UX.
//
//  * TODO: 
//    - Transition from FutureBuilder to GetX Controller state management 
//      to separate business logic from the UI build method.
//    - Implement Pagination/SliverList for better performance with large datasets.
// -----------------------------------------------------------------------------

class TransactionList extends StatelessWidget {
  final int categoryId;
  final TransactionHandler transactionHandler = TransactionHandler();
  final SettingController settingsController = Get.find<SettingController>();

  TransactionList({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() {
      // Accessing refreshTrigger to rebuild the widget when data changes
      settingsController.refreshTrigger.value;

      return FutureBuilder(
        future: transactionHandler.getTransactionsByCategory(categoryId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                AppLocalizations.of(context)!.noTransactionsFound,
                style: const TextStyle(fontSize: 16),
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
                          (_) {
                            settingsController.refreshTrigger.value++;
                          },
                        );
                      },
                      backgroundColor: theme.colorScheme.surfaceContainer,
                      foregroundColor: theme.colorScheme.primary,
                      icon: Icons.edit,
                      label: 'Edit',
                    ),
                    SlidableAction(
                      onPressed: (_) async {
                        final local = AppLocalizations.of(context)!;

                        bool? confirmed = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(local.confirmDelete),
                            content: Text(
                              "'${trx.t_name}' ${local.deleteConfirm}",
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: Text(local.cancel),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: Text(
                                  local.delete,
                                  style: TextStyle(color: theme.colorScheme.error),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true) {
                          await TransactionHandler().deleteTransaction(trx.t_id!);

                          // Notify controllers to refresh UI state
                          settingsController.refreshTrigger.value++;
                          final dashboardController = Get.find<DashboardController>();
                          await dashboardController.refreshDashboard();

                          Get.snackbar(
                            local.deleted,
                            "'${trx.t_name}' ${local.wasRemoved}",
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
                  subtitle: Text(settingsController.formatDate(date)),
                  trailing: Text(
                    settingsController.formatCurrency(trx.amount),
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
                      if (result == true) {
                        settingsController.refreshTrigger.value++;
                      }
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