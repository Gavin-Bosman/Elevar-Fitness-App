import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:elevar_fitness_tracker/local_storage/routine_db_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StatsBody extends StatefulWidget {
  Function updatePage;
  
  StatsBody(this.updatePage, {super.key});
  @override
  State<StatsBody> createState() => StatsBodyState();
}

class StatsBodyState extends State<StatsBody> {
  final RoutineDBModel dbModel = RoutineDBModel();
  bool darkmode = false;

  // Local prefs
  SharedPreferences? prefs;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((sharedPrefs) {
      setState(() {
        prefs = sharedPrefs;
        darkmode = prefs?.getBool('darkmode') ?? false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppStyles.backgroundColor(darkmode),
      appBar: AppBar(
        title:
            Row(
              children: [
                Icon(
                  CupertinoIcons.graph_square,
                  color: AppStyles.textColor(darkmode)
                ),
                const SizedBox(width: 10),
                Text(
                  "Your Statistics",
                  style: AppStyles.getHeadingStyle(darkmode)
                ),
              ],
            ),
        backgroundColor: AppStyles.primaryColor(darkmode).withOpacity(darkmode ? 0.5 : 1.0),
      ),
      body: GestureDetector(
        onHorizontalDragUpdate: (details) {
          if (details.delta.distance > 5) {
            if (details.delta.dx < 0) {
              widget.updatePage(1);
            }
          }
        },
        child: Stack(
          children: [
            Container(
              color: darkmode ? Colors.transparent : AppStyles.primaryColor(darkmode).withOpacity(0.2)
            ),
            FutureBuilder<List<Map<String, dynamic>>>(
              future: dbModel.getUniqueWorkoutStats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                  List<Map<String, dynamic>> exerciseStats = snapshot.data!;
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: ListView.builder(
                      itemCount: exerciseStats.length,
                      itemBuilder: (context, index) {
                        var exerciseStat = exerciseStats[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2, horizontal: 10),
                          child: Container(
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
                              title: Text(exerciseStat['exerciseName'],
                                  style: AppStyles.getSubHeadingStyle(darkmode)),
                              subtitle: Text(
                                'Max Reps: ${exerciseStat['maxReps']} | Max Weight: ${exerciseStat['maxWeight']} lbs',
                                style: TextStyle(
                                  fontFamily: 'Geologica',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: AppStyles.accentColor(darkmode)
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  );
                } else {
                  return Center(child: Text('No exercise stats available', style: AppStyles.getSubHeadingStyle(darkmode),));
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
