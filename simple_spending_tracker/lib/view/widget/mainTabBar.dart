import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/view/pages/calendar_page.dart';
import 'package:simple_spending_tracker/view/pages/dashboard.dart';
import 'package:simple_spending_tracker/view/pages/settings_page.dart';
import 'package:simple_spending_tracker/view/pages/transactions.dart';
import '../../controller/tabbar_controller.dart';

class Maintabbar extends StatelessWidget {
  Maintabbar({super.key});

  final controller = Get.find<TabbarController>();

  final List<Widget> pages = [
    Dashboard(),
    Transactions(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.index.value,
          children: pages,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.index.value,
          onTap: controller.changeTabIndex,
          type: BottomNavigationBarType.fixed,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.list),
              label: 'Transactions',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.calendar_month),
              label: 'Calendar',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
