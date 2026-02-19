import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/global_providers.dart';
import '../database/database.dart';

class PreviewScreen extends ConsumerStatefulWidget {
  final List<XFile> images;

  const PreviewScreen({super.key, required this.images});

  @override
  ConsumerState<PreviewScreen> createState() => _PreviewScreenState();
}

class _PreviewScreenState extends ConsumerState<PreviewScreen> {
  bool _isProcessing = false;
  Map<int, String> _processingStatuses = {}; // index -> status
  List<Subject>? _subjects;

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final repo = ref.read(noteRepositoryProvider);
    final subjects = await repo.getAllSubjects();
    setState(() {
      _subjects = subjects;
    });
  }

  Future<void> _processAll() async {
    setState(() {
      _isProcessing = true;
    });

    final repo = ref.read(noteRepositoryProvider);
    final pipelineManagerFuture = ref.read(pipelineManagerProvider.future);
    
    try {
      final pipelineManager = await pipelineManagerFuture;

      for (int i = 0; i < widget.images.length; i++) {
        setState(() {
          _processingStatuses[i] = '正在保存...';
        });

        // 1. Add to database as capture
        final file = File(widget.images[i].path);
        final captureId = await repo.addCapture(file.path);

        setState(() {
          _processingStatuses[i] = '正在分类与识别...';
        });

        // 2. Start pipeline
        // Note: Currently ignores subjectId to allow 'Auto-classification' via LLM step 
        // if the pipeline supports it. Otherwise it stays as null.
        await pipelineManager.processCapture(captureId, file);

        setState(() {
          _processingStatuses[i] = '完成';
        });
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('所有照片已处理并分类')),
        );
        // After completion, go back to main screen or show results.
        // For now, go back to main screen.
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('处理出错: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('预览与上传'),
        actions: [
          if (!_isProcessing)
            TextButton(
              onPressed: _processAll,
              child: const Text('开始上传', style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
            ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: widget.images.length,
              itemBuilder: (context, index) {
                final status = _processingStatuses[index];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(widget.images[index].path),
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (status != null)
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.black45,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Center(
                          child: Text(
                            status,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    if (status == '完成')
                      const Positioned(
                        top: 5,
                        right: 5,
                        child: Icon(Icons.check_circle, color: Colors.green),
                      ),
                  ],
                );
              },
            ),
          ),
          if (_isProcessing)
            const Padding(
              padding: EdgeInsets.all(20.0),
              child: Column(
                children: [
                  LinearProgressIndicator(),
                  SizedBox(height: 10),
                  Text('自动分类识别中，请稍候...'),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
