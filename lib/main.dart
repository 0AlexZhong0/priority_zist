import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class BrandColors {
  final Color primary = Colors.black;
}

class Brand {
  final BrandColors colors = BrandColors();
}

final brand = Brand();

class TaskItem {
  TaskItem({required this.name, required this.addedAt});

  final String name;
  final String addedAt;
}

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

final taskItems = [
  TaskItem(name: "Task 1", addedAt: "Yesterday"),
  TaskItem(name: "Task 2", addedAt: "Today")
];

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
      ),
      body: Center(
        child: Column(
          children: taskItems
              .map(
                  (task) => TaskRow(addedAt: task.addedAt, taskName: task.name))
              .toList(),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _modalBottomSheetMenu(context);
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
      this.leadingTooltip = "",
      this.onPressLeadingIcon})
      : super(key: key);

  final String addedAt;
  final String taskName;
  final String leadingTooltip;

  final Function? onTap;
  final Function? onLongPress;
  final Function? onPressLeadingIcon;

  @override
  Widget build(BuildContext context) {
    return ListTile(
        title: Text(taskName),
        subtitle: Text(addedAt),
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
          icon: Icon(Icons.circle_outlined),
          tooltip: leadingTooltip,
        ));
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
        TextField(
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
                  icon: Icon(Icons.send),
                  onPressed: () {
                    print("Add a tasks");
                    Navigator.pop(context);
                  },
                  splashColor: Colors.transparent),
              hintText: "e.g. Buy eggs for breakfast"),
        ),
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

void _modalBottomSheetMenu(BuildContext context) {
  showModalBottomSheet(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      context: context,
      builder: (context) {
        return AddTaskView();
      });
}
