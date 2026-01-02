import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/spending_transaction.dart';

// -----------------------------------------------------------------------------
//  * TransactionsDetail - Transaction Management & Editor
//  * -----------------------------------------------------------------------------
//  * [Description]
//  * Provides a detailed view and editing interface for existing transactions.
//  * Supports updating information and permanent deletion with confirmation.
//  -----------------------------------------------------------------------------

class TransactionsDetail extends StatefulWidget {
  const TransactionsDetail({super.key});

  @override
  State<TransactionsDetail> createState() => _TransactionsDetailState();
}

class _TransactionsDetailState extends State<TransactionsDetail> {
  late SpendingTransaction trx;

  late TextEditingController titleController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  final settingsController = Get.find<SettingController>();

  late DateTime selectedDate;
  late String selectedType;
  late bool isRecurring;

  @override
  void initState() {
    super.initState();
    // Hydrate state from navigation arguments
    trx = Get.arguments as SpendingTransaction;

    titleController = TextEditingController(text: trx.t_name);
    amountController = TextEditingController(text: trx.amount.toString());
    memoController = TextEditingController(text: trx.memo);

    selectedDate = DateTime.parse(trx.date);
    selectedType = trx.type;
    isRecurring = trx.isRecurring;
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final deleteColor = isDark ? Colors.red.shade300 : Colors.red.shade700;

    return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: theme.colorScheme.onSurface,
        actions: [
          TextButton(
            onPressed: deleteTransaction,
            child: Text(
              local.delete,
              style: TextStyle(color: deleteColor, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: local.title),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: amountController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: local.amount),
                ),
                const SizedBox(height: 16),
                // Transaction Type Selector
                LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = (constraints.maxWidth - 16) / 2;
                    return SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment(
                          value: 'expense',
                          label: SizedBox(width: segmentWidth, child: Center(child: Text(local.expense))),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: SizedBox(width: segmentWidth, child: Center(child: Text(local.income))),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: <String>{selectedType},
                      onSelectionChanged: (newSelection) {
                        setState(() => selectedType = newSelection.first);
                      },
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: theme.colorScheme.primaryContainer,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                // Date Selection Row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(settingsController.formatDate(selectedDate)),
                    TextButton(onPressed: pickDate, child: Text(local.selectDate)),
                  ],
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: memoController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: local.memo),
                ),
                const SizedBox(height: 16),
                // Recurring Toggle
                Row(
                  children: [
                    Checkbox(
                      value: isRecurring,
                      onChanged: (v) => setState(() => isRecurring = v ?? false),
                    ),
                    Text(local.recurring),
                  ],
                ),
                const SizedBox(height: 32),
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(foregroundColor: theme.colorScheme.error),
                        child: Text(local.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(onPressed: save, child: Text(local.save)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// pickDate: Triggers the system date picker
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDate = picked);
  }

  /// save: Validates and updates the transaction in the database
  Future<void> save() async {
    final amount = double.tryParse(amountController.text);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) return;

    final updated = SpendingTransaction(
      t_id: trx.t_id,
      c_id: trx.c_id,
      t_name: titleController.text,
      date: "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}",
      type: selectedType,
      amount: amount,
      memo: memoController.text,
      isRecurring: isRecurring,
    );

    await TransactionHandler().updateTransaction(updated);
    await settingsController.refreshAllData();
    Get.back(result: true);
  }

  /// deleteTransaction: Shows a confirmation dialog before permanent removal
  void deleteTransaction() {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    Get.defaultDialog(
      title: local.deleteTransaction,
      middleText: local.deleteTransactionConfirm,
      textCancel: local.cancel,
      textConfirm: local.delete,
      confirmTextColor: theme.colorScheme.onErrorContainer,
      buttonColor: theme.colorScheme.errorContainer,
      onConfirm: () async {
        await TransactionHandler().deleteTransaction(trx.t_id!);
        await settingsController.refreshAllData();
        Get.back(); // Close dialog
        Get.back(result: true); // Return to list
      },
    );
  }
}