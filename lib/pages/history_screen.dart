import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
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
  Map<String, dynamic>? _selectedSession;

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
              child: const Text("Delete", style: TextStyle(color: Colors.red)),
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
      appBar: AppBar(
        title: const Text('History'),
        automaticallyImplyLeading: false, // Remove the back button
        actions: _sessions.isNotEmpty
            ? [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton.icon(
                    onPressed: _toggleEditMode,
                    icon: Icon(_isEditMode ? Icons.check : Icons.edit,
                        color: Colors.white),
                    label: Text(_isEditMode ? "Done" : "Edit",
                        style: const TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isEditMode ? Colors.green : Colors.red,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ),
              ]
            : null,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _sessions.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.info_outline, size: 100, color: Colors.grey),
                    SizedBox(height: 20),
                    Text(
                      'No sessions found',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'To see your session history, record at least one activity from the exercises on the Home screen.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  ],
                ),
              )
            : SingleChildScrollView(
                child: Column(
                  children: [
                    CustomPaint(
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
                                  ? MediaQuery.of(context).size.width / 2 -
                                      120 +
                                      randomOffset
                                  : MediaQuery.of(context).size.width / 2 +
                                      20 +
                                      randomOffset;
                              final sessionSize = 90.0;
                              final sessionDateTime =
                                  DateTime.parse(_sessions[index]['date']);
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
                                          setState(() {
                                            _selectedSession = _sessions[index];
                                          });
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
                    const SizedBox(height: 20),
                    if (_selectedSession != null)
                      SessionChart(session: _selectedSession!),
                  ],
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
              color: isEditMode ? Colors.red.withOpacity(0.6) : Colors.purple,
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

class SessionChart extends StatelessWidget {
  final Map<String, dynamic> session;

  const SessionChart({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Session Chart for: ${session['date']}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text('Average WPM: ${session['averageWpm']}'),
            Text('Within Limit %: ${session['withinLimitPercentage']}'),
            const SizedBox(height: 10),
            Center(
              child: RadialChart(session: session), // Replace with chart widget
            ),
          ],
        ),
      ),
    );
  }
}

// Implement the RadialChart widget
class RadialChart extends StatelessWidget {
  final Map<String, dynamic> session;

  const RadialChart({Key? key, required this.session}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Dummy data for radial chart
    final data = session.entries
        .where((entry) => entry.value is int && entry.value > 2)
        .toList();
    final total = data.fold(0, (sum, entry) => sum + entry.value as int);

    return SizedBox(
      width: 200,
      height: 200,
      child: CustomPaint(
        painter: RadialChartPainter(data.cast<MapEntry<String, int>>(), total),
      ),
    );
  }
}

class RadialChartPainter extends CustomPainter {
  final List<MapEntry<String, int>> data;
  final int total;

  RadialChartPainter(this.data, this.total);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20;

    double startAngle = -pi / 2;
    for (final entry in data) {
      final sweepAngle = (entry.value / total) * 2 * pi;
      paint.color =
          Colors.primaries[entry.key.hashCode % Colors.primaries.length];
      canvas.drawArc(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width,
            height: size.height),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
      startAngle += sweepAngle;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
