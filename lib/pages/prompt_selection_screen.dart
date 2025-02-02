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
  int currentPromptIndex = 0;
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
        prompts = ["Error loading prompts."];
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
      currentPromptIndex = index;
      shownIndexes.add(index);
      if (shownIndexes.length >= prompts.length) {
        shownIndexes.clear();
      }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select a Prompt'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose your Prompt',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Select a prompt from the provided options to start your challenge.',
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            if (prompts.isEmpty)
              const CircularProgressIndicator()
            else
              Column(
                children: [
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
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => SpeechToTextPage(),
                  ),
                );
              },
              icon: const Icon(Icons.check),
              label: const Text('Keep Prompt'),
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
      ),
    );
  }
}
