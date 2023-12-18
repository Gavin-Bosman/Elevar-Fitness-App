import 'package:elevar_fitness_tracker/login_signup_page/login_body.dart';
import 'package:elevar_fitness_tracker/login_signup_page/signup_body.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elevar_fitness_tracker/home_page/homepage.dart';

// This page covers navigation for all login/signup activities.

// Upon loading, it can display either a login or a signup page
// based on the showSignup bool provided. The optional parameters
// for username, email, etc. are used when navigating back to the
// signup page from the account info page (the "second stage" of
// signup when users enter personal information).

// If no parameters are provided, it will default to login.
class LoginSignupPage extends StatefulWidget {
  const LoginSignupPage({
    this.username = "",
    this.email = "",
    this.password = "",
    this.showSignup = false,
    super.key}
  );
  final String username;
  final String email;
  final String password;
  final bool showSignup;

  @override
  LoginSignupPageState createState() => LoginSignupPageState();

  // This method creates a route that slides the new page (provided
  // by the 'page' parmeter) in from either the left or the right
  // depending on the 'slideRight' parameter.
  // Used when switching between login and signup pages.
  static Route createSlidingRoute(Widget page, bool slideRight) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        Offset begin = slideRight ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.ease;

        var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                          
        return SlideTransition(
          position: animation.drive(tween),
          child: child
        );
      }
    );
  }
}

class LoginSignupPageState extends State<LoginSignupPage> {
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        prefs = sharedPrefs;
      });
    });
    
    // If we somehow get here despite being logged in, just go to home screen
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      _navigateToHomeIfLoggedIn();
    });
  }

  // This method checks if we are logged in (by checking if we
  // have a username and password stored in local storage) and,
  // if so, navigates to the home page.
  void _navigateToHomeIfLoggedIn() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    String username = prefs.getString('username') ?? "";
    String password = prefs.getString('password') ?? "";

    if (username.isNotEmpty && password.isNotEmpty) {
      if (context.mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return widget.showSignup ? SignupBody(
      prefs: prefs,
      username: widget.username,
      email: widget.email,
      password: widget.password) : LoginBody(prefs);
  }
}