import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'speech_to_text.dart';
import 'home_screen.dart';
import 'history_screen.dart';
import 'personalized_words_page.dart';
import 'settings_screen.dart';
import 'signin_screen.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);
final Color accentColor = Color(0xFFFF3926);
final Color cardColor = Color(0xFF973462);
final Color chartLineColor = Color(0xFF7670B9);
final Color backgroundColor = Color(0xFFEFF3FE);
final Color textColor = Colors.black87;

class SpeedSelectionPage extends StatefulWidget {
  final String nextPageRoute;
  final String? prompt;

  const SpeedSelectionPage({Key? key, required this.nextPageRoute, this.prompt})
      : super(key: key);

  @override
  _SpeedSelectionPageState createState() => _SpeedSelectionPageState();
}

class _SpeedSelectionPageState extends State<SpeedSelectionPage> {
  String? _selectedSpeed = '130-160'; // Default selection

  final Map<String, String> _speedDescriptions = {
    '100-130':
        'Slow pace (100-130 wpm) for speeches that require emphasis and reflection.',
    '130-160':
        'Normal pace (130-160 wpm) for clear and structured presentations.',
    '160-210':
        'Fast pace (160-210+ wpm) for dynamic situations requiring energy and enthusiasm.',
  };

  void _navigateToNextPage() {
    if (_selectedSpeed != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SpeechToTextPage(
            selectedPace: _selectedSpeed!,
            prompt: widget.prompt,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a speed before proceeding.')),
      );
    }
  }

  void _onItemTapped(int index) {
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
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => const PersonalizedWordsPage()),
        );
        break;
      case 3:
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
      case 4:
        _showLogoutConfirmation();
        break;
    }
  }

  void _showLogoutConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Logout"),
          content: const Text("Are you sure you want to logout?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _logout();
              },
              child: const Text("Logout", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SigninScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final double cardWidth = MediaQuery.of(context).size.width * 0.7;
    final double cardHeight = 80;

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: ClipPath(
          clipper: WaveClipperTwo(),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [primaryColor, secondaryColor],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.only(top: 23.0, left: 15.0),
                child: Text(
                  'Select Your Speaking Pace',
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
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Speed Selection Buttons
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 12,
              runSpacing: 12,
              children: _speedDescriptions.keys.map((speed) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedSpeed = speed;
                    });
                  },
                  child: Container(
                    width: cardWidth,
                    height: cardHeight,
                    decoration: BoxDecoration(
                      color: _selectedSpeed == speed
                          ? secondaryColor
                          : Colors.white,
                      border: Border.all(color: Colors.black, width: 2),
                      borderRadius: BorderRadius.circular(8),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.2),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      speed,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: _selectedSpeed == speed
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 25),

            // Explanation Card
            Container(
              width: double.infinity, // Make the card wider
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: Colors.black, width: 3),
                borderRadius: BorderRadius.circular(12),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.grey,
                    offset: Offset(10, 10),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    "Why Choose This Speed?",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    _speedDescriptions[_selectedSpeed!]!,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            // Proceed Button
            ElevatedButton(
              onPressed: _selectedSpeed != null ? _navigateToNextPage : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: secondaryColor,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              child: Text(
                'Start Speech Exercise',
                style: TextStyle(fontSize: 18, color: Colors.white),
              ),
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
          currentIndex: 0, // Valid index to avoid error
          selectedItemColor: Colors.grey,
          unselectedItemColor: Colors.grey,
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
