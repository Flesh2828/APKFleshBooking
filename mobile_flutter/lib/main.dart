import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/room_list_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Client
  // Ganti URL dan Anon Key dengan kredensial Supabase Project Anda
  await Supabase.initialize(
    url: 'https://xyzcompany.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.dummy_anon_key_for_demonstration',
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
