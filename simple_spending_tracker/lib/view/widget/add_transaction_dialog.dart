import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/model/spending_transaction.dart';

class AddTransactionDialog extends StatefulWidget {
  final int c_id;

  const AddTransactionDialog({super.key, required this.c_id});

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  // Property
  final TextEditingController amountController = TextEditingController();
  final TextEditingController memoController = TextEditingController();
  final TextEditingController t_nameController = TextEditingController();

  String selectedType = 'expense'; // expense / income
  bool isRecurring = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Transaction'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          // TiTLE
          TextField(
            controller: t_nameController,
            decoration: const InputDecoration(
              labelText: 'Title',
              ),
            keyboardType: TextInputType.text,
          ),

          // AMOUNT
          TextField(
            controller: amountController,
            decoration: const InputDecoration(
              labelText: 'Amount',
              ),
            keyboardType: TextInputType.number,
          ),

          // MEMO
          TextField(
            controller: memoController,
            decoration: const InputDecoration(
              labelText: 'Memo',
              ),
            keyboardType: TextInputType.text,
            maxLines: 2,
          ),

          const SizedBox(height: 16),

          // TYPE RADIO
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Column(
                children: [
                  Radio(
                    value: 'expense',
                    groupValue: selectedType,
                    onChanged: (v) => updateType(v.toString()),
                  ),
                  const SizedBox(height: 4),
                  const Text('Expense'),
                ],
              ),
              Column(
                children: [
                  Radio(
                    value: 'income',
                    groupValue: selectedType,
                    onChanged: (v) => updateType(v.toString()),
                  ),
                  const SizedBox(height: 4),
                  const Text('Income'),
                ],
              ),
            ],
          ),

          const SizedBox(height: 8),

          // DATE PICKER
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                DateFormat('yyyy-MM-dd').format(selectedDateTime),
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextButton(onPressed: pickDate, child: const Text("Select Date")),
            ],
          ),

          const SizedBox(height: 8),

          // RECURRING SWITCH
          Row(
            children: [
              Checkbox(
                value: isRecurring,
                onChanged: (v) => updateRecurring(v ?? false),
              ),
              const Text("Recurring Transaction"),
            ],
          ),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(onPressed: saveTransaction, child: const Text('Save')),
      ],
    );
  }

  // --- Functions ---

  updateRecurring(bool v) {
    isRecurring = v;
    setState(() {});
  }

  updateType(String v) {
    selectedType = v;
    setState(() {});
  }

  pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() => selectedDateTime = picked);
    }
  }

  saveTransaction() async{
    if (t_nameController.text.trim().isEmpty) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(content: Text('Please enter a title')),
  );
  return;
}else{
    SpendingTransaction transaction = SpendingTransaction(
      c_id: widget.c_id, 
      t_name: t_nameController.text, 
      date: selectedDateTime.toString(), 
      type: selectedType,
      amount: double.tryParse(amountController.text) ?? 0.0, 
      memo: memoController.text, 
      isRecurring: isRecurring,
    );

    await TransactionHandler().insertTransaction(transaction);
}
    Navigator.pop(context, true);
  }


  
}// END
