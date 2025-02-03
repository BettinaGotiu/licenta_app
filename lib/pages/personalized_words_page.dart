import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
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
      bool confirmed = await _showConfirmationDialog();
      if (!confirmed) return;

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

  Future<bool> _showConfirmationDialog() async {
    return await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Deletion'),
              content: const Text('Are you sure you want to delete this word?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Delete'),
                ),
              ],
            );
          },
        ) ??
        false;
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
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 10.0, right: 180),
                child: Text(
                  'Filler Words',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Nacelle',
                  ),
                ),
              ),
            ),
          ),
        ),
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
                      deleteIcon: _isEditing
                          ? Icon(Icons.delete, color: Color(0xFFFF3926))
                          : null,
                      backgroundColor: _isEditing ? Colors.grey[200] : null,
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                          color: _isEditing
                              ? Color(0xFFFF3926)
                              : Color(0xFF11BDE3),
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Add New Word'),
                          content: TextField(
                            controller: _wordController,
                            decoration:
                                const InputDecoration(hintText: 'Enter word'),
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
                  icon: Icon(Icons.add),
                  label: Text('Add'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3539AC),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {
                      _isEditing = !_isEditing;
                    });
                  },
                  icon: Icon(
                    _isEditing ? Icons.check : Icons.edit,
                  ),
                  label: _isEditing ? Text('Done') : Text('Edit'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3539AC),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton.icon(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: const Text('Help'),
                          content: const Text(
                            'This page allows you to manage and track filler words, which are commonly used words in speeches and daily conversations when people lose their train of thought or do not know what to say. These words should be avoided for more effective communication. You can add specific words that you tend to use frequently, and the app will help you monitor and reduce their usage over time.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: const Text('Close'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  icon: Icon(Icons.help_outline),
                  label: Text('Help'),
                  style: ElevatedButton.styleFrom(
                    foregroundColor: Colors.white,
                    backgroundColor: Color(0xFF3539AC),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      bottomNavigationBar: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        child: BottomNavigationBar(
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home, size: 24),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history, size: 24),
              label: 'History',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.edit_note, size: 24),
              label: 'Filler Words',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person, size: 24),
              label: 'User',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.logout, size: 24),
              label: 'Logout',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Color(0xFF3539AC),
          unselectedItemColor: Colors.grey[600],
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          selectedFontSize: 12,
          unselectedFontSize: 12,
          backgroundColor: Colors.white,
          elevation: 10,
          type: BottomNavigationBarType.fixed,
        ),
      ),
    );
  }
}
