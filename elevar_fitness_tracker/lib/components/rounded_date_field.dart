import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:elevar_fitness_tracker/home_page/page_bodies/account_body.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class RoundedDateField extends StatefulWidget {
  RoundedDateField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.onPress,
    required this.prefs,
    this.errorText
  });

  final String hintText;
  final TextEditingController controller;
  final Function() onPress;
  final SharedPreferences? prefs;
  String? errorText;

  @override
  RoundedDateFieldState createState() => RoundedDateFieldState();
}

class RoundedDateFieldState extends State<RoundedDateField> {
  void editBirthdateDialog(BuildContext context, String username, Map<String, dynamic> data) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      initialDate: (data['birthdate'] as Timestamp).toDate(),
      firstDate: DateTime(1950),
      lastDate: DateTime.now(),
      cancelText: "Cancel",
      confirmText: "Confirm",
      helpText: "Edit Birthdate",
    );

    if (picked != null) {
      FirebaseFirestore.instance.collection('users').doc(username).update({
        'birthdate': Timestamp.fromDate(picked),
      });

      setState(() { });
      // ignore: use_build_context_synchronously
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Updated birthdate to \"${AccountBody.formatTimestamp(Timestamp.fromDate(picked).toDate())}\"")
        )
      );      
    } 
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 5),
      decoration: BoxDecoration(
        color: AppStyles.primaryColor(isDarkMode).withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        //boxShadow: [BoxShadow(color: Color(0x0e000000), offset: Offset(0.0, 1.0), blurRadius: 2.0)],
      ),
      child: TextField(
        readOnly: true,
        controller: widget.controller,
        style: TextStyle(
          fontFamily: 'Geologica',
          color: AppStyles.textColor(isDarkMode)
        ),
        decoration: InputDecoration(
          icon: Icon(
            CupertinoIcons.calendar,
            color: AppStyles.primaryColor(isDarkMode)
          ),
          suffixIcon: IconButton(
            onPressed: () => setState(() {
              widget.onPress();
            }),
            icon: Icon(
            CupertinoIcons.calendar,
            color: AppStyles.primaryColor(isDarkMode)
            ),
          ),
          hintText: widget.hintText,
          hintStyle: TextStyle(
            color: AppStyles.accentColor(isDarkMode)
          ),
          border: InputBorder.none,
          errorText: widget.errorText,
          errorStyle: const TextStyle(
            fontFamily: 'Geologica'
          )
        ),
      )
    );
  }
}