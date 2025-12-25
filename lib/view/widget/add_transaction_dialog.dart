import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/spending_transaction.dart';

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
  late TextEditingController t_nameController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  final settingsController = Get.find<SettingsController>();

  String selectedType = 'expense';
  bool isRecurring = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();

    /// Initialize controllers with existing transaction or empty fields.
    /// 기존 거래 수정 시 데이터를 채우고, 새 거래 추가 시 빈 컨트롤러 생성.
    if (widget.transactionToEdit != null) {
      final trx = widget.transactionToEdit!;
      t_nameController = TextEditingController(text: trx.t_name);
      amountController = TextEditingController(text: trx.amount.toString());
      memoController = TextEditingController(text: trx.memo);
      selectedType = trx.type;
      isRecurring = trx.isRecurring;
      selectedDateTime = DateTime.parse(trx.date);
    } else {
      t_nameController = TextEditingController();
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
        // Make the dialog scrollable when keyboard is open
        // 키보드가 올라왔을 때 다이얼로그가 스크롤 가능하도록 설정
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

              // === Transaction Title ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: t_nameController,
                  decoration: InputDecoration(labelText: local.title),
                ),
              ),

              // === Transaction Amount ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: amountController,
                  decoration: InputDecoration(labelText: local.amount),
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                ),
              ),

              // === Transaction Memo ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: TextField(
                  controller: memoController,
                  decoration: InputDecoration(labelText: local.memo),
                  maxLines: 2,
                ),
              ),

              // === Transaction Type Selector ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 8.0,
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final segmentWidth = (constraints.maxWidth - 16) / 2;
                    return SegmentedButton<String>(
                      segments: <ButtonSegment<String>>[
                        ButtonSegment(
                          value: 'expense',
                          label: SizedBox(
                            width: segmentWidth,
                            child: Center(child: Text(local.expense)),
                          ),
                          icon: const Icon(Icons.remove_circle_outline),
                        ),
                        ButtonSegment(
                          value: 'income',
                          label: SizedBox(
                            width: segmentWidth,
                            child: Center(child: Text(local.income)),
                          ),
                          icon: const Icon(Icons.add_circle_outline),
                        ),
                      ],
                      selected: <String>{selectedType},
                      onSelectionChanged: (newSelection) {
                        setState(() {
                          selectedType = newSelection.first;
                        });
                      },
                      style: ButtonStyle(
                        visualDensity: VisualDensity.compact,
                        shape: WidgetStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        backgroundColor: WidgetStateProperty.resolveWith(
                          (states) => states.contains(WidgetState.selected)
                              ? theme.colorScheme.primaryContainer
                              : theme.colorScheme.surface,
                        ),
                      ),
                    );
                  },
                ),
              ),

              // === Recurring Checkbox ===
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Row(
                  children: [
                    Checkbox(
                      value: isRecurring,
                      onChanged: (v) {
                        setState(() {
                          isRecurring = v ?? false;
                        });
                      },
                    ),
                    Text(local.recurring),
                  ],
                ),
              ),

              // === Date Picker ===
              TextButton(
                onPressed: pickDate,
                child: Text(settingsController.formatDate(selectedDateTime)),
              ),

              // === Action Buttons ===
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
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
                      child: Text(
                        widget.transactionToEdit == null
                            ? local.save
                            : local.update,
                      ),
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

  /// Opens a date picker to select transaction date.
  /// 거래 날짜를 선택하는 DatePicker를 연다.
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDateTime = picked;
      });
    }
  }

  /// Saves or updates the transaction, refreshes data, and closes the dialog.
  /// 거래를 추가 또는 수정하고, 데이터 새로고침 후 다이얼로그를 닫는다.
  Future<void> saveTransaction() async {
    final amount = double.tryParse(amountController.text);
    if (t_nameController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }

    final trx = SpendingTransaction(
      t_id: widget.transactionToEdit?.t_id,
      c_id: widget.c_id,
      t_name: t_nameController.text,
      date:
          "${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2, '0')}-${selectedDateTime.day.toString().padLeft(2, '0')}",
      type: selectedType,
      amount: amount,
      memo: memoController.text,
      isRecurring: isRecurring,
    );

    if (widget.transactionToEdit == null) {
      await TransactionHandler().insertTransaction(
        trx,
        customDate: selectedDateTime,
      );
    } else {
      await TransactionHandler().updateTransaction(trx);
    }

    await settingsController.refreshAllData();

    if (context.mounted) {
      Navigator.pop(context, true);
    }
  }
}


