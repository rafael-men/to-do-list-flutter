import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import 'package:main/models/task_series.dart';
import 'package:main/models/task.dart';
import 'package:main/services/database_helper.dart';

class TaskSeriesController extends ChangeNotifier {
  final DatabaseHelper dbHelper;

  List<TaskSeries> _series = [];
  List<TaskSeries> get series => List.unmodifiable(_series);

  TaskSeriesController(this.dbHelper);

  Future<void> loadSeries() async {
    try {
      _series = await dbHelper.getAllSeries();
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createSeries(String name, List<Task> tasks) async {
    final id = const Uuid().v4();
    final newSeries = TaskSeries(id: id, name: name);

    try {
      await dbHelper.insertSeries(newSeries);

      for (final task in tasks) {
        final taskWithSeries = task.copyWith(seriesId: id);
        await dbHelper.insertTask(taskWithSeries);
      }

      _series.add(newSeries);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateSeries(String id, String newName) async {
    final index = _series.indexWhere((s) => s.id == id);
    if (index == -1) {
      return;
    }

    final updated = TaskSeries(id: id, name: newName);
    try {
      await dbHelper.updateSeries(updated);
      _series[index] = updated;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteSeries(String id) async {
    try {
      await dbHelper.deleteTasksBySeriesId(id); 
      await dbHelper.deleteSeries(id); 
      _series.removeWhere((s) => s.id == id);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  TaskSeries? getSeriesById(String id) {
    return _series.firstWhere((s) => s.id == id, orElse: () => TaskSeries(id: id, name: 'Desconhecida'));
  }

  bool hasSeries(String id) => _series.any((s) => s.id == id);

  void clear() {
    _series.clear();
    notifyListeners();
  }
}
