import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'theme/app_theme.dart';
import 'utils/date_formatter.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/booking_form_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi locale formatting agar tidak terjadi LocaleDataException
  await DateFormatterIndo.ensureInitialized();

  // Inisialisasi Supabase Client
  await Supabase.initialize(
    url: 'https://wmtdckxqsgjmuwvikleb.supabase.co',
    // ignore: deprecated_member_use
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndtdGRja3hxc2dqbXV3dmlrbGViIiwicm9sZSI6ImFub24iLCJpYXQiOjE3OTA2NTk3OTUsImV4cCI6MjEwNjIzNTc5NX0.aZf8-x9znllJy3ONrbECsc1T30NeigcrsT64k8hem5U',
  );

  runApp(const GuildSpaceApp());
}

class GuildSpaceApp extends StatelessWidget {
  const GuildSpaceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GuildSpace Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/booking': (context) => const BookingFormScreen(),
      },
    );
  }
}

/// Compatibility alias
typedef RoomBookApp = GuildSpaceApp;
