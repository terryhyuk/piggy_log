import 'package:flutter/material.dart';
import 'package:piggy_log/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:piggy_log/l10n/app_localizations.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    
    final provider = context.watch<SettingProvider>();
    final settings = provider.settings;

    // Loading state handling
    if (settings == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

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
              onSelected: (code) => provider.setLanguage(code),
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
              onSelected: (mode) => provider.setThemeMode(mode),
              position: PopupMenuPosition.under,
              offset: const Offset(200, 0),
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'system', child: Text('System')),
                const PopupMenuItem(value: 'light', child: Text('Light')),
                const PopupMenuItem(value: 'dark', child: Text('Dark')),
              ],
              child: ListTile(
                title: Text(l10n.theme),
                subtitle: Text(settings.themeMode),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 3. Financial Currency Formatting
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: (code) => provider.setCurrency(code),
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
                subtitle: Text(settings.currencyCode),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 4. Temporal Format Preferences
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: (format) => provider.setDateFormat(format),
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
                subtitle: Text(settings.dateFormat),
                trailing: const Icon(Icons.chevron_right),
              ),
            ),
          ),

          // 5. Data Management (Backup/Restore)
          _buildCardWrapper(
            context,
            child: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'export') {
                  provider.exportBackup(context);
                } else if (value == 'import') {
                  provider.importBackup(context);
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

  Widget _buildCardWrapper(BuildContext context, {required Widget child}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
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
}