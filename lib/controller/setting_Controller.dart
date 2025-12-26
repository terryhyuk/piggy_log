import 'dart:io';
import 'dart:typed_data';
import 'package:file_picker/file_picker.dart';
import 'package:path/path.dart';
import 'package:piggy_log/VM/dashboard_handler.dart';
import 'package:piggy_log/controller/category_controller.dart';
import 'package:piggy_log/controller/tabbar_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/settings_handler.dart';
import 'package:piggy_log/controller/calendar_controller.dart';
import 'package:piggy_log/controller/dashboard_controller.dart';
import 'package:piggy_log/model/settings.dart';
import 'package:piggy_log/view/splashScrrenPage.dart';
import 'package:sqflite/sqflite.dart';

// -----------------------------------------------------------------------------------------------------------
//  * SettingController.dart
//  * * This class serves as the 'Brain' of the Piggy Log app.
//  * Its primary responsibilities include:
//  * 1. App Configuration: Managing Theme (Light/Dark), Language (Locale), and Date/Currency formats.
//  * 2. Data Persistence: Saving and loading user preferences via SettingsHandler.
//  * 3. Backup & Restore: Exporting/Importing the SQLite database (.db) with full data integrity.
//  * 4. System Reboot: Refreshing all controllers and the UI state after a data restore to prevent crashes.
// -----------------------------------------------------------------------------------------------------------

class SettingController extends GetxController {
  final SettingsHandler _handler = SettingsHandler();

  RxInt refreshTrigger = 0.obs;
  Rxn<Settings> settings = Rxn<Settings>();
  var themeMode = Rxn<ThemeMode>();
  var locale = Rxn<Locale?>();
  NumberFormat? currencyFormat;
  DateFormat? dateFormat;

  @override
  void onInit() {
    super.onInit();
    Future.microtask(() => loadSettings());
  }

  // Load app settings from Database
  Future<void> loadSettings() async {
    settings.value = await _handler.getSettings();

    if (settings.value == null) {
      await _handler.insertDefaultSettings();
      settings.value = await _handler.getSettings();
    }

    themeMode.value = _parseThemeMode(settings.value!.theme_mode);
    _initCurrencyFormat();
    _initDateFormat();
    setLanguage(settings.value!.language, persist: false);
  }

  ThemeMode _parseThemeMode(String mode) {
    return switch (mode) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
  }

  void setThemeMode(String mode, {bool persist = true}) {
    themeMode.value = _parseThemeMode(mode);
    Get.changeThemeMode(themeMode.value!);

    if (persist && settings.value != null) {
      settings.value!.theme_mode = mode;
      _handler.updateSettings(settings.value!);
    }
  }

  void setLanguage(String code, {bool persist = true}) {
    final newLocale = (code == 'system') ? null : Locale(code);
    locale.value = newLocale;

    if (newLocale != null) {
      Get.updateLocale(newLocale);
    }

    if (persist && settings.value != null) {
      settings.value!.language = code;
      _handler.updateSettings(settings.value!);
    }

    _initCurrencyFormat();
  }

  void setCurrency(String code, {bool persist = true}) {
    if (persist && settings.value != null) {
      settings.value!.currency_code = code;
      settings.value!.currency_symbol = _getCurrencySymbol(code);
      _handler.updateSettings(settings.value!);
      _initCurrencyFormat();
      refreshTrigger.value++;
    }
  }

  void setDateFormat(String format, {bool persist = true}) {
    if (persist && settings.value != null) {
      settings.value!.date_format = format;
      _handler.updateSettings(settings.value!);
      _initDateFormat();  
      refreshTrigger.value++;
    }
  }

  String _getCurrencySymbol(String code) {
    return switch (code) {
      'USD' => '\$',
      'CAD' => '\$',
      'KRW' => '₩',
      'JPY' => '¥',
      'THB' => '฿',
      _ => '\$',
    };
  }

  void _initCurrencyFormat() {
    final lang = settings.value?.language ?? 'en';
    final String localeStr = switch (lang) {
      'ko' => 'ko_KR',
      'ja' => 'ja_JP',
      'th' => 'th_TH',
      _ => 'en_US',
    };

    final symbol = settings.value?.currency_symbol ?? '\$';
    final code = settings.value?.currency_code ?? 'system';

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
    final formatStr = settings.value?.date_format ?? 'yyyy-MM-dd';
    dateFormat = DateFormat(formatStr);
  }

