import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'speech_to_text.dart';

class DailyChallengePage extends StatefulWidget {
  const DailyChallengePage({Key? key}) : super(key: key);

  @override
  _DailyChallengePageState createState() => _DailyChallengePageState();
}

class _DailyChallengePageState extends State<DailyChallengePage> {
  List<String> prompts = [];
  String? currentPrompt;
  int refreshCount = 3;

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

// Load prompts from assets
  void _loadPrompts() async {
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
      _getRandomPrompt();
    } catch (e) {
      setState(() {
        currentPrompt = "Error loading prompts.";
      });
    }
  }

// Get a random prompt
  void _getRandomPrompt() {
    if (prompts.isEmpty) return;
    final random = Random();
    setState(() {
      currentPrompt = prompts[random.nextInt(prompts.length)];
    });
  }

// Refresh the prompt
  void _refreshPrompt() {
    if (refreshCount > 1) {
      _getRandomPrompt();
      setState(() {
        refreshCount--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daily Challenge'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Attempts left: $refreshCount',
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              currentPrompt == null
                  ? const CircularProgressIndicator()
                  : Card(
                      elevation: 10,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          currentPrompt!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton.icon(
                    onPressed: refreshCount > 0 ? _refreshPrompt : null,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SpeechToTextPage(),
                        ),
                      );
                    },
                    icon: const Icon(Icons.check),
                    label: const Text('Keep'),
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white,
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
