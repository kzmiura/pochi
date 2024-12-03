import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:pochi/pages/home_screen.dart';
import 'package:pochi/pages/signin_screen.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

late final List<CameraDescription> cameras;
final supabase = Supabase.instance.client;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://xroalasoafrhvcphegmi.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inhyb2FsYXNvYWZyaHZjcGhlZ21pIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MzI1MTI2MDYsImV4cCI6MjA0ODA4ODYwNn0.xcSBzrnFpiU6UoL_lTk_4pYiLrrzAcDQWRedLoY1NO0',
  );

  cameras = await availableCameras();

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'POCHI',
      home: supabase.auth.currentSession != null
          ? const HomeScreen()
          : const SignInScreen(),
    );
  }
}
