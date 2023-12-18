import 'package:elevar_fitness_tracker/home_page/homepage.dart';
import 'package:elevar_fitness_tracker/login_signup_page/login_signup_page.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Loading Animation Demo',
      theme: ThemeData(
        primarySwatch: Colors.grey,
        useMaterial3: true,
      ),
      home: const LoadingScreen(),
    );
  }
}

class LoadingScreen extends StatefulWidget {
  const LoadingScreen({super.key});

  @override
  LoadingScreenState createState() => LoadingScreenState();
}
//Delay functions transfer from loading screen to home page
class LoadingScreenState extends State<LoadingScreen> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();

    // Initialize shared preferences
    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        prefs = sharedPrefs;
      });
    });

    _initDarkMode();
    _navigateToNextScreenWithDelay();
  }


  void _navigateToNextScreenWithDelay() async {
    // Get stored username + password
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String username = prefs.getString('username') ?? "";
    String password = prefs.getString('password') ?? "";

    //Set a 3 second delay before moving to the next page
    await Future.delayed(const Duration(seconds: 3));

    if (mounted) {
      // If we are already logged in, go to home page
      if (username.isNotEmpty && password.isNotEmpty) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else { // If not, go to login page
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const LoginSignupPage()),
        );
      }
    }
  }

  void _initDarkMode() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    if (prefs.getBool('darkmode') == null) {
      // Initialize darkmode preference to match device if it's not already set
      await prefs.setBool('darkmode', SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor(prefs?.getBool('darkmode') ?? false),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'ELEVAR',
              style: TextStyle(
                fontFamily: 'Geologica',
                fontSize: 48,
                fontWeight: FontWeight.w700,
                color: AppStyles.textColor(prefs?.getBool('darkmode') ?? false),
              ),
            ),  

            const SizedBox(height: 25),

            LoadingAnimationWidget.threeArchedCircle(
              color: AppStyles.textColor(prefs?.getBool('darkmode') ?? false),
              size: 50,
            ),
          ],
        ),
      ),
    );
  }
}
