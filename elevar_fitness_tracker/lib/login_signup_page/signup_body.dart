import 'package:elevar_fitness_tracker/components/rounded_button.dart';
import 'package:elevar_fitness_tracker/components/rounded_input_field.dart';
import 'package:elevar_fitness_tracker/home_page/homepage.dart';
import 'package:elevar_fitness_tracker/login_signup_page/account_info_body.dart';
import 'package:elevar_fitness_tracker/login_signup_page/login_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Possible results when the user attempts to continue to the account
// info screen based on the values in the text fields.
enum SignupResult { success, emptyUsername, emptyEmail, emptyPassword, usernameExists }

class SignupBody extends StatefulWidget {
  // Optional params for username, email, etc.
  // If provided, the page will start with it's text fields filled in
  // with the provided values. Used when navigating back to this page
  // from the account info page.
  const SignupBody(
    {
      this.username = "",
      this.email = "",
      this.password = "",
      this.prefs,
      super.key
    }
  );
  final String username;
  final String email;
  final String password;
  final SharedPreferences? prefs;

  @override
  State<SignupBody> createState() => SignupBodyState();
}

class SignupBodyState extends State<SignupBody> {
  final usernameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  // Variables for storing the error text for the text fields
  // (these get updated to show or hide errors such as empty field)
  String? usernameError;
  String? emailError;
  String? passwordError;

  @override
  void initState() {
    super.initState();

    // Initialize text fields with values if provided
    usernameController.text = widget.username;
    emailController.text = widget.email;
    passwordController.text = widget.password;
  }

  // Handle the user obscuring or unobscuring the password field
  bool hidePassword = true;
  void flipHidePassword() {
    setState(() {
      hidePassword = !hidePassword;
    });
  }

  // This method is called when the user attempts to continue to the
  // account info page by hitting the "Continue" button. It validates
  // the values of the text fields and returns one of the SignupResult
  // enums based on if they are valid or not.
  Future<SignupResult> trySignup() async {
    // Check if username is empty *before* we try to check if it exists in
    // cloud database so we're not making calls to it if we don't have to.
    if (usernameController.text.isEmpty) {
      return SignupResult.emptyUsername;
    }

    CollectionReference users = FirebaseFirestore.instance.collection('users');
    final userResult = await users.doc(usernameController.text).get();

    if (userResult.exists) {
      return SignupResult.usernameExists;
    } else if (emailController.text.isEmpty) {
      return SignupResult.emptyEmail;
    } else if (passwordController.text.isEmpty) {
      return SignupResult.emptyPassword;
    }

    return SignupResult.success;
  }
  
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size; // Size of screen
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;

    // This offset checks if the keyboard is open or not by checking the bottom viewInsets.
    // If it is above zero (keyboard is open), we have raise the offset to move the page up
    // so none of the text fields or buttons get hidden behind the keyboard.
    // Yes, I could have just raised everything from the start, but I wanted everything to
    // look centered on the screen. Also, trying to animate this value ruined everything and
    // wasted half a day of my life, so it will just jump up and down. :thumbsup:
    double offset = MediaQuery.of(context).viewInsets.bottom > 0 ? 5.2 : 3.65;
    
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onHorizontalDragUpdate: (details) {
        if (details.delta.distance > 5) {
          if (details.delta.dx > 0) {
            Navigator.pushReplacement(
              context,
              LoginSignupPage.createSlidingRoute(const LoginSignupPage(), false),
            );
          }
        }
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: AppStyles.backgroundColor(isDarkMode),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              // We use the offset variable from above here to move everything up and down
              padding: EdgeInsets.only(left: 20, top: size.height / offset, bottom: 10),
              child: Text(
                "Sign Up",
                style: TextStyle(
                  fontFamily: 'Geologica',
                  fontSize: 48,
                  fontWeight: FontWeight.w800,
                  color: AppStyles.textColor(isDarkMode)
                )
              ),
            ),
            ListView(
              shrinkWrap: true,
              padding: EdgeInsets.zero,
              children: [
                RoundedInputField(
                  hintText: "Username",
                  controller: usernameController,
                  icon: CupertinoIcons.person_crop_circle_fill,
                  onChanged: (value) {},
                  errorText: usernameError,
                  prefs: widget.prefs
                ),
                RoundedInputField(
                  hintText: "E-mail",
                  controller: emailController,
                  icon: CupertinoIcons.mail_solid,
                  onChanged: (value) {},
                  errorText: emailError,
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
                RoundedButton("Continue", () {
                  trySignup().then((result) {
                    // If the trySignup method returned success, then navigate to the
                    // account info page (while passing along the information entered
                    // on this page).
                    // If not, handle accordingly.
                    switch (result) {
                      case SignupResult.success:
                        setState(() {
                          usernameError = null;
                          emailError = null;
                          passwordError = null;
                        });
      
                        Navigator.pushReplacement(
                          context,
                          LoginSignupPage.createSlidingRoute(AccountInfoBody(
                            usernameController.text,
                            emailController.text,
                            passwordController.text,
                            widget.prefs), true),
                        );
                      case SignupResult.emptyUsername:
                        setState(() {
                          usernameError = "Username cannot be empty";
                          emailError = null;
                          passwordError = null;
                        });
                      case SignupResult.emptyEmail:
                        setState(() {
                          usernameError = null;
                          emailError = "E-mail cannot be empty";
                          passwordError = null;
                        });
                      case SignupResult.emptyPassword:
                        setState(() {
                          usernameError = null;
                          emailError = null;
                          passwordError = "Password cannot be empty";
                        });
                      case SignupResult.usernameExists:
                        setState(() {
                          usernameError = "Username already exists";
                          emailError = null;
                          passwordError = null;
                        });
                      default:
                        setState(() {
                          usernameError = null;
                          emailError = null;
                          passwordError = null;
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Error occured while signing up."),)
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
              ],
            ),
            const Spacer(),
              Container(
                margin: const EdgeInsets.symmetric(vertical: 40),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already have an account? ",
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
                          LoginSignupPage.createSlidingRoute(const LoginSignupPage(), false),
                        );
                      },
                      child: Text(
                        "Log In",
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
        )
      ),
    );
  }
}