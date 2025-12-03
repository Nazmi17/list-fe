import '../constants/api_constants.dart';
import '../models/task.dart';
import 'api_service.dart';

class TaskService {
  final ApiService _apiService;

  TaskService({required ApiService apiService}) : _apiService = apiService;

  Future<Task> createTask({
    required String title,
    String? description,
    required Priority priority,
    required DateTime startDate,
    required DateTime dueDate,
    int? folderId,
  }) async {
    try {
      final body = <String, dynamic>{
        'title': title,
        'priority': priority.name,
        'start_date': startDate.toIso8601String(),
        'due_date': dueDate.toIso8601String(),
      };

      if (description != null) body['description'] = description;
      if (folderId != null) body['folderId'] = folderId;

      final response = await _apiService.post(ApiConstants.tasks, body: body);

      return Task.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> getTasks({
    Priority? priority,
    bool? complete,
    int? folderId,
  }) async {
    try {
      final queryParams = <String, String>{};

      if (priority != null) queryParams['priority'] = priority.name;
      if (complete != null) queryParams['complete'] = complete.toString();
      if (folderId != null) queryParams['folderId'] = folderId.toString();

      final response = await _apiService.get(
        ApiConstants.tasks,
        queryParams: queryParams.isNotEmpty ? queryParams : null,
      );

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> updateTask({
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
      final body = <String, dynamic>{};

      if (title != null) body['title'] = title;
      if (description != null) body['description'] = description;
      if (priority != null) body['priority'] = priority.name;
      if (complete != null) body['complete'] = complete;
      if (startDate != null) body['start_date'] = startDate.toIso8601String();
      if (dueDate != null) body['due_date'] = dueDate.toIso8601String();
      if (folderId != null) body['folderId'] = folderId;

      final response = await _apiService.put(
        ApiConstants.task(taskId),
        body: body,
      );

      return Task.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<Task> toggleTaskComplete(int taskId, bool complete) async {
    try {
      final response = await _apiService.put(
        ApiConstants.task(taskId),
        body: {'complete': complete},
      );

      return Task.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteTask(int taskId) async {
    try {
      await _apiService.delete(ApiConstants.task(taskId));
    } catch (e) {
      rethrow;
    }
  }

  Future<List<Task>> getTasksInFolder(int folderId) async {
    try {
      final response = await _apiService.get(
        ApiConstants.folderTasks(folderId),
      );

      return (response as List).map((json) => Task.fromJson(json)).toList();
    } catch (e) {
      rethrow;
    }
  }
}
