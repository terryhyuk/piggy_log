import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class RecentTransactionsList extends StatelessWidget {
  final List<Map<String, dynamic>> transactions;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;

  const RecentTransactionsList({
    super.key,
    required this.transactions,
    required this.formatDate,
    required this.formatCurrency,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.recentTransactions,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),

        ...transactions.map((trx) {
          final String? hex = trx['color'];
  Color color;
  
  if (hex != null && hex.isNotEmpty) {
    try {
      color = Color(int.parse(hex, radix: 16));
    } catch (e) {
      // Fallback color in case of parsing error
      color = theme.colorScheme.primary;
    }
  } else {
    color = theme.colorScheme.primary;
  }

  final Color bgColor = color.withValues(alpha: 0.1);

  // [Icon Handling] Reconstructing IconData from DB metadata
  final int code = trx['icon_codepoint'] ?? 0;
  final IconData icon = (code != 0)
      ? IconData(
          code,
          fontFamily: trx['icon_font_family'],
          fontPackage: trx['icon_font_package'],
        )
      : Icons.category;

          return Card(
            elevation: 0,
            margin: const EdgeInsets.symmetric(vertical: 4),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
            ),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: bgColor,
                child: Icon(icon, size: 20, color: color),
              ),
              title: Text(
                trx['name'] ?? 'No Name',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                formatDate(DateTime.parse(trx['date'])),
                style: TextStyle(
                  color: theme.colorScheme.onSurfaceVariant, 
                  fontSize: 12,
                ),
              ),
              trailing: Text(
                formatCurrency((trx['amount'] as num).toDouble()),
                style: TextStyle(
                  color: trx['type'] == 'expense' 
                      ? Colors.redAccent 
                      : Colors.green,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }),
      ],
    );
  }
}