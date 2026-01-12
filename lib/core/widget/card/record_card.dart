import 'package:flutter/material.dart';

class RecordCard extends StatelessWidget {
  final Map<String, dynamic> trx;
  final String Function(DateTime) formatDate;
  final String Function(double) formatCurrency;
  final VoidCallback? onTap;

  const RecordCard({
    super.key,
    required this.trx,
    required this.formatDate,
    required this.formatCurrency,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final String? hex = trx['color'];
    Color color = (hex != null && hex.isNotEmpty)
        ? Color(int.parse(hex, radix: 16))
        : theme.colorScheme.primary;

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
          backgroundColor: color.withValues(alpha: 0.1),
          child: Icon(icon, size: 20, color: color),
        ),
        title: Text(trx['name'] ?? 'No Name', style: const TextStyle(fontWeight: FontWeight.w500)),
        subtitle: Text(formatDate(DateTime.parse(trx['date'])), style: const TextStyle(fontSize: 12)),
        trailing: Text(
          formatCurrency((trx['amount'] as num).toDouble()),
          style: TextStyle(
            color: trx['type'] == 'expense' ? Colors.redAccent : Colors.green,
            fontWeight: FontWeight.bold,
          ),
        ),
        onTap: onTap,
      ),
    );
  }
}