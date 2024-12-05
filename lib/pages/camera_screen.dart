import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pochi/main.dart';
import 'package:path/path.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final CameraController _controller;

  @override
  void initState() {
    super.initState();

    () async {
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
      );
      try {
        await _controller.initialize();
      } on CameraException catch (e) {
        switch (e.code) {
          case 'CameraAccessDenied':
            print(e.description);
            break;
          default:
            break;
        }
      }
      if (!mounted) return;
      setState(() {});
    }();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Stack(
          children: [
            _controller.value.isInitialized
                ? CameraPreview(_controller)
                : const CircularProgressIndicator(),
            IconButton.filled(
              onPressed: () async {
                final xFileImage = await _controller.takePicture();
                final image = File(xFileImage.path);
                if (!context.mounted) return;
                showDialog(
                  context: context,
                  builder: (context) => AlertDialog(
                    content: Image.file(image),
                    actions: [
                      TextButton(
                        onPressed: () async {
                          final images = supabase.storage.from('images');
                          final id = supabase.auth.currentUser!.id;
                          final fileName = basenameWithoutExtension(image.path);
                          try {
                            await images.upload('$id/$fileName', image);
                          } on StorageException catch (e) {
                            print(e.message);
                          } finally {
                            if (context.mounted) Navigator.pop(context);
                          }
                        },
                        child: const Text('Save'),
                      ),
                    ],
                  ),
                );
              },
              icon: const Icon(Icons.circle),
            ),
          ],
        ),
      ),
    );
  }
}
