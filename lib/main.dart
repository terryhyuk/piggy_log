import 'package:flutter/widgets.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:piggy_log/app.dart';
import 'package:piggy_log/core/database/database_service.dart';
import 'package:piggy_log/core/database/repository/calendar_repository.dart';
import 'package:piggy_log/core/database/repository/category_repository.dart';
import 'package:piggy_log/core/database/repository/dashboard_repasitory.dart';
import 'package:piggy_log/core/database/repository/record_repository.dart';
import 'package:piggy_log/core/database/repository/settings_repository.dart';
import 'package:piggy_log/providers/calendar_provider.dart';
import 'package:piggy_log/providers/category_provider.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';
import 'package:piggy_log/providers/record_provider.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:piggy_log/providers/tab_provider.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await initializeDateFormatting();

  // Initialize the database service and open connection
  final dbService = DatabaseService(); 
  await dbService.database; 

  // Repositories 
  final categoryRepo = CategoryRepository();
  final dashboardRepo = DashboardRepository();
  final calendarRepo = CalendarRepository();
  final settingRepo = SettingsRepository(); 
  final recordRepo = RecordRepository();

  runApp(
    MultiProvider(
      providers: [
        // SettingProvider should be first as others might depend on it
        ChangeNotifierProvider(create: (_) => SettingProvider(settingRepo)),
        ChangeNotifierProvider(create: (_) => TabProvider()),
        ChangeNotifierProvider(create: (_) => CategoryProvider(categoryRepo)),
        ChangeNotifierProvider(
          create: (_) => DashboardProvider(dashboardRepo, recordRepo),
        ),
        ChangeNotifierProvider(create: (_) => CalendarProvider(calendarRepo)),
        ChangeNotifierProvider(create: (_) => RecordProvider(recordRepo)),
      ],
      child: const App(),
    ),
  );
}