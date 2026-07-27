import 'dart:async';

import 'package:pedometer/pedometer.dart';

class StepService {
  Stream<StepCount> get stepStream => Pedometer.stepCountStream;
}