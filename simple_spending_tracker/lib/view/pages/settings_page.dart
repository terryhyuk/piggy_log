import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/VM/settings_handler.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/model/settings.dart';
import 'package:simple_spending_tracker/view/widget/language_sheet.dart';

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

    // if null, create default and insert to DB
    if (result == null) {
      settings = Settings(
        id: 1,
        language: 'system',
        currency_code: 'system',
        currency_symbol: '\$',
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
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        children: [
          ListTile(
            title: Text('Language'),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: _change_language,
          ),
          ListTile(
            title: Text('Theme'),
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
            title: Text('Currency'),
            subtitle: Text(settings.currency_code),
            trailing: PopupMenuButton<String>(
              onSelected: _changeCurrency,
              itemBuilder: (_) => [
                  const PopupMenuItem(value: 'system', child: Text('System')),
                  const PopupMenuItem(value: 'USD', child: Text('USD - \$')),
                  const PopupMenuItem(value: 'KRW', child: Text('KRW - ₩')),
                  const PopupMenuItem(value: 'CAD', child: Text('CAD - \$')),
                  const PopupMenuItem(value: 'JPY', child: Text('JPY - ¥')),
              ],
            ),
          ),
          ListTile(
            title: Text('Date Format'),
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
    };

    final data = currencies[currencyCode]!;
    settings.currency_symbol = data['symbol']!;
    settings.currency_code = data['code']!;

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
