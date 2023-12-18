import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AccountPageEntry extends StatefulWidget {
  const AccountPageEntry({
    required this.prefs,
    required this.entryName,
    required this.icon,
    required this.text,
    required this.onPress,
    this.hideText = false,
    super.key
  });
  
  final SharedPreferences? prefs;
  final String entryName;
  final IconData? icon;
  final String text;
  final Function() onPress;
  final bool hideText;
  
  @override
  State<AccountPageEntry> createState() => AccountPageEntryState();
}

class AccountPageEntryState extends State<AccountPageEntry> {
  bool showEntryName = false;

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;

    return ListTile(
      leading: Icon(
        widget.icon,
        color: AppStyles.textColor(isDarkMode),
        size: 24
      ),
      title: GestureDetector(
        onTap: () {
          setState(() {
            showEntryName = !showEntryName;
          });
        },
        child: Text(
          showEntryName ? widget.entryName : widget.hideText ? '*' * widget.text.length : widget.text,
          style: TextStyle(
            fontFamily: 'Geologica',
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: showEntryName ? AppStyles.accentColor(isDarkMode) : AppStyles.textColor(isDarkMode),
          )
        ),
      ),
      trailing: IconButton(
        icon: Icon(
          Icons.edit,
          color: AppStyles.accentColor(isDarkMode)
        ),
        onPressed: () {
          widget.onPress();
        },
      ),
      contentPadding: const EdgeInsets.only(left: 20),
    );
  }
}

class DarkModeToggleEntry extends StatefulWidget {
  const DarkModeToggleEntry({
    required this.prefs, required this.refreshParent, required this.stateCallBack, super.key
  });
  
  final SharedPreferences? prefs;
  final Function() refreshParent;
  final Function stateCallBack;
  
  @override
  State<DarkModeToggleEntry> createState() => DarkModeToggleEntryState();
}

class DarkModeToggleEntryState extends State<DarkModeToggleEntry> {
  @override
  Widget build(BuildContext context) {
    bool isDarkMode = widget.prefs?.getBool('darkmode') ?? false;

    return ListTile(
      leading: Icon(
        CupertinoIcons.moon_fill,
        color: AppStyles.textColor(isDarkMode),
        size: 24
      ),
      title: Text(
        "Enable Dark Mode",
        style: TextStyle(
          fontFamily: 'Geologica',
          fontSize: 18,
          fontWeight: FontWeight.w500,
          color: AppStyles.textColor(isDarkMode),
        )
      ),
      trailing: Padding(
        padding: const EdgeInsets.only(right: 8.0),
        child: Switch(
          value: isDarkMode,
          activeColor: AppStyles.primaryColor(isDarkMode),
          onChanged: (bool value) {
            widget.prefs?.setBool('darkmode', !isDarkMode);
            widget.stateCallBack(!isDarkMode);
            //setState(() {});
            widget.refreshParent();
          },
        ),
      ),
      contentPadding: const EdgeInsets.only(left: 20),
    );
  }
}