import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../widgets/summary_card.dart';
import 'add_workout_screen.dart';
import '../widgets/workout_chart.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:io';
import '../services/profile_service.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/step_service.dart';
import '../services/goal_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> workouts = [];
  

 String? _imagePath;
 double? _bmi;
 int _steps = 0;
 final GoalService goalService = GoalService();

String goalWeight = "";
String goalSteps = "";
String goalCalories = "";
String goalWater = "";

final StepService _stepService = StepService();

Stream<StepCount>? _stepStream;

@override
void initState() {
  super.initState();
  loadWorkouts();
  _loadProfileImage();
    _loadBMI();
    loadGoals();
   // _initStepCounter();//
}
Future<void> _initStepCounter() async {
  var status = await Permission.activityRecognition.request();

  if (!status.isGranted) {
    return;
  }

  _stepStream = _stepService.stepStream;

  _stepStream!.listen((event) {
    if (!mounted) return;

    setState(() {
      _steps = event.steps;
    });
  });
}

Future<void> _loadProfileImage() async {
_imagePath = await ProfileService.getProfileImage();
  if (mounted) {
    setState(() {});
  }
}

Future<void> _loadBMI() async {
  _bmi = await ProfileService.getBMI();

  if (mounted) {
    setState(() {});
  }
}
  Future<void> loadWorkouts() async {
    workouts = await DatabaseService.instance.getWorkouts();
    setState(() {});
  }
  Future<void> loadGoals() async {
  final goals = await goalService.loadGoals();

  setState(() {
    goalWeight = goals["weight"]!;
    goalSteps = goals["steps"]!;
    goalCalories = goals["calories"]!;
    goalWater = goals["water"]!;
  });
}

  int get totalCalories =>
      workouts.fold(0, (sum, item) => sum + item.calories);

  int get totalDuration =>
      workouts.fold(0, (sum, item) => sum + item.duration);

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
      appBar: AppBar(
  title: const Text("Fitness Tracker"),
  centerTitle: true,
  actions: [
    IconButton(
      icon: const Icon(Icons.logout),
      onPressed: () async {
        await FirebaseAuth.instance.signOut();
      },
    ),
  ],
),

      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
           padding: const EdgeInsets.only(bottom: 100),
          children: [
           Container(
  padding: const EdgeInsets.all(20),
  decoration: BoxDecoration(
    gradient: LinearGradient(
      colors: [
        Theme.of(context).colorScheme.primary,
        Colors.green,
      ],
    ),
    borderRadius: BorderRadius.circular(20),
  ),
  child: Row(
    children: [
      CircleAvatar(
  radius: 25,
  backgroundImage:
      _imagePath != null ? FileImage(File(_imagePath!)) : null,
  child: _imagePath == null
      ? const Icon(Icons.person)
      : null,
),
      SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           Text(
  "Welcome ${user?.displayName ?? 'User'} 👋",
  style: const TextStyle(
    color: Colors.white,
    fontSize: 22,
    fontWeight: FontWeight.bold,
  ),
),

            SizedBox(height: 6),

            Text(
              "Let's crush today's workout! 💪",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    ],
  ),
),

            const SizedBox(height: 25),

            Row(
              children: [
                Expanded(
                  child: SummaryCard(
                    title: "Today's Workouts",
                    value: workouts.length.toString(),
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SummaryCard(
                    title: "Calories",
                    value: "$totalCalories kcal",
                    icon: Icons.local_fire_department,
                  ),
                ),
              ],
            ),

          const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: SummaryCard(
        title: "Duration",
        value: "$totalDuration min",
        icon: Icons.timer,
      ),
    ),
    const SizedBox(width: 12),
    Expanded(
      child: SummaryCard(
        title: "BMI",
        value: _bmi == null
            ? "--"
            : _bmi!.toStringAsFixed(2),
        icon: Icons.monitor_weight,
      ),
    ),
  ],
),

const SizedBox(height: 16),

Row(
  children: [
    Expanded(
      child: SummaryCard(
        title: "Steps",
        value: _steps.toString(),
        icon: Icons.directions_walk,
      ),
    ),
  ],
),

const SizedBox(height: 20),

Card(
  elevation: 4,
  shape: RoundedRectangleBorder(
    borderRadius: BorderRadius.circular(18),
  ),
  child: Padding(
    padding: const EdgeInsets.all(16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
       const Row(
  children: [
    Icon(
      Icons.track_changes,
      color: Colors.green,
      size: 28,
    ),
    SizedBox(width: 10),
    Text(
      "My Goals",
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
  ],
),

        const SizedBox(height: 16),

       ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.monitor_weight),
  title: const Text("Target Weight"),
  trailing: Text(
    "${goalWeight.isEmpty ? '--' : goalWeight} kg",
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
),

const Divider(),

ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.directions_walk),
  title: const Text("Daily Steps"),
  trailing: Text(
    goalSteps.isEmpty ? "--" : goalSteps,
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
),

const Divider(),

ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.local_fire_department),
  title: const Text("Calories Goal"),
  trailing: Text(
    "${goalCalories.isEmpty ? '--' : goalCalories} kcal",
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
),

const Divider(),

ListTile(
  contentPadding: EdgeInsets.zero,
  leading: const Icon(Icons.water_drop),
  title: const Text("Water Goal"),
  trailing: Text(
    "${goalWater.isEmpty ? '--' : goalWater} L",
    style: const TextStyle(fontWeight: FontWeight.bold),
  ),
),
      ],
    ),
  ),
),
WorkoutChart(
  calories: totalCalories,
  duration: totalDuration,
),

            const SizedBox(height: 30),

            const Text(
              "Today's Activity",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 15),

            workouts.isEmpty
                ? const Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Center(
                        child: Text(
                          "No workouts added yet.",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  )
                : ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: workouts.length,
                    itemBuilder: (context, index) {
  final workout = workouts[index];

  return Card(
    child: ListTile(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AddWorkoutScreen(
              workout: workout,
            ),
          ),
        );

        if (result == true) {
          await loadWorkouts();
        }
      },
      leading: const Icon(Icons.fitness_center),
      title: Text(workout.name),
      subtitle: Text(
        "${workout.duration} min • ${workout.calories} kcal",
      ),
      trailing: IconButton(
        icon: const Icon(
          Icons.delete,
          color: Colors.red,
        ),
        onPressed: () async {
          await DatabaseService.instance.deleteWorkout(workout.id!);

          await loadWorkouts();

          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                "Workout deleted successfully",
              ),
            ),
          );
        },
      ),
    ),
  );
},
                ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => const AddWorkoutScreen(),
            ),
          );

          if (result == true) {
            loadWorkouts();
          }
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}