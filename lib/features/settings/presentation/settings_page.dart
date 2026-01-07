import 'package:flutter/material.dart';
import 'package:get_x/get.dart';
import 'package:intl/intl.dart';
import 'package:piggy_log/core/db/settings_handler.dart';
import 'package:piggy_log/features/settings/controller/setting_controller.dart';
import 'package:piggy_log/l10n/app_localizations.dart';
import 'package:piggy_log/features/settings/model/settings.dart';

// -----------------------------------------------------------------------------
//  * SettingsPage - User Preferences & Data Management
//  * -----------------------------------------------------------------------------
//  * [Description]
//  * Central hub for managing application-wide preferences.
//  * Features a high-accessibility UI with full-card touch targets 
//  * for all selection menus.
//  -----------------------------------------------------------------------------

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late Settings settings;
  bool isLoaded = false;

  @override
  void initState() {
    super.initState();
    loadSettings();
  }

  @override
  Widget build(BuildContext context) {
    if (!isLoaded) return const Center(child: CircularProgressIndicator());
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.settings),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 10),
        children: [
          // 1. Language Configuration
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: _changeLanguage,
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0), 
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'system', child: Text('System')),
                const PopupMenuItem(value: 'ko', child: Text('한국어')),
                const PopupMenuItem(value: 'en', child: Text('English')),
                const PopupMenuItem(value: 'ja', child: Text('日本語')),
                const PopupMenuItem(value: 'th', child: Text('ไทย')),
              ],
              child: ListTile(
                title: Text(l10n.language),
                subtitle: Text(settings.language),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 2. Visual Theme Customization
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: _changeMode,
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'system', child: Text('System')),
                const PopupMenuItem(value: 'light', child: Text('Light')),
                const PopupMenuItem(value: 'dark', child: Text('Dark')),
              ],
              child: ListTile(
                title: Text(l10n.theme),
                subtitle: Text(settings.theme_mode),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 3. Financial Currency Formatting
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: _changeCurrency,
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'system', child: Text('System')),
                const PopupMenuItem(value: 'USD', child: Text('USD - \$')),
                const PopupMenuItem(value: 'KRW', child: Text('KRW - ₩')),
                const PopupMenuItem(value: 'CAD', child: Text('CAD - \$')),
                const PopupMenuItem(value: 'JPY', child: Text('JPY - ¥')),
                const PopupMenuItem(value: 'THB', child: Text('THB - ฿'))
              ],
              child: ListTile(
                title: Text(l10n.currency),
                subtitle: Text(settings.currency_code),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 4. Temporal Format Preferences
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: _changeDateFormat,
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'yyyy-MM-dd', child: Text('2025-12-08')),
                const PopupMenuItem(value: 'MM/dd/yyyy', child: Text('12/08/2025')),
                const PopupMenuItem(value: 'dd/MM/yyyy', child: Text('08/12/2025')),
                const PopupMenuItem(value: 'MMM d, yyyy', child: Text('Dec 8, 2025')),
              ],
              child: ListTile(
                title: Text(l10n.dateformat),
                subtitle: Text(settings.date_format),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 5. Data Persistence & Backup Management
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'export') {
                  Get.find<SettingController>().exportBackup();
                } else if (value == 'import') {
                  Get.find<SettingController>().importBackupdialog();
                }
              },
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0),
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'export',
                  child: Row(
                    children: [
                      const Icon(Icons.upload_file, size: 20),
                      const SizedBox(width: 10),
                      Text(l10n.exportBackup),
                    ],
                  ),
                ),
                PopupMenuItem(
                  value: 'import',
                  child: Row(
                    children: [
                      const Icon(Icons.download_for_offline, size: 20, color: Colors.red),
                      const SizedBox(width: 10),
                      Text(l10n.importBackup, style: const TextStyle(color: Colors.red)),
                    ],
                  ),
                ),
              ],
              child: ListTile(
                title: Text(l10n.dataManagement),
                subtitle: Text(l10n.exportDesc),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Custom wrapper that standardizes card aesthetics and maximizes the touch area.
  Widget _buildCardWrapper(BuildContext context, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(15),
          child: child,
        ),
      ),
    );
  }

  /// Fetches and hydrates preference state from the local database.
  Future<void> loadSettings() async {
    final handler = SettingsHandler();
    final result = await handler.getSettings();

    if (result == null) {
      final locale = WidgetsBinding.instance.platformDispatcher.locale;
      final format = NumberFormat.simpleCurrency(locale: locale.toString());

      settings = Settings(
        id: 1, language: 'system', currency_code: 'system',
        currency_symbol: format.currencySymbol,
        date_format: 'yyyy-MM-dd', theme_mode: 'system',
      );
      await handler.insertDefaultSettings();
    } else {
      settings = result;
    }
    isLoaded = true;
    if (mounted) setState(() {});
  }

  Future<void> _changeLanguage(String code) async {
    settings.language = code;
    await SettingsHandler().updateSettings(settings);
    Get.find<SettingController>().setLanguage(code);
    setState(() {});
  }

  Future<void> _changeMode(String themeMode) async {
    settings.theme_mode = themeMode;
    await SettingsHandler().updateSettings(settings);
    Get.find<SettingController>().setThemeMode(themeMode);
    setState(() {});
  }

  Future<void> _changeCurrency(String currencyCode) async {
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
      settings.currency_code = 'system';
      settings.currency_symbol = format.currencySymbol;
    } else {
      final data = currencies[currencyCode]!;
      settings.currency_symbol = data['symbol']!;
      settings.currency_code = data['code']!;
    }
    await SettingsHandler().updateSettings(settings);
    Get.find<SettingController>().setCurrency(currencyCode);
    setState(() {});
  }

  Future<void> _changeDateFormat(String format) async {
    settings.date_format = format;
    await SettingsHandler().updateSettings(settings);
    Get.find<SettingController>().setDateFormat(format);
    setState(() {});
  }
}