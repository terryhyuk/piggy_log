import 'package:intl/intl.dart';

String formatCurrency(double amount, String locale, String currency) {
  final format = NumberFormat.currency(locale: Intl.systemLocale);
  return format.format(amount);
}