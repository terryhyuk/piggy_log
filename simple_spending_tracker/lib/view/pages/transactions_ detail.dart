import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/model/spending_transaction.dart';

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

    trx = Get.arguments as SpendingTransaction;

    titleController = TextEditingController(text: trx.t_name);
    amountController =
        TextEditingController(text: trx.amount.toString());
    memoController = TextEditingController(text: trx.memo);

    selectedDate = DateTime.parse(trx.date);
    selectedType = trx.type;
    isRecurring = trx.isRecurring;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final deleteColor =
        isDark ? Colors.red.shade300 : Colors.red.shade700;

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
              'Delete',
              style: TextStyle(
                color: deleteColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                ),
              ),
              const SizedBox(height: 16),

              // Amount
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Amount',
                ),
              ),
              const SizedBox(height: 16),

              // Type
              Row(
                children: [
                  Radio(
                    value: 'expense',
                    groupValue: selectedType,
                    onChanged: (v) =>
                        setState(() => selectedType = v.toString()),
                  ),
                  const Text('Expense'),
                  const SizedBox(width: 20),
                  Radio(
                    value: 'income',
                    groupValue: selectedType,
                    onChanged: (v) =>
                        setState(() => selectedType = v.toString()),
                  ),
                  const Text('Income'),
                ],
              ),
              const SizedBox(height: 16),

              // Date
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    DateFormat.yMMMd().format(selectedDate),
                    style: theme.textTheme.bodyMedium,
                  ),
                  TextButton(
                    onPressed: pickDate,
                    child: const Text('Select date'),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Memo
              TextField(
                controller: memoController,
                maxLines: 3,
                decoration: const InputDecoration(
                  labelText: 'Memo',
                ),
              ),
              const SizedBox(height: 16),

              // Recurring
              Row(
                children: [
                  Checkbox(
                    value: isRecurring,
                    onChanged: (v) =>
                        setState(() => isRecurring = v ?? false),
                  ),
                  const Text('Recurring'),
                ],
              ),

              const Spacer(),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: save,
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Functions ---

  pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

save() async {
    final amount = double.tryParse(amountController.text);
    if (titleController.text.trim().isEmpty || amount == null || amount <= 0) {
      return;
    }

    final dateStr = "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

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

    // 1. DB 업데이트
    await TransactionHandler().updateTransaction(updated);

    // 2. ✅ 모든 페이지 갱신 (SettingsController에 만든 함수 호출)
    await settingsController.refreshAllData();

    // 3. 페이지 닫기
    Get.back(result: true);
  }

  deleteTransaction() {
    Get.defaultDialog(
      title: 'Delete transaction',
      middleText: 'Are you sure you want to delete this transaction?',
      textCancel: 'Cancel',
      textConfirm: 'Delete',
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        // 1. DB 삭제
        await TransactionHandler().deleteTransaction(trx.t_id!);
        
        // 2. ✅ 모든 페이지 갱신
        await settingsController.refreshAllData();

        Get.back(); // 다이얼로그 닫기
        Get.back(result: true); // 상세 페이지 닫기
      },
    );
  }
//   save() async {
//     final amount = double.tryParse(amountController.text);
//     if (titleController.text.trim().isEmpty ||
//         amount == null ||
//         amount <= 0) {
//       return;
//     }

//     final dateStr =
//         "${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}";

//     final updated = SpendingTransaction(
//       t_id: trx.t_id,
//       c_id: trx.c_id,
//       t_name: titleController.text,
//       date: dateStr,
//       type: selectedType,
//       amount: amount,
//       memo: memoController.text,
//       isRecurring: isRecurring,
//     );

//     await TransactionHandler().updateTransaction(updated);

//     Get.back(result: true);
//   }

//   deleteTransaction() {
//   Get.defaultDialog(
//     title: 'Delete transaction',
//     middleText: 'Are you sure you want to delete this transaction?',
//     textCancel: 'Cancel',
//     textConfirm: 'Delete',
//     confirmTextColor: Colors.white,
//     buttonColor: Colors.red,
//     cancelTextColor: Theme.of(context).colorScheme.onSurface,
//     onConfirm: () async {
//       await TransactionHandler().deleteTransaction(trx.t_id!);
//       Get.back(); // close dialog
//       Get.back(result: true); // close detail page
//     },
//   );
// }

}
