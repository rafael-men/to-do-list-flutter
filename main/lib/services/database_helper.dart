import 'package:flutter/foundation.dart';
import 'package:main/models/task.dart';
import 'package:main/models/task_series.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:sembast/sembast_io.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;
  static final _store = intMapStoreFactory.store('tasks');
  static final _seriesStore = stringMapStoreFactory.store('series');


  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('tasks.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    if (kIsWeb) {

      final factory = databaseFactoryWeb;
      return await factory.openDatabase(fileName);
    } else {
   
      final appDocDir = await getApplicationDocumentsDirectory();
      final dbPath = join(appDocDir.path, fileName);
      final factory = databaseFactoryIo;
      return await factory.openDatabase(dbPath);
    }
  }

  Future<int> insertTask(Task task) async {
    final db = await database;
    return await _store.add(db, task.toMap());
  }

  Future<List<Task>> getTasks() async {
    final db = await database;
    final snapshot = await _store.find(db, finder: Finder(sortOrders: [SortOrder('taskName')]));
    return snapshot.map((record) => Task.fromMap(record.value)).toList();
  }

  Future<int> updateTask(Task task) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('id', task.id));
    return await _store.update(db, task.toMap(), finder: finder);
  }

  Future<int> deleteTask(String id) async {
    final db = await database;
    final finder = Finder(filter: Filter.equals('id', id));
    return await _store.delete(db, finder: finder);
  }

  Future<int> deleteAllTasks() async {
    final db = await database;
    return await _store.delete(db);
  }


Future<void> insertSeries(TaskSeries series) async {
  final db = await database;
  await _seriesStore.record(series.id).put(db, series.toMap());
}


Future<void> updateSeries(TaskSeries series) async {
  final db = await database;
  await _seriesStore.record(series.id).update(db, series.toMap());
}


Future<void> deleteSeries(String id) async {
  final db = await database;
  await _seriesStore.record(id).delete(db);
}


Future<List<TaskSeries>> getAllSeries() async {
  final db = await database;
  final snapshot = await _seriesStore.find(db, finder: Finder(sortOrders: [SortOrder('name')]));
  return snapshot.map((record) => TaskSeries.fromMap(record.value)).toList();
}


Future<int> deleteTasksBySeriesId(String seriesId) async {
  final db = await database;
  final finder = Finder(filter: Filter.equals('seriesId', seriesId));
  return await _store.delete(db, finder: finder);
}


Future<List<Task>> getTasksBySeriesId(String seriesId) async {
  final db = await database;
  final finder = Finder(filter: Filter.equals('seriesId', seriesId));
  final records = await _store.find(db, finder: finder);
  return records.map((record) => Task.fromMap(record.value)).toList();
}


  Future<bool> isDatabaseReady() async {
    try {
      final db = await database;
      await _store.count(db);
      return true;
    } catch (e) {
      return false;
    }
  }


  Future close() async {
    final db = _database;
    if (db != null) {
      await db.close();
      _database = null;
    }
  }
}
