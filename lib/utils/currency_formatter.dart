import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

String formatCurrency(double amount, {String? locale, String? symbol}) {

  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();

  // Use the system locale if no locale is provided
  final resolvedLocale = (locale == null || locale == "system")
      ? deviceLocale
      : locale;

  final format = NumberFormat.currency( // ignore: deprecated_member_use
    locale: resolvedLocale,
    symbol: symbol == "system" ? null : symbol,
  );

  return format.format(amount); 
}
