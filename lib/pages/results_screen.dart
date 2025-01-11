import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'home_screen.dart';
import 'common_words.dart'; // Import the common_words file
import 'package:uuid/uuid.dart'; // Import UUID package
import 'package:intl/intl.dart'; // Import intl package

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
  double? _lastSessionsAverage;
  List<Map<String, dynamic>> _sessions = [];

  @override
  void initState() {
    super.initState();
    _commonWordCounts = {};
    _countCommonWords();
    _fetchPreviousSessionsData();
  }

  void _countCommonWords() {
    // Initialize counts to 0
    commonWords.forEach((expression) {
      _commonWordCounts[expression] = 0;
    });

    // Count occurrences of each expression
    for (String expression in commonWords) {
      _commonWordCounts[expression] =
          _countOccurrences(widget.spokenText, expression);
    }
  }

  int _countOccurrences(String text, String pattern) {
    RegExp regExp = RegExp(RegExp.escape(pattern), caseSensitive: false);
    return regExp.allMatches(text).length;
  }

  Future<void> _fetchPreviousSessionsData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      CollectionReference userCollection = FirebaseFirestore.instance
          .collection('user_data')
          .doc(userId)
          .collection('sessions');

      // Fetch all sessions
      final snapshot = await userCollection.orderBy('date').get();

      setState(() {
        _sessions = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
        _lastSessionsAverage = _sessions.isNotEmpty
            ? _sessions
                    .map(
                        (session) => session['withinLimitPercentage'] as double)
                    .reduce((a, b) => a + b) /
                _sessions.length
            : 0.0;
      });

      // Save the current session
      await _saveResultsToFirestore(userCollection);
    }
  }

  Future<void> _saveResultsToFirestore(
      CollectionReference userCollection) async {
    // Generate a unique ID for the session
    String sessionId = Uuid().v4();

    // Save the session data as a new document
    await userCollection.doc(sessionId).set({
      'averageWpm': widget.averageWpm,
      'date': DateTime.now().toIso8601String(),
      'withinLimitPercentage': widget.withinLimitPercentage,
      'spokenText': widget.spokenText,
      'commonWordCounts': _commonWordCounts,
    });

    setState(() {
      _isLoading = false; // Stop showing the loading widget
    });
  }

  Widget _buildLineChart() {
    List<ChartLineDataItem> dataPoints = _sessions
        .asMap()
        .entries
        .map((entry) => ChartLineDataItem(
              x: entry.key.toDouble() + 1,
              value: entry.value['withinLimitPercentage'].toDouble(),
            ))
        .toList();

    // Add the new session data point
    dataPoints.add(ChartLineDataItem(
      x: dataPoints.length + 1.0,
      value: widget.withinLimitPercentage,
    ));

    List<String> dateLabels = _sessions
        .map((session) => DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(session['date'] as String)))
        .toList();

    // Add label for the new session
    dateLabels.add(DateFormat('yyyy-MM-dd').format(DateTime.now()));

    return _sessions.isEmpty
        ? Container(
            height: 200,
            child: Center(
              child: Text(
                'No session data available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        : SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: dataPoints.length *
                  100, // Adjust the width based on the number of data points
              height: 200,
              child: Chart(
                layers: [
                  ChartAxisLayer(
                    settings: ChartAxisSettings(
                      x: ChartAxisSettingsAxis(
                        frequency: 1.0,
                        max: dataPoints.length.toDouble(),
                        min: 1.0,
                        textStyle:
                            TextStyle(color: Colors.black, fontSize: 12.0),
                      ),
                      y: ChartAxisSettingsAxis(
                        frequency: 10.0,
                        max: 100.0,
                        min: 0.0,
                        textStyle:
                            TextStyle(color: Colors.black, fontSize: 12.0),
                      ),
                    ),
                    labelX: (value) => dateLabels[value.toInt() - 1],
                    labelY: (value) => value.toString(),
                  ),
                  ChartLineLayer(
                    items: dataPoints,
                    settings: ChartLineSettings(
                      color: Colors.blue,
                      thickness: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    String comparisonMessage = '';
    if (_lastSessionsAverage != null) {
      double improvement = widget.withinLimitPercentage - _lastSessionsAverage!;
      if (improvement > 0) {
        comparisonMessage =
            'Great job! Your within limit percentage has improved by ${improvement.toStringAsFixed(2)}% compared to the average of the last sessions.';
      } else if (improvement < 0) {
        comparisonMessage =
            'Keep trying! Your within limit percentage is lower by ${improvement.abs().toStringAsFixed(2)}% compared to the average of the last sessions.';
      } else {
        comparisonMessage =
            'You have maintained the same within limit percentage as the average of the last sessions.';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Results'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator()) // Display loading widget
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    // Make the main content scrollable
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Spoken Text:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.spokenText,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Average Words Per Minute:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            widget.averageWpm.toStringAsFixed(2),
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Percentage of Time Within Selected Pace:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            '${widget.withinLimitPercentage.toStringAsFixed(2)}%',
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Common Words and Expressions:',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 10),
                          ..._commonWordCounts.entries.map((entry) {
                            return Text(
                              '${entry.key}: ${entry.value} times',
                              style: const TextStyle(fontSize: 16),
                            );
                          }).toList(),
                          const SizedBox(height: 20),
                          if (comparisonMessage.isNotEmpty)
                            Text(
                              comparisonMessage,
                              style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green),
                            ),
                          const SizedBox(height: 20),
                          _buildLineChart(), // Add the line chart here
                          const SizedBox(
                              height: 20), // Add some space at the bottom
                        ],
                      ),
                    ),
                  ),
                ),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 10.0),
                  color: Colors.blue,
                  child: Center(
                    child: FloatingActionButton(
                      backgroundColor: Colors.blue,
                      child: const Icon(Icons.home, color: Colors.white),
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const HomeScreen()),
                          (Route<dynamic> route) => false,
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
