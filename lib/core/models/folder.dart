import 'user.dart';

class Folder {
  final int id;
  final String name;
  final String? description;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final User? user; // Owner (untuk shared folder)
  final List<User> members; // <--- TAMBAHAN: List member (untuk own folder)

  Folder({
    required this.id,
    required this.name,
    this.description,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
    this.user,
    this.members = const [], // Default kosong
  });

  factory Folder.fromJson(Map<String, dynamic> json) {
    // Parsing list 'sharedWith' dari backend menjadi List<User>
    var membersList = <User>[];
    if (json['sharedWith'] != null) {
      membersList = (json['sharedWith'] as List).map((item) {
        // Struktur Prisma: sharedWith -> [ { user: { ... } } ]
        return User.fromJson(item['user']);
      }).toList();
    }

    return Folder(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      userId: json['userId'] ?? json['user_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      user: json['user'] != null ? User.fromJson(json['user']) : null,
      members: membersList, // <--- Masukkan hasil parsing
    );
  }

  // ... (toJson dan copyWith sesuaikan jika perlu, tapi update di atas yang paling penting)
}
