import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:get_x/get.dart';
import 'package:piggy_log/view/pages/calendar_page.dart';
import 'package:piggy_log/view/pages/category_page.dart';
import 'package:piggy_log/view/pages/dashboard.dart';
import 'package:piggy_log/view/pages/settings_page.dart';
import '../../controller/tabbar_controller.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Core navigation hub using IndexedStack to preserve widget state across tabs. 
//    Focuses on responsive feedback and smooth visual transitions.
//
//  * TODO: 
//    - Decouple Page list into a separate Navigation Service.
//    - Improve dependency injection by using GetView or deferred initialization.
// -----------------------------------------------------------------------------

class Maintabbar extends StatelessWidget {
  Maintabbar({super.key});

  final controller = Get.find<TabbarController>();

  /// Navigation pages preserved via IndexedStack.
  final List<Widget> pages = [
    Dashboard(),
    CategoryPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        /// IndexedStack ensures that page states (scroll position, etc.) are maintained.
        body: IndexedStack(index: controller.index.value, children: pages),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.index.value,
          onTap: (i) {
            // Native tactile feedback for enhanced mobile UX.
            HapticFeedback.lightImpact();
            controller.changeTabIndex(i);
          },
          type: BottomNavigationBarType.fixed,
          showSelectedLabels: false,
          showUnselectedLabels: false,
          selectedItemColor: Theme.of(context).colorScheme.primary,
          unselectedItemColor: Colors.grey,
          items: [
            _navItem(context, FontAwesome.chart_pie, 0),
            _navItem(context, FontAwesome.tags, 1),
            _navItem(context, FontAwesome.calendar_empty, 2),
            _navItem(context, FontAwesome.cog, 3),
          ],
        ),
      ),
    );
  }

  /// Helper for building BottomNavigationBarItems with selection animations.
  BottomNavigationBarItem _navItem(
    BuildContext context,
    IconData icon,
    int index,
  ) {
    final isSelected = controller.index.value == index;

    return BottomNavigationBarItem(
      label: '',
      icon: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, size: 32),
      ),
    );
  }
}