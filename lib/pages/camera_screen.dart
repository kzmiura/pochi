import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pochi/main.dart';
import 'package:http/http.dart' as http;

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late final CameraController _controller;

  Future<void> _uploadImage() async {
    try {
      final xFileImage = await _controller.takePicture();
      final req = http.MultipartRequest(
        "POST",
        Uri.parse(
            'https://pochi-upload.onrender.com/upload/${supabase.auth.currentUser!.id}'),
      );
      req.files.add(
        await http.MultipartFile.fromPath(
          "image",
          xFileImage.path,
        ),
      );
      final res = await req.send();
      print(res.statusCode);
    } on CameraException catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();

    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
    );
    _controller.initialize().onError<CameraException>(
      (error, stackTrace) {
        switch (error.code) {
          case 'CameraAccessDenied':
            print(error.description);
            break;
          default:
            break;
        }
      },
    ).then((_) {
      if (!mounted) return;
      setState(() {});
    });
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Stack(
          alignment: Alignment.bottomCenter,
          children: _controller.value.isInitialized
              ? [
                  CameraPreview(_controller),
                  IconButton.filled(
                    onPressed: _uploadImage,
                    icon: const Icon(Icons.circle),
                  ),
                ]
              : [const CircularProgressIndicator()],
        ),
      ),
    );
  }
}
