import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get_x/route_manager.dart';
import 'package:simple_spending_tracker/view/pages/dashboard.dart';
import 'package:simple_spending_tracker/view/pages/transactions.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  static const seedColor = Colors.blue;

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      // *************************************
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('ko', 'KR'),
        Locale('en', 'US'),
        Locale('ja', 'JP'),
      ],
      // *************************************

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
