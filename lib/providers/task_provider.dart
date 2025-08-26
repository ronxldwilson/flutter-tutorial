import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:questdo/models/task.dart';

class TaskProvider with ChangeNotifier {
  final Box<Task> _taskBox = Hive.box<Task>('tasks');

  List<Task> get tasks => _taskBox.values.toList();

  void addTask(Task task) {
    _taskBox.put(task.id, task);
    notifyListeners();
  }

  void updateTask(Task task) {
    _taskBox.put(task.id, task);
    notifyListeners();
  }

  void deleteTask(String id) {
    _taskBox.delete(id);
    notifyListeners();
  }

  void updateTaskStatus(String id, String status) {
    final task = _taskBox.get(id);
    if (task != null) {
      task.status = status;
      if (status == 'Completed') {
        task.completedAt = DateTime.now();
      } else {
        task.completedAt = null;
      }
      _taskBox.put(id, task);
      notifyListeners();
    }
  }
}
