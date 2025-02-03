import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'speed_selection.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({Key? key}) : super(key: key);

  @override
  _DailyChallengePageState createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  List<String> prompts = [];
  int currentPromptIndex = 0;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _dailyStreaksCollection = 'daily_streaks';

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  Future<void> _loadPrompts() async {
    final domains = [
      'art',
      'career',
      'education',
      'environment',
      'imagination',
      'mindset',
      'science',
      'sport',
      'technology'
    ];
    try {
      for (var domain in domains) {
        final filePath = 'assets/promts/$domain.jsonl';
        final contents = await rootBundle.loadString(filePath);
        prompts.addAll(contents.split('\n').where((line) => line.isNotEmpty));
      }
      _checkAndLoadDailyPrompts();
    } catch (e) {
      setState(() {
        prompts = ["Error loading prompts."];
      });
    }
  }

  Future<void> _checkAndLoadDailyPrompts() async {
    final today = DateTime.now();
    final docRef =
        _firestore.collection(_dailyStreaksCollection).doc('current');
    final doc = await docRef.get();

    if (doc.exists) {
      final data = doc.data()!;
      final savedDate = (data['date'] as Timestamp).toDate();
      if (_isSameDay(savedDate, today)) {
        setState(() {
          prompts = [data['promt1'], data['promt2'], data['promt3']];
          currentPromptIndex = 0;
        });
      } else {
        _saveNewDailyPrompts(docRef, today);
      }
    } else {
      _saveNewDailyPrompts(docRef, today);
    }
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  Future<void> _saveNewDailyPrompts(
      DocumentReference docRef, DateTime today) async {
    final random = Random();
    final newPrompts =
        List.generate(3, (_) => prompts[random.nextInt(prompts.length)]);
    await docRef.set({
      'promt1': newPrompts[0],
      'promt2': newPrompts[1],
      'promt3': newPrompts[2],
      'date': today,
    });

    setState(() {
      prompts = newPrompts;
      currentPromptIndex = 0;
    });
  }

  void _previousPrompt() {
    setState(() {
      currentPromptIndex =
          (currentPromptIndex - 1 + prompts.length) % prompts.length;
    });
  }

  void _nextPrompt() {
    setState(() {
      currentPromptIndex = (currentPromptIndex + 1) % prompts.length;
    });
  }

  void _navigateToSpeedSelection(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeedSelectionPage(
          nextPageRoute: '/speech_to_text',
          prompt: prompts[currentPromptIndex],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF3539AC), Color(0xFF11BDE3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 30.0, left: 8.0),
                  child: Align(
                    alignment: Alignment.topLeft,
                    child: IconButton(
                      icon:
                          Icon(Icons.arrow_back, color: Colors.white, size: 28),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                    ),
                  ),
                ),
                Center(
                  child: Padding(
                    padding:
                        const EdgeInsets.only(top: 0.0, bottom: 20, right: 170),
                    child: Text(
                      'Daily Challenge',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Nacelle',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Welcome to your Daily Challenge!',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Complete the following prompt to improve your skills.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (prompts.isEmpty)
              const CircularProgressIndicator()
            else
              Column(
                children: [
                  Text(
                    'Prompt ${currentPromptIndex + 1}/3',
                    style: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: 250,
                    height: 350,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(color: Colors.black, width: 3),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black,
                          offset: Offset(15, 15),
                          spreadRadius: -2.5,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Center(
                      child: Text(
                        prompts[currentPromptIndex],
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, size: 30),
                  onPressed: _previousPrompt,
                ),
                const SizedBox(width: 20),
                IconButton(
                  icon: const Icon(Icons.arrow_forward, size: 30),
                  onPressed: _nextPrompt,
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () => _navigateToSpeedSelection(context),
              icon: const Icon(Icons.check),
              label: const Text('Start Challenge'),
              style: ElevatedButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Color(0xFF11BDE3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
