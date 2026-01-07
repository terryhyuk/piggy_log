// ignore_for_file: non_constant_identifier_names

import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/core/db/transaction_handler.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/features/transaction/model/spending_transaction.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    A multi-purpose transaction gateway that handles both creation and 
//    modifications. It enforces data integrity through strict validation 
//    and ensures high UX stability with keyboard-aware padding.
//
//  * TODO: 
//    - Abstract the form fields into a separate 'TransactionForm' widget.
//    - Implement a 'Currency Input Formatter' to handle localized separators.
// -----------------------------------------------------------------------------

class AddTransactionDialog extends StatefulWidget {
  final int c_id; 
  final SpendingTransaction? transactionToEdit; 

  const AddTransactionDialog({
    super.key,
    required this.c_id,
    this.transactionToEdit,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TextEditingController tNameController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  final settingsController = Get.find<SettingController>();

  String selectedType = 'expense';
  bool isRecurring = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // [Logic] Initializes the form state based on the presence of existing data.
    if (widget.transactionToEdit != null) {
      final trx = widget.transactionToEdit!;
      tNameController = TextEditingController(text: trx.t_name);
      amountController = TextEditingController(text: trx.amount.toString());
      memoController = TextEditingController(text: trx.memo);
      selectedType = trx.type;
      isRecurring = trx.isRecurring;
      selectedDateTime = DateTime.parse(trx.date);
    } else {
      tNameController = TextEditingController();
      amountController = TextEditingController();
      memoController = TextEditingController();
    }
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
        // Dynamic bottom padding prevents the software keyboard from obscuring input fields.
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  widget.transactionToEdit == null
                      ? local.addTransaction
                      : local.editTransaction,
                  style: theme.textTheme.titleLarge,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: tNameController,
                  decoration: InputDecoration(labelText: local.description),
                  textInputAction: TextInputAction.next,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: local.amount),
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  textInputAction: TextInputAction.done,
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: TextField(
                  controller: memoController,
                  decoration: InputDecoration(labelText: local.memo),
                  maxLines: 2,
                ),
              ),

              // Transaction Type Selector: Uses SegmentedButton for a native OS feel.
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: LayoutBuilder(
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
                        selectedForegroundColor: theme.colorScheme.onPrimaryContainer,
                      ),
                    );
                  },
                ),
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: isRecurring,
                      onChanged: (v) => setState(() => isRecurring = v ?? false),
                    ),
                    Text(local.recurring),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(settingsController.formatDate(selectedDateTime)),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(local.cancel),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        foregroundColor: theme.colorScheme.onPrimary,
                        backgroundColor: theme.colorScheme.primary,
                      ),
                      onPressed: saveTransaction,
                      child: Text(widget.transactionToEdit == null ? local.save : local.update),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Triggers a system date picker with localized date constraints.
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDateTime = picked);
  }

  /// Validates input, persists the record, and triggers a global UI refresh.
  Future<void> saveTransaction() async {
    final local = AppLocalizations.of(context)!;
    final String name = tNameController.text.trim();
    final String amountStr = amountController.text.trim();
    final double? amount = double.tryParse(amountStr);

    // [Validation] Ensures non-empty descriptions and positive financial values.
    if (name.isEmpty || amount == null || amount <= 0) {
      Get.snackbar("", local.checkTitleAndAmount, backgroundColor: Colors.orangeAccent);
      return;
    }

    final trx = SpendingTransaction(
      t_id: widget.transactionToEdit?.t_id,
      c_id: widget.c_id,
      t_name: name,
      date: "${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')}",
      type: selectedType,
      amount: amount,
      memo: memoController.text.trim(),
      isRecurring: isRecurring,
    );

    if (widget.transactionToEdit == null) {
      await TransactionHandler().insertTransaction(trx, customDate: selectedDateTime);
    } else {
      await TransactionHandler().updateTransaction(trx);
    }

    if (!mounted) return;
    
    // Critical: Synchronizes the application state with the database persistence layer.
    await settingsController.refreshAllData(); 

    Get.snackbar(
      widget.transactionToEdit == null ? local.categoryCreated : local.categoryUpdated,
      widget.transactionToEdit == null ? local.newCategoryAdded : local.changesSaved,
      backgroundColor: widget.transactionToEdit == null ? Colors.green : Colors.blue,
      colorText: Colors.white,
    );
    
    Navigator.pop(context, true);
  }
}