import 'package:elevar_fitness_tracker/components/rounded_button.dart';
import 'package:elevar_fitness_tracker/components/rounded_date_field.dart';
import 'package:elevar_fitness_tracker/components/rounded_input_field.dart';
import 'package:elevar_fitness_tracker/home_page/page_bodies/account_body.dart';
import 'package:elevar_fitness_tracker/login_signup_page/login_signup_page.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:elevar_fitness_tracker/home_page/homepage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Possible results when the user attempts to continue finish signing up
enum AccountInfoResult { success, emptyFirstName, emptyLastName, emptyBirthdate }

class AccountInfoBody extends StatefulWidget {
  // We take in the values the user entered on the previous signup screen so
  // that we have all the information we need by the time they are finished on this
  // screen.
  const AccountInfoBody(
    this.username,
    this.email,
    this.password,
    this.prefs,
    {super.key});

  final String username;
  final String email;
  final String password;

  final SharedPreferences? prefs;

  @override
  State<AccountInfoBody> createState() => AccountInfoState();
}

class AccountInfoState extends State<AccountInfoBody> {
  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  // The birthdateControler is for displaying the date in a readable fashion
  // for the user, the actual date that we store in the cloud is birthdate.
  final birthdateController = TextEditingController();
  DateTime? birthdate;

  // Variables for storing the error text for the text fields
  // (these get updated to show or hide errors such as empty field)
  String? firstNameError;
  String? lastNameError;
  String? birthdateError;

  // This method opens a date picker and returns whatever the
  // user picked. If they don't pick a date for whatever reason
  // then we just default to right here, right now.
  Future<DateTime> pickBirthdate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: DateTime.now(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      cancelText: "Cancel",
      confirmText: "Confirm",
      helpText: "Enter Birthdate",
    );

    return picked ?? DateTime.now();
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;

    // This method is called when the user attempts to finish sign up
    // by hitting the "Sign Up" button. It validates the values of the
    // text fields and returns one of the AccountInfoResult enums based
    // on if they are valid or not.
    Future<AccountInfoResult> trySignup() async {
      if (firstNameController.text.isEmpty) {
        return AccountInfoResult.emptyFirstName;
      } else if (lastNameController.text.isEmpty) {
        return AccountInfoResult.emptyLastName;
      } else if (birthdate == null) {
        return AccountInfoResult.emptyBirthdate;
      }

      return AccountInfoResult.success;
    }

    // This method only gets called once the trySignup method is
    // successful. It pushes all the information that the user entered
    // to the cloud, making a new entry that can then be used to log in
    // with.
    Future<void> completeSignup() async {
      CollectionReference users = FirebaseFirestore.instance.collection('users');
      await users.doc(widget.username).set({
        'email': widget.email,
        'password': widget.password,
        'first_name': firstNameController.text,
        'last_name': lastNameController.text,
        'birthdate': Timestamp.fromDate(birthdate ?? DateTime.now())

           });
        //Save the user's name in SharePreferences
        widget.prefs?.setString('first_name', firstNameController.text);
        widget.prefs?.setString('last_name', lastNameController.text);
      

    }

    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppStyles.backgroundColor(isDarkMode),
      // App bar with a back button that lets the user navigate back
      // to the signup page, retaining the information that they already
      // entered there.
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: AppStyles.textColor(isDarkMode),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              LoginSignupPage.createSlidingRoute(
                LoginSignupPage(
                  showSignup: true,
                  username: widget.username,
                  email: widget.email,
                  password: widget.password,
              ), true),
            );
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 20, top: 70, bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  // Use the username from the previous signup page to
                  // simultaneously let the user know that we are keeping
                  // track of their progress despite switching screens, and
                  // also validate that my code works. Yippee!
                  "Hi, ${widget.username}!",
                  style: TextStyle(
                    fontFamily: 'Geologica',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.accentColor(isDarkMode)
                  )
                ),
                Text(
                  "Tell us about yourself",
                  style: TextStyle(
                    fontFamily: 'Geologica',
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppStyles.textColor(isDarkMode)
                  )
                )
              ],
            ),
          ),
          RoundedInputField(
            hintText: "First Name",
            controller: firstNameController,
            icon: CupertinoIcons.person_crop_circle_fill,
            onChanged: (value) {},
            errorText: firstNameError,
            prefs: widget.prefs
          ),
          RoundedInputField(
            hintText: "Last Name",
            controller: lastNameController,
            icon: CupertinoIcons.mail_solid,
            onChanged: (value) {},
            errorText: lastNameError,
            prefs: widget.prefs
          ),
          RoundedDateField(
            hintText: "Birthdate",
            controller: birthdateController,
            onPress: () {
              pickBirthdate().then((date) {
                // Update both the TextController for displaying to the user
                // purposes, and the actual birthdate variable that we are
                // storing the date in.
                birthdateController.text = AccountBody.formatTimestamp(date, asText: true);
                birthdate = date;
              });
            },
            errorText: birthdateError,
            prefs: widget.prefs
          ),
          RoundedButton("Sign Up", () {
            trySignup().then((result) {
              // First, we trySignup to validate that the information that the
              // user entered is all valid.
              switch (result) {
                case AccountInfoResult.success:
                  setState(() {
                    firstNameError = null;
                    lastNameError = null;
                    birthdateError = null;
                  });

                  // If that was successful, then we actually push all the
                  // information to the cloud, store the username and password
                  // in local storage (to automatically "log the user in" with
                  // the information they entered), and navigate to home.
                  completeSignup().then((value) {
                    widget.prefs?.setString('username', widget.username);
                    widget.prefs?.setString('password', widget.password);

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const HomePage()),
                    );
                  });
                case AccountInfoResult.emptyFirstName:
                  setState(() {
                    firstNameError = "First name cannot be empty";
                    lastNameError = null;
                    birthdateError = null;
                  });
                case AccountInfoResult.emptyLastName:
                  setState(() {
                    firstNameError = null;
                    lastNameError = "Last name cannot be empty";
                    birthdateError = null;
                  });
                case AccountInfoResult.emptyBirthdate:
                  setState(() {
                    firstNameError = null;
                    lastNameError = null;
                    birthdateError = "Birthdate cannot be empty";
                  });
                default:
                  setState(() {
                    firstNameError = null;
                    lastNameError = null;
                    birthdateError = null;
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error occured while signing up."),)
                  );
              }
            });
          }, widget.prefs)
        ]
      )
    );
  }

}