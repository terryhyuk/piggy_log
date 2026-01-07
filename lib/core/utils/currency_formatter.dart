import 'package:intl/intl.dart';
import 'package:flutter/widgets.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent:
//    Provides a standardized financial data representation across the application.
//    Supports dynamic locale resolution by prioritizing user preferences 
//    while falling back to system-level platform settings.
// -----------------------------------------------------------------------------

/// Converts a numeric amount into a localized currency string.
String formatCurrency(double amount, {String? locale, String? symbol}) {

  // 1. System Context Discovery:
  // Accesses the device's native locale through the PlatformDispatcher.
  final deviceLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();

  // 2. Logic Resolution:
  // Determines whether to use a specific user-defined locale or the system default.
  final resolvedLocale = (locale == null || locale == "system")
      ? deviceLocale
      : locale;

  // 3. Formatting Engine Initialization:
  // Leverages the 'intl' package's NumberFormat to handle complex 
  // currency positioning and digit grouping (e.g., 1,000 vs 1.000).
  final format = NumberFormat.currency(
    locale: resolvedLocale,
    // When symbol is 'system', passing null allows NumberFormat to use 
    // the standard symbol for that specific locale.
    symbol: symbol == "system" ? null : symbol,
  );

  return format.format(amount); 
}