import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';

class NotifPage extends StatefulWidget {
  const NotifPage({super.key});

  @override
  State<NotifPage> createState() => _NotifPageState();
}

class _NotifPageState extends State<NotifPage> {
  bool darkmode = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notifications", style: AppStyles.getHeadingStyle(darkmode)),
        backgroundColor: AppStyles.highlightColor(darkmode),
      ),
      body: ListView(children: const [
        ListTile(
          title: Text(''),
        )
      ]),
    );
  }
}