import 'package:book_villa/firebase_options.dart';
import 'package:book_villa/views/admin_signup.dart';
import 'package:book_villa/views/home_page.dart';
import 'package:book_villa/views/admin_login.dart';
import 'package:book_villa/views/user_login.dart';
import 'package:book_villa/views/user_signup.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // firebase initalistion
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // run this app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Book Library',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const HomePage(),
      // Different Pages Routes
      routes: {
        '/adminLogin': (context) => const AdminLoginPage(),
        '/adminSignup': (context) => const AdminSignupPage(),
        '/userLogin': (context) => const UserLoginPage(),
        '/userSignup': (context) => const UserSignupPage(),
      },
    );
  }
}
