import '../constants/api_constants.dart';
import '../models/folder.dart';
import '../models/folder_share.dart';
import '../models/folders_response.dart';
import 'api_service.dart';

class FolderService {
  final ApiService _apiService;

  FolderService({required ApiService apiService}) : _apiService = apiService;

  Future<Folder> createFolder({
    required String name,
    String? description,
  }) async {
    try {
      final body = {'name': name};
      if (description != null) body['description'] = description;

      final response = await _apiService.post(ApiConstants.folders, body: body);

      return Folder.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FoldersResponse> getFolders() async {
    try {
      final response = await _apiService.get(ApiConstants.folders);
      return FoldersResponse.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<FolderShare> shareFolder({
    required int folderId,
    required int userId,
  }) async {
    try {
      final response = await _apiService.post(
        ApiConstants.folderShare(folderId),
        body: {'userId': userId},
      );

      return FolderShare.fromJson(response);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> unshareFolder({
    required int folderId,
    required int userId,
  }) async {
    try {
      await _apiService.delete(ApiConstants.folderUnshare(userId, folderId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteFolder(int folderId) async {
    try {
      await _apiService.delete(ApiConstants.folder(folderId));
    } catch (e) {
      rethrow;
    }
  }

  Future<void> leaveSharedFolder(int folderId) async {
    try {
      await _apiService.delete(ApiConstants.folderLeave(folderId));
    } catch (e) {
      rethrow;
    }
  }
}
