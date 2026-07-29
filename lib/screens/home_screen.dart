import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/workout.dart';
import '../services/database_service.dart';
import '../services/goal_service.dart';
import '../services/profile_service.dart';
import '../services/step_service.dart';
import '../widgets/summary_card.dart';
import '../widgets/workout_chart.dart';
import 'add_workout_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // ===========================
  // Data
  // ===========================

  List<Workout> workouts = [];

  String? _imagePath;
  double? _bmi;
  int _steps = 0;

  final GoalService goalService = GoalService();
  final StepService _stepService = StepService();

  Stream<StepCount>? _stepStream;

  String goalWeight = "";
  String goalSteps = "";
  String goalCalories = "";
  String goalWater = "";

  // ===========================
  // Search & Filter (NEW)
  // ===========================

  final TextEditingController searchController =
      TextEditingController();

  String searchText = "";

  // ===========================
  // Daily Quotes (NEW)
  // ===========================

  final List<String> quotes = [
    "Every workout counts 💪",
    "Stay consistent.",
    "Small progress is still progress.",
    "Push yourself today.",
    "Fitness is a lifestyle.",
    "One more rep!",
    "Never skip your goals.",
    "Discipline beats motivation.",
  ];

  String get todayQuote {
    final day = DateTime.now().day;
    return quotes[day % quotes.length];
  }

  // ===========================
  // Init
  // ===========================

  @override
  void initState() {
    super.initState();

    loadWorkouts();
    loadGoals();
    _loadProfileImage();
    _loadBMI();

    // Uncomment when step counter is enabled
    // _initStepCounter();
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }

  // ===========================
  // Greeting
  // ===========================

  String getGreeting() {
    final hour = DateTime.now().hour;

    if (hour < 12) {
      return "Good Morning";
    } else if (hour < 17) {
      return "Good Afternoon";
    } else {
      return "Good Evening";
    }
  }

  // ===========================
  // Step Counter
  // ===========================

  Future<void> _initStepCounter() async {
    final status =
        await Permission.activityRecognition.request();

    if (!status.isGranted) return;

    _stepStream = _stepService.stepStream;

    _stepStream?.listen((event) {
      if (!mounted) return;

      setState(() {
        _steps = event.steps;
      });
    });
  }

  // ===========================
  // Profile
  // ===========================

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

  // ===========================
  // Goals
  // ===========================

  Future<void> loadGoals() async {
    final goals = await goalService.loadGoals();

    if (!mounted) return;

    setState(() {
      goalWeight = goals["weight"]!;
      goalSteps = goals["steps"]!;
      goalCalories = goals["calories"]!;
      goalWater = goals["water"]!;
    });
  }

  // ===========================
  // Workouts
  // ===========================

  Future<void> loadWorkouts() async {
    workouts = await DatabaseService.instance.getWorkouts();

    if (mounted) {
      setState(() {});
    }
  }

  int get totalCalories =>
      workouts.fold(0, (sum, item) => sum + item.calories);

  int get totalDuration =>
      workouts.fold(0, (sum, item) => sum + item.duration);

  List<Workout> get filteredWorkouts {
    if (searchText.isEmpty) return workouts;

    return workouts.where((workout) {
      return workout.name
          .toLowerCase()
          .contains(searchText.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return Scaffold(
  appBar: AppBar(
    centerTitle: true,
    elevation: 0,
    title: const Text(
      "FitTrack",
      style: TextStyle(
        fontWeight: FontWeight.bold,
        letterSpacing: 1,
      ),
    ),
    actions: [
      IconButton(
        icon: const Icon(Icons.logout),
        onPressed: () async {
          await FirebaseAuth.instance.signOut();
        },
      ),
    ],
  ),

  body: RefreshIndicator(
    onRefresh: () async {
      await loadWorkouts();
      await loadGoals();
      await _loadProfileImage();
      await _loadBMI();
    },

    child: ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [

        //=========================
        // PREMIUM HEADER
        //=========================

        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary,
                Colors.green.shade600,
              ],
            ),
          ),

          child: Row(
            children: [

              CircleAvatar(
                radius: 32,
                backgroundColor: Colors.white,
                backgroundImage: _imagePath != null
                    ? FileImage(File(_imagePath!))
                    : null,
                child: _imagePath == null
                    ? const Icon(Icons.person,size:30)
                    : null,
              ),

              const SizedBox(width:18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [

                    Text(
                      getGreeting(),
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                      ),
                    ),

                    const SizedBox(height:4),

                    Text(
                      DateFormat("EEEE, dd MMM yyyy")
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),

                    const SizedBox(height:6),

                    Text(
                      user?.displayName ?? "User",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 27,
                      ),
                    ),

                    const SizedBox(height:8),

                    Text(
                      todayQuote,
                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),

                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height:22),

        //=========================
        // SEARCH BAR
        //=========================

        TextField(
          controller: searchController,
          onChanged: (value) {
            setState(() {
              searchText = value;
            });
          },
          decoration: InputDecoration(
            hintText: "Search workout...",
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(
              borderRadius:
                  BorderRadius.circular(16),
            ),
          ),
        ),

        const SizedBox(height:20),

        //=========================
        // SUMMARY
        //=========================

        Row(
          children: [

            Expanded(
              child: SummaryCard(
                title: "Today's Workouts",
                value: workouts.length.toString(),
                icon: Icons.fitness_center,
              ),
            ),

            const SizedBox(width:12),

            Expanded(
              child: SummaryCard(
                title: "Calories",
                value: "$totalCalories kcal",
                icon: Icons.local_fire_department,
              ),
            ),

          ],
        ),

        const SizedBox(height:16),

        Row(
          children: [

            Expanded(
              child: SummaryCard(
                title: "Duration",
                value: "$totalDuration min",
                icon: Icons.timer,
              ),
            ),

            const SizedBox(width:12),

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

        const SizedBox(height:16),

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

        const SizedBox(height:24),
                //=========================
        // GOALS CARD
        //=========================

        Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
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
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 18),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.monitor_weight),
                  title: const Text("Target Weight"),
                  trailing: Text(
                    goalWeight.isEmpty
                        ? "--"
                        : "$goalWeight kg",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.directions_walk),
                  title: const Text("Daily Steps"),
                  trailing: Text(
                    goalSteps.isEmpty
                        ? "--"
                        : goalSteps,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.local_fire_department),
                  title: const Text("Calories Goal"),
                  trailing: Text(
                    goalCalories.isEmpty
                        ? "--"
                        : "$goalCalories kcal",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Divider(),

                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.water_drop),
                  title: const Text("Water Goal"),
                  trailing: Text(
                    goalWater.isEmpty
                        ? "--"
                        : "$goalWater L",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

              ],
            ),
          ),
        ),

        const SizedBox(height: 22),

        //=========================
        // WEEKLY PROGRESS (NEW)
        //=========================

        Card(
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  "Weekly Progress",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 18),

                LinearProgressIndicator(
                  value: workouts.isEmpty
                      ? 0
                      : (workouts.length / 7).clamp(0.0, 1.0),
                  minHeight: 10,
                  borderRadius: BorderRadius.circular(12),
                ),

                const SizedBox(height: 18),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.spaceBetween,
                  children: [

                    Column(
                      children: [
                        Text(
                          workouts.length.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Workouts"),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          totalCalories.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Calories"),
                      ],
                    ),

                    Column(
                      children: [
                        Text(
                          totalDuration.toString(),
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text("Minutes"),
                      ],
                    ),

                  ],
                ),

              ],
            ),
          ),
        ),

        const SizedBox(height: 24),

        //=========================
        // CHART
        //=========================

        WorkoutChart(
          calories: totalCalories,
          duration: totalDuration,
        ),

        const SizedBox(height: 30),

        const Text(
          "Today's Activity",
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 18),
        //=========================
// WORKOUT LIST
//=========================

filteredWorkouts.isEmpty
    ? Card(
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: 35,
            horizontal: 20,
          ),
          child: Column(
            children: [

              Icon(
                Icons.fitness_center,
                size: 75,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(height: 18),

              const Text(
                "No Workouts Found",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 10),

              Text(
                searchText.isEmpty
                    ? "Start your fitness journey by adding your first workout."
                    : "No workout matches your search.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 25),

              ElevatedButton.icon(
                icon: const Icon(Icons.add),
                label: const Text("Add Workout"),
                onPressed: () async {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          const AddWorkoutScreen(),
                    ),
                  );

                  if (result == true) {
                    loadWorkouts();
                  }
                },
              ),

            ],
          ),
        ),
      )

    : ListView.builder(
        shrinkWrap: true,
        physics:
            const NeverScrollableScrollPhysics(),
        itemCount: filteredWorkouts.length,

        itemBuilder: (context, index) {

          final workout =
              filteredWorkouts[index];

        return Dismissible(
            key: ValueKey(workout.id),

            background: Container(
              alignment: Alignment.centerLeft,
              padding:
                  const EdgeInsets.only(left: 20),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: const Icon(
                Icons.edit,
                color: Colors.white,
              ),
            ),

            secondaryBackground: Container(
              alignment: Alignment.centerRight,
              padding:
                  const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius:
                    BorderRadius.circular(18),
              ),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),

            confirmDismiss: (direction) async {

              if (direction ==
                  DismissDirection.startToEnd) {

                final result =
                    await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        AddWorkoutScreen(
                      workout: workout,
                    ),
                  ),
                );

                if (result == true) {
                  loadWorkouts();
                }

                return false;
              }

              return await showDialog<bool>(
                    context: context,
                    builder: (_) => AlertDialog(
                      title:
                          const Text("Delete Workout"),
                      content: const Text(
                        "Do you really want to delete this workout?",
                      ),
                      actions: [

                        TextButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context, false),
                          child:
                              const Text("Cancel"),
                        ),

                        ElevatedButton(
                          onPressed: () =>
                              Navigator.pop(
                                  context, true),
                          child:
                              const Text("Delete"),
                        ),

                      ],
                    ),
                  ) ??
                  false;
            },
            onDismissed: (_) async {
  await DatabaseService.instance.deleteWorkout(workout.id!);

  await loadWorkouts();

  if (!mounted) return;

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.all(16),
      backgroundColor: Colors.green.shade600,
      content: const Text(
        "Workout deleted successfully",
      ),
    ),
  );
},

            child: Card(
              elevation: 2,
              margin:
                  const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(18),
              ),

              child: ListTile(

                onTap: () async {

                  final result =
                      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddWorkoutScreen(
                        workout: workout,
                      ),
                    ),
                  );

                  if (result == true) {
                    loadWorkouts();
                  }
                },

                leading: CircleAvatar(
                  child: const Icon(
                    Icons.fitness_center,
                  ),
                ),

                title: Text(
                  workout.name,
                  style: const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                subtitle: Text(
                  "${workout.duration} min • ${workout.calories} kcal",
                ),

                trailing: const Icon(
                  Icons.arrow_forward_ios,
                  size: 18,
                ),
              ),
            ),
          );
        },
      ),
              //=========================
        // DELETE AFTER SWIPE
        //=========================

       

          ],
    ),
  ),

floatingActionButton: FloatingActionButton.extended(
  onPressed: () async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const AddWorkoutScreen(),
      ),
    );

    if (result == true) {
      await loadWorkouts();
    }
  },
  icon: const Icon(Icons.add),
  label: const Text(
    "Add Workout",
    style: TextStyle(
      fontWeight: FontWeight.bold,
    ),
  ),
),

);
}
} 