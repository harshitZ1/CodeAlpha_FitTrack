import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WorkoutChart extends StatelessWidget {
  final int calories;
  final int duration;

  const WorkoutChart({
    super.key,
    required this.calories,
    required this.duration,
  });

  @override
  Widget build(BuildContext context) {
    final maxValue = (calories > duration ? calories : duration) + 20;

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: const [
                Icon(
                  Icons.analytics_rounded,
                  color: Colors.green,
                  size: 28,
                ),
                SizedBox(width: 10),
                Text(
                  "Workout Analytics",
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 260,
              child: BarChart(
                BarChartData(
                  maxY: maxValue.toDouble(),
                  alignment: BarChartAlignment.spaceAround,

                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: maxValue / 5,
                  ),

                  borderData: FlBorderData(show: false),
                                    titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        reservedSize: 40,
                        showTitles: true,
                        interval: (maxValue / 5).toDouble(),
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toInt().toString(),
                            style: const TextStyle(fontSize: 11),
                          );
                        },
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 35,
                        getTitlesWidget: (value, meta) {
                          switch (value.toInt()) {
                            case 0:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "🔥 Calories",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );

                            case 1:
                              return const Padding(
                                padding: EdgeInsets.only(top: 8),
                                child: Text(
                                  "⏱ Duration",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              );

                            default:
                              return const SizedBox();
                          }
                        },
                      ),
                    ),
                  ),

                  barGroups: [
                    BarChartGroupData(
                      x: 0,
                      barRods: [
                        BarChartRodData(
                          toY: calories.toDouble(),
                          width: 38,
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.orange,
                              Colors.deepOrange,
                            ],
                          ),
                        ),
                      ],
                    ),

                    BarChartGroupData(
                      x: 1,
                      barRods: [
                        BarChartRodData(
                          toY: duration.toDouble(),
                          width: 38,
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            colors: [
                              Colors.green,
                              Colors.teal,
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                                  ),
              ),
            ),

            const SizedBox(height: 20),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildInfoCard(
                  Icons.local_fire_department,
                  Colors.deepOrange,
                  "$calories kcal",
                  "Calories",
                ),
                _buildInfoCard(
                  Icons.timer,
                  Colors.green,
                  "$duration min",
                  "Duration",
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(
    IconData icon,
    Color color,
    String value,
    String label,
  ) {
    return Container(
      width: 130,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: color,
            size: 30,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}