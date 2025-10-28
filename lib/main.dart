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
  // ✅ CHANGED: Create a variable to hold the auth subscription
  late final StreamSubscription<AuthState> _authSubscription;

  @override
  void initState() {
    super.initState();

    // ✅ CHANGED: Start the auth listener
    // This will listen for when the user signs in or out
    _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen((
      data,
    ) {
      // When the auth state changes, call setState()
      // This will force the `build` method to run again
      setState(() {});
    });
  }

  // ✅ CHANGED: Cancel the listener when the widget is removed
  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Because of the listener, this `build` method will now
    // run again after sign-in, and `session` will be updated.
    final session = Supabase.instance.client.auth.currentSession;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: session == null ? Login() : Bottomnav(),
    );
  }
}
