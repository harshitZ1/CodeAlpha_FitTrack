class Workout {
  int? id;
  String name;
  int duration;
  int calories;
  String date;

  Workout({
    this.id,
    required this.name,
    required this.duration,
    required this.calories,
    required this.date,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'duration': duration,
      'calories': calories,
      'date': date,
    };
  }

  factory Workout.fromMap(Map<String, dynamic> map) {
    return Workout(
      id: map['id'],
      name: map['name'],
      duration: map['duration'],
      calories: map['calories'],
      date: map['date'],
    );
  }
}