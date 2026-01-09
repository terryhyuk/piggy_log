import 'package:flutter/material.dart';
import 'package:piggy_log/core/utils/app_snackbar.dart';
import 'package:piggy_log/features/record/presentation/records_detail.dart';
import 'package:piggy_log/features/record/widgets/add_records_dialog.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:piggy_log/data/models/record_model.dart';

class RecordsList extends StatefulWidget {
  final int categoryId;

  const RecordsList({super.key, required this.categoryId});

  @override
  State<RecordsList> createState() => _TransactionListState();
}

class _TransactionListState extends State<RecordsList> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RecordProvider>().fetchRecords(widget.categoryId);
    });
  }

  Future<void> _goToDetail(RecordModel rec) async {
    final bool? isUpdated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const RecordsDetail(),
        settings: RouteSettings(arguments: rec),
      ),
    );

    if (isUpdated == true && mounted) {
      context.read<RecordProvider>().fetchRecords(widget.categoryId);
    }
  }

  Future<void> _openEditDialog(RecordModel rec) async {
    final bool? isUpdated = await showDialog<bool>(
      context: context,
      builder: (_) => AddTransactionDialog(
        categoryId: widget.categoryId,
        recordToEdit: rec,
      ),
    );

    if (isUpdated == true && mounted) {
      context.read<RecordProvider>().fetchRecords(widget.categoryId);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final local = AppLocalizations.of(context)!;
    final recordProvider = context.watch<RecordProvider>();
    final settingProvider = context.watch<SettingProvider>();

    final records = recordProvider.records;

    if (records.isEmpty) {
      return Center(
        child: Text(local.noTransactionsFound, style: const TextStyle(fontSize: 16)),
      );
    }

    return ListView.builder(
      itemCount: records.length,
      itemBuilder: (context, index) {
        final rec = records[index];
        final date = DateTime.parse(rec.date);

        return Slidable(
          key: ValueKey(rec.id),
          endActionPane: ActionPane(
            motion: const DrawerMotion(),
            children: [
              // [Update] Inline edit via dialog
              SlidableAction(
                onPressed: (_) => _openEditDialog(rec),
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                foregroundColor: theme.colorScheme.primary,
                icon: Icons.edit,
                label: 'Edit',
              ),

              // [Delete] Remove transaction with confirmation
              SlidableAction(
                onPressed: (_) async {
                  bool? confirmed = await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title: Text(local.confirmDelete),
                      content: Text("'${rec.name}' ${local.deleteConfirm}"),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context, false), 
                          child: Text(local.cancel)
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(
                            local.delete, 
                            style: TextStyle(color: theme.colorScheme.error)
                          ),
                        ),
                      ],
                    ),
                  );

                  if (confirmed == true && mounted) {
                    await recordProvider.deleteRecord(context, rec.id!, widget.categoryId);
                    if (context.mounted) {
                      AppSnackBar.show(context, local.deleted, isError: true);
                    }
                  }
                },
                backgroundColor: theme.colorScheme.errorContainer,
                foregroundColor: theme.colorScheme.onErrorContainer,
                icon: Icons.delete,
                label: 'Delete',
              ),
            ],
          ),
          child: ListTile(
            title: Text(rec.name),
            subtitle: Text(settingProvider.formatDate(date)),
            trailing: Text(
              settingProvider.formatCurrency(rec.amount),
              style: TextStyle(
                color: rec.type == 'expense' 
                    ? theme.colorScheme.error 
                    : theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: () => _goToDetail(rec),
          ),
        );
      },
    );
  }
}