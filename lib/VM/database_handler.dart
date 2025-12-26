import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// Handles the initialization and creation of the local SQLite database.
/// This class creates all tables required by the app (categories, transactions, monthly budgets).
class DatabaseHandler {
  /// Opens the SQLite database. If it does not exist, it will be created.
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();

    return openDatabase(
      join(path, 'piggy_log.db'),

      /// Runs only when the database is created for the first time.
      onCreate: (db, version) async {

        // -------------------------------
        // category table
        // stores user-created categories.
        // icon is saved as codePoint + fontFamily information.
        // -------------------------------
        await db.execute("""
          create table categories (
            id integer primary key autoincrement,
            c_name text not null,
            icon_codepoint integer not null,
            icon_font_family text,
            icon_font_package text,
            color text not null
          )
        """);

        // -------------------------------
        // transactions table
        // each record is linked to a category through c_id.
        // -------------------------------
        await db.execute("""
          create table spending_transactions (
            t_id integer primary key autoincrement,
            c_id integer not null,
            t_name text not null,
            date text not null,
            type text not null,
            amount real not null,
            memo text,
            isRecurring integer not null default 0,
            foreign key(c_id) references categories(id)
          )
        """);

        // -------------------------------
        // monthly budget table
        // stores budget goals for each category per year-month format.
        // -------------------------------
        await db.execute("""
          create table monthly_budget (
            m_id integer primary key autoincrement,
            c_id integer not null,
            yearMonth text not null,
            targetAmount real not null,
            foreign key(c_id) references categories(id)
          )
        """);

        // -------------------------------
        // settings table
        // stores app settings.
        // -------------------------------
        await db.execute(
          """
          create table settings (
          id integer primary key,
          language text not null,
          currency_code text not null,
          currency_symbol text not null,
          date_format text not null,
          theme_mode text not null
          )
        """);
      },

      version: 1, // database version
    );
  }

  // DatabaseHandler 클래스 맨 밑에 추가
Future<void> closeDB() async {
  String path = await getDatabasesPath();
  // 열려있는 경로의 DB를 강제로 찾아서 닫아버리는 기능입니다.
  final db = await openDatabase(join(path, 'piggy_log.db'));
  await db.close();
}
  
} // END
