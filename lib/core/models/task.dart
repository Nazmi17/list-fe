import 'user.dart'; 

enum Priority { HIGH, MEDIUM, LOW }

class Task {
  final int id;
  final String title;
  final String? description;
  final Priority priority;
  final bool complete;
  final DateTime startDate;
  final DateTime dueDate;
  final int? folderId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  final User? user;

  Task({
    required this.id,
    required this.title,
    this.description,
    required this.priority,
    required this.complete,
    required this.startDate,
    required this.dueDate,
    this.folderId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    return Task(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      priority: Priority.values.firstWhere(
        (e) => e.name == json['priority'],
        orElse: () => Priority.MEDIUM, 
      ),
      complete: json['complete'],
      startDate: DateTime.parse(json['start_date']),
      dueDate: DateTime.parse(json['due_date']),
      folderId: json['folderId'],
      userId:
          json['userId'] ??
          json['user_id'], 
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),

      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'priority': priority.name,
      'complete': complete,
      'start_date': startDate.toIso8601String(),
      'due_date': dueDate.toIso8601String(),
      'folderId': folderId,
      'userId': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),

      if (user != null) 'user': user!.toJson(),
    };
  }

  Task copyWith({
    int? id,
    String? title,
    String? description,
    Priority? priority,
    bool? complete,
    DateTime? startDate,
    DateTime? dueDate,
    int? folderId,
    int? userId,
    DateTime? createdAt,
    DateTime? updatedAt,
    User? user, 
  }) {
    return Task(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      complete: complete ?? this.complete,
      startDate: startDate ?? this.startDate,
      dueDate: dueDate ?? this.dueDate,
      folderId: folderId ?? this.folderId,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      user: user ?? this.user,
    );
  }
}
