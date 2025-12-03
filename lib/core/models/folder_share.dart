class FolderShare {
  final int id;
  final int folderId;
  final int userId;
  final DateTime createdAt;
  final DateTime updatedAt;

  FolderShare({
    required this.id,
    required this.folderId,
    required this.userId,
    required this.createdAt,
    required this.updatedAt,
  });

  factory FolderShare.fromJson(Map<String, dynamic> json) {
    return FolderShare(
      id: json['id'],
      folderId: json['folderId'],
      userId: json['userId'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'folderId': folderId,
      'userId': userId,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }
}
