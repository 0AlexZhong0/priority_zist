import 'package:flutter/foundation.dart';

class TaskItem {
  TaskItem(
      {required this.id,
      required this.name,
      required this.reach,
      required this.impact,
      required this.confidence,
      required this.effort,
      required this.addedAt,
      this.completed = false});

  final String id;
  final DateTime addedAt;

  // the values below can be updated
  double reach;
  double impact;
  double confidence;
  double effort;

  String name;
  bool completed;
}

class EditTaskInput {
  EditTaskInput(
      {required this.id,
      this.reach,
      this.impact,
      this.confidence,
      this.effort,
      this.name});

  final String id;

  final double? reach;
  final double? impact;
  final double? confidence;
  final double? effort;

  // the name and completed can be updated
  final String? name;
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
    final taskIdx = _taskIdxById(id);
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

  void deleteTask(String id) {
    final taskIdx = _taskIdxById(id);
    if (taskIdx == -1) return;

    _taskItems.removeAt(taskIdx);

    notifyListeners();
  }

  void editTask(EditTaskInput input) {
    final taskIdx = _taskIdxById(input.id);

    if (taskIdx == -1) return;

    if (input.reach != null) {
      _taskItems[taskIdx].reach = input.reach!;
    }
    if (input.impact != null) {
      _taskItems[taskIdx].impact = input.impact!;
    }
    if (input.confidence != null) {
      _taskItems[taskIdx].confidence = input.confidence!;
    }
    if (input.effort != null) {
      _taskItems[taskIdx].effort = input.effort!;
    }
    if (input.name != null) {
      _taskItems[taskIdx].name = input.name!;
    }

    notifyListeners();
  }

  int _taskIdxById(String id) {
    return _taskItems.indexWhere((item) => item.id == id);
  }
}
