import 'package:flutter/foundation.dart';

class TaskItem {
  TaskItem(
      {required this.name,
      required this.addedAt,
      required this.id,
      this.completed = false});

  final String id;
  final DateTime addedAt;

  // the name and completed can be updated
  String name;
  bool completed;
}

class TaskModel extends ChangeNotifier {
  bool showCompletedTasks = true;

  // internal state
  final List<TaskItem> _taskItems = [];

  List<TaskItem> get items => _taskItems
      .where((item) => showCompletedTasks ? true : !item.completed)
      .toList();

  /// Adds [item] to takks. This is the only way to modify the tasks from outside.
  void add(TaskItem item) {
    _taskItems.add(item);
    // This line tells [Model] that it should
    // rebuild the widgets that depend on it.
    notifyListeners();
  }

  void remove(String id) {
    _taskItems.removeWhere((element) => element.id == id);
    notifyListeners();
  }

  void toggleTaskCompleteStatus(String id) {
    final taskIdx = _taskItems.indexWhere((item) => item.id == id);
    if (taskIdx == -1) return;

    var task = _taskItems[taskIdx];
    task.completed = !task.completed;
    _taskItems[taskIdx] = task;

    notifyListeners();
  }

  void toggleShowCompletedTasks() {
    showCompletedTasks = !showCompletedTasks;
    notifyListeners();
  }
}
