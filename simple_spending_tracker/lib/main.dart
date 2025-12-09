import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/controller/tabbar_controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/view/pages/dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

  Get.put(TabbarController());

  // Controllerr for setting
  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingsController controller = Get.find<SettingsController>();

    return Obx(
      () => GetMaterialApp(
        title: 'Simple Spending Tracker',
        locale: controller.locale.value,
        themeMode: controller.themeMode.value ?? ThemeMode.system,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        theme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.light,
        ),
        darkTheme: ThemeData(
          useMaterial3: true,
          colorSchemeSeed: Colors.blue,
          brightness: Brightness.dark,
        ),
        home: Dashboard(),
      ),
    );
  }

  // static of(BuildContext context) {}
}

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();
//   await initializeDateFormatting(); // for local notifications

//   final SettingsHandler settingsHandler = SettingsHandler();
//   final Settings? settings = await settingsHandler.getSettings();

//   // If no settings in DB, insert defaults and then re-fetch
//   Settings effectiveSettings;
//   if (settings == null) {
//     await settingsHandler.insertDefaultSettings();
//     effectiveSettings = (await settingsHandler.getSettings())!;
//   } else {
//     effectiveSettings = settings;
//   }

//   // Determine initial Locale and ThemeMode from settings (or system)
//   Locale? initialLocale;
//   if (effectiveSettings.language != 'system') {
//     initialLocale = Locale(effectiveSettings.language);
//   }

//   ThemeMode initialThemeMode;
//   switch (effectiveSettings.theme_mode) {
//     case 'light':
//       initialThemeMode = ThemeMode.light;
//       break;
//     case 'dark':
//       initialThemeMode = ThemeMode.dark;
//       break;
//     default:
//       initialThemeMode = ThemeMode.system;
//   }

//   runApp(
//     MyApp(initialLocale: initialLocale, initialThemeMode: initialThemeMode),
//   );
// }

// class MyApp extends StatefulWidget {
  
//   final Locale? initialLocale;
//   final ThemeMode initialThemeMode;

//   const MyApp({
//     super.key,
//     this.initialLocale,
//     this.initialThemeMode = ThemeMode.system,
//   });

//   // convenience accessor
//   static _MyAppState? of(BuildContext context) =>
//       context.findAncestorStateOfType<_MyAppState>();

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   Locale? _locale;
//   static const seedColor = Colors.blue;

//   @override
//   void initState() {
//     super.initState();
//     _locale = widget.initialLocale;
//   }

//   // Public setters
//   void setLocale(Locale? locale) {
//     _locale = locale;
//     setState(() {});
//   }

//   @override
//   Widget build(BuildContext context) {

//     return GetMaterialApp(
//       title: 'Flutter Demo',
//       locale: _locale,
//       themeMode: Get.find<SettingsController>().themeMode.value ?? ThemeMode.system,
//       localizationsDelegates: AppLocalizations.localizationsDelegates,
//       supportedLocales: AppLocalizations.supportedLocales,
//       darkTheme: ThemeData(
//         brightness: Brightness.dark,
//         useMaterial3: true,
//         colorSchemeSeed: seedColor,
//       ),
//       theme: ThemeData(
//         brightness: Brightness.light,
//         useMaterial3: true,
//         colorSchemeSeed: seedColor,
//       ),
//       home: const Transactions(),
//     );
//   }
// }