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

// -----------------------------------------------------------------------------
//  * Refactoring Intent:
//    Acts as the central system coordinator. Manages application-wide states 
//    including L10n, Theme, and critical Disaster Recovery (Backup/Restore).
//    Implemented a 'Hard Reboot' strategy to maintain data integrity across 
//    database migrations and restores.
// -----------------------------------------------------------------------------

class SettingController extends GetxController {
  final SettingsHandler _handler = SettingsHandler();

  // Reactive state triggers for UI synchronization
  RxInt refreshTrigger = 0.obs;
  Rxn<Settings> settings = Rxn<Settings>();
  var themeMode = Rxn<ThemeMode>();
  var locale = Rxn<Locale?>();
  
  // Formatters cached for performance
  NumberFormat? currencyFormat;
  DateFormat? dateFormat;

  @override
  void onInit() {
    super.onInit();
    // Schedule loading to prevent blocking the initial frame
    Future.microtask(() => loadSettings());
  }

  /// Synchronizes local app settings with the SQLite storage.
  Future<void> loadSettings() async {
    settings.value = await _handler.getSettings();

    if (settings.value == null) {
      await _handler.insertDefaultSettings();
      settings.value = await _handler.getSettings();
    }

    // Apply persisted configurations
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
      'USD' => '\$', 'CAD' => '\$', 'KRW' => '₩',
      'JPY' => '¥', 'THB' => '฿', _ => '\$',
    };
  }

  /// Configures the NumberFormat based on selected currency and region.
  void _initCurrencyFormat() {
    final lang = settings.value?.language ?? 'en';
    final String localeStr = switch (lang) {
      'ko' => 'ko_KR', 'ja' => 'ja_JP', 'th' => 'th_TH', _ => 'en_US',
    };

    final symbol = settings.value?.currency_symbol ?? '\$';
    final code = settings.value?.currency_code ?? 'system';

    // Zero-decimal logic for specific currencies (KRW, JPY)
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

  String formatDate(DateTime date) => dateFormat?.format(date) ?? '';
  String formatCurrency(double amount) => currencyFormat?.format(amount) ?? '0';

  /// Forces all active controllers to sync with current settings.
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

  /// Physical database export to binary (.db) file.
  Future<void> exportBackup() async {
    try {
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));

      if (!await dbFile.exists()) return;

      // Close DB briefly to ensure file handle safety
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
      Get.snackbar("Error", "Export failed.");
    }
  }

  /// Restoration Logic: Performs a safe system-wide reboot after data injection.
  Future<void> importBackup() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
      if (result == null || result.files.single.path == null) return;

      File selectedFile = File(result.files.single.path!);
      final dbPath = await getDatabasesPath();
      final dbFile = File(join(dbPath, 'piggy_log.db'));

      // 1. Overwrite existing local DB with backup file
      await _handler.databaseHandler.closeDB();
      await selectedFile.copy(dbFile.path);

      // 2. Refresh database instance
      await _handler.databaseHandler.initializeDB();

      // 3. UX Safety: Navigate to Splash to detach active listeners
      Get.offAll(() => const SplashScreen());
      await Future.delayed(const Duration(milliseconds: 500));

      // 4. Memory Purge: Clear all controllers to prevent stale data usage
      _purgeAllControllers();

      // 5. System Re-injection: Rebooting core controllers and handlers
      _reinitializeCoreSystems();

      Get.snackbar(
        AppLocalizations.of(Get.context!)!.restoreSuccess,
        AppLocalizations.of(Get.context!)!.restoreSuccess,
        snackPosition: SnackPosition.top,
        backgroundColor: Colors.black87,
        colorText: Colors.white,
      );

    } catch (e) {
      await _handler.databaseHandler.initializeDB();
      Get.snackbar("Error", "Restore failed.");
    }
  }

  void _purgeAllControllers() {
    if (Get.isRegistered<TabbarController>()) Get.delete<TabbarController>(force: true);
    if (Get.isRegistered<DashboardController>()) Get.delete<DashboardController>(force: true);
    if (Get.isRegistered<DashboardHandler>()) Get.delete<DashboardHandler>(force: true);
    if (Get.isRegistered<CategoryController>()) Get.delete<CategoryController>(force: true);
    if (Get.isRegistered<CalendarController>()) Get.delete<CalendarController>(force: true);
  }

  Future<void> _reinitializeCoreSystems() async {
    Get.put(TabbarController());
    await loadSettings(); 

    // Re-establish Dependency Injection Graph
    Get.put(DashboardHandler()); 
    final dash = Get.put(DashboardController()); 
    Get.put(CategoryController());
    Get.put(CalendarController());

    await dash.refreshDashboard();

    if (settings.value != null) {
      Get.changeThemeMode(_parseThemeMode(settings.value!.theme_mode));
    }
  }

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