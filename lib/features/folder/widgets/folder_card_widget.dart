import 'package:flutter/material.dart';
import '../../../../core/models/folder.dart';

class FolderCardWidget extends StatelessWidget {
  final Folder folder;
  final int taskCount;
  final int? completionPercentage;
  final String? ownerName;
  final bool isShared;
  final VoidCallback onTap;

  const FolderCardWidget({
    super.key,
    required this.folder,
    required this.taskCount,
    this.completionPercentage,
    this.ownerName,
    this.isShared = false,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF1D1D1D),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[800]!, width: 1),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: const Color(0xFF8BE4A9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.folder,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
      
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        folder.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$taskCount Tasks',
                        style: TextStyle(color: Colors.grey[400], fontSize: 13),
                      ),
                      if (isShared && ownerName != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.person,
                              size: 12,
                              color: Colors.grey[600],
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Owner: $ownerName',
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (completionPercentage != null)
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF8BE4A9),
                        width: 3,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        '$completionPercentage%',
                        style: const TextStyle(
                          color: Color(0xFF8BE4A9),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
