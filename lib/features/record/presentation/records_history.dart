import 'package:flutter/material.dart';
import 'package:piggy_log/data/models/category_model.dart';
import 'package:piggy_log/features/categort/widget/build_header.dart';
import 'package:piggy_log/features/record/widgets/add_records_dialog.dart';
import 'package:piggy_log/features/record/widgets/records_list.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';

class TransactionsHistory extends StatefulWidget {
  const TransactionsHistory({super.key});

  @override
  State<TransactionsHistory> createState() => _TransactionsHistoryState();
}

class _TransactionsHistoryState extends State<TransactionsHistory> {
  CategoryModel? _category;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // [Logic] Initialize only if it hasn't been set yet
    if (_category == null) {
      final arg = ModalRoute.of(context)?.settings.arguments;
      if (arg is CategoryModel) {
        _category = arg;
      } else {
        // Fallback for safety if arguments are missing
        _category = CategoryModel(
          iconCodePoint: Icons.category.codePoint,
          color: "FF808080",
          name: "Unknown",
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Show loading or empty if category is not yet loaded
    if (_category == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            BuildHeader(
              category: _category!, // Using bang operator safely
              onAddTap: () => _openAddTransactionDialog(),
            ),
            Expanded(child: RecordsList(categoryId: _category!.id ?? 0)),
          ],
        ),
      ),
    );
  }

  /// Opens the dialog with necessary Providers injected
  Future<void> _openAddTransactionDialog() async {
    if (_category == null) return;

    // Fetch providers from current context before entering dialog scope
    final recordProvider = context.read<RecordProvider>();
    final settingProvider = context.read<SettingProvider>();

    await showDialog(
      context: context,
      builder: (dialogContext) => MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: recordProvider),
          ChangeNotifierProvider.value(value: settingProvider),
        ],
        child: AddTransactionDialog(categoryId: _category!.id!),
      ),
    );

    // Refresh UI if necessary when dialog closes
    if (mounted) setState(() {});
  }
}
