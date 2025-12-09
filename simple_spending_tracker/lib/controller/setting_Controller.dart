import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:simple_spending_tracker/VM/settings_handler.dart';
import 'package:simple_spending_tracker/model/settings.dart';

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
      _ => '\$',
    };
  }

  _initCurrencyFormat() {
    final lang = settings.value?.language ?? 'en';
    final localeStr = lang == 'ko'
        ? 'ko_KR'
        : lang == 'ja'
        ? 'ja_JP'
        : 'en_US';

    final symbol = settings.value?.currency_symbol ?? '\$';

    int decimalDigits =
        (settings.value?.currency_code == 'KRW' ||
            settings.value?.currency_code == 'JPY')
        ? 0
        : 2;

    currencyFormat = NumberFormat.currency(
      locale: localeStr,
      symbol: symbol,
      decimalDigits: decimalDigits,
    );
  }

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
} // END
