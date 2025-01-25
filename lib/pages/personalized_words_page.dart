import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'common_words.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'settings_screen.dart';

class PersonalizedWordsPage extends StatefulWidget {
  const PersonalizedWordsPage({Key? key}) : super(key: key);

  @override
  _PersonalizedWordsPageState createState() => _PersonalizedWordsPageState();
}

class _PersonalizedWordsPageState extends State<PersonalizedWordsPage> {
  final TextEditingController _wordController = TextEditingController();
  final User? user = FirebaseAuth.instance.currentUser;
  Map<String, int> commonWordCounts = {};
  bool _isEditing = false;
  int _selectedIndex = 2; // Default to "Filler Words" tab

  @override
  void initState() {
    super.initState();
    _fetchCommonWords();
  }

  Future<void> _fetchCommonWords() async {
    if (user != null) {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .get();

      setState(() {
        commonWordCounts = Map<String, int>.from(snapshot['commonWordCounts']);
      });
    }
  }

  void _addWord(String word) async {
    if (user != null) {
      setState(() {
        commonWordCounts[word] = commonWordCounts[word] ?? 0;
      });

      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .update({
        'commonWordCounts': commonWordCounts,
      });
    }
  }

  void _deleteWord(String word) async {
    if (user != null) {
      setState(() {
        commonWordCounts.remove(word);
      });

      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .update({
        'commonWordCounts': commonWordCounts,
      });

      // Remove the word from any sessions it might have occurred in
      QuerySnapshot sessionsSnapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .get();

      for (QueryDocumentSnapshot session in sessionsSnapshot.docs) {
        Map<String, dynamic> sessionData =
            session.data() as Map<String, dynamic>;

        if (sessionData.containsKey('words') &&
            sessionData['words'].containsKey(word)) {
          sessionData['words'].remove(word);
          await FirebaseFirestore.instance
              .collection('user_data')
              .doc(user!.uid)
              .collection('sessions')
              .doc(session.id)
              .update({
            'words': sessionData['words'],
          });
        }
      }
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex == index) {
      return;
    }

    switch (index) {
      case 0:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
        break;
      case 1:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
        break;
      case 2:
        // Already on Filler Words page
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Personalized Words'),
        automaticallyImplyLeading: false, // Remove the back button
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  spacing: 8.0,
                  runSpacing: 4.0,
                  children: commonWordCounts.keys.map((word) {
                    return Chip(
                      label: Text(word),
                      onDeleted: _isEditing ? () => _deleteWord(word) : null,
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
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
            label: const Text('Add'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 10),
          FloatingActionButton.extended(
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
            label: _isEditing ? const Text('Done') : const Text('Edit'),
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, size: 20),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history, size: 20),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.edit_note, size: 20),
            label: 'Filler Words',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 20),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
