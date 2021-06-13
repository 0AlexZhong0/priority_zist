import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import 'models/task.dart';

enum CheckDayStatus { yesterday, today, tomorrow, others }

// utils
CheckDayStatus checkDay(DateTime dateToCheck) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final yesterday = DateTime(now.year, now.month, now.day - 1);
  final tomorrow = DateTime(now.year, now.month, now.day + 1);

  final date = DateTime(dateToCheck.year, dateToCheck.month, dateToCheck.day);

  if (date == today)
    return CheckDayStatus.today;
  else if (date == yesterday)
    return CheckDayStatus.yesterday;
  else if (date == tomorrow) return CheckDayStatus.tomorrow;

  return CheckDayStatus.others;
}

String formatTaskDateTime(DateTime d) {
  final status = checkDay(d);
  if (status == CheckDayStatus.today)
    return 'today';
  else if (status == CheckDayStatus.yesterday)
    return 'yesterday';
  else if (status == CheckDayStatus.tomorrow) return 'tomorrow';

  return DateFormat.yMMMMd().format(d);
}

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => TaskModel(),
      child: MyApp(),
    ),
  );
}

class BrandColors {
  final Color primary = Colors.black;
}

class Brand {
  final BrandColors colors = BrandColors();
}

final brand = Brand();

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PriorityZist',
      theme: ThemeData(primaryColor: brand.colors.primary),
      home: MyHomePage(title: 'Tasks'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(
          widget.title,
          style: TextStyle(color: Colors.white),
        ),
        leading: GestureDetector(
          onTap: () {
            print("Open the app menu");
          },
          child: Icon(
            Icons.menu, // add custom icons also
          ),
        ),
        actions: <Widget>[
          Padding(
              padding: EdgeInsets.only(right: 20.0),
              child: GestureDetector(
                onTap: () {
                  print("Open search bar");
                },
                child: Icon(
                  Icons.search,
                  size: 26.0,
                ),
              )),
          Consumer<TaskModel>(builder: (context, taskModel, child) {
            return Padding(
                padding: EdgeInsets.only(right: 20.0),
                child: PopupMenuButton<String>(
                  onSelected: (selected) {
                    switch (selected) {
                      case 'Hide Completed Tasks':
                      case 'Show Completed Tasks':
                        taskModel.toggleShowCompletedTasks();
                        return;
                    }
                  },
                  itemBuilder: (BuildContext context) {
                    return {
                      taskModel.showCompletedTasks
                          ? 'Hide Completed Tasks'
                          : 'Show Completed Tasks'
                    }.map((String choice) {
                      return PopupMenuItem<String>(
                        value: choice,
                        child: Text(choice),
                      );
                    }).toList();
                  },
                ));
          })
        ],
      ),
      body: Center(
        child: Consumer<TaskModel>(builder: (context, taskModel, child) {
          void _onDeleteTask(String id) {
            taskModel.deleteTask(id);

            Navigator.pop(context);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text('Task deleted')),
            );
          }

          return Column(
            children: taskModel.items.length == 0
                ? [
                    Container(
                        padding: EdgeInsets.only(top: 12),
                        child: Text('No tasks', style: TextStyle(fontSize: 24)))
                  ]
                : taskModel.items
                    .map((task) => TaskRow(
                          taskName: task.name,
                          completed: task.completed,
                          addedAt: formatTaskDateTime(task.addedAt),
                          onTap: () {
                            showPZBottomSheet(
                                context, EditTaskView(task: task));
                          },
                          onLongPress: () {
                            showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return SimpleDialog(
                                    title: Text('Actions'),
                                    children: <Widget>[
                                      SimpleDialogOption(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        child: ListTile(
                                            leading: IconButton(
                                                icon: Icon(Icons.delete),
                                                onPressed: () {
                                                  _onDeleteTask(task.id);
                                                }),
                                            title: Text("Delete Task"),
                                            onTap: () {
                                              _onDeleteTask(task.id);
                                            }),
                                      ),
                                    ],
                                  );
                                });
                          },
                          onPressLeadingIcon: () {
                            taskModel.toggleTaskCompleteStatus(task.id);
                          },
                        ))
                    .toList(),
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showPZBottomSheet(context, AddTaskView());
        },
        tooltip: 'Add Task',
        child: Icon(Icons.add),
        backgroundColor: brand.colors.primary,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class TaskRow extends StatelessWidget {
  TaskRow(
      {Key? key,
      required this.addedAt,
      required this.taskName,
      this.onTap,
      this.onLongPress,
      this.completed = false,
      this.leadingTooltip,
      this.onPressLeadingIcon})
      : super(key: key);

  final bool completed;
  final String addedAt;
  final String taskName;
  final String? leadingTooltip;

  final Function? onTap;
  final Function? onLongPress;
  final Function? onPressLeadingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(
          taskName,
          style: TextStyle(
              decoration: completed ? TextDecoration.lineThrough : null),
        ),
        subtitle: Text(addedAt[0].toUpperCase() + addedAt.substring(1)),
        onTap: () {
          if (onTap != null) onTap!();
        },
        onLongPress: () {
          if (onLongPress != null) onLongPress!();
        },
        leading: IconButton(
          hoverColor: Colors.transparent,
          color: brand.colors.primary,
          onPressed: () {
            if (onPressLeadingIcon != null) onPressLeadingIcon!();
          },
          icon: Icon(
              completed ? Icons.check_circle_outlined : Icons.circle_outlined),
          tooltip: leadingTooltip,
        ));
  }
}

