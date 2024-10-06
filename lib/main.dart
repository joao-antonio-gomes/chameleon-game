import 'dart:ui';

import 'package:chameleon/exception/error_handling.dart';
import 'package:chameleon/screens/auth_screen.dart';
import 'package:chameleon/screens/exercise_screen.dart';
import 'package:chameleon/screens/home_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
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
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'Flutter Demo',
        theme: ThemeData(
          colorScheme: const ColorScheme(
              brightness: Brightness.dark,
              primary: Color(0xFF430088),
              onPrimary: Color(0xFFD7D7D7),
              secondary: Color(0xFFB71D1D),
              onSecondary: Color(0xFF004B88),
              error: Color(0xFFB71D1D),
              onError: Color(0xFFD7D7D7),
              surface: Color(0xFFFFC500),
              onSurface: Color(0xFFFFC500)),
          useMaterial3: false,
        ),
        home: ErrorHandlerWidget(
          key: key,
          child: const ScreenRouter(),
        ));
  }
}

class ScreenRouter extends StatelessWidget {
  const ScreenRouter({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const AuthScreen();
        });
  }
}
