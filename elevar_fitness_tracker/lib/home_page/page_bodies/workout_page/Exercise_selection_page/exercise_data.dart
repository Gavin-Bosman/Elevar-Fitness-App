class ExerciseItem {
  ExerciseItem(this.name, this.muscle, this.isSelected, [this.reps, this.weight]);
  
  final String name;
  final String muscle;
  bool isSelected;
  int? reps;
  int? weight;
}

ExerciseItem fromMap(Map<String,dynamic> data) {
  return ExerciseItem(data['name']!, data['muscle']!, false);
}

