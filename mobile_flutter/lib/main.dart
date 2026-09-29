import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/room_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Client
  // Ganti URL dan Anon Key dengan kredensial Supabase Project Anda
  await Supabase.initialize(
    url: 'https://wmtdckxqsgjmuwvikleb.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtdGRja3hxc2dqbXV3dmlrbGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2NTk3OTUsImV4cCI6MjEwNjIzNTc5NX0.aZf8-x9znllJy3ONrbECsc1T30NeigcrsT64k8hem5U',
  );

  runApp(const RoomBookApp());
}

class RoomBookApp extends StatelessWidget {
  const RoomBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      title: 'RoomBook Mobile',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue primary
          brightness: Brightness.light,
        ),
      ),
      // Jika session aktif langsung ke RoomListScreen, sebaliknya ke LoginScreen
      initialRoute: session != null ? '/rooms' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/rooms': (context) => const RoomListScreen(),
      },
    );
  }
}
