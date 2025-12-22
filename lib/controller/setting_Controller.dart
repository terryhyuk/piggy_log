import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/VM/settings_handler.dart';
import 'package:piggy_log/controller/calendar_Controller.dart';
import 'package:piggy_log/controller/dashboard_Controller.dart';
import 'package:piggy_log/model/settings.dart';

class SettingsController extends GetxController {
  final SettingsHandler _handler = SettingsHandler();

  RxInt refreshTrigger = 0.obs;

  Rxn<Settings> settings = Rxn<Settings>();
  var themeMode = Rxn<ThemeMode>();
  var locale = Rxn<Locale?>();
  NumberFormat? currencyFormat;
  DateFormat? dateFormat;

  @override
  onInit() {
    super.onInit();
    Future.microtask(() => loadSettings());
  }

  loadSettings() async {
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

  setThemeMode(String mode, {bool persist = true}) {
    themeMode.value = _parseThemeMode(mode);
    Get.changeThemeMode(themeMode.value!);

    if (persist && settings.value != null) {
      settings.value!.theme_mode = mode;
      _handler.updateSettings(settings.value!);
    }
  }

  setLanguage(String code, {bool persist = true}) {
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

  setCurrency(String code, {bool persist = true}) {
    if (persist && settings.value != null) {
      settings.value!.currency_code = code;
      settings.value!.currency_symbol = _getCurrencySymbol(code);
      _handler.updateSettings(settings.value!);
      _initCurrencyFormat();
      refreshTrigger.value++;
    }
  }

  setDateFormat(String format, {bool persist = true}) {
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

_initCurrencyFormat() {
    final lang = settings.value?.language ?? 'en';
    
    final String localeStr = switch (lang) {
      'ko' => 'ko_KR',
      'ja' => 'ja_JP',
      'th' => 'th_TH',
      _ => 'en_US',
    };

    final symbol = settings.value?.currency_symbol ?? '\$';
    final code = settings.value?.currency_code ?? 'system'; // 변수 하나 선언

    // 핵심: 'system'일 때랑 'KRW/JPY'일 때 둘 다 체크해야 함!
    int decimalDigits;
    if (code == 'system') {
      // 시스템 설정일 때는 현재 폰 언어가 한국어/일본어인지 확인
      final systemLocale = WidgetsBinding.instance.platformDispatcher.locale.toString();
      decimalDigits = (systemLocale.contains('ko') || systemLocale.contains('ja')) ? 0 : 2;
    } else {
      // 사용자가 직접 통화를 골랐을 때
      decimalDigits = (code == 'KRW' || code == 'JPY') ? 0 : 2;
    }

    currencyFormat = NumberFormat.currency(
      locale: localeStr,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }
  // _initCurrencyFormat() {
  //   final lang = settings.value?.language ?? 'en';
    
  //   final String localeStr = switch (lang) {
  //     'ko' => 'ko_KR',
  //     'ja' => 'ja_JP',
  //     'th' => 'th_TH',
  //     _ => 'en_US',
  //   };

  //   // final localeStr = lang == 'ko'
  //   //     ? 'ko_KR'
  //   //     : lang == 'ja'
  //   //     ? 'ja_JP'
  //   //     : 'en_US';

  //   final symbol = settings.value?.currency_symbol ?? '\$';

  //   int decimalDigits =
  //       (settings.value?.currency_code == 'KRW' ||
  //           settings.value?.currency_code == 'JPY')
  //       ? 0
  //       : 2;

  //   currencyFormat = NumberFormat.currency(
  //     locale: localeStr,
  //     symbol: symbol,
  //     decimalDigits: decimalDigits,
  //   );
  // }

  _initDateFormat() {
    final formatStr = settings.value?.date_format ?? 'yyyy-MM-dd';
    dateFormat = DateFormat(formatStr);
  }

  formatDate(DateTime date) {
    return dateFormat?.format(date);
  }

  formatCurrency(double amount) {
    return currencyFormat?.format(amount);
  }

  Future<void> refreshAllData() async {
    // 1. 설정/카테고리 리스트 트리거 갱신
    Get.find<SettingsController>().refreshTrigger.value++;

    // 2. 대시보드 데이터 갱신
    if (Get.isRegistered<DashboardController>()) {
      await Get.find<DashboardController>().refreshDashboard();
    }

    // 3. 달력 데이터 갱신 (현재 달력 페이지라면)
    if (Get.isRegistered<CalendarController>()) {
      final cal = Get.find<CalendarController>();
      await cal.loadDailyTotals();
      cal.selectDate(cal.selectedDay.value);
    }
  }
  
} // END
