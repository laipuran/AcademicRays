import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_providers.dart';
import '../database/database.dart';
import 'camera_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 1; // 默认在“课中”

  void _onItemTapped(int index) {
    if (index == 1 && _selectedIndex == 1) {
      _navigateToCamera();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  Future<void> _navigateToCamera() async {
    await Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const CameraScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notesAsync = ref.watch(notesStreamProvider);

    final List<Widget> widgetOptions = <Widget>[
      const Center(child: Text('课前内容')),
      // --- 课中内容：实时读取数据库中的笔记 ---
      notesAsync.when(
        data: (notes) => notes.isEmpty
            ? const Center(child: Text('还没有笔记，点击下方 + 号开始拍照'))
            : ListView.builder(
                itemCount: notes.length,
                itemBuilder: (context, index) {
                  final note = notes[index];
                  return ListTile(
                    leading: const Icon(Icons.description),
                    title: Text(note.markdownContent?.split('\n').first.replaceAll('#', '').trim() ?? '无标题笔记'),
                    subtitle: Text(
                      note.rawText ?? '正在识别中...',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      // 点击查看详情
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('笔记详情'),
                          content: SingleChildScrollView(
                            child: Text(note.markdownContent ?? note.rawText ?? '无内容'),
                          ),
                          actions: [
                            TextButton(onPressed: () => Navigator.pop(context), child: const Text('关闭'))
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('读取失败: $err')),
      ),
      const Center(child: Text('课后内容')),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Academic Rays'),
      ),
      body: widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: <BottomNavigationBarItem>[
          const BottomNavigationBarItem(
            icon: Icon(Icons.history_edu),
            label: '课前',
          ),
          BottomNavigationBarItem(
            icon: Icon(_selectedIndex == 1 ? Icons.add_circle : Icons.school),
            label: '课中',
          ),
          const BottomNavigationBarItem(
            icon: Icon(Icons.assignment),
            label: '课后',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blueAccent,
        onTap: _onItemTapped,
      ),
    );
  }
}
