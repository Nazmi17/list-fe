import 'user.dart';

class Folder {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user;

  Folder({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user, 
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    return Folder(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['userId'] ?? json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'user_id': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
