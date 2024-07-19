import 'package:flutter/material.dart';
import 'package:JustNotes/home_screen.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that the Flutter binding has been initialized.
  await Firebase.initializeApp(); // Initializes the default app instance after the Flutter framework has been initialized.
  runApp(const MyApp()); // Runs the app.
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    /// Input: BuildContext context
    /// Output: MaterialApp
    /// This function returns the MaterialApp widget which is the root of the application.
    return const MaterialApp( 
      home: HomeScreen(), // HomeScreen is the first screen that will be displayed when the app is run.
    );
  }
}
