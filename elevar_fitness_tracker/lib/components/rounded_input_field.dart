import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ignore: must_be_immutable
class RoundedInputField extends StatefulWidget {
  RoundedInputField({
    super.key,
    required this.hintText,
    required this.controller,
    required this.icon,
    required this.onChanged,
    required this.prefs,
    this.errorText,
    this.hidden,
    this.updateHiddenFn
  });

  final String hintText;
  final TextEditingController controller;
  final IconData icon;
  final ValueChanged<String> onChanged;
  final SharedPreferences? prefs;
  String? errorText;
  bool? hidden;
  Function? updateHiddenFn;

  @override
  RoundedInputFieldState createState() => RoundedInputFieldState();
}

class RoundedInputFieldState extends State<RoundedInputField> {
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
        onChanged: widget.onChanged,
        controller: widget.controller,
        style: TextStyle(
          fontFamily: 'Geologica',
          color: AppStyles.textColor(isDarkMode)
        ),
        decoration: InputDecoration(
          icon: Icon(
            widget.icon,
            color: AppStyles.primaryColor(isDarkMode)
          ),
          suffixIcon: widget.hidden != null ? 
            widget.hidden! ? IconButton(
              onPressed: () => setState(() {
                if (widget.hidden != null && widget.updateHiddenFn != null) {
                  widget.updateHiddenFn!();
                }
              }),
              icon: Icon(
                CupertinoIcons.eye_fill,
                color: AppStyles.primaryColor(isDarkMode)
            ),
            ) : IconButton(
              onPressed: () => setState(() {
                if (widget.hidden != null) {
                  widget.hidden = !widget.hidden!;
                }
              }),
              icon: Icon(
              CupertinoIcons.eye_slash_fill,
              color: AppStyles.primaryColor(isDarkMode)
                      ),
            ) : null,
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
        obscureText: widget.hidden != null ? widget.hidden! : false,
      )
    );
  }
}