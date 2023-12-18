/*
  This file returns the encapsulating body widget for the Home page
*/
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:pedometer/pedometer.dart';
import 'package:elevar_fitness_tracker/notifications/notifications.dart';
import 'package:elevar_fitness_tracker/notifications/notification_page.dart';
import 'package:elevar_fitness_tracker/local_storage/routine_db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'view_routine.dart';
import 'package:elevar_fitness_tracker/home_page/page_bodies/workout_page/workout_body.dart';


class HomeBody extends StatefulWidget {
  Function updatePage;

  HomeBody(this.updatePage, {super.key});
  @override
  State<HomeBody> createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {

  // defining instance variables
  AppStyles styles = AppStyles();
  String username = "";
  String firstName = "";
  String lastName = "";
  SharedPreferences? prefs;
  RoutineDBModel database = RoutineDBModel();
  List<dynamic> routineNames = [];
  late List<Map<String,dynamic>> routineData = [];
  bool refresh = true;
  bool darkmode = false;

  // Notification variables
  final notifications = Notifications();
  String notifTitle = "Elevar";
  String notifBody = "Welcome to Elevar! You have agreed to receive notifications for your workouts.";
  String? payload;

  // Pedometer variables
  late Stream<StepCount> _stepCountStream;
  String _stepCount = "0";
  IconData currentNotifIcon = CupertinoIcons.bell;
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool hasClicked = false;

  void onStateCallBack(bool toRefresh) {
    setState(() {
      refresh = toRefresh;
    });
  }

  // Defining instance methods
  @override
  void initState() {
    super.initState();
    initPlatformState();

    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        prefs = sharedPrefs;
        darkmode = prefs?.getBool('darkmode') ?? false;
        //widget.stateCallBack(darkmode); // void call back to parent
      });
    });
  }
    void _loadUserData() async {
    prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs?.getString('username') ?? "";
    });

    if (username.isNotEmpty) {
      FirebaseFirestore.instance.collection('users').doc(username).get().then((snapshot) {
        if (snapshot.exists) {
          setState(() {
            firstName = snapshot.data()?['first_name'] ?? "";
            lastName = snapshot.data()?['last_name'] ?? "";
          });
        }
      });
    }
  }
  void _trackStepCount(StepCount event) {
    setState(() {
      _stepCount = event.steps.toString();
    });
  }

  void _trackStepError(error) {
    setState(() {
      print("_trackStepError: $error");
    });
  }

  void initPlatformState() {
    _stepCountStream = Pedometer.stepCountStream;
    _stepCountStream.listen(_trackStepCount).onError(_trackStepError);
  }

  void notificationIconChange() {
    setState(() {
      currentNotifIcon = (currentNotifIcon == CupertinoIcons.bell)
          ? CupertinoIcons.bell_slash
          : CupertinoIcons.bell;
    });
  }

  void sendNotification() {
    notifications.sendNotification(
        notifTitle, notifBody, "This is the payload");
  }

  void showNotifAlert() {
    showDialog(
      context: scaffoldKey.currentContext!,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('You have opted to receive notifications', style: AppStyles.getSubHeadingStyle(darkmode),),
          content: Text(
              'Hold the notification bell to see your list of workout notifications',
              style: AppStyles.getMainTextStyle(darkmode),
              ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Confirm', style: AppStyles.getMainTextStyle(darkmode),),
            ),
          ],
        );
      },
    );
  }

  void handleNotifButton() {
    if ((currentNotifIcon == CupertinoIcons.bell_slash) && (!hasClicked)) {
      showNotifAlert();
      hasClicked = true;
    }
    if (currentNotifIcon == CupertinoIcons.bell_slash) {
      notificationIconChange();
      sendNotification();
    } else if (currentNotifIcon == CupertinoIcons.bell) {
      notificationIconChange();
    }
  }

  Future initRoutineData() async {
    routineNames = await database.getDistinctRoutineNames();
    routineData = await database.getAllRoutineData();
  }

  // main widget body
  @override
  Widget build(BuildContext context) {
    notifications.init();
    if(refresh) {
      initRoutineData().then((value) {
        setState(() {
          refresh = false;
        });
      });
    }

    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppStyles.backgroundColor(darkmode),
      appBar: AppBar(
        title: Row(
          children: [
            Icon(
              CupertinoIcons.home,
              color: AppStyles.textColor(darkmode)
            ),
            const SizedBox(width: 10),
              Text("Home", style: AppStyles.getHeadingStyle(darkmode)),
            ],
        ),
        backgroundColor: AppStyles.primaryColor(darkmode),
        actions: [
          ElevatedButton(
            onPressed: handleNotifButton,
            onLongPress: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: ((context) => const NotifPage()),
                  ));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              elevation: 0
            ),
            child: Icon(
              currentNotifIcon,
              color: AppStyles.textColor(darkmode),
            ),
          )
        ],
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.distance > 5) {
            if (details.delta.dx < 0) {
              widget.updatePage(2);
            } else if (details.delta.dx > 0) {
              widget.updatePage(0);
            }
          }
        },
        child: Stack(
          children: [
            Container(
              color: darkmode ? Colors.transparent : AppStyles.primaryColor(darkmode).withOpacity(0.2)
            ),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0, top:25.0, bottom: 10.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox( // holds the pedometer step count
                    width: double.infinity,
                    height: 150.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 150.0,
                          height: 150.0,
                          decoration: BoxDecoration(
                            color: darkmode ? AppStyles.primaryColor(!darkmode).withOpacity(0.2) : AppStyles.backgroundColor(darkmode),
                            borderRadius: BorderRadius.circular(100.0),
                            border: Border.all(
                              width: 8,
                              color: AppStyles.secondaryColor(darkmode).withOpacity(0.25)
                            ),
                            boxShadow: [
                              BoxShadow(
                                spreadRadius: 1,
                                blurRadius: 3,
                                offset: const Offset(0, 3),
                                color: Colors.black.withOpacity(0.05)
                              ),
                              BoxShadow(
                                blurRadius: 1,
                                offset: const Offset(0, 1),
                                color: Colors.black.withOpacity(0.1)
                              )
                            ]
                          ),
                        ),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _stepCount,
                              style: TextStyle(
                                fontFamily: 'Geologica',
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                color: AppStyles.textColor(darkmode)
                              ),
                              textAlign: TextAlign.center,
                            ),
                            Text(
                              "steps",
                              style: TextStyle(
                                fontFamily: 'Geologica',
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                                color: AppStyles.textColor(darkmode).withOpacity(0.6)
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        )
                        
                      ],
                    ),
                  ),
            
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: SizedBox(
                      height: 50.0,
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          routineData.isEmpty ? Text("Try Adding A Workout!", style: AppStyles.getSubHeadingStyle(darkmode),)
                          : Text(
                            "Your Routines:", 
                            style: TextStyle(
                              fontFamily: 'Geologica',
                              fontWeight: FontWeight.w500,
                              color: AppStyles.textColor(darkmode),
                              fontSize: 20.0,
                            )
                          ),
                        ],
                      )
                    ),
                  ),
            
                  Expanded( // holds this scrollable listview of routines
                    child: ListView.separated(
                      itemBuilder: (context, index) {
                        return routineTile(routineNames[index], routineData.where((element) => element['routineName'] == routineNames[index]).toList());
                      },
                      separatorBuilder: (context, index) => const Divider(color: Colors.transparent),
                      itemCount: routineNames.length,
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => WorkoutPage(onStateCallBack)),
          );
        },
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(20.0)),
          side: BorderSide(color: AppStyles.backgroundColor(!darkmode), width: 2.0)
        ),
        backgroundColor: AppStyles.backgroundColor(darkmode),
        focusColor: AppStyles.highlightColor(darkmode),
        tooltip: "Create a new workout",
        child: Icon(Icons.add, size: 24, color: AppStyles.textColor(darkmode)),
      ),
    );
  }

  // method for generating a ListTile for the main widgets ListView
  Widget routineTile(String name, List<Map<String,dynamic>> exercises) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.all(Radius.circular(20)),
        color: darkmode ? AppStyles.primaryColor(darkmode).withOpacity(0.2) : AppStyles.backgroundColor(darkmode),                  
        boxShadow: [
          BoxShadow(
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(0, 3),
            color: Colors.black.withOpacity(0.05)
          ),
          BoxShadow(
            blurRadius: 1,
            offset: const Offset(0, 1),
            color: Colors.black.withOpacity(0.1)
          )
        ]
      ),
      child: ListTile(
        title: Text(
          name, 
          style: AppStyles.getSubHeadingStyle(darkmode),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        trailing: IconButton(
          onPressed: () {
            Navigator.push(
              context, 
              MaterialPageRoute(builder:(context) => RoutineView(name, onStateCallBack),)
            );
          },
          icon: Icon(
            Icons.more_horiz,
            color: AppStyles.accentColor(darkmode),
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.0),
          side: BorderSide.none
        ),
        contentPadding: const EdgeInsets.only(left: 20, right: 5),
      ),
    );
  } 
}