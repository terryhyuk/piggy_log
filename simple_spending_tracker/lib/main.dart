import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:simple_spending_tracker/controller/calendar_Controller.dart';
import 'package:simple_spending_tracker/controller/category_Controller.dart';
import 'package:simple_spending_tracker/controller/dashboard_Controller.dart';
import 'package:simple_spending_tracker/controller/setting_Controller.dart';
import 'package:simple_spending_tracker/controller/tabbar_controller.dart';
import 'package:simple_spending_tracker/l10n/app_localizations.dart';
import 'package:simple_spending_tracker/view/widget/mainTabBar.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

    Get.put(TabbarController());

  // Controllerr for setting
  final settingsController = Get.put(SettingsController());
  await settingsController.loadSettings();
    Get.put(DashboardController());
    Get.put(CategoryController());
    Get.put(CalendarController());


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
        home: Maintabbar(),
      ),
    );
  }

}