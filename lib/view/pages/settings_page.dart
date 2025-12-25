import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/settings_handler.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/model/settings.dart';
import 'package:piggy_log/view/widget/language_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  // Property
  late Settings settings;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

Future<void> loadSettings() async {
  final handler = SettingsHandler();
  final result = await handler.getSettings();

  if (result == null) {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final String localeString = locale.toString();

    int? digits = (localeString.contains('ko') || localeString.contains('ja')) ? 0 : null;

    final format = NumberFormat.simpleCurrency(
      locale: localeString, 
      decimalDigits: digits
    );

    settings = Settings(
      id: 1,
      language: 'system',
      currency_code: 'system',
      currency_symbol: format.currencySymbol, 
      date_format: 'yyyy-MM-dd',
      theme_mode: 'system',
    );
    await handler.insertDefaultSettings();
  } else {
    settings = result;
  }
  isLoaded = true;
  setState(() {});
}

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.settings,
          ),
        ),
      body: ListView(
        children: [
          ListTile(
            title: Text(
                AppLocalizations.of(context)!.language,
                ),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _change_language,
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.theme,
              ),
            subtitle: Text(settings.theme_mode),
            trailing: PopupMenuButton<String>(
              onSelected: _change_mode,
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'system', child: Text('System')),
                const PopupMenuItem(value: 'light', child: Text('Light')),
                const PopupMenuItem(value: 'dark', child: Text('Dark')),
              ],
            ),
          ),
          ListTile(
            title: Text(
              AppLocalizations.of(context)!.currency,
              ),
            subtitle: Text(settings.currency_code),
            trailing: PopupMenuButton<String>(
              onSelected: _changeCurrency,
              itemBuilder: (_) => [
                  const PopupMenuItem(value: 'system', child: Text('System')),
                  const PopupMenuItem(value: 'USD', child: Text('USD - \$')),
                  const PopupMenuItem(value: 'KRW', child: Text('KRW - ₩')),
                  const PopupMenuItem(value: 'CAD', child: Text('CAD - \$')),
                  const PopupMenuItem(value: 'JPY', child: Text('JPY - ¥')),
                  const PopupMenuItem(value: 'THB', child: Text('THB - ฿'))
              ],
            ),
          ),
          ListTile(
            title: Text(
                AppLocalizations.of(context)!.dateformat,
                ),
            subtitle: Text(settings.date_format),
            trailing: PopupMenuButton<String>(
              onSelected: _changeDateFormat,
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'yyyy-MM-dd',
                  child: Text('2025-12-08'),
                ),
                const PopupMenuItem(
                  value: 'MM/dd/yyyy',
                  child: Text('12/08/2025'),
                ),
                const PopupMenuItem(
                  value: 'dd/MM/yyyy',
                  child: Text('08/12/2025'),
                ),
                const PopupMenuItem(
                  value: 'MMM d, yyyy',
                  child: Text('Dec 8, 2025'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Fuctions

  _change_language() async {
    final result = await showModalBottomSheet(
      context: context,
      builder: (_) => LanguageSheet(currentLanguage: settings.language),
    );
    if (result != null && result is Map<String, dynamic>) {
      settings.language = result['code'];
      await SettingsHandler().updateSettings(settings);
      // update locale
      if (result['code'] != 'system') {
      Get.find<SettingsController>().setLanguage(result['code']);
    }
      setState(() {});
    }
  }

  _change_mode(String themeMode) async {
    settings.theme_mode = themeMode;
    await SettingsHandler().updateSettings(settings);  
    Get.find<SettingsController>().setThemeMode(themeMode);
    setState(() {});
  }

  _changeCurrency(String currencyCode) async {
  final currencies = {
    'USD': {'symbol': '\$', 'code': 'USD'},
    'CAD': {'symbol': '\$', 'code': 'CAD'},
    'KRW': {'symbol': '₩', 'code': 'KRW'},
    'JPY': {'symbol': '¥', 'code': 'JPY'},
    'THB': {'symbol': '฿', 'code': 'THB'},
  };

  if (currencyCode == 'system') {
    // get system locale
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    final format = NumberFormat.simpleCurrency(locale: locale.toString());
    
    settings.currency_code = 'system'; 
    settings.currency_symbol = format.currencySymbol; // system local symbol 
  } else {
    final data = currencies[currencyCode]!;
    settings.currency_symbol = data['symbol']!;
    settings.currency_code = data['code']!;
  }

  await SettingsHandler().updateSettings(settings);
  Get.find<SettingsController>().setCurrency(currencyCode);
  setState(() {});
}

  _changeDateFormat(String format) async {
    settings.date_format = format;
    await SettingsHandler().updateSettings(settings);
    Get.find<SettingsController>().setDateFormat(format);
    setState(() {});
  }

} // END
