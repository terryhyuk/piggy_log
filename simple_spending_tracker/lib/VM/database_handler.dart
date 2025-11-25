import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHandler {

  Future<Database> initializeDB()async{
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'myFlowLogix.db'),
      onCreate: (db, version) async{
        await db.execute(
          """
          create table categories (
          id integer primary key autoincrement,
          c_name text not null,
          icon text not null,
          color text not null
          )
          """
        );
        await db.execute(
          """
          create table transactions (
          t_id integer primary key autoincrement,
          c_id integer not null,
          date text not null,
          type text not null,
          amount real not null,
          memo text,
          isRecurring integer not null default 0,
          foreign key(c_id) references categories(id)
        )
        """
        );
        await db.execute(
          """
          create table monthly_budget (
          m_id integer primary key autoincrement,
          c_id integer not null,
          yearMonth text not null,
          targetAmount real not null,
          foreign key(c_id) references categories(id)
          )"""
        );
      },
      version: 1
    );
  }
}// END