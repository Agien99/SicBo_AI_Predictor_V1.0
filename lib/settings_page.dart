import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  final String currentStrategy;

  const SettingsPage({super.key, required this.currentStrategy});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late String _predictionStrategy;

  @override
  void initState() {
    super.initState();
    _predictionStrategy = widget.currentStrategy;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Settings', style: Theme.of(context).textTheme.titleLarge?.copyWith(color: Theme.of(context).colorScheme.onPrimaryContainer)),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Theme.of(context).colorScheme.onPrimaryContainer),
          onPressed: () => Navigator.pop(context, _predictionStrategy),
        ),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  'Prediction Strategy:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: _predictionStrategy,
                  onChanged: (String? newValue) {
                    setState(() {
                      _predictionStrategy = newValue!;
                    });
                  },
                  items: <String>['Sum-based', 'Pattern-based']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value, style: Theme.of(context).textTheme.bodyLarge),
                    );
                  }).toList(),
                  isExpanded: true,
                  underline: Container(), // Remove default underline
                  icon: Icon(Icons.arrow_drop_down, color: Theme.of(context).colorScheme.primary),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: Theme.of(context).colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
