import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/home_page/homepage.dart';
import 'package:elevar_fitness_tracker/loading_screen/loading_screen.dart'; // Import the loading screen
import 'package:elevar_fitness_tracker/local_storage/exercises_db_model.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

final navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  //await deleteAllExercises();
  await insertDummyData();

  runApp(MaterialApp(
    home: const MyApp(),
    navigatorKey: navigatorKey,
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Elevar',
      theme: ThemeData(
        useMaterial3: true,
      ),
      initialRoute: '/', // Set the initial route
      routes: {
        '/': (context) =>
            const LoadingScreen(), // Define the LoadingScreen as the initial route
        '/home': (context) => const HomePage(), // Define the HomePage route
      },
    );
  }
}
