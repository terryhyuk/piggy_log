import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/VM/transaction_handler.dart';
import 'package:piggy_log/controller/setting_Controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/spending_transaction.dart';


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

  final settingsController = Get.find<SettingsController>();

  late DateTime selectedDate;
  late String selectedType;
  late bool isRecurring;

  @override
  void initState() {
    super.initState();

    /// Initialize UI fields with transaction data passed by arguments.
    /// 전달받은 거래 데이터를 UI 컨트롤러에 초기화한다.
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

      /// Main editable form area
      /// 거래 상세 내용을 편집할 수 있는 메인 폼 영역
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
                // === Title ===
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(labelText: local.title),
                ),
                const SizedBox(height: 16),

                // === Amount ===
                TextField(
                  controller: amountController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(labelText: local.amount),
                ),
                const SizedBox(height: 16),

                // === Type Selector ===
                LayoutBuilder(
                  builder: (context, constraints) {
                    /// Equal-width SegmentedButton for multi-language layout.
                    /// 다국어 UI에서도 동일한 폭을 유지하도록 SegmentedButton 균등 분배.
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
                        shape: WidgetStateProperty.all(
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
                const SizedBox(height: 16),

                // === Date Picker ===
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      settingsController.formatDate(selectedDate),
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      onPressed: pickDate,
                      child: Text(local.selectDate),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // === Memo ===
                TextField(
                  controller: memoController,
                  maxLines: 3,
                  decoration: InputDecoration(labelText: local.memo),
                ),
                const SizedBox(height: 16),

                // === Recurring Checkbox ===
                Row(
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

                const SizedBox(height: 32),

                // === Action Buttons ===
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: theme.colorScheme.error,
                        ),
                        child: Text(local.cancel),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: save,
                        child: Text(local.save),
                      ),
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

  /// Opens a date picker to let user choose a new date.
  /// 날짜 선택 다이얼로그를 열어 사용자가 새로운 날짜를 고를 수 있게 한다.
  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  /// Saves the updated transaction to the database and closes the screen.
  /// 수정된 거래를 DB에 저장하고 화면을 닫는다.
  Future<void> save() async {
    final amount = double.tryParse(amountController.text);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }

    final dateStr =
        "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

    final updated = SpendingTransaction(
      t_id: trx.t_id,
      c_id: trx.c_id,
      t_name: titleController.text,
      date: dateStr,
      type: selectedType,
      amount: amount,
      memo: memoController.text,
      isRecurring: isRecurring,
    );

    await TransactionHandler().updateTransaction(updated);
    await settingsController.refreshAllData();
    Get.back(result: true);
  }

  /// Shows a delete confirmation dialog and removes the transaction if confirmed.
  /// 삭제 확인 다이얼로그를 표시하고 사용자가 승인하면 거래를 삭제한다.
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
        Get.back(); // close dialog
        Get.back(result: true); // close detail page
      },
    );
  }
}