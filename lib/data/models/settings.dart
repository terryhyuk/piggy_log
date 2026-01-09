class SettingsModel {
  final int id;               
  final String language;
  final String currencyCode;  // [DB: TEXT] e.g., 'KRW', 'USD'
  final String currencySymbol;// [DB: TEXT] e.g., '₩', '$', 'system
  final String dateFormat;    // [DB: TEXT] e.g., 'yyyy-MM-dd'
  final String themeMode;     // [DB: TEXT] 'light', 'dark', 'system'

  SettingsModel({
    required this.id,
    required this.language,
    required this.currencyCode,
    required this.currencySymbol,
    required this.dateFormat,
    required this.themeMode,
  });

  // Allows updating specific fields while keeping others intact.
  SettingsModel copyWith({
    int? id,
    String? language,
    String? currencyCode,
    String? currencySymbol,
    String? dateFormat,
    String? themeMode,
  }) {
    return SettingsModel(
      id: id ?? this.id,
      language: language ?? this.language,
      currencyCode: currencyCode ?? this.currencyCode,
      currencySymbol: currencySymbol ?? this.currencySymbol,
      dateFormat: dateFormat ?? this.dateFormat,
      themeMode: themeMode ?? this.themeMode,
    );
  }

  factory SettingsModel.fromMap(Map<String, dynamic> map) {
    return SettingsModel(
      id: map['id'],
      language: map['language'],
      currencyCode: map['currency_code'],
      currencySymbol: map['currency_symbol'],
      dateFormat: map['date_format'],
      themeMode: map['theme_mode'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'language': language,
      'currency_code': currencyCode,
      'currency_symbol': currencySymbol,
      'date_format': dateFormat,
      'theme_mode': themeMode,
    };
  }
}