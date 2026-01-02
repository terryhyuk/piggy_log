import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: 
//    Provides a modal interface for real-time locale switching. 
//    Designed to support dynamic i18n updates with a clean selection UI.
//
//  * TODO: 
//    - Move hardcoded language lists to a global configuration or assets file.
//    - Implement a 'LanguageManager' service to centralize locale logic.
// -----------------------------------------------------------------------------

class LanguageSheet extends StatelessWidget {
  final String currentLanguage;

  const LanguageSheet({super.key, required this.currentLanguage});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    /// Supported locale configurations. 
    /// 'system' allows the app to follow the OS level language settings.
    final languages = [
      {'label': 'System Default', 'code': 'system'},
      {'label': 'English', 'code': 'en'},
      {'label': '한국어', 'code': 'ko'},
      {'label': '日本語', 'code': 'ja'},
      {'label': 'ไทย (Thai)', 'code': 'th'}
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ) ?? const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 20),

          /// Mapping language list to interactive ListTiles
          ...languages.map((lang) {
            final isSelected = currentLanguage == lang['code'];
            
            return ListTile(
              title: Text(
                lang['label']!,
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : null,
                ),
              ),
              trailing: isSelected
                  ? Icon(Icons.check, color: theme.colorScheme.primary)
                  : null,
              onTap: () {
                // Returns the selected language map to the caller
                Navigator.pop(context, lang);
              },
            );
          }).toList(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}