import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'common_words.dart'; // Import the common_words file
import 'package:uuid/uuid.dart'; // Import UUID package

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
    _saveResultsToFirestore();
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

    setState(() {
      _isLoading = false; // Stop showing the loading widget
    });
  }

  int _countOccurrences(String text, String pattern) {
    RegExp regExp = RegExp(RegExp.escape(pattern), caseSensitive: false);
    return regExp.allMatches(text).length;
  }

  void _saveResultsToFirestore() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      String userId = user.uid;
      CollectionReference userCollection = FirebaseFirestore.instance
          .collection('user_data')
          .doc(userId)
          .collection('sessions');

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
    }
  }

  @override
  Widget build(BuildContext context) {
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
