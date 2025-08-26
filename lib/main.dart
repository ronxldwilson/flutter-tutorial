
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum Priority { Low, Medium, High }

enum FilterType { All, Completed, Incomplete }

enum SortType { None, DueDate, Priority }

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.system;

  void _toggleTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Todo App',
      theme: ThemeData(primarySwatch: Colors.blue),
      darkTheme: ThemeData.dark(),
      themeMode: _themeMode,
      home: MyHomePage(
        title: 'Todo App',
        onThemeChanged: _toggleTheme,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title, required this.onThemeChanged});

  final String title;
  final ValueChanged<ThemeMode> onThemeChanged;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Todo> _todos = <Todo>[];
  FilterType _filter = FilterType.All;
  SortType _sort = SortType.None;

  @override
  void initState() {
    super.initState();
    _loadTodos();
  }

  void _loadTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String? todosString = prefs.getString('todos');
    if (todosString != null) {
      final List<dynamic> todosJson = jsonDecode(todosString);
      setState(() {
        _todos = todosJson.map((json) => Todo.fromJson(json)).toList();
      });
    }
  }

  void _saveTodos() async {
    final prefs = await SharedPreferences.getInstance();
    final String todosString = jsonEncode(_todos.map((todo) => todo.toJson()).toList());
    await prefs.setString('todos', todosString);
  }

  void _addTodoItem(String title, DateTime? dueDate, Priority priority) {
    setState(() {
      _todos.add(Todo(title: title, isDone: false, dueDate: dueDate, priority: priority));
    });
    _saveTodos();
  }

  void _toggleTodoStatus(int index) {
    setState(() {
      final todo = _filteredAndSortedTodos[index];
      todo.isDone = !todo.isDone;
    });
    _saveTodos();
  }

  void _deleteTodoItem(int index) {
    setState(() {
      final todo = _filteredAndSortedTodos[index];
      _todos.remove(todo);
    });
    _saveTodos();
  }

  void _editTodoItem(int index, String title, DateTime? dueDate, Priority priority) {
    setState(() {
      final todo = _filteredAndSortedTodos[index];
      todo.title = title;
      todo.dueDate = dueDate;
      todo.priority = priority;
    });
    _saveTodos();
  }

  Future<void> _displayTodoDialog({Todo? todo, int? index}) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (BuildContext context) {
        return _TodoDialog(todo: todo);
      },
    );

    if (result != null) {
      if (index != null) {
        _editTodoItem(index, result['title'], result['dueDate'], result['priority']);
      } else {
        _addTodoItem(result['title'], result['dueDate'], result['priority']);
      }
    }
  }

  List<Todo> get _filteredAndSortedTodos {
    List<Todo> filteredTodos = _todos;
    if (_filter == FilterType.Completed) {
      filteredTodos = _todos.where((todo) => todo.isDone).toList();
    } else if (_filter == FilterType.Incomplete) {
      filteredTodos = _todos.where((todo) => !todo.isDone).toList();
    }

    if (_sort == SortType.DueDate) {
      filteredTodos.sort((a, b) {
        if (a.dueDate == null && b.dueDate == null) return 0;
        if (a.dueDate == null) return 1;
        if (b.dueDate == null) return -1;
        return a.dueDate!.compareTo(b.dueDate!);
      });
    } else if (_sort == SortType.Priority) {
      filteredTodos.sort((a, b) => b.priority.index.compareTo(a.priority.index));
    }

    return filteredTodos;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: () {
              final currentThemeMode = Theme.of(context).brightness == Brightness.dark
                  ? ThemeMode.light
                  : ThemeMode.dark;
              widget.onThemeChanged(currentThemeMode);
            },
          ),
          PopupMenuButton(
            onSelected: (value) {
              setState(() {
                if (value is FilterType) {
                  _filter = value;
                } else if (value is SortType) {
                  _sort = value;
                }
              });
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry>[
              PopupMenuItem(
                enabled: false,
                child: Text('Filter by', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              CheckedPopupMenuItem(
                checked: _filter == FilterType.All,
                value: FilterType.All,
                child: const Text('All'),
              ),
              CheckedPopupMenuItem(
                checked: _filter == FilterType.Completed,
                value: FilterType.Completed,
                child: const Text('Completed'),
              ),
              CheckedPopupMenuItem(
                checked: _filter == FilterType.Incomplete,
                value: FilterType.Incomplete,
                child: const Text('Incomplete'),
              ),
              const PopupMenuDivider(),
              PopupMenuItem(
                enabled: false,
                child: Text('Sort by', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              CheckedPopupMenuItem(
                checked: _sort == SortType.None,
                value: SortType.None,
                child: const Text('None'),
              ),
              CheckedPopupMenuItem(
                checked: _sort == SortType.DueDate,
                value: SortType.DueDate,
                child: const Text('Due Date'),
              ),
              CheckedPopupMenuItem(
                checked: _sort == SortType.Priority,
                value: SortType.Priority,
                child: const Text('Priority'),
              ),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: _filteredAndSortedTodos.length,
        itemBuilder: (BuildContext context, int index) {
          final todo = _filteredAndSortedTodos[index];
          return ListTile(
            leading: Icon(Icons.circle, color: _getPriorityColor(todo.priority)),
            title: Text(
              todo.title,
              style: TextStyle(
                decoration: todo.isDone ? TextDecoration.lineThrough : TextDecoration.none,
              ),
            ),
            subtitle: todo.dueDate != null ? Text(todo.dueDate.toString().substring(0, 10)) : null,
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Checkbox(value: todo.isDone, onChanged: (value) => _toggleTodoStatus(index)),
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () => _displayTodoDialog(todo: todo, index: index),
                ),
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: () => _deleteTodoItem(index),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _displayTodoDialog(),
        tooltip: 'Add Item',
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getPriorityColor(Priority priority) {
    switch (priority) {
      case Priority.High:
        return Colors.red;
      case Priority.Medium:
        return Colors.orange;
      case Priority.Low:
        return Colors.green;
    }
  }
}

class _TodoDialog extends StatefulWidget {
  final Todo? todo;

  const _TodoDialog({this.todo});

  @override
  State<_TodoDialog> createState() => _TodoDialogState();
}

class _TodoDialogState extends State<_TodoDialog> {
  final TextEditingController _textFieldController = TextEditingController();
  DateTime? _dueDate;
  Priority _priority = Priority.Medium;

  @override
  void initState() {
    super.initState();
    if (widget.todo != null) {
      _textFieldController.text = widget.todo!.title;
      _dueDate = widget.todo!.dueDate;
      _priority = widget.todo!.priority;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.todo == null ? 'Add a new todo item' : 'Edit todo item'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _textFieldController,
            decoration: const InputDecoration(hintText: 'Enter todo item'),
            autofocus: true,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Text('Due Date:'),
              const Spacer(),
              TextButton(
                onPressed: () async {
                  final pickedDate = await showDatePicker(
                    context: context,
                    initialDate: _dueDate ?? DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );
                  if (pickedDate != null) {
                    setState(() {
                      _dueDate = pickedDate;
                    });
                  }
                },
                child: Text(_dueDate?.toString().substring(0, 10) ?? 'Select Date'),
              ),
            ],
          ),
          Row(
            children: [
              const Text('Priority:'),
              const Spacer(),
              DropdownButton<Priority>(
                value: _priority,
                onChanged: (Priority? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _priority = newValue;
                    });
                  }
                },
                items: Priority.values.map<DropdownMenuItem<Priority>>((Priority value) {
                  return DropdownMenuItem<Priority>(
                    value: value,
                    child: Text(value.toString().split('.').last),
                  );
                }).toList(),
              ),
            ],
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Save'),
          onPressed: () {
            Navigator.of(context).pop({
              'title': _textFieldController.text,
              'dueDate': _dueDate,
              'priority': _priority,
            });
          },
        ),
      ],
    );
  }
}

class Todo {
  String title;
  bool isDone;
  DateTime? dueDate;
  Priority priority;

  Todo({
    required this.title,
    required this.isDone,
    this.dueDate,
    this.priority = Priority.Medium,
  });

  factory Todo.fromJson(Map<String, dynamic> json) => Todo(
        title: json['title'],
        isDone: json['isDone'],
        dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
        priority: Priority.values[json['priority']],
      );

  Map<String, dynamic> toJson() => {
        'title': title,
        'isDone': isDone,
        'dueDate': dueDate?.toIso8601String(),
        'priority': priority.index,
      };
}
