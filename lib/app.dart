import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/core/controller/tabbar_controller.dart';
import 'package:piggy_log/core/db/dashboard_handler.dart';
import 'package:piggy_log/core/widget/splash/splash_scrren.dart';
import 'package:piggy_log/features/calendar/controller/calendar_controller.dart';
import 'package:piggy_log/features/categort/controller/category_controller.dart';
import 'package:piggy_log/features/dashboard/controller/dashboard_controller.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Piggy Log',
      
      // [Dependency Injection] Initialize controllers using the latest binds list syntax
      binds: [
        Bind.put(TabbarController(), permanent: true),
        Bind.put(SettingController(), permanent: true),
        Bind.put(DashboardController(), permanent: true),
        Bind.put(DashboardHandler(), permanent: true),
        Bind.put(CategoryController(), permanent: true),
        Bind.put(CalendarController(), permanent: true),
      ],

      // [Reactive Theme & Locale] Accessing controllers after initialization
      builder: (context, child) {
        return GetX<SettingController>(
          builder: (controller) {
            if (!Get.isRegistered<DashboardController>()) {
              Get.put(DashboardController(), permanent: true);
            }
            return Theme(
              data: ThemeData(
                useMaterial3: true,
                colorSchemeSeed: Colors.blue,
                brightness: controller.themeMode.value == ThemeMode.dark 
                    ? Brightness.dark 
                    : Brightness.light,
              ),
              child: child!,
            );
          },
        );
      },

      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      
      home: const SplashScreen(),
    );
  }
}