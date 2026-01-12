import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:piggy_log/core/widget/splash/splash_scrren.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:sqflite/sqflite.dart';
import 'package:piggy_log/core/database/database_service.dart';
import 'package:piggy_log/core/database/repository/settings_repository.dart';
import 'package:piggy_log/data/models/settings.dart';
import 'package:piggy_log/providers/calendar_provider.dart';
import 'package:piggy_log/providers/dashboard_provider.dart';

class SettingProvider with ChangeNotifier {
  final SettingsRepository _repository;

  SettingsModel? settings;
  ThemeMode? themeMode;
  Locale? locale;

  NumberFormat? currencyFormat;
  DateFormat? dateFormat;

  String appVersion = "";

  SettingProvider(this._repository) {
    Future.microtask(() => loadSettings());
  }

  Future<void> loadSettings() async {
    appVersion = await _repository.getAppVersion();
    settings = await _repository.getSettings();

    if (settings == null) {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();

      final defaultSettings = SettingsModel(
        id: 1,
        language: 'system',
        currencyCode: 'system',
        currencySymbol: NumberFormat.simpleCurrency(locale: systemLocale).currencySymbol,
        dateFormat: 'yyyy-MM-dd',
        themeMode: 'system',
      );

      await _repository.insertDefaultSettings(defaultSettings);
      settings = await _repository.getSettings();
    }

    if (settings != null) {
      themeMode = _parseThemeMode(settings!.themeMode);
      _initCurrencyFormat();
      _initDateFormat();
      
      final code = settings!.language;
      locale = (code == 'system') ? null : Locale(code);
    }
    notifyListeners();
  }

  ThemeMode _parseThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setLanguage(String code, {bool persist = true}) {
    final newLocale = (code == 'system') ? null : Locale(code);
    locale = newLocale;

    if (settings != null) {
      settings = settings!.copyWith(language: code);
      if (persist) _repository.updateSettings(settings!);
    }

    _initCurrencyFormat();
    notifyListeners(); 
  }

  Future<void> setThemeMode(String mode) async {
    if (settings != null) {
      settings = settings!.copyWith(themeMode: mode);
      themeMode = _parseThemeMode(mode);
      await _repository.updateSettings(settings!);
      notifyListeners(); 
    }
  }

  Future<void> setCurrency(String currencyCode) async {
    if (settings == null) return;

    final currencies = {
      'USD': {'symbol': '\$', 'code': 'USD'},
      'CAD': {'symbol': '\$', 'code': 'CAD'},
      'KRW': {'symbol': '₩', 'code': 'KRW'},
      'JPY': {'symbol': '¥', 'code': 'JPY'},
      'THB': {'symbol': '฿', 'code': 'THB'},
    };

    if (currencyCode == 'system') {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final format = NumberFormat.simpleCurrency(locale: locale.toString());
      settings = settings!.copyWith(
        currencyCode: 'system',
        currencySymbol: format.currencySymbol,
      );
    } else {
      final data = currencies[currencyCode]!;
      settings = settings!.copyWith(
        currencyCode: data['code']!,
        currencySymbol: data['symbol']!,
      );
    }

    await _repository.updateSettings(settings!);
    _initCurrencyFormat();
    notifyListeners();
  }

  Future<void> setDateFormat(String format) async {
    if (settings != null) {
      settings = settings!.copyWith(dateFormat: format);
      _initDateFormat();
      await _repository.updateSettings(settings!);
      notifyListeners();
    }
  }

  void _initCurrencyFormat() {
    final lang = settings?.language ?? 'en';
    final String localeStr = (lang == 'system')
        ? WidgetsBinding.instance.platformDispatcher.locale.toString()
        : switch (lang) {
            'ko' => 'ko_KR',
            'ja' => 'ja_JP',
            'th' => 'th_TH',
            _ => 'en_US',
          };

    final symbol = settings?.currencySymbol ?? '\$';
    final code = settings?.currencyCode ?? 'system';

    int decimalDigits;
    if (code == 'system') {
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();
      decimalDigits = (systemLocale.contains('ko') || systemLocale.contains('ja')) ? 0 : 2;
    } else {
      decimalDigits = (code == 'KRW' || code == 'JPY') ? 0 : 2;
    }

    currencyFormat = NumberFormat.currency(
      locale: localeStr,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

  void _initDateFormat() {
    final formatStr = settings?.dateFormat ?? 'yyyy-MM-dd';
    dateFormat = DateFormat(formatStr);
  }

  String formatDate(DateTime date) => dateFormat?.format(date) ?? '';
  String formatCurrency(double amount) => currencyFormat?.format(amount) ?? '0';

  // --- [Data Management: Backup & Restore] ---

  Future<void> exportBackup(BuildContext context) async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));
      
      await DatabaseService().close();
      
      final bytes = await dbFile.readAsBytes();
      await FilePicker.platform.saveFile(
        fileName: 'piggy_log_backup.db',
        bytes: bytes,
      );

      await DatabaseService().database; // Re-open after export
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Success! 🐷")));
      }
    } catch (e) {
      await DatabaseService().database;
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Backup Failed!")));
      }
    }
  }

  Future<void> importBackup(BuildContext context) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;

      File selectedFile = File(result.files.single.path!);
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));

      // 1. Close current connection 
      await DatabaseService().close();

      // 2. Overwrite the database file
      final bytes = await selectedFile.readAsBytes();
      await dbFile.writeAsBytes(bytes, flush: true);

      // 3. Re-establish connection to the new file 
      // Since repositories use the getter, they will automatically pick up this connection.
      await DatabaseService().database; 

      // 4. Reload local settings from the new DB
      await loadSettings(); 

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("성공"), backgroundColor: Colors.green),
        );

        // 5. Navigate to Splash to rebuild the UI with new data 
        Future.delayed(const Duration(milliseconds: 300), () {
          if (context.mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const SplashScreen()),
              (route) => false,
            );
          }
        });
      }
    } catch (e) {
      await DatabaseService().database; 
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("실패"), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> showImportDialog(BuildContext context) async {
    final l10n = AppLocalizations.of(context)!;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.warning),
        content: Text(l10n.restoreWarning),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.cancel),
          ),
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              importBackup(context); 
            },
            child: Text(l10n.confirm),
          ),
        ],
      ),
    );
  }

  Future<void> refreshAllData({
    DashboardProvider? dashboardProvider,
    CalendarProvider? calendarProvider,
  }) async {
    if (dashboardProvider != null) await dashboardProvider.refreshDashboard();
    if (calendarProvider != null) {
      await calendarProvider.loadDailyTotals();
      await calendarProvider.selectDate(calendarProvider.selectedDay);
    }
    notifyListeners();
  }
}