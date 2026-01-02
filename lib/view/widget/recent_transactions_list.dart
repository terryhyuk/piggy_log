import 'package:flutter/material.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Displaying a streamlined list of recent activities with a focus on 
//    visual hierarchy and custom color blending for a premium UI feel.
//
//  * TODO: 
//    - Abstract the 'Transaction Card' into a separate reusable widget.
//    - Add a 'View All' navigation trigger for better user flow.
// -----------------------------------------------------------------------------

class RecentTransactionsList extends StatelessWidget {
  final List transactions;
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

        /// Builds dynamic transaction cards with sophisticated UI styling.
        ...transactions.map((trx) {
          // [Logic] Dynamic Color Parsing
          final String? hex = trx['color'];
          final Color color = (hex != null && hex.length == 8)
              ? Color(int.parse(hex, radix: 16))
              : Colors.grey;

          // [Design] Color Blending Strategy
          // Blending the category color with the surface color using lerp 
          // to achieve a cohesive 'Material 3' look.
          final Color bgColor = Color.lerp(theme.colorScheme.surface, color, 0.15)!;

          // [Logic] Icon Reconstruction from DB metadata
          final int? code = trx['icon_codepoint'] as int?;
          final IconData icon = (code != null && code != 0)
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
                trx['t_name'] ?? 'No Name',
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
                formatCurrency(trx['amount']),
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