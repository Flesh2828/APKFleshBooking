import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Supabase Client
  await Supabase.initialize(
    url: 'https://wmtdckxqsgjmuwvikleb.supabase.co',
    // ignore: deprecated_member_use
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
        scaffoldBackgroundColor: const Color(0xFFF8FAFC),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
      ),
      // Jika session aktif langsung ke MainNavigationScreen, sebaliknya ke LoginScreen
      initialRoute: session != null ? '/main' : '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/rooms': (context) => const MainNavigationScreen(),
      },
    );
  }
}
