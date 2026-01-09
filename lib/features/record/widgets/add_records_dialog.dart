import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:piggy_log/data/models/record_model.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';

class AddTransactionDialog extends StatefulWidget {
  final int categoryId;
  final RecordModel? recordToEdit;

  const AddTransactionDialog({
    super.key,
    required this.categoryId,
    this.recordToEdit,
  });

  @override
  State<AddTransactionDialog> createState() => _AddTransactionDialogState();
}

class _AddTransactionDialogState extends State<AddTransactionDialog> {
  late TextEditingController nameController;
  late TextEditingController amountController;
  late TextEditingController memoController;

  String selectedType = 'expense';
  bool isRecurring = false;
  DateTime selectedDateTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    // [Init] Setting up initial values for edit or create mode
    if (widget.recordToEdit != null) {
      final rec = widget.recordToEdit!;
      nameController = TextEditingController(text: rec.name);
      amountController = TextEditingController(text: rec.amount.toString());
      memoController = TextEditingController(text: rec.memo);
      selectedType = rec.type;
      isRecurring = rec.isRecurring;
      selectedDateTime = DateTime.parse(rec.date);
    } else {
      nameController = TextEditingController();
      amountController = TextEditingController();
      memoController = TextEditingController();
      selectedDateTime = DateTime.now();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    amountController.dispose();
    memoController.dispose();
    super.dispose();
  }

  void _handleTypeChange(Set<String> newSelection) {
    selectedType = newSelection.first; 
    setState(() {});
  }

  void _handleRecurringChange(bool? value) {
    isRecurring = value ?? false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final local = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final settingProvider = context.watch<SettingProvider>();

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: SingleChildScrollView(
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
                  widget.recordToEdit == null
                      ? local.addTransaction
                      : local.editTransaction,
                  style: theme.textTheme.titleLarge,
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: TextField(
                  controller: nameController,
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
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                      onSelectionChanged: _handleTypeChange,
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
                      onChanged: _handleRecurringChange,
                    ),
                    Text(local.recurring),
                    const Spacer(),
                    TextButton.icon(
                      onPressed: pickDate,
                      icon: const Icon(Icons.calendar_today, size: 18),
                      label: Text(settingProvider.formatDate(selectedDateTime)),
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
                      onPressed: saveRecord,
                      child: Text(
                        widget.recordToEdit == null ? local.save : local.update,
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

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      selectedDateTime = picked;
      setState(() {});
    }
  }

  Future<void> saveRecord() async {
    final local = AppLocalizations.of(context)!;
    final String name = nameController.text.trim();
    final String amountStr = amountController.text.trim();
    final double? amount = double.tryParse(amountStr);
    final recordProvider = context.read<RecordProvider>();

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

    final record = RecordModel(
      id: widget.recordToEdit?.id,
      categoryId: widget.categoryId,
      name: name,
      date: selectedDateTime.toIso8601String().split('T')[0],
      type: selectedType,
      amount: amount,
      memo: memoController.text.trim(),
      isRecurring: isRecurring,
    );

    if (widget.recordToEdit == null) {
      await recordProvider.addRecord(context, record);
      if (mounted) AppSnackBar.show(context, local.transactionCreated);
    } else {
      await recordProvider.updateRecord(context, record);
      if (mounted) AppSnackBar.show(context, local.transactionUpdated);
    }

    if (mounted) Navigator.pop(context, true);
  }
}