import 'package:flutter/material.dart';
import '../models/workout.dart';
import '../services/database_service.dart';
import '../widgets/summary_card.dart';
import 'add_workout_screen.dart';
import '../widgets/workout_chart.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Workout> workouts = [];

  @override
  void initState() {
    super.initState();
    loadWorkouts();
  }

  Future<void> loadWorkouts() async {
    workouts = await DatabaseService.instance.getWorkouts();
    setState(() {});
  }

  int get totalCalories =>
      workouts.fold(0, (sum, item) => sum + item.calories);

  int get totalDuration =>
      workouts.fold(0, (sum, item) => sum + item.duration);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Tracker"),
        centerTitle: true,
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
  child: const Row(
    children: [
      CircleAvatar(
        radius: 25,
        child: Icon(Icons.person),
      ),
      SizedBox(width: 15),

      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Welcome Harshit 👋",
              style: TextStyle(
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
                const Expanded(
                  child: SummaryCard(
                    title: "BMI",
                    value: "--",
                    icon: Icons.monitor_weight,
                  ),
                ),
              ],
            ),
const SizedBox(height: 30),
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