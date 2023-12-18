import 'package:flutter/material.dart';
import 'package:elevar_fitness_tracker/materials/styles.dart';
import 'package:elevar_fitness_tracker/home_page/page_bodies/workout_page/Exercise_selection_page/exercise_data.dart';
import 'package:elevar_fitness_tracker/http/http_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AddExercise extends StatefulWidget {
  const AddExercise({super.key});

  @override
  AddExerciseState createState() => AddExerciseState();
}

class AddExerciseState extends State<AddExercise> {

  AddExerciseState() { // initializing the selected value of the dropdown
    selectedValue = states[0];
  }

  final formkey = GlobalKey<FormState>();
  final HttpModel http = HttpModel();
  TextEditingController textControl = TextEditingController();
  bool refresh = true;
  List<ExerciseItem> exercises = [];
  List<ExerciseItem> selectedExercises = [];
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

  final List<String> states = [
    'abdominals',
    'abductors',
    'adductors',
    'biceps',
    'calves',
    'chest',
    'forearms',
    'glutes',
    'hamstrings',
    'lats',
    'lower_back',
    'middle_back',
    'neck',
    'quadriceps',
    'traps',
    'triceps'
  ];
  String? selectedValue;

  Future<void> init() async {
    // initial http request on page build
    exercises = await http.getExerciseItemByMuscle(selectedValue!);
  }

  @override
  Widget build(BuildContext context) {
    if (refresh) {
      init().then(
        (value) {
          setState(() {
            refresh = false;
          });
        },
      );
    }

    return Scaffold(
      backgroundColor: AppStyles.backgroundColor(darkmode),
      appBar: AppBar(
        title: Text('Exercises', style: AppStyles.getHeadingStyle(darkmode)),
        backgroundColor: AppStyles.primaryColor(darkmode),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppStyles.textColor(darkmode)),
          onPressed: () => Navigator.of(context).pop(),
        )
      ),
      body: Column(
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
            child: SizedBox(
                width: double.infinity,
                child: DropdownButtonFormField(
                  dropdownColor: AppStyles.backgroundColor(darkmode),
                  value: null,
                  key: formkey,
                  items: states.map((String item) {
                    return DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        style: AppStyles.getSubHeadingStyle(darkmode),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      selectedValue = value;
                      refresh = true;
                    });
                  },
                  icon: Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: AppStyles.accentColor(darkmode),
                  ),
                  decoration: InputDecoration(
                    labelText: "Select Muscle:",
                    focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: AppStyles.accentColor(darkmode))),
                  ),
                )),
          ),
          Expanded(
            child: ListView.separated(
              itemBuilder: (context, index) {
                return exerciseTile(
                    exercises[index].name,
                    exercises[index].muscle,
                    exercises[index].isSelected,
                    index);
              },
              separatorBuilder: (context, index) => Divider(
                color: AppStyles.accentColor(darkmode),
              ),
              itemCount: exercises.length,
            ),
          ),
          Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 10.0, horizontal: 25.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(
                        AppStyles.primaryColor(darkmode)),
                    elevation: MaterialStateProperty.all<double>(4.0),
                    side: MaterialStateProperty.all<BorderSide>(const BorderSide(color:Colors.black, width: 2.0))
                  ),
                  child: Text(
                    'Add All',
                    style: AppStyles.getSubHeadingStyle(darkmode),
                  ),
                  onPressed: () {
                    Navigator.pop(context, selectedExercises);
                    setState(() {
                      selectedExercises.forEach((element) {
                        element.isSelected = false;
                      });
                      selectedExercises = [];
                    });
                  },
                ),
              ))
        ],
      ),
    );
  }

  Widget exerciseTile(String name, String muscle, bool isSelected, int index) {
    return ListTile(
      leading: Icon(
        Icons.area_chart,
        color: AppStyles.highlightColor(darkmode),
      ),
      title: Text(
        name,
        style: AppStyles.getSubHeadingStyle(darkmode),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        muscle,
        style: AppStyles.getMainTextStyle(darkmode),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check_box_rounded,
              color: AppStyles.highlightColor(darkmode),
            )
          : Icon(
              Icons.check_box_outline_blank_rounded,
              color: AppStyles.accentColor(darkmode),
            ),
      onTap: () {
        setState(() {
          exercises[index].isSelected = !exercises[index].isSelected;
          if (exercises[index].isSelected == true) {
            selectedExercises.add(exercises[index]);
          } else if (exercises[index].isSelected == false) {
            selectedExercises.removeWhere(
                (element) => element.name == exercises[index].name);
          }
        });
      },
    );
  }
}
