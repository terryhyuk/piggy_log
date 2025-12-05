import 'package:flutter/material.dart';
import 'package:get_x/route_manager.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_spending_tracker/VM/settings_handler.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/view/pages/transactions.dart';




void main() async{
  WidgetsFlutterBinding.ensureInitialized();  // for local notifications
  await initializeDateFormatting();

  final SettingsHandler settingsHandler = SettingsHandler();
  final settings = await settingsHandler.getSettings();
  final GlobalKey<_MyAppState> appKey = GlobalKey<_MyAppState>();

  if (settings == null) {
    await settingsHandler.insertDefaultSettings();
  }

  // runApp(const MyApp());
  runApp(MyApp(key: appKey));

}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static _MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<_MyAppState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  Locale? _locale;
  static const seedColor = Colors.blue;

  void setLocale(Locale locale){
    _locale = locale;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      locale: _locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,


      themeMode: ThemeMode.system, // default
      darkTheme: ThemeData(
        brightness:  Brightness.dark,
        useMaterial3: true,
        colorSchemeSeed:  seedColor,
      ),

      theme: ThemeData(
      brightness:  Brightness.light,
        useMaterial3: true,
        colorSchemeSeed:  seedColor,
      ),
      home: const Transactions(),
    );
  }

}
