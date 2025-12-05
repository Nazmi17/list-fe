import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/models/folder.dart';
import '../../../../core/providers/folder_provider.dart';

class ManageMembersDialog extends StatelessWidget {
  final Folder folder;

  const ManageMembersDialog({super.key, required this.folder});

  @override
  Widget build(BuildContext context) {
    final folderProvider = context.watch<FolderProvider>();

    // Ambil folder terbaru dari provider (agar list member update realtime)
    // Jika tidak ketemu (misal baru dihapus), pakai folder yang dipassing
    final currentFolder = folderProvider.ownFolders.firstWhere(
      (f) => f.id == folder.id,
      orElse: () => folder,
    );

    return AlertDialog(
      backgroundColor: const Color(0xFF1D1D1D),
      title: const Text(
        'Manage Members',
        style: TextStyle(color: Colors.white, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: currentFolder.members.isEmpty
            ? Column(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.group_off, size: 40, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("No members yet", style: TextStyle(color: Colors.grey)),
                ],
              )
            : ListView.separated(
                shrinkWrap: true,
                itemCount: currentFolder.members.length,
                separatorBuilder: (context, index) =>
                    Divider(color: Colors.grey[800]),
                itemBuilder: (context, index) {
                  final member = currentFolder.members[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF8BE4A9),
                      child: Text(
                        member.username[0].toUpperCase(),
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      member.username,
                      style: const TextStyle(color: Colors.white),
                    ),
                    subtitle: Text(
                      member.email,
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.person_remove, color: Colors.red),
                      onPressed: () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            backgroundColor: const Color(0xFF2C2C2C),
                            title: const Text(
                              'Remove User?',
                              style: TextStyle(color: Colors.white),
                            ),
                            content: Text(
                              'Are you sure you want to remove ${member.username}?',
                              style: const TextStyle(color: Colors.grey),
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text(
                                  'Remove',
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          // Panggil fungsi unshareFolder
                          await context.read<FolderProvider>().unshareFolder(
                            folderId: folder.id,
                            userId: member.id,
                          );

                          // Refresh folder agar list member terupdate
                          if (context.mounted) {
                            await context.read<FolderProvider>().fetchFolders();
                          }
                        }
                      },
                    ),
                  );
                },
              ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Close',
            style: TextStyle(color: Color(0xFF8BE4A9)),
          ),
        ),
      ],
    );
  }
}
