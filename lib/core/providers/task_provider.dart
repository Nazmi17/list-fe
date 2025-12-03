import 'package:flutter/foundation.dart';
import '../models/task.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService;

  List<Task> _tasks = [];
  bool _isLoading = false;
  String? _errorMessage;

  TaskProvider({required TaskService taskService}) : _taskService = taskService;

  List<Task> get tasks => _tasks;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  List<Task> getTasksByFolder(int? folderId) {
    if (folderId == null) {
      return _tasks.where((task) => task.folderId == null).toList();
    }
    return _tasks.where((task) => task.folderId == folderId).toList();
  }

  List<Task> getTasksByPriority(Priority priority) {
    return _tasks.where((task) => task.priority == priority).toList();
  }

  List<Task> getCompletedTasks() {
    return _tasks.where((task) => task.complete).toList();
  }

  List<Task> getIncompleteTasks() {
    return _tasks.where((task) => !task.complete).toList();
  }

  Future<void> fetchTasks({
    Priority? priority,
    bool? complete, 
    int? folderId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      print('Fetching tasks... Complete param: $complete');

      if (complete == null) {
        final results = await Future.wait([
          _taskService.getTasks(
            priority: priority,
            folderId: folderId,
            complete: false,
          ),
          _taskService.getTasks(
            priority: priority,
            folderId: folderId,
            complete: true,
          ),
        ]);

        _tasks = [...results[0], ...results[1]];

        _tasks.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      } else {
        _tasks = await _taskService.getTasks(
          priority: priority,
          complete: complete,
          folderId: folderId,
        );
      }

      print('Total tasks loaded: ${_tasks.length}'); // Debug jumlah data

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error fetching tasks: $e');
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createTask({
    required String title,
    String? description,
    required Priority priority,
    required DateTime startDate,
    required DateTime dueDate,
    int? folderId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final task = await _taskService.createTask(
        title: title,
        description: description,
        priority: priority,
        startDate: startDate,
        dueDate: dueDate,
        folderId: folderId,
      );

      _tasks.add(task);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateTask({
    required int taskId,
    String? title,
    String? description,
    Priority? priority,
    bool? complete,
    DateTime? startDate,
    DateTime? dueDate,
    int? folderId,
  }) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final updatedTask = await _taskService.updateTask(
        taskId: taskId,
        title: title,
        description: description,
        priority: priority,
        complete: complete,
        startDate: startDate,
        dueDate: dueDate,
        folderId: folderId,
      );

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> toggleTaskComplete(int taskId) async {
    try {
      final task = _tasks.firstWhere((t) => t.id == taskId);
      final updatedTask = await _taskService.toggleTaskComplete(
        taskId,
        !task.complete,
      );

      final index = _tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        _tasks[index] = updatedTask;
      }

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteTask(int taskId) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      await _taskService.deleteTask(taskId);
      _tasks.removeWhere((t) => t.id == taskId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
