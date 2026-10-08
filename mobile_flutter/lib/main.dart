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

  runApp(const RoomBookApp());
}

class RoomBookApp extends StatelessWidget {
  const RoomBookApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RoomBook Mobile',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/main',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/main': (context) => const MainNavigationScreen(),
        '/booking': (context) => const BookingFormScreen(),
      },
    );
  }
}
