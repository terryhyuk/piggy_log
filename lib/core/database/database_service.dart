import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  DatabaseService._internal();

  factory DatabaseService() => _instance;

  /// Returns an active database connection.
  Future<Database> get database async {
    if (_database != null && _database!.isOpen) return _database!;
    _database = await _initializeDB();
    return _database!;
  }

  /// Initializes SQLite database and ensures all tables exist.
  Future<Database> _initializeDB() async {
    final String path = await getDatabasesPath();
    final String dbPath = join(path, 'piggy_log.db');

    // Keep version at 1 to maintain consistency for existing users.
    final Database db = await openDatabase(
      dbPath,
      version: 1,
      onConfigure: (db) async {
        // Enforce foreign key constraints for data integrity.
        await db.execute("PRAGMA foreign_keys = ON");
      },
      onCreate: (db, version) async {
        // Executes for completely new installations.
        await _createCoreTables(db);
        await _createPiggyTable(db);
      },
    );

    // [Migration & Safety] Check for legacy tables and migrate data if necessary.
    await _migrateLegacyData(db);

    // Final safety check for piggy_status table.
    await _createPiggyTable(db);

    return db;
  }

  /// Creates core tables with the new standardized naming convention.
  Future<void> _createCoreTables(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        icon_codepoint INTEGER NOT NULL,
        icon_font_family TEXT,
        icon_font_package TEXT,
        color TEXT NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        date TEXT NOT NULL,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        memo TEXT,
        is_recurring INTEGER NOT NULL DEFAULT 0,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE CASCADE
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS monthly_budgets (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        year_month TEXT NOT NULL UNIQUE, -- '2026-01' (UNIQUE ensures one budget per month)
        target_amount REAL NOT NULL
      )
    """);

    await db.execute("""
      CREATE TABLE IF NOT EXISTS settings (
        id INTEGER PRIMARY KEY,
        language TEXT NOT NULL,
        currency_code TEXT NOT NULL,
        currency_symbol TEXT NOT NULL,
        date_format TEXT NOT NULL,
        theme_mode TEXT NOT NULL
      )
    """);
  }

  /// Migrates data from old tables to new tables.
  Future<void> _migrateLegacyData(Database db) async {
    var oldTableCheck = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name='spending_transactions'",
    );

    if (oldTableCheck.isNotEmpty) {
      // [Core Fix] Disable foreign keys during migration to prevent crashes
      await db.execute("PRAGMA foreign_keys = OFF");

      try {
        // 1. Ensure new tables exist
        await _createCoreTables(db);

        // 2. Migration: spending_transactions -> records
        // Use INSERT OR IGNORE to prevent duplicate ID errors
        await db.execute("""
          INSERT OR IGNORE INTO records (id, category_id, name, date, type, amount, memo, is_recurring)
          SELECT t_id, c_id, t_name, date, type, amount, memo, isRecurring 
          FROM spending_transactions
        """);

        // 3. Migration: monthly_budget -> monthly_budgets
        await db.execute("""
          INSERT OR IGNORE INTO monthly_budgets (id, category_id, year_month, target_amount)
          SELECT m_id, c_id, yearMonth, targetAmount 
          FROM monthly_budget
        """);

        // 4. Cleanup: Remove legacy tables
        await db.execute("DROP TABLE IF EXISTS spending_transactions");
        await db.execute("DROP TABLE IF EXISTS monthly_budget");
      } catch (e) {
        return debugPrint("Migration failed: $e");
      } finally {
        await db.execute("PRAGMA foreign_keys = ON");
      }
    }
  }

  /// Ensures piggy_status table exists (Supports legacy version updates).
  Future<void> _createPiggyTable(Database db) async {
    await db.execute("""
      CREATE TABLE IF NOT EXISTS piggy_status (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        level INTEGER DEFAULT 1,
        total_savings REAL DEFAULT 0.0,
        last_update TEXT
      )
    """);
  }

  /// Closes the database safely.
  Future<void> close() async {
    if (_database != null && _database!.isOpen) {
      await _database!.close();
      _database = null;
    }
  }
}
