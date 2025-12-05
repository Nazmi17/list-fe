import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/providers/folder_provider.dart';
import '../../../../core/providers/task_provider.dart';
import '../../../../core/providers/auth_provider.dart'; 
import '../../../../core/services/user_service.dart';
import '../../../../core/services/api_service.dart';
import '../../../../core/models/user.dart';
import '../../../../core/models/folder.dart';
import '../../../../core/routes/routes.dart'; 
import '../widgets/user_card_widget.dart';
import '../widgets/folder_selection_dialog.dart';

class SharePage extends StatefulWidget {
  const SharePage({super.key});

  @override
  State<SharePage> createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final _searchController = TextEditingController();
  List<User> _searchResults = [];
  bool _isSearching = false;
  bool _hasSearched = false;
  UserService? _userService;

  Future<void> _showLogoutDialog(
    BuildContext context,
    AuthProvider authProvider,
  ) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1D1D1D),
        title: const Text('Logout', style: TextStyle(color: Colors.white)),
        content: const Text(
          'Are you sure you want to logout?',
          style: TextStyle(color: Colors.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (shouldLogout == true) {
      await authProvider.logout();

      if (context.mounted) {
        context.read<TaskProvider>().clearState();
        context.read<FolderProvider>().clearState();

        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.login,
          (route) => false,
        );
      }
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final apiService = context.read<ApiService>();
      _userService = UserService(apiService: apiService);

      if (mounted) {
        context.read<FolderProvider>().fetchFolders();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _hasSearched = false;
      });
      return;
    }

    if (_userService == null) {
      final apiService = context.read<ApiService>();
      _userService = UserService(apiService: apiService);
    }

    setState(() {
      _isSearching = true;
      _hasSearched = true;
    });

    try {
      final results = await _userService!.searchUsers(query);
      if (mounted) {
        setState(() {
          _searchResults = results;
          _isSearching = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSearching = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error searching users: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _shareFolder(User user) async {
    final folderProvider = context.read<FolderProvider>();

    final Folder? selectedFolder = await showDialog<Folder>(
      context: context,
      builder: (context) =>
          FolderSelectionDialog(folders: folderProvider.ownFolders),
    );

    if (selectedFolder == null) return;

    final success = await folderProvider.shareFolder(
      folderId: selectedFolder.id,
      userId: user.id,
    );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Folder "${selectedFolder.name}" shared with ${user.username}',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            folderProvider.errorMessage ?? 'Failed to share folder',
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Ambil AuthProvider untuk logout
    final authProvider = context.read<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0),
        elevation: 0,
        title: const Text(
          'Share',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
             Navigator.pushNamed(context, AppRoutes.settings);
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(20),
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF8BE4A9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(color: Colors.black, fontSize: 16),
                decoration: InputDecoration(
                  hintText: 'Search',
                  hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search, color: Colors.black),
                    onPressed: () => _searchUsers(_searchController.text),
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 16,
                  ),
                ),
                onSubmitted: _searchUsers,
              ),
            ),
          ),

          Expanded(
            child: _isSearching
                ? const Center(
                    child: CircularProgressIndicator(color: Color(0xFF8BE4A9)),
                  )
                : _hasSearched && _searchResults.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.search_off,
                          size: 80,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No users found',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : !_hasSearched
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset(
                          'assets/images/bro3.png',
                          width: 200,
                          height: 200,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(
                              Icons.people_outline,
                              size: 100,
                              color: Colors.grey[600],
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Find a friend to do tasks together',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      final user = _searchResults[index];
                      return UserCardWidget(
                        user: user,
                        onTap: () => _shareFolder(user),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
