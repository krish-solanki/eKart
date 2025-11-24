import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:shopping_app/pages/bottom_nav.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shopping_app/pages/Login.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  // Initialize Supabase
  await Supabase.initialize(
    url: 'https://hummoctauxhmrealpqks.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh1bW1vY3RhdXhobXJlYWxwcWtzIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTM5NTU4MjUsImV4cCI6MjA2OTUzMTgyNX0.jMC0BGC-GQJBvrm9qBilyDtLMFKK2yiUvDbJn2zIUFk',
  );

  FlutterNativeSplash.remove();

  runApp(const MainApp());
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,

      /// Listening to Supabase Auth Stream
      home: StreamBuilder<AuthState>(
        stream: Supabase.instance.client.auth.onAuthStateChange,
        builder: (context, snapshot) {
          final session = Supabase.instance.client.auth.currentSession;

          // Check if user is logged in or not
          if (session == null) {
            return Login();
          } else {
            return Bottomnav();
          }
        },
      ),
    );
  }
}
