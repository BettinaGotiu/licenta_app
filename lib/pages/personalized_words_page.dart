import 'package:flutter/material.dart';
import 'common_words.dart';

class PersonalizedWordsPage extends StatefulWidget {
  const PersonalizedWordsPage({Key? key}) : super(key: key);

  @override
  _PersonalizedWordsPageState createState() => _PersonalizedWordsPageState();
}

class _PersonalizedWordsPageState extends State<PersonalizedWordsPage> {
  final TextEditingController _wordController = TextEditingController();

  void _addWord(String word) {
    setState(() {
      commonWords.add(word);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Words'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: commonWords.map((word) {
                return Chip(
                  label: Text(word),
                );
              }).toList(),
            ),
            const Spacer(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Add New Word'),
                content: TextField(
                  controller: _wordController,
                  decoration: const InputDecoration(hintText: 'Enter word'),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      if (_wordController.text.trim().isNotEmpty) {
                        _addWord(_wordController.text.trim());
                        _wordController.clear();
                        Navigator.of(context).pop();
                      }
                    },
                    child: const Text('Add'),
                  ),
                ],
              );
            },
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
