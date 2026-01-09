import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/data/models/record_model.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';

class RecordsDetail extends StatefulWidget {
  const RecordsDetail({super.key});

  @override
  State<RecordsDetail> createState() => _TransactionsDetailState();
}

class _TransactionsDetailState extends State<RecordsDetail> {
  late RecordModel record;

  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  late DateTime selectedDate;
  late String selectedType;
  late bool isRecurring;

  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_isInitialized) {
      record = ModalRoute.of(context)!.settings.arguments as RecordModel;

      nameController = TextEditingController(text: record.name);
      amountController = TextEditingController(text: record.amount.toString());
      memoController = TextEditingController(text: record.memo);

      selectedDate = DateTime.parse(record.date);
      selectedType = record.type;
      isRecurring = record.isRecurring;
      _isInitialized = true;
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settingProvider = context.watch<SettingProvider>();
    final recordProvider = context.read<RecordProvider>();

    return Scaffold(
      appBar: AppBar(
        actions: [
          TextButton(
            onPressed: () => _confirmDelete(recordProvider, local),
            child: Text(
              local.delete,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(
                  labelText: local.description,
                ), // [FIX] title -> description
              ),
              const SizedBox(height: 16),
              TextField(
                controller: amountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: InputDecoration(labelText: local.amount),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: memoController,
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: local.memo,
                  alignLabelWithHint: true,
                  border: const OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(settingProvider.formatDate(selectedDate)),
                  TextButton(
                    onPressed: _pickDate,
                    child: Text(local.selectDate),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(local.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _save(recordProvider, local),
                      child: Text(local.update),
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

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) selectedDate = picked;
    setState(() {});
  }

  Future<void> _save(RecordProvider provider, AppLocalizations local) async {
    final String name = nameController.text.trim();
    final String amountStr = amountController.text.trim();
    final double? amount = double.tryParse(amountStr);

    // [Validation] Check for empty name or invalid amount
    if (name.isEmpty) {
      AppSnackBar.show(context, local.pleaseEnterDescription, isError: true);
      return;
    }
    if (amountStr.isEmpty) {
      AppSnackBar.show(context, local.pleaseEnterAmount, isError: true);
      return;
    }
    if (amount == null || amount <= 0) {
      AppSnackBar.show(context, local.invalidAmount, isError: true);
      return;
    }

    final String dbDate = selectedDate.toIso8601String().split('T')[0];

    final updated = record.copyWith(
      name: name,
      amount: amount,
      date: dbDate,
      type: selectedType,
      memo: memoController.text.trim(),
      isRecurring: isRecurring,
    );

    await provider.updateRecord(context, updated);

    if (mounted) {
      Navigator.pop(context, true);
      // Show success snackbar on the previous screen
      AppSnackBar.show(context, local.transactionUpdated);
    }
  }

  Future<void> _confirmDelete(
    RecordProvider provider,
    AppLocalizations local,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(local.deleteTransaction),
        content: Text(local.deleteTransactionConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(local.cancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              local.delete,
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await provider.deleteRecord(context, record.id!, record.categoryId);

      if (mounted) {
        Navigator.pop(context, true);
        // Show delete notification on the previous screen
        AppSnackBar.show(context, local.deleted, isError: true);
      }
    }
  }
}
