import 'package:intl/intl.dart';

String formatCurrency(double amount, String locale, String currency) {
  return NumberFormat.currency(
    locale: locale, 
    symbol: '',
    name: currency).format(amount);
}