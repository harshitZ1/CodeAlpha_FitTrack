import 'package:flutter/material.dart';
import '../services/goal_service.dart';
import '../services/goal_service.dart';

class FitnessGoalsScreen extends StatefulWidget {
  const FitnessGoalsScreen({super.key});

  @override
  State<FitnessGoalsScreen> createState() => _FitnessGoalsScreenState();
}

class _FitnessGoalsScreenState extends State<FitnessGoalsScreen> {
  final TextEditingController weightController = TextEditingController();
  final TextEditingController stepsController = TextEditingController();
  final TextEditingController caloriesController = TextEditingController();
  final TextEditingController waterController = TextEditingController();

  final GoalService goalService = GoalService();

  @override
  void initState() {
    super.initState();
    loadGoals();
  }

  Future<void> loadGoals() async {
    final goals = await goalService.loadGoals();

    setState(() {
      weightController.text = goals["weight"]!;
      stepsController.text = goals["steps"]!;
      caloriesController.text = goals["calories"]!;
      waterController.text = goals["water"]!;
    });
  }

  @override
  void dispose() {
    weightController.dispose();
    stepsController.dispose();
    caloriesController.dispose();
    waterController.dispose();
    super.dispose();
  }

  Widget buildField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }

  Future<void> saveGoals() async {
    await goalService.saveGoals(
      weight: weightController.text,
      steps: stepsController.text,
      calories: caloriesController.text,
      water: waterController.text,
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Goals Saved Successfully"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Fitness Goals"),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            buildField(
              label: "Target Weight (kg)",
              icon: Icons.monitor_weight,
              controller: weightController,
            ),
            buildField(
              label: "Daily Steps Goal",
              icon: Icons.directions_walk,
              controller: stepsController,
            ),
            buildField(
              label: "Daily Calories Goal",
              icon: Icons.local_fire_department,
              controller: caloriesController,
            ),
            buildField(
              label: "Daily Water Goal (L)",
              icon: Icons.water_drop,
              controller: waterController,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: saveGoals,
                child: const Text(
                  "Save Goals",
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}