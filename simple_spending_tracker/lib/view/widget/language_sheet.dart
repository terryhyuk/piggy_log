import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

class LanguageSheet extends StatelessWidget {
  final String currentLanguage;

  const LanguageSheet({super.key, required this.currentLanguage});

  @override
  Widget build(BuildContext context) {
    final languages = [
      {'label': 'English', 'code': 'en'},
      {'label': '한국어', 'code': 'ko'},
      {'label': '日本語', 'code': 'ja'},
    ];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            AppLocalizations.of(context)!.language,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),

          ...languages.map((lang) {
            return ListTile(
              title: Text(lang['label']!),
              trailing: currentLanguage == lang['code']
                  ? const Icon(Icons.check, color: Colors.black)
                  : null,
              onTap: () => Navigator.pop(context, lang),
            );
          }).toList(),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
