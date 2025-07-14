// Represents a single prediction record.
class PredictionRecord {
  // The values of the three dice.
  final int dice1;
  final int dice2;
  final int dice3;

  // The predicted result (e.g., "Big" or "Small").
  final String result;
  // The expected total of the dice.
  final String expectedTotal;
  // The dice numbers that might appear.
  final String diceNumbersMightAppear;
  // Whether a double is possible.
  final String possibleDouble;

  // The timestamp of when the prediction was made.
  final DateTime timestamp;

  PredictionRecord({
    required this.dice1,
    required this.dice2,
    required this.dice3,
    required this.result,
    required this.expectedTotal,
    required this.diceNumbersMightAppear,
    required this.possibleDouble,
    required this.timestamp,
  });
}
