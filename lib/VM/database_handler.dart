import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

// -----------------------------------------------------------------------------
//  * Refactoring Intent: Centralized DB management via Singleton for consistency.
//  * TODO: Implement migrations & backup validation.
// -----------------------------------------------------------------------------

class DatabaseHandler {
  static final DatabaseHandler _instance = DatabaseHandler._internal();
  static Database? _database;

  DatabaseHandler._internal();

  factory DatabaseHandler() => _instance;

  /// Returns an active database connection.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await initializeDB();
    return _database!;
  }

  /// Initializes SQLite database and core schema.
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    String dbPath = join(path, 'piggy_log.db');

    Database db = await openDatabase(
      dbPath,
      onCreate: (db, version) async {
        await db.execute("""
          CREATE TABLE categories (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_name TEXT NOT NULL,
            icon_codepoint INTEGER NOT NULL,
            icon_font_family TEXT,
            icon_font_package TEXT,
            color TEXT NOT NULL
          )
        """);

        await db.execute("""
          CREATE TABLE spending_transactions (
            t_id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_id INTEGER NOT NULL,
            t_name TEXT NOT NULL,
            date TEXT NOT NULL,
            type TEXT NOT NULL,
            amount REAL NOT NULL,
            memo TEXT,
            isRecurring INTEGER NOT NULL DEFAULT 0,
            FOREIGN KEY(c_id) REFERENCES categories(id)
          )
        """);

        await db.execute("""
          CREATE TABLE monthly_budget (
            m_id INTEGER PRIMARY KEY AUTOINCREMENT,
            c_id INTEGER NOT NULL,
            yearMonth TEXT NOT NULL,
            targetAmount REAL NOT NULL,
            FOREIGN KEY(c_id) REFERENCES categories(id)
          )
        """);

        await db.execute("""
          CREATE TABLE settings (
            id INTEGER PRIMARY KEY,
            language TEXT NOT NULL,
            currency_code TEXT NOT NULL,
            currency_symbol TEXT NOT NULL,
            date_format TEXT NOT NULL,
            theme_mode TEXT NOT NULL
          )
        """);

        await _createPiggyTable(db);
      },
      version: 1,
    );

    await _createPiggyTable(db);
    return db;
  }

  /// Ensures piggy_status table exists.
  Future<void> _createPiggyTable(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS piggy_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        p_name TEXT NOT NULL,
        p_level INTEGER DEFAULT 1,
        total_savings REAL DEFAULT 0.0,
        last_update TEXT
      )
    """);
  }

  /// Closes the database safely.
  Future<void> closeDB() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
