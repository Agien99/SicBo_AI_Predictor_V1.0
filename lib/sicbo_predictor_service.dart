import 'package:tflite_flutter/tflite_flutter.dart';

class SicboPredictorService {
  late Interpreter _interpreter;

  Future<void> loadModel() async {
    try {
      // Placeholder for loading a real TFLite model.
      // For example: _interpreter = await Interpreter.fromAsset('sicbo_model.tflite');
      print("Model loading skipped for now. Using dummy prediction.");
    } catch (e) {
      print("Failed to load model: $e");
    }
  }

  Map<String, String> predict(List<int> diceValues) {
    final sum = diceValues.reduce((a, b) => a + b);
    String bigSmallResult;
    if (sum >= 11 && sum <= 17) {
      bigSmallResult = 'Big';
    } else if (sum >= 4 && sum <= 10) {
      bigSmallResult = 'Small';
    } else {
      bigSmallResult = 'Invalid'; // For triples (e.g., 1,1,1 or 6,6,6) which are neither Big nor Small in some rulesets
    }

    final expectedTotal = '${sum}';

    final diceNumbersMightAppear = diceValues.join(', ');

    String possibleDouble = 'No';
    if (diceValues[0] == diceValues[1] ||
        diceValues[0] == diceValues[2] ||
        diceValues[1] == diceValues[2]) {
      possibleDouble = 'Yes';
    }

    return {
      'bigSmall': bigSmallResult,
      'expectedTotal': expectedTotal,
      'diceNumbersMightAppear': diceNumbersMightAppear,
      'possibleDouble': possibleDouble,
    };
  }

  void dispose() {
    _interpreter.close();
  }
}
