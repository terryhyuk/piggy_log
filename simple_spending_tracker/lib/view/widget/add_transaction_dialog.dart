import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/transaction_handler.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
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
      title: Text(
        AppLocalizations.of(context)!.addTransaction,
        ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // TiTLE
          TextField(
            controller: t_nameController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.title),
            keyboardType: TextInputType.text,
          ),
          // AMOUNT
          TextField(
            controller: amountController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.amount,
              ),
            keyboardType: TextInputType.number,
          ),
          // MEMO
          TextField(
            controller: memoController,
            decoration: InputDecoration(
              labelText: AppLocalizations.of(context)!.memo,
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
                  Text(
                    AppLocalizations.of(context)!.expense),
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
                  Text(
                    AppLocalizations.of(context)!.income),
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
              TextButton(
                onPressed: pickDate, 
                child: Text(
                  AppLocalizations.of(context)!.selectDate
                  ),
                  ),
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
              Text(
                AppLocalizations.of(context)!.recurringTransaction
              ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            AppLocalizations.of(context)!.cancel),
        ),
        ElevatedButton(
          onPressed: saveTransaction, 
          child:
            Text(
              AppLocalizations.of(context)!.save,
              ),
            ),
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

  saveTransaction() async {
    if (t_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.pleaseEnterTitle,
            ),
            ),
            );
      return;
    }
    final amount = double.tryParse(amountController.text);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(
        SnackBar(
          content: Text(
            AppLocalizations.of(context)!.enterValidAmount,
            ),
            ),
            );
      return;
    }
    SpendingTransaction transaction = SpendingTransaction(
      c_id: widget.c_id,
      t_name: t_nameController.text,
      date: selectedDateTime.toString(),
      type: selectedType,
      amount: amount,
      memo: memoController.text,
      isRecurring: isRecurring,
    );
    await TransactionHandler().insertTransaction(transaction);
    Navigator.pop(context, true);
  }
} // END
