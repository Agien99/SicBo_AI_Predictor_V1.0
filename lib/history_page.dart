import 'package:flutter/material.dart';
import './prediction_record.dart';

class HistoryPage extends StatelessWidget {
  final List<PredictionRecord> records;

  const HistoryPage({super.key, required this.records});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction History'),
      ),
      body: ListView.builder(
        itemCount: records.length,
        itemBuilder: (context, index) {
          final record = records[index];
          return Card(
            margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            elevation: 2,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: ListTile(
              title: Text(
                'Dice: ${record.dice1}, ${record.dice2}, ${record.dice3} (Total: ${record.dice1 + record.dice2 + record.dice3})',
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Big/Small: ${record.result}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Expected Total: ${record.expectedTotal}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Dice Might Appear: ${record.diceNumbersMightAppear}', style: Theme.of(context).textTheme.bodyMedium),
                  Text('Possible Double: ${record.possibleDouble}', style: Theme.of(context).textTheme.bodyMedium),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
