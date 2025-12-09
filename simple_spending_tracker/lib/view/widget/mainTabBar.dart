import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:simple_spending_tracker/view/pages/dashboard.dart';
import 'package:simple_spending_tracker/view/pages/settings_page.dart';
import 'package:simple_spending_tracker/view/pages/transactions.dart';

import '../../VM/tabbar_controller.dart';

class Maintabbar extends StatelessWidget {
  Maintabbar({super.key});

  final controller = Get.put(TabbarController());

  final pages = const [
    Dashboard(),
    Transactions(),
    SettingsPage(),
  ];


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: pages[controller.index.value],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.index.value,
          onTap: controller.changeTabIndex,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.dashboard,
                ), 
                label: 'Dashboard',
                ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.list,
                ), 
                label: 'Transactions'
                ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.settings,
                ), 
                label: 'Settings',
                ),
          ],
        ),
      ),
    );
  }
}// END