import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/controller/dashboard_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/model/spending_transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final int c_id;
  final SpendingTransaction? transactionToEdit; // 수정용 optional

  const AddTransactionDialog({super.key, required this.c_id, this.transactionToEdit});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TextEditingController t_nameController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  String selectedType = 'expense';
  bool isRecurring = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
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
    return AlertDialog(
      title: Text(widget.transactionToEdit == null ? 'Add Transaction' : 'Edit Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 기존 AddTransactionDialog 내용 그대로
          TextField(controller: t_nameController, decoration: const InputDecoration(labelText: 'Title')),
          TextField(controller: amountController, decoration: const InputDecoration(labelText: 'Amount'), keyboardType: TextInputType.number),
          TextField(controller: memoController, decoration: const InputDecoration(labelText: 'Memo'), maxLines: 2),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Radio(value: 'expense', groupValue: selectedType, onChanged: (v) => setState(() => selectedType = v!)),
              const Text('Expense'),
              Radio(value: 'income', groupValue: selectedType, onChanged: (v) => setState(() => selectedType = v!)),
              const Text('Income'),
            ],
          ),
          Row(
            children: [
              Checkbox(value: isRecurring, onChanged: (v) => setState(() => isRecurring = v!)),
              const Text('Recurring'),
            ],
          ),
          TextButton(onPressed: pickDate, child: Text(DateFormat('yyyy-MM-dd').format(selectedDateTime))),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
        ElevatedButton(
          onPressed: saveTransaction,
          child: Text(widget.transactionToEdit == null ? 'Save' : 'Update'),
        ),
      ],
    );
  }

  pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => selectedDateTime = picked);
  }

  saveTransaction() async {
    final amount = double.tryParse(amountController.text);

    if (t_nameController.text.trim().isEmpty || amount == null || amount <= 0) return;

    SpendingTransaction trx = SpendingTransaction(
      t_id: widget.transactionToEdit?.t_id,
      c_id: widget.c_id,
      t_name: t_nameController.text,
      date: "${selectedDateTime.year}-${selectedDateTime.month.toString().padLeft(2,'0')}-${selectedDateTime.day.toString().padLeft(2,'0')}",
      type: selectedType,
      amount: amount,
      memo: memoController.text,
      isRecurring: isRecurring,
    );

    if (widget.transactionToEdit == null) {
      await TransactionHandler().insertTransaction(trx, customDate: selectedDateTime);
    } else {
      await TransactionHandler().updateTransaction(trx);
    }

    // Dashboard refresh
    final controller = Get.find<DashboardController>();
    await controller.refreshDashboard();

    // calendar refresh
    final settingsController = Get.find<SettingsController>();
    settingsController.refreshTrigger.value++;

    Navigator.pop(context, true);
  }
}

