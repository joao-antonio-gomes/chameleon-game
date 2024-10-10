import 'dart:ui';

import 'package:chameleon/views/auth_screen.dart';
import 'package:chameleon/views/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'firebase_options.dart';

Future<void> main() async {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    return true;
  };
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({super.key});

  final bool isLoggedIn = FirebaseAuth.instance.currentUser != null;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xFF430088),
              onPrimary: Color(0xFFD7D7D7),
              secondary: Color(0xFF004B88),
              onSecondary: Color(0xFFD7D7D7),
              error: Color(0xFFB71D1D),
              onError: Color(0xFFD7D7D7),
              surface: Color(0xFF430088),
              onSurface: Color(0xFFD7D7D7)),
          useMaterial3: false,
        ),
        initialRoute: isLoggedIn ? '/home' : '/login',
        routes: {
          '/home': (context) => HomeScreen(),
          '/login': (context) => const AuthScreen(),
        });
  }
}
