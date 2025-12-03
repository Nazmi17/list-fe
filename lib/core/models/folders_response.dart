import 'folder.dart';

class FoldersResponse {
  final List<Folder> own;
  final List<Folder> shared;

  FoldersResponse({required this.own, required this.shared});

  factory FoldersResponse.fromJson(Map<String, dynamic> json) {
    return FoldersResponse(
      own: (json['own'] as List).map((e) => Folder.fromJson(e)).toList(),
      shared: (json['shared'] as List).map((e) => Folder.fromJson(e)).toList(),
    );
  }
}
