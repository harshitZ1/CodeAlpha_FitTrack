import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/database_service.dart';

class AddWorkoutScreen extends StatefulWidget {
  final Workout? workout;

  const AddWorkoutScreen({
    super.key,
    this.workout,
  });

  @override
  State<AddWorkoutScreen> createState() => _AddWorkoutScreenState();
}

class _AddWorkoutScreenState extends State<AddWorkoutScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _workoutController =
      TextEditingController();

  final TextEditingController _durationController =
      TextEditingController();

  final TextEditingController _caloriesController =
      TextEditingController();

      @override
void initState() {
  super.initState();

  if (widget.workout != null) {
    _workoutController.text = widget.workout!.name;
    _durationController.text =
        widget.workout!.duration.toString();
    _caloriesController.text =
        widget.workout!.calories.toString();
  }
}

  @override
  void dispose() {
    _workoutController.dispose();
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
  widget.workout == null
      ? "Add Workout"
      : "Edit Workout",
),
      ),
     body: Padding(
  padding: const EdgeInsets.all(20),
  child: Form(
    key: _formKey,
    child: ListView(
      children: [
       Text(
  widget.workout == null
      ? "New Workout"
      : "Edit Workout",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        TextFormField(
          controller: _workoutController,
          decoration: const InputDecoration(
            labelText: "Workout Name",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.fitness_center),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please enter workout name";
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: _durationController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Duration (minutes)",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.timer),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please enter duration";
            }
            return null;
          },
        ),

        const SizedBox(height: 20),

        TextFormField(
          controller: _caloriesController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: "Calories Burned",
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.local_fire_department),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return "Please enter calories";
            }
            return null;
          },
        ),

        const SizedBox(height: 30),

        SizedBox(
          height: 55,
          child: ElevatedButton.icon(
          onPressed: () async {
  if (_formKey.currentState!.validate()) {

    final workout = Workout(
      id: widget.workout?.id,
      name: _workoutController.text.trim(),
      duration: int.parse(_durationController.text),
      calories: int.parse(_caloriesController.text),
      date: DateTime.now().toString().split(' ')[0],
    );

    if (widget.workout == null) {
      await DatabaseService.instance.insertWorkout(workout);
    } else {
      await DatabaseService.instance.updateWorkout(workout);
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          widget.workout == null
              ? "Workout Saved Successfully!"
              : "Workout Updated Successfully!",
        ),
      ),
    );

    Navigator.pop(context, true);
  }
},
          icon: const Icon(Icons.save),
          label: Text(
            widget.workout == null
                ? "Save Workout"
                : "Update Workout",
          ),
        ),
      ),
    ],
  ),
),
),
);
  }
}