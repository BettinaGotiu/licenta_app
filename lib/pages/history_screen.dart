import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_custom_clippers/flutter_custom_clippers.dart';
import 'package:intl/intl.dart';
import 'dart:math';
import 'home_screen.dart';
import 'settings_screen.dart';
import 'signin_screen.dart';
import 'personalized_words_page.dart';

// Define the color palette
final Color primaryColor = Color(0xFF3539AC);
final Color secondaryColor = Color(0xFF11BDE3);
final Color accentColor = Color(0xFFFF3926);
final Color cardColor = Color(0xFF973462);
final Color chartLineColor = Color(0xFF7670B9);
final Color backgroundColor = Color(0xFFEFF3FE);
final Color textColor = Colors.black87;

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late User? user;
  List<Map<String, dynamic>> _sessions = [];
  int _selectedIndex = 1; // Highlight History widget
  bool _isEditMode = false;
  bool _isLoading = true;
  bool _noSessionsFound = false;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    _fetchSessionData();
  }

  Future<void> _fetchSessionData() async {
    if (user != null) {
      final snapshot = await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .orderBy('date')
          .get();

      await Future.delayed(const Duration(seconds: 0)); // Artificial delay

      setState(() {
        _sessions = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
        _isLoading = false;
        _noSessionsFound = _sessions.isEmpty;
      });
    } else {
      setState(() {
        _isLoading = false;
        _noSessionsFound = true;
      });
    }
  }

  void _onItemTapped(int index) {
    if (index == _selectedIndex) return;

    if (index == 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    } else if (index == 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HistoryScreen()),
      );
    } else if (index == 2) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const PersonalizedWordsPage()),
      );
    } else if (index == 3) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    } else if (index == 4) {
      _showLogoutConfirmation();
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

  void _toggleEditMode() {
    setState(() {
      _isEditMode = !_isEditMode;
    });
  }

  Future<void> _deleteSession(String sessionId) async {
    if (user != null) {
      await FirebaseFirestore.instance
          .collection('user_data')
          .doc(user!.uid)
          .collection('sessions')
          .doc(sessionId)
          .delete();

      _fetchSessionData();
    }
  }

  void _confirmDeleteSession(String sessionId, String sessionDateTime) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Session"),
          content: Text(
              "Are you sure you want to delete the session registered at $sessionDateTime? This action cannot be undone."),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteSession(sessionId);
                Navigator.of(context).pop();
              },
              child: Text("Delete", style: TextStyle(color: accentColor)),
            ),
          ],
        );
      },
    );
  }

  String _formatDate(DateTime date) {
    return DateFormat('yyyy-MM-dd HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(140.0),
        child: Stack(
          children: [
            ClipPath(
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
                    padding: const EdgeInsets.only(top: 10.0, right: 100.0),
                    child: Text(
                      'Sessions History',
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
            Positioned(
              bottom: -0.5,
              right: 10,
              child: ElevatedButton.icon(
                onPressed: _toggleEditMode,
                icon: Icon(
                  _isEditMode ? Icons.check : Icons.edit,
                  color: Colors.white,
                ),
                label: Text(
                  _isEditMode ? "Done" : "Edit",
                  style: const TextStyle(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _noSessionsFound
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(Icons.info_outline,
                                  size: 100, color: Colors.grey),
                              SizedBox(height: 20),
                              Text(
                                'No sessions found',
                                style: TextStyle(
                                    fontSize: 24, fontWeight: FontWeight.bold),
                              ),
                              SizedBox(height: 10),
                              Text(
                                'To see your session history, record at least one activity from the exercises on the Home screen.',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : SingleChildScrollView(
                          child: CustomPaint(
                            painter: PathPainter(_sessions.length),
                            child: SizedBox(
                              height: _sessions.length * 250.0,
                              child: Stack(
                                children: List.generate(
                                  _sessions.length,
                                  (index) {
                                    final isEven = index % 2 == 0;
                                    final randomOffset =
                                        Random().nextDouble() * 40 - 20;
                                    final positionLeft = isEven
                                        ? MediaQuery.of(context).size.width /
                                                2 -
                                            120 +
                                            randomOffset
                                        : MediaQuery.of(context).size.width /
                                                2 +
                                            20 +
                                            randomOffset;
                                    final sessionSize = 90.0;
                                    final sessionDateTime = DateTime.parse(
                                        _sessions[index]['date']);
                                    final formattedDateTime =
                                        _formatDate(sessionDateTime);
                                    return Positioned(
                                      top: index * 250.0,
                                      left: positionLeft.clamp(
                                          16.0,
                                          MediaQuery.of(context).size.width -
                                              166.0), // Account for padding
                                      child: GestureDetector(
                                        onTap: !_isEditMode
                                            ? () {
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        SessionDetailScreen(
                                                      session: _sessions[index],
                                                    ),
                                                  ),
                                                );
                                              }
                                            : null,
                                        child: SessionNode(
                                          sessionNumber: index + 1,
                                          sessionDate: formattedDateTime,
                                          size: sessionSize,
                                          isEditMode: _isEditMode,
                                          onDelete: () {
                                            _confirmDeleteSession(
                                                _sessions[index]['id'],
                                                formattedDateTime);
                                          },
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          ),
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
          currentIndex: _selectedIndex,
          selectedItemColor: primaryColor,
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

class PathPainter extends CustomPainter {
  final int sessionCount;

  PathPainter(this.sessionCount);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = secondaryColor
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    double x = size.width / 2;
    double y = 100; // Start below the buttons

    path.moveTo(x, y);

    for (int i = 0; i < sessionCount - 1; i++) {
      final isEven = i % 2 == 0;
      final controlX = isEven ? x + 100 : x - 100;
      final nextX = isEven ? x + 120 : x - 120;
      y += 250;
      path.quadraticBezierTo(controlX.clamp(50.0, size.width - 50.0), y - 125,
          nextX.clamp(50.0, size.width - 50.0), y);
      x = nextX;
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

class SessionNode extends StatelessWidget {
  final int sessionNumber;
  final String sessionDate;
  final double size;
  final bool isEditMode;
  final VoidCallback onDelete;

  const SessionNode({
    Key? key,
    required this.sessionNumber,
    required this.sessionDate,
    required this.size,
    required this.isEditMode,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: isEditMode ? onDelete : null,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              color: isEditMode ? accentColor.withOpacity(0.6) : cardColor,
              borderRadius: BorderRadius.circular(50),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Center(
              child: isEditMode
                  ? const Icon(Icons.delete, color: Colors.white)
                  : Text(
                      'Session\n$sessionNumber',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          sessionDate,
          style: const TextStyle(fontSize: 12, color: Colors.grey),
        ),
      ],
    );
  }
}

class SessionDetailScreen extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionDetailScreen({Key? key, required this.session})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        title: const Text('Session Details'),
        backgroundColor: primaryColor,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Date: ${session['date']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Average WPM: ${session['averageWpm']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Within Limit Percentage: ${session['withinLimitPercentage']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Spoken Text: ${session['spokenText']}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 10),
            Text(
              'Common Word Counts: ${session['commonWordCounts']}',
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }
}
