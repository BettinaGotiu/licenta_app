import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultsScreen extends StatelessWidget {
  final String spokenText;
  final double averageWpm;
  final double withinLimitPercentage;
  final List<String> foundExpressions;

  const ResultsScreen({
    Key? key,
    required this.spokenText,
    required this.averageWpm,
    required this.withinLimitPercentage,
    required this.foundExpressions,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Spoken Text:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              spokenText,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Average Words Per Minute:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              averageWpm.toStringAsFixed(2),
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Percentage of Time Within Selected Pace:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              '${withinLimitPercentage.toStringAsFixed(2)}%',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            const Text(
              'Common Expressions Found:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            foundExpressions.isEmpty
                ? const Text(
                    'No common expressions found.',
                    style: TextStyle(fontSize: 16),
                  )
                : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: foundExpressions.map((expression) {
                      return Text(
                        expression,
                        style: const TextStyle(fontSize: 16),
                      );
                    }).toList(),
                  ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                    (Route<dynamic> route) => false,
                  );
                },
                child: const Text('Go to Home Screen'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