class EditTaskView extends StatefulWidget {
  final TaskItem task;

  const EditTaskView({required this.task});

  @override
  _EditTaskViewState createState() => _EditTaskViewState(
      impact: task.impact,
      reach: task.reach,
      confidence: task.confidence,
      effort: task.effort);
}

class _EditTaskViewState extends State<EditTaskView> {
  double reach;
  double impact;
  double effort;
  double confidence;

  _EditTaskViewState(
      {required this.impact,
      required this.reach,
      required this.confidence,
      required this.effort});

  @override
  Widget build(BuildContext context) {
    var _txtController = TextEditingController(text: widget.task.name);

    return Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Consumer<TaskModel>(builder: (context, taskModel, child) {
            return TextField(
              autofocus: true,
              controller: _txtController,
              minLines: 1,
              maxLines: 6,
              onChanged: (text) {
                _txtController.value = _txtController.value.copyWith(
                  text: text,
                  selection: TextSelection.collapsed(offset: text.length),
                );
              },
              decoration: InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(18),
                  suffixIcon: IconButton(
                      color: brand.colors.primary,
                      icon: Icon(Icons.send),
                      onPressed: () {
                        taskModel.editTask(EditTaskInput(
                            id: widget.task.id,
                            name: _txtController.text,
                            reach: reach,
                            impact: impact,
                            confidence: confidence,
                            effort: effort));

                        Navigator.pop(context);

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: const Text('Successful Edit')),
                        );
                      },
                      splashColor: Colors.transparent),
                  hintText: "e.g. Buy eggs for breakfast"),
            );
          }),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    "Reach",
                  ),
                  Slider(
                    activeColor: brand.colors.primary,
                    value: reach,
                    min: 1,
                    max: 6,
                    divisions: 5,
                    label: reach.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        reach = value;
                      });
                    },
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    "Impact",
                  ),
                  Slider(
                    min: 1,
                    max: 4,
                    divisions: 3,
                    value: impact,
                    activeColor: brand.colors.primary,
                    label: impact.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        impact = value;
                      });
                    },
                  )
                ],
              )
            ],
          ),
          Row(
            children: [
              Column(
                children: [
                  Text(
                    "Confidence",
                  ),
                  Slider(
                    min: 1,
                    max: 100,
                    divisions: 99,
                    value: confidence,
                    activeColor: brand.colors.primary,
                    label: confidence.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        confidence = value;
                      });
                    },
                  )
                ],
              ),
              Column(
                children: [
                  Text(
                    "Effort",
                  ),
                  Slider(
                    min: 1,
                    max: 6,
                    divisions: 5,
                    value: effort,
                    activeColor: brand.colors.primary,
                    label: effort.round().toString(),
                    onChanged: (double value) {
                      setState(() {
                        effort = value;
                      });
                    },
                  )
                ],
              )
            ],
          ),
          Container(
            margin: EdgeInsets.only(bottom: 18),
            child: Text(
              "RICE Score: ${calculateRiceScore(reach, impact, confidence, effort).toStringAsFixed(1)}",
              style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
            ),
          )
        ]);
  }
}

class AddTaskView extends StatefulWidget {
  @override
  _AddTaskViewState createState() => _AddTaskViewState();
}

class _AddTaskViewState extends State<AddTaskView> {
  // the comments are the possible range of each parameter
  // 1 ~ 6
  double _reach = 3.0;
  // 1 ~ 100%
  double _confidence = 50.0;
  // 1 ~ 4
  double _impact = 2.0;
  // 1 ~ 6
  double _effort = 3.0;

  var _txtController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Consumer<TaskModel>(builder: (context, taskModel, child) {
          return TextField(
            autofocus: true,
            controller: _txtController,
            minLines: 1,
            maxLines: 6,
            onChanged: (text) {
              _txtController.value = _txtController.value.copyWith(
                text: text,
                selection: TextSelection.collapsed(offset: text.length),
              );
            },
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: EdgeInsets.all(18),
                suffixIcon: IconButton(
                    color: brand.colors.primary,
                    icon: Icon(Icons.send),
                    onPressed: () {
                      taskModel.add(TaskItem(
                        id: Uuid().v4(),
                        reach: _reach,
                        impact: _impact,
                        confidence: _confidence,
                        effort: _effort,
                        addedAt: DateTime.now(),
                        name: _txtController.text,
                      ));
                      Navigator.pop(context);
                    },
                    splashColor: Colors.transparent),
                hintText: "e.g. Buy eggs for breakfast"),
          );
        }),
        Row(
          children: [
            Column(
              children: [
                Text(
                  "Reach",
                ),
                Slider(
                  activeColor: brand.colors.primary,
                  value: _reach,
                  min: 1,
                  max: 6,
                  divisions: 5,
                  label: _reach.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _reach = value;
                    });
                  },
                )
              ],
            ),
            Column(
              children: [
                Text(
                  "Impact",
                ),
                Slider(
                  min: 1,
                  max: 4,
                  divisions: 3,
                  value: _impact,
                  activeColor: brand.colors.primary,
                  label: _impact.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _impact = value;
                    });
                  },
                )
              ],
            )
          ],
        ),
        Row(
          children: [
            Column(
              children: [
                Text(
                  "Confidence",
                ),
                Slider(
                  min: 1,
                  max: 100,
                  divisions: 99,
                  value: _confidence,
                  activeColor: brand.colors.primary,
                  label: _confidence.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _confidence = value;
                    });
                  },
                )
              ],
            ),
            Column(
              children: [
                Text(
                  "Effort",
                ),
                Slider(
                  min: 1,
                  max: 6,
                  divisions: 5,
                  value: _effort,
                  activeColor: brand.colors.primary,
                  label: _effort.round().toString(),
                  onChanged: (double value) {
                    setState(() {
                      _effort = value;
                    });
                  },
                )
              ],
            )
          ],
        ),
        Container(
          margin: EdgeInsets.only(bottom: 18),
          child: Text(
            "RICE Score: ${calculateRiceScore(_reach, _impact, _confidence, _effort).toStringAsFixed(1)}",
            style: TextStyle(fontSize: 22, fontStyle: FontStyle.italic),
          ),
        )
      ],
    );
  }
}

// utils
double calculateRiceScore(
    double reach, double impact, double confidence, double effort) {
  return (reach * impact * confidence) / effort;
}

void showPZBottomSheet(BuildContext context, Widget? child) {
  // the isScrollControlled and padding avoids the device keyboard
  showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      builder: (context) {
        return Container(
            padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom),
            child: child);
      });
}
