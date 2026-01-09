import 'package:flutter/material.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/core/widget/splash/splash_scrren.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Rebuilds the app whenever SettingProvider notifies changes
    final settings = context.watch<SettingProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piggy Log',
      
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: settings.themeMode == ThemeMode.dark 
            ? Brightness.dark 
            : Brightness.light,
      ),

      // Localization Setup
      locale: settings.locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,

      home: const SplashScreen(),
    );
  }
}