import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pochi/main.dart';

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
        child: _controller.value.isInitialized
            ? CameraPreview(_controller)
            : const CircularProgressIndicator(),
      ),
    );
  }
}
