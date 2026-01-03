import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:piggy_log/controller/calendar_controller.dart';
import 'package:piggy_log/controller/category_controller.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/controller/setting_controller.dart';
import 'package:piggy_log/controller/tabbar_controller.dart';
import 'package:piggy_log/fake_data.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/view/splashScrrenPage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting();

    Get.put(TabbarController());

  // Controllerr for setting
  final settingsController = Get.put(SettingController());
  await settingsController.loadSettings();
    Get.put(DashboardController());
    Get.put(DashboardHandler());
    Get.put(CategoryController());
    Get.put(CalendarController());

  // Fake_Data.fill();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final SettingController controller = Get.find<SettingController>();

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Piggy Log',
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
        // home: Maintabbar(),
        home: SplashScreen(),
      ),
    );
  }

}