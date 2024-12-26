import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'speech_to_text.dart';

class PromptSelectionPage extends StatefulWidget {
  final String domain;

  const PromptSelectionPage({required this.domain});

  @override
  _PromptSelectionPageState createState() => _PromptSelectionPageState();
}

class _PromptSelectionPageState extends State<PromptSelectionPage> {
  List<String> prompts = [];
  String? currentPrompt;
  Set<int> shownIndexes = {};

  @override
  void initState() {
    super.initState();
    _loadPrompts();
  }

  void _loadPrompts() async {
    final filePath = 'assets/promts/${widget.domain}.jsonl';
    try {
      print('Trying to load file from path: $filePath'); // Debug statement
      final contents = await rootBundle.loadString(filePath);
      setState(() {
        prompts =
            contents.split('\n').where((line) => line.isNotEmpty).toList();
        _getRandomPrompt();
      });
    } catch (e) {
      print('Error: $e'); // Debug statement
      setState(() {
        currentPrompt = "Error loading prompts.";
      });
    }
  }

  void _getRandomPrompt() {
    if (prompts.isEmpty) return;
    final random = Random();
    int index;
    do {
      index = random.nextInt(prompts.length);
    } while (
        shownIndexes.contains(index) && shownIndexes.length < prompts.length);

    setState(() {
      currentPrompt = prompts[index];
      shownIndexes.add(index);
      if (shownIndexes.length >= prompts.length) {
        shownIndexes.clear();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Prompt'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
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
                    onPressed: () {
                      // Navigate to speech to text page with the selected prompt
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
                      backgroundColor: Colors.green,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  ElevatedButton.icon(
                    onPressed: _getRandomPrompt,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
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
