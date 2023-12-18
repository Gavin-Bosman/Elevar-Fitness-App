import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:elevar_fitness_tracker/home_page/page_bodies/workout_page/Exercise_selection_page/exercise_data.dart';


class HttpModel {
  final String apiKey = '43JIXmYWWvv8fLYlfLMpLg==dv6aqGSLW9sbIEm6';

  Future<List<Map<String,dynamic>>> getByMuscle(String muscle) async {
    var url = Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=$muscle');
    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if(response.statusCode != 200) {throw HttpException('${response.statusCode}');} // status 200 means success
      return List<Map<String,String>>.from(jsonDecode(response.body));
    } on HttpException { // handling error exceptions
      rethrow;
    }
  }

  Future<Map<String,dynamic>> getByName(String name) async {
    var url = Uri.parse('https://api.api-ninjas.com/v1/exercises?name=$name');
    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if(response.statusCode != 200) {throw HttpException('${response.statusCode}');} // status 200 means success
      return List<Map<String,dynamic>>.from(jsonDecode(response.body))[0];
    } on HttpException { // handling error exceptions
      rethrow;
    }
  }

  Future<List<ExerciseItem>> getExerciseItemByMuscle(String muscle) async {
    var url = Uri.parse('https://api.api-ninjas.com/v1/exercises?muscle=$muscle');
    try {
      final response = await http.get(url, headers: {'X-Api-Key': apiKey});
      if(response.statusCode != 200) {throw HttpException('${response.statusCode}');} // status 200 means success
      final res = List<Map<String,dynamic>>.from(jsonDecode(response.body));
      return res.map((e) => fromMap(e)).toList(); // using the exerciseItem fromMap method
    } on HttpException { // handling error exceptions
      rethrow;
    }
  }
  
}