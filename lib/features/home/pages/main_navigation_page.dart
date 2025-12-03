import 'package:flutter/material.dart';
import 'package:custom_navigation_bar/custom_navigation_bar.dart';
import '../../task/pages/task_list_page.dart';
import '../../folder/pages/folder_list_page.dart';
import '../../share/pages/share_page.dart';

class MainNavigationPage extends StatefulWidget {
  const MainNavigationPage({super.key});

  @override
  State<MainNavigationPage> createState() => _MainNavigationPageState();
}

class _MainNavigationPageState extends State<MainNavigationPage> {
  int _currentIndex =
      1; 

  final List<Widget> _pages = [
    const FolderListPage(),
    const TaskListPage(), 
    const SharePage(), 
  ];


  void _onFabPressed() {
    if (_currentIndex == 0) {
      Navigator.pushNamed(context, '/add-folder'); 
    } else {
      Navigator.pushNamed(context, '/add-task');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      body: IndexedStack(index: _currentIndex, children: _pages),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _onFabPressed,
        backgroundColor: const Color(0xFF8BE4A9),
        elevation: 4,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF1D1D1D), 
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: CustomNavigationBar(
              iconSize: 28,
              selectedColor: const Color(0xFF8BE4A9), 
              strokeColor: const Color(0xFF8BE4A9),
              unSelectedColor: Colors.grey[600]!,
              backgroundColor: Colors
                  .transparent, 
              borderRadius: const Radius.circular(12),
              blurEffect: false,
              opacity: 1,
              currentIndex: _currentIndex,
              onTap: (index) {
                setState(() {
                  _currentIndex = index;
                });
              },
              items: [
                CustomNavigationBarItem(
                  icon: const Icon(Icons.folder_outlined),
                  selectedIcon: const Icon(
                    Icons.folder,
                  ), 
                  title: const Text('Folder', style: TextStyle(fontSize: 12)),
                ),
                CustomNavigationBarItem(
                  icon: const Icon(
                    Icons.check_box_outlined,
                  ), 
                  selectedIcon: const Icon(Icons.check_box),
                  title: const Text('Task', style: TextStyle(fontSize: 12)),
                ),
                CustomNavigationBarItem(
                  icon: const Icon(Icons.share_outlined),
                  selectedIcon: const Icon(Icons.share),
                  title: const Text('Share', style: TextStyle(fontSize: 12)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
