import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:math';
import 'home_screen.dart';
import 'settings_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  late User? user;
  List<Map<String, dynamic>> _sessions = [];
  int _selectedIndex = 1;
  bool _isEditMode = false;

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

      setState(() {
        _sessions = snapshot.docs
            .map((doc) => {'id': doc.id, ...doc.data() as Map<String, dynamic>})
            .toList();
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
        MaterialPageRoute(builder: (context) => const SettingsScreen()),
      );
    }
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

  void _confirmDeleteSession(String sessionId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Delete Session"),
          content: const Text(
              "Are you sure you want to delete this session? This action cannot be undone."),
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
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        automaticallyImplyLeading: false, // Remove the back button
        actions: [
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ElevatedButton.icon(
                onPressed: _toggleEditMode,
                icon: const Icon(Icons.check, color: Colors.white),
                label:
                    const Text("Done", style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ElevatedButton.icon(
              onPressed: _toggleEditMode,
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text("Edit", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sessions.isEmpty
            ? const Center(child: CircularProgressIndicator())
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
                          final randomOffset = Random().nextDouble() * 40 - 20;
                          final positionLeft = isEven
                              ? MediaQuery.of(context).size.width / 2 -
                                  120 +
                                  randomOffset
                              : MediaQuery.of(context).size.width / 2 +
                                  20 +
                                  randomOffset;
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
                              child: Stack(
                                children: [
                                  SessionNode(
                                    sessionNumber: index + 1,
                                    sessionDate: _sessions[index]['date'],
                                  ),
                                  if (_isEditMode)
                                    Container(
                                      width: 90.0,
                                      height: 90.0,
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.6),
                                        borderRadius: BorderRadius.circular(50),
                                      ),
                                      child: Center(
                                        child: IconButton(
                                          icon: const Icon(Icons.delete),
                                          color: Colors.red,
                                          onPressed: () {
                                            _confirmDeleteSession(
                                                _sessions[index]['id']);
                                          },
                                        ),
                                      ),
                                    ),
                                ],
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
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'User',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.amber[800],
        onTap: _onItemTapped,
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
      ..color = Colors.orangeAccent
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final path = Path();
    double x = size.width / 2;
    double y = 60;

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

  const SessionNode({
    Key? key,
    required this.sessionNumber,
    required this.sessionDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final sizeOptions = [70.0, 80.0, 90.0];
    final randomSize = sizeOptions[Random().nextInt(sizeOptions.length)];

    return Column(
      children: [
        Container(
          width: randomSize,
          height: randomSize,
          decoration: BoxDecoration(
            color: Colors.purple,
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
            child: Text(
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
      appBar: AppBar(
        title: const Text('Session Details'),
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
