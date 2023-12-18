import 'package:elevar_fitness_tracker/components/rounded_button.dart';
import 'package:elevar_fitness_tracker/components/rounded_input_field.dart';
import 'package:elevar_fitness_tracker/login_signup_page/login_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elevar_fitness_tracker/home_page/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Possible results when the user attempts to log in based on the values
// in the text fields.
enum LoginResult { success, emptyUsername, emptyPassword, noAccount, incorrectPassword }

class LoginBody extends StatefulWidget {
  const LoginBody(this.prefs, {super.key});
  final SharedPreferences? prefs;

  @override
  LoginBodyState createState() => LoginBodyState();
}

class LoginBodyState extends State<LoginBody> {
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  // This method is called when the user attemps to log in by
  // hitting the login button after filling in the information
  // in the text fields.
  // Depending on the validity of the values in the text fields,
  // it will return one of the possible values found in the
  // LoginReult enum.
  Future<LoginResult> tryLogin() async {
    if (usernameController.text.isEmpty) {
      return LoginResult.emptyUsername;
    } else if (passwordController.text.isEmpty) {
      return LoginResult.emptyPassword;
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userResult = await users.doc(usernameController.text).get();

    if (!userResult.exists) {
      return LoginResult.noAccount;
    }

    Map<String, dynamic> data = userResult.data() as Map<String, dynamic>;
    if (data['password'] == passwordController.text) {
      return LoginResult.success;
    } else {
      return LoginResult.incorrectPassword;
    }
  }

  // Variables for storing the error text for the text fields
  // (these get updated to show or hide errors such as empty field)
  String? usernameError;
  String? passwordError;

  // Handle the user obscuring or unobscuring the password field
  bool hidePassword = true;
  void flipHidePassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Size of screen
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppStyles.backgroundColor(isDarkMode),
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragUpdate: (details) {
          if (details.delta.distance > 5) {
            if (details.delta.dx < 0) {
              Navigator.pushReplacement(
                context,
                LoginSignupPage.createSlidingRoute(const LoginSignupPage(showSignup: true,), true),
              );
            }
          }
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.only(left: 20, top: size.height / 3.65, bottom: 10),
              child: Text(
                "Login",
                style: TextStyle(
                  fontFamily: 'Geologica',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.textColor(isDarkMode)
                )
              ),
            ),
            RoundedInputField(
              hintText: "Username",
              controller: usernameController,
              icon: CupertinoIcons.person_crop_circle_fill,
              onChanged: (value) {},
              errorText: usernameError,
              prefs: widget.prefs
            ),
            RoundedInputField(
              hintText: "Password",
              controller: passwordController,
              icon: CupertinoIcons.lock_fill,
              onChanged: (value) {},
              errorText: passwordError,
              prefs: widget.prefs,
              hidden: hidePassword,
              updateHiddenFn: flipHidePassword,
            ),
            RoundedButton("Login", () {
              tryLogin().then((result) {
                // If the tryLogin method returned success, then store the username and
                // password used to login in local storage and navigate to the home screen.
                // If it returned any other value, handle it accordingly.
                switch (result) {
                  case LoginResult.success:
                    setState(() {
                      usernameError = null;
                      passwordError = null;
                    });
        
                    widget.prefs?.setString('username', usernameController.text);
                    widget.prefs?.setString('password', passwordController.text);
        
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  case LoginResult.emptyUsername:
                    setState(() {
                      usernameError = "Username cannot be empty";
                      passwordError = null;
                    });
                  case LoginResult.emptyPassword:
                    setState(() {
                      usernameError = null;
                      passwordError = "Password cannot be empty";
                    });
                  case LoginResult.incorrectPassword:
                    setState(() {
                      usernameError = null;
                      passwordError = "Incorrect password";
                    });
                  case LoginResult.noAccount:
                    setState(() {
                      usernameError = "Username not found";
                      passwordError = null;
                    });
                  default:
                    setState(() {
                      usernameError = null;
                      passwordError = null;
                    });
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Error occured while logging in."),)
                    );
                }
              });
            }, widget.prefs),
            Container(
              margin: const EdgeInsets.only(bottom: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "or ",
                    style: TextStyle(
                      fontFamily: 'Geologica',
                      fontSize: 14,
                      color: AppStyles.accentColor(isDarkMode).withOpacity(0.5)
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      widget.prefs?.setString('username', '');
                      widget.prefs?.setString('password', '');
        
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (context) => const HomePage()),
                      );
                    },
                    child: Text(
                      "continue as guest",
                      style: TextStyle(
                        fontFamily: 'Geologica',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppStyles.primaryColor(!isDarkMode).withOpacity(0.5)
                      )
                    )
                  )
                ],
              ),
            ),
            const Spacer(),
            Container(
              margin: const EdgeInsets.symmetric(vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Don't have an account? ",
                    style: TextStyle(
                      fontFamily: 'Geologica',
                      fontSize: 14,
                      color: AppStyles.accentColor(isDarkMode).withOpacity(0.5)
                    )
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushReplacement(
                        context,
                        LoginSignupPage.createSlidingRoute(const LoginSignupPage(showSignup: true,), true),
                      );
                    },
                    child: Text(
                      "Sign Up",
                      style: TextStyle(
                        fontFamily: 'Geologica',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppStyles.accentColor(isDarkMode)
                      )
                    )
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}