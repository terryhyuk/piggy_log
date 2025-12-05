import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:simple_spending_tracker/VM/settings_handler.dart';
import 'package:simple_spending_tracker/main.dart';
import 'package:simple_spending_tracker/model/settings.dart';
import 'package:simple_spending_tracker/view/widget/language_sheet.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
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
        currency_code: 'CAD',
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
            title: const Text('Language'),
            subtitle: Text(settings.language),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () async {
              final result = await showModalBottomSheet(
                context: context,
                builder: (_) => LanguageSheet(currentLanguage: settings.language),
              );
              if (result != null && result is Map<String, dynamic>) {
                settings.language = result['code'];
                await SettingsHandler().updateSettings(settings);
                // update locale
                Locale newLocale = Locale(result['code']);
                MyApp.of(context)?.setLocale(newLocale);
                
                setState(() {});
              }
            },
          ),
        ],
      ),
    );
  }
}
