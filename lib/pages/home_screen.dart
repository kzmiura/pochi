import 'dart:async';

import 'package:flutter/material.dart';
import 'package:pochi/main.dart';
import 'package:pochi/pages/camera_screen.dart';
import 'package:pochi/pages/signin_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  var _currentIndex = 0;
  late final StreamSubscription _subscription;

  @override
  void initState() {
    super.initState();
    final auth = supabase.auth;
    _subscription = auth.onAuthStateChange.listen((data) {
      final session = data.session;
      if (session == null) {
        if (!mounted) return;
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const SignInScreen()),
          (route) => false,
        );
      }
    });
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: () async {
              await supabase.auth.signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: [
        Center(
          child: Text('Home'),
        ),
        Center(
          child: Text('Album'),
        )
      ][_currentIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(supabase.auth.currentUser!.email ?? 'No email'),
            ),
            ListTile(
              title: Text('Home'),
              leading: Icon(Icons.home),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text('Album'),
              leading: Icon(Icons.photo_album),
              onTap: () {
                setState(() {
                  _currentIndex = 1;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: cameras.isEmpty
            ? null
            : () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CameraScreen()),
                );
              },
        child: const Icon(Icons.camera_enhance),
      ),
    );
  }
}
