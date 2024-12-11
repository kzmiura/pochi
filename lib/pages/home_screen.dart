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

  Future<List<String>> _fetchImages() async {
    final objects = await supabase.storage
        .from('images')
        .list(path: '${supabase.auth.currentUser!.id}/');
    final signedUrls = await Future.wait(
      objects.map(
        (object) {
          final signedUrl = supabase.storage.from('images').createSignedUrl(
                '${supabase.auth.currentUser!.id}/${object.name}',
                60 * 60 * 24,
              );
          return signedUrl;
        },
      ),
    );

    return signedUrls;
  }

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
        title: Text(['Home', 'Album'][_currentIndex]),
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
        FutureBuilder(
          future: _fetchImages(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              if (snapshot.hasData) {
                final urls = snapshot.data!;
                return GridView.builder(
                  itemCount: urls.length,
                  itemBuilder: (context, index) {
                    return Card(
                      child: Image.network(urls[index]),
                    );
                  },
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                );
              } else if (snapshot.hasError) {
                return Text(snapshot.error.toString());
              }
            }
            return const CircularProgressIndicator();
          },
        ),
      ][_currentIndex],
      drawer: Drawer(
        child: ListView(
          children: [
            DrawerHeader(
              child: Text(supabase.auth.currentUser!.email ?? 'No email'),
            ),
            ListTile(
              title: const Text('Home'),
              leading: const Icon(Icons.home),
              onTap: () {
                setState(() {
                  _currentIndex = 0;
                });
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Album'),
              leading: const Icon(Icons.photo_album),
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
