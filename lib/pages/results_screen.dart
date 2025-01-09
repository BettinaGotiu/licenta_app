import 'package:flutter/material.dart';
import 'home_screen.dart';

class ResultsScreen extends StatefulWidget {
  final String spokenText;
  final double averageWpm;
  final double withinLimitPercentage;

  const ResultsScreen({
    Key? key,
    required this.spokenText,
    required this.averageWpm,
    required this.withinLimitPercentage,
  }) : super(key: key);

  @override
  _ResultsScreenState createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late Map<String, int> _commonWordCounts;
  bool _isLoading = true; // For displaying the loading widget

  @override
  void initState() {
    super.initState();
    _commonWordCounts = {};
    _countCommonWords();
  }

  void _countCommonWords() {
    List<String> commonExpressions = [
      "basically",
      "you know",
      "actually",
      "literally",
      "like"
    ];

    // Initialize counts to 0
    commonExpressions.forEach((expression) {
      _commonWordCounts[expression] = 0;
    });

    // Count occurrences of each expression
    for (String expression in commonExpressions) {
      _commonWordCounts[expression] =
          _countOccurrences(widget.spokenText, expression);
    }

    setState(() {
      _isLoading = false; // Stop showing the loading widget
    });
  }

  int _countOccurrences(String text, String pattern) {
    RegExp regExp = RegExp(RegExp.escape(pattern), caseSensitive: false);
    return regExp.allMatches(text).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Display loading widget
          : Padding(
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
                    widget.spokenText,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Average Words Per Minute:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    widget.averageWpm.toStringAsFixed(2),
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Percentage of Time Within Selected Pace:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${widget.withinLimitPercentage.toStringAsFixed(2)}%',
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Common Words and Expressions:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  ..._commonWordCounts.entries.map((entry) {
                    return Text(
                      '${entry.key}: ${entry.value} times',
                      style: const TextStyle(fontSize: 16),
                    );
                  }).toList(),
                  const Spacer(),
                  Center(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
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
