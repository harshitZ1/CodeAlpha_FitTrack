import 'package:flutter/material.dart';
import '../services/profile_service.dart';

class BmiScreen extends StatefulWidget {
  const BmiScreen({super.key});

  @override
  State<BmiScreen> createState() => _BmiScreenState();
}

class _BmiScreenState extends State<BmiScreen> {
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();

  double? bmi;
  String category = "";

  Future<void> calculateBMI() async {
    final height = double.tryParse(_heightController.text);
    final weight = double.tryParse(_weightController.text);

    if (height == null || weight == null || height <= 0 || weight <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Enter valid height and weight"),
        ),
      );
      return;
    }

    final h = height / 100;
    final result = weight / (h * h);

    String bmiCategory;

    if (result < 18.5) {
      bmiCategory = "Underweight";
    } else if (result < 25) {
      bmiCategory = "Normal Weight";
    } else if (result < 30) {
      bmiCategory = "Overweight";
    } else {
      bmiCategory = "Obese";
    }

    await ProfileService.saveBMI(
      bmi: result,
      height: height,
      weight: weight,
      category: bmiCategory,
    );

    setState(() {
      bmi = result;
      category = bmiCategory;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("BMI saved successfully!"),
      ),
    );
  }

  Color get resultColor {
    switch (category) {
      case "Underweight":
        return Colors.blue;
      case "Normal Weight":
        return Colors.green;
      case "Overweight":
        return Colors.orange;
      case "Obese":
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("BMI Calculator"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView(
          children: [
            TextField(
              controller: _heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Height (cm)",
                prefixIcon: Icon(Icons.height),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _weightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Weight (kg)",
                prefixIcon: Icon(Icons.monitor_weight),
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              height: 55,
              child: ElevatedButton(
                onPressed: calculateBMI,
                child: const Text("Calculate BMI"),
              ),
            ),
            const SizedBox(height: 35),
            if (bmi != null)
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Text(
                        "Your BMI",
                        style: TextStyle(fontSize: 20),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        bmi!.toStringAsFixed(2),
                        style: const TextStyle(
                          fontSize: 42,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 15),
                      Text(
                        category,
                        style: TextStyle(
                          fontSize: 22,
                          color: resultColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}