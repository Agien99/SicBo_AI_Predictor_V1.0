import 'package:flutter/material.dart';
import './prediction_record.dart';
import './history_page.dart';
import './settings_page.dart';
import './sicbo_predictor_service.dart';

void main() {
  runApp(const MyApp());
}

// The main application widget.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SicBo AI Predictor',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple).copyWith(
          primary: Colors.deepPurple,
          secondary: Colors.amber,
        ),
        useMaterial3: true,
        textTheme: const TextTheme(
          headlineLarge: TextStyle(fontSize: 48.0, fontWeight: FontWeight.bold, color: Colors.deepPurple),
          headlineMedium: TextStyle(fontSize: 28.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleLarge: TextStyle(fontSize: 24.0, fontWeight: FontWeight.bold, color: Colors.black87),
          titleMedium: TextStyle(fontSize: 18.0, fontWeight: FontWeight.w600, color: Colors.black54),
          bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
          bodyMedium: TextStyle(fontSize: 14.0, color: Colors.black54),
        ),
      ),
      home: const PredictionPage(),
    );
  }
}

// The main page of the application, where users can input dice rolls and get predictions.
class PredictionPage extends StatefulWidget {
  const PredictionPage({super.key});

  @override
  State<PredictionPage> createState() => _PredictionPageState();
}

class _PredictionPageState extends State<PredictionPage> {
  final SicboPredictorService _predictorService = SicboPredictorService();
  List<int> _diceValues = [0, 0, 0]; // Initialize with 0 to indicate not selected
  int _currentDiceIndex = 0; // 0 for first dice, 1 for second, 2 for third
  Map<String, String> _prediction = {};
  final List<PredictionRecord> _history = [];
  String _predictionStrategy = 'Sum-based';
  int _historyCounter = 0;

  @override
  void initState() {
    super.initState();
    _predictorService.loadModel();
  }

  @override
  void dispose() {
    _predictorService.dispose();
    super.dispose();
  }

  void _selectDiceValue(int value) {
    setState(() {
      if (_currentDiceIndex < 3) {
        _diceValues[_currentDiceIndex] = value;
        _currentDiceIndex++;
        if (_currentDiceIndex == 3) {
          _predict(); // Automatically predict after the third dice is selected
        }
      }
    });
  }

  void _resetDiceSelection() {
    setState(() {
      _diceValues = [0, 0, 0];
      _currentDiceIndex = 0;
      _prediction = {}; // Clear prediction when resetting dice
    });
  }

  void _incrementDice(int index) {
    setState(() {
      _diceValues[index] = (_diceValues[index] % 6) + 1;
    });
  }

  void _predict() {
    final predictionResult = _predictorService.predict(_diceValues);

    final record = PredictionRecord(
      dice1: _diceValues[0],
      dice2: _diceValues[1],
      dice3: _diceValues[2],
      result: predictionResult['bigSmall']!,
      expectedTotal: predictionResult['expectedTotal']!,
      diceNumbersMightAppear: predictionResult['diceNumbersMightAppear']!,
      possibleDouble: predictionResult['possibleDouble']!,
      timestamp: DateTime.now(),
    );

    setState(() {
      _prediction = predictionResult;
      _history.add(record);
      _historyCounter++;
    });
  }

  void _resetHistory() {
    setState(() {
      _history.clear();
      _historyCounter = 0;
    });
  }

  // Navigates to the history page.
  void _viewHistory() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HistoryPage(records: _history),
      ),
    );
  }

  // Navigates to the settings page.
  void _viewSettings() async {
    final newStrategy = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsPage(currentStrategy: _predictionStrategy),
      ),
    );

    if (newStrategy != null) {
      setState(() {
        _predictionStrategy = newStrategy;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SicBo AI Predictor'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _viewSettings,
          ),
        ],
      ),
      body: Column(
        children: <Widget>[
          // Predicted Result Area
          Expanded(
            flex: 3, // Roughly 60% of the remaining space
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 8,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  color: Theme.of(context).colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Big/Small:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_prediction['bigSmall'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Expected Total:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_prediction['expectedTotal'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Dice Might Appear:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_prediction['diceNumbersMightAppear'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 15),
                        Text(
                          'Possible Double:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer),
                          textAlign: TextAlign.center,
                        ),
                        Text(
                          '${_prediction['possibleDouble'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.headlineMedium?.copyWith(color: Theme.of(context).colorScheme.primary),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          // User Input (Dice Selection)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  _currentDiceIndex < 3
                      ? 'Please select value of the ${['First', 'Second', 'Third'][_currentDiceIndex]} Dice'
                      : 'Selected Dice Values:',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                _currentDiceIndex < 3
                    ? Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(3, (index) {
                              final diceValue = index + 1;
                              return GestureDetector(
                                onTap: () => _selectDiceValue(diceValue),
                                child: _buildDiceFace(diceValue),
                              );
                            }),
                          ),
                          const SizedBox(height: 15),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: List.generate(3, (index) {
                              final diceValue = index + 4;
                              return GestureDetector(
                                onTap: () => _selectDiceValue(diceValue),
                                child: _buildDiceFace(diceValue),
                              );
                            }),
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: _diceValues.map((value) => _buildDiceFace(value, isSelected: true)).toList(),
                      ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: _resetDiceSelection,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset Dice'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onPrimary,
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    textStyle: Theme.of(context).textTheme.bodyLarge,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          // History Result
          Expanded(
            flex: 2, // Roughly 40% of the remaining space
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('History Count: $_historyCounter', style: Theme.of(context).textTheme.titleMedium),
                      ElevatedButton.icon(
                        onPressed: _resetHistory,
                        icon: const Icon(Icons.delete_forever),
                        label: const Text('Clear History'),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Theme.of(context).colorScheme.onError,
                          backgroundColor: Theme.of(context).colorScheme.error,
                          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                          textStyle: Theme.of(context).textTheme.bodyMedium,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: _history.length,
                    itemBuilder: (context, index) {
                      final record = _history[index];
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
                              Text('Timestamp: ${record.timestamp.toLocal().toString().split('.')[0]}', style: Theme.of(context).textTheme.bodySmall),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDiceFace(int value, {bool isSelected = false}) {
    return Container(
      width: 70,
      height: 70,
      decoration: BoxDecoration(
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.white,
        border: Border.all(color: Colors.black, width: 2),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 3,
            offset: const Offset(2, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (value == 1 || value == 3 || value == 5)
            Align(
              alignment: Alignment.center,
              child: _buildDot(),
            ),
          if (value >= 2)
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
          if (value >= 2)
            Align(
              alignment: Alignment.bottomRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
          if (value >= 4)
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
          if (value >= 4)
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
          if (value == 6)
            Align(
              alignment: Alignment.centerLeft,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
          if (value == 6)
            Align(
              alignment: Alignment.centerRight,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: _buildDot(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDot() {
    return Container(
      width: 12,
      height: 12,
      decoration: const BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }
}