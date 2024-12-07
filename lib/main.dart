import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'models/user.dart';
import 'views/auth/sign_in_page.dart';
import 'views/auth/sign_up_page.dart';
import 'views/home/home_page.dart';
import 'controllers/auth_controller.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(HedieatyApp());
}

class HedieatyApp extends StatelessWidget {
  final AuthController _authController = AuthController();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hedieaty',
      theme: ThemeData(
        primarySwatch: Colors.blue, // Light theme primary color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.light), // Accent color for light theme
        scaffoldBackgroundColor: Colors.white,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blueGrey, // Dark theme primary color
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent, brightness: Brightness.dark), // Accent color for dark theme
        scaffoldBackgroundColor: Colors.black,
        appBarTheme: AppBarTheme(color: Colors.blueGrey[900]),
        textTheme: TextTheme(
          bodyLarge: TextStyle(color: Colors.white),
          bodyMedium: TextStyle(color: Colors.grey[400]),
        ),
      ),
      themeMode: ThemeMode.system,
      home: StreamBuilder<UserModel?>(
        stream: _authController.userStream,
        builder: (context, snapshot) {
          // If the stream is loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          // If user is authenticated
          if (snapshot.hasData) {
            return HomePage(); // Show home page if user is logged in
          }

          // If user is not authenticated
          return SignInPage(); // Show sign-in page if no user is logged in
        },
      ),
      routes: {
        '/sign-in': (context) => SignInPage(),
        '/sign-up': (context) => SignUpPage(),
        //'/home': (context) => HomePage(),
      },
      debugShowCheckedModeBanner: false,
    );
  }
}