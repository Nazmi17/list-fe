import 'package:flutter/foundation.dart';
import '../models/folder.dart';
import '../services/folder_service.dart';

class FolderProvider extends ChangeNotifier {
  final FolderService _folderService;

  List<Folder> _ownFolders = [];
  List<Folder> _sharedFolders = [];
  bool _isLoading = false;
  String? _errorMessage;

  FolderProvider({required FolderService folderService})
    : _folderService = folderService;

  List<Folder> get ownFolders => _ownFolders;
  List<Folder> get sharedFolders => _sharedFolders;
  List<Folder> get allFolders => [..._ownFolders, ..._sharedFolders];
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchFolders() async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final response = await _folderService.getFolders();
      _ownFolders = response.own;
      _sharedFolders = response.shared;

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _errorMessage = e.toString();
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> createFolder({required String name, String? description}) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      final folder = await _folderService.createFolder(
        name: name,
        description: description,
      );

      _ownFolders.add(folder);
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

  Future<bool> shareFolder({required int folderId, required int userId}) async {
    try {
      _errorMessage = null;
      await _folderService.shareFolder(folderId: folderId, userId: userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> unshareFolder({
    required int folderId,
    required int userId,
  }) async {
    try {
      _errorMessage = null;
      await _folderService.unshareFolder(folderId: folderId, userId: userId);
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> deleteFolder(int folderId) async {
    try {
      _errorMessage = null;

      await _folderService.deleteFolder(folderId);

      _ownFolders.removeWhere((folder) => folder.id == folderId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> leaveSharedFolder(int folderId) async {
    try {
      _errorMessage = null;

      await _folderService.leaveSharedFolder(folderId);

      _sharedFolders.removeWhere((folder) => folder.id == folderId);

      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
