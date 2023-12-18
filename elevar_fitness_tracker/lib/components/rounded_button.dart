import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:flutter/cupertino.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoundedButton extends StatefulWidget {
  const RoundedButton(this.text, this.onPress, this.prefs, {super.key});
  final String text;
  final Function() onPress;
  final SharedPreferences? prefs;

  @override
  RoundedButtonState createState() => RoundedButtonState();
}

class RoundedButtonState extends State<RoundedButton> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10),
      padding: const EdgeInsets.symmetric(horizontal: 20),
      width: size.width,
      height: 50,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: TextButton(
          onPressed: widget.onPress,
          style: ButtonStyle(
            backgroundColor: MaterialStateProperty.all(AppStyles.primaryColor(widget.prefs?.getBool('darkmode') ?? false))
          ),
          child: Text(
            widget.text,
            style: TextStyle(
              fontFamily: 'Geologica',
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppStyles.textColor(widget.prefs?.getBool('darkmode') ?? false)
            ),
          )
        )
      )
    );
  }

}