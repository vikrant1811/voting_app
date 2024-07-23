import 'package:app_voting/firebase_options.dart';
import 'package:app_voting/screens/info_screen.dart';
import 'package:app_voting/screens/signup_screen.dart';
import 'package:app_voting/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'screens/home_screen.dart';
import 'screens/login_screen.dart';
import 'screens/ballot_screen.dart';
import 'screens/results_screen.dart';

Future<void> main() async {
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
      debugShowCheckedModeBanner: false,
      title: 'Online Voting System',
      theme: ThemeData(
        primarySwatch: Colors.grey,
      ),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/login': (context) => LoginScreen(),
        '/signup': (context) => SignUpScreen(),
        '/info': (context) => InfoScreen(),
        '/home': (context) => HomeScreen(),
        '/vote': (context) => BallotScreen(),
        '/results': (context) => ResultsScreen(),
      },
    );
  }
}
