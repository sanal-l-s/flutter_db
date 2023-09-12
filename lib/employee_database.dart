import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import 'employee.dart';

class EmployeeDatabase {
  late Database _database;

  Future<void> initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'employees.db');

    _database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
          await db.execute('''
          CREATE TABLE employees (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            position TEXT
          )
        ''');
        });
  }

  Future<int> insertEmployee(Employee employee) async {
    await initDatabase();
    return await _database.insert('employees', employee.toMap());
  }

  Future<List<Employee>> getEmployees() async {
    await initDatabase();
    final List<Map<String, dynamic>> maps = await _database.query('employees');

    return List.generate(maps.length, (i) {
      return Employee.fromMap(maps[i]);
    });
  }

  Future<int> updateEmployee(Employee employee) async {
    await initDatabase();
    return await _database.update(
      'employees',
      employee.toMap(),
      where: 'id = ?',
      whereArgs: [employee.id],
    );
  }

  Future<int> deleteEmployee(int id) async {
    await initDatabase();
    return await _database.delete(
      'employees',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> closeDatabase() async {
    await _database.close();
  }
}