  // Returns formatted date, ensures it never returns null for UI safety
  String formatDate(DateTime date) => dateFormat?.format(date) ?? '';
  String formatCurrency(double amount) => currencyFormat?.format(amount) ?? '0';

  Future<void> refreshAllData() async {
    refreshTrigger.value++;
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().refreshDashboard();
    }
    if (Get.isRegistered<CalendarController>()) {
      final cal = Get.find<CalendarController>();
      await cal.loadDailyTotals();
      cal.selectDate(cal.selectedDay.value);
    }
  }

  // Export DB file to external storage
  Future<void> exportBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));

      if (!await dbFile.exists()) return;

      await _handler.databaseHandler.closeDB();
      Uint8List bytes = await dbFile.readAsBytes();

      String? outputFile = await FilePicker.platform.saveFile(
        fileName: 'piggy_log_backup.db',
        bytes: bytes,
        type: FileType.any, 
      );

      await _handler.databaseHandler.initializeDB();

      if (outputFile != null) {
        Get.snackbar("Success", "Backup saved successfully.");
      }
    } catch (e) {
      await _handler.databaseHandler.initializeDB();
      debugPrint("Export error: $e");
      Get.snackbar("Error", "Export failed.");
    }
  }

  // Import DB file and reboot all controllers EXCEPT itself
  Future<void> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;

      File selectedFile = File(result.files.single.path!);
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));

      // 1. Close current DB and Overwrite with backup
      await _handler.databaseHandler.closeDB();
      await selectedFile.copy(dbFile.path);

      // 2. Re-initialize Database connection
      await _handler.databaseHandler.initializeDB();

      // 3. Move to SplashScreen first to safely detach UI listeners
      Get.offAll(() => const SplashScreen());

      // 4. Give UI brief moment to settle before clearing memory
      await Future.delayed(const Duration(milliseconds: 500));

// 5. Clean up (SettingController 제외 싹 제거)
      if (Get.isRegistered<TabbarController>()) Get.delete<TabbarController>(force: true);
      if (Get.isRegistered<DashboardController>()) Get.delete<DashboardController>(force: true);
      if (Get.isRegistered<DashboardHandler>()) Get.delete<DashboardHandler>(force: true);
      if (Get.isRegistered<CategoryController>()) Get.delete<CategoryController>(force: true);
      if (Get.isRegistered<CalendarController>()) Get.delete<CalendarController>(force: true);

      // 6. Re-register (순서가 중요합니다: 핸들러 먼저, 그 다음 컨트롤러)
      Get.put(TabbarController());
      await loadSettings(); 

      // ⚠️ 핸들러를 먼저 등록해서 컨트롤러가 이를 참조할 수 있게 함
      Get.put(DashboardHandler()); 
      final dash = Get.put(DashboardController()); // 변수에 담기
      
      Get.put(CategoryController());
      Get.put(CalendarController());

      // 6-1. [핵심 추가] 새 DB 데이터를 실제로 긁어오라고 명령
      // 이 명령이 있어야 '삭제된 상태'의 DB를 대시보드가 인지합니다.
      await dash.refreshDashboard();
      // 7. Re-apply restored theme mode
      if (settings.value != null) {
        Get.changeThemeMode(_parseThemeMode(settings.value!.theme_mode));
      }

      // 8. Success Feedback
      Get.snackbar(
        AppLocalizations.of(Get.context!)!.restoreSuccess,
        AppLocalizations.of(Get.context!)!.restoreSuccess,
        snackPosition: SnackPosition.top,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

    } catch (e) {
      await _handler.databaseHandler.initializeDB();
      debugPrint("Import error: $e");
      Get.snackbar("Error", "Restore failed.");
    }
  }

  // Show confirmation dialog before starting restore
  Future<void> importBackupdialog() async {
    Get.defaultDialog(
      title: AppLocalizations.of(Get.context!)!.warning,
      middleText: AppLocalizations.of(Get.context!)!.restoreWarning,
      textCancel: AppLocalizations.of(Get.context!)!.cancel,
      textConfirm: AppLocalizations.of(Get.context!)!.confirm,
      confirmTextColor: Colors.white,
      buttonColor: Colors.red,
      onConfirm: () async {
        Get.back();
        await Future.delayed(const Duration(milliseconds: 300));
        await importBackup();
      },
    );
  }
}