import 'package:get_x/get.dart';
import 'package:piggy_log/core/db/dashboard_handler.dart';
import 'package:piggy_log/features/calendar/controller/calendar_controller.dart';
import 'package:piggy_log/features/categort/controller/category_controller.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/core/controller/tabbar_controller.dart';
import 'package:piggy_log/features/dashboard/controller/dashboard_controller.dart';

class InitialBinding extends Binding {
  @override
  List<Bind> dependencies() {
    return [
      Bind.put(TabbarController(), permanent: true),
      Bind.put(SettingController(), permanent: true),
      Bind.put(DashboardController(), permanent: true),
      Bind.put(DashboardHandler(), permanent: true),
      Bind.put(CategoryController(), permanent: true),
      Bind.put(CalendarController(), permanent: true),
    ];
  }
}