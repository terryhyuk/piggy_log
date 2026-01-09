import 'package:piggy_log/providers/category_provider.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttericon/font_awesome_icons.dart';
import 'package:piggy_log/providers/tab_provider.dart';
import 'package:piggy_log/features/calendar/presentation/calendar_page.dart';
import 'package:piggy_log/features/categort/presentation/category_page.dart';
import 'package:piggy_log/features/dashboard/presentation/dashboard.dart';
import 'package:piggy_log/features/settings/presentation/settings_page.dart';

class MainNavigation extends StatelessWidget {
  const MainNavigation({super.key});

  final List<Widget> _pages = const [
    Dashboard(),
    CategoryPage(),
    CalendarPage(),
    SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    // Property
    final tabProvider = context.watch<TabProvider>();
    final int currentIndex = tabProvider.currentIndex;

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          HapticFeedback.lightImpact();
          context.read<CategoryProvider>().setEditModeFalse();
          tabProvider.changeTabIndex(index);
        },
        type: BottomNavigationBarType.fixed,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        selectedItemColor: Theme.of(context).colorScheme.primary,
        unselectedItemColor: Colors.grey,
        items: [
          _navItem(context, FontAwesome.chart_pie, 0, currentIndex),
          _navItem(context, FontAwesome.tags, 1, currentIndex),
          _navItem(context, FontAwesome.calendar_empty, 2, currentIndex),
          _navItem(context, FontAwesome.cog, 3, currentIndex),      
          ],
        ),
    );
  }

// ---------Functions ----------
BottomNavigationBarItem _navItem (
  BuildContext context,
  IconData icon,
  int index,
  int currentIndex,
){
  final bool isSelected = (index == currentIndex);

  return BottomNavigationBarItem(
    label: '',
    icon: AnimatedContainer(
      duration: const Duration(milliseconds: 100),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: isSelected
        ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.12)
        : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icon, size: 32,
        color: isSelected ? Theme.of(context).colorScheme.primary : Colors.grey,
      ),
      ),
    );
}

}// END