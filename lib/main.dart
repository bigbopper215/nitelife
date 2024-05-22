import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nite_life/auth/auth.dart';
import 'package:nite_life/auth/login_or_register.dart';
import 'package:nite_life/firebase_options.dart';
import 'package:nite_life/themes/light_mode.dart';
import 'package:nite_life/themes/dark_mode.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthPage(),
      theme: lightMode,
      darkTheme: darkMode,
    );
  }
}
