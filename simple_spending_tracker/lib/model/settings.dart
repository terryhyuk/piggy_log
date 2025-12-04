class Settings {
  int id;
  String language;
  String currency_code;
  String currency_symbol;
  String date_format;
  String theme_mode;

  Settings({
    required this.id,
    required this.language,
    required this.currency_code,
    required this.currency_symbol,
    required this.date_format,
    required this.theme_mode,
  });

  factory Settings.fromMap(Map<String, dynamic> res) {
    return Settings(
      id: res['id'],
      language: res['language'],
      currency_code: res['currency_code'],
      currency_symbol: res['currency_symbol'],
      date_format: res['date_format'],
      theme_mode: res['theme_mode'],
    );
  }
}