import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:mrx_charts/mrx_charts.dart';
import 'package:table_calendar/table_calendar.dart';
import 'signin_screen.dart';
import 'calendar_screen.dart';
import 'settings_screen.dart';
import 'domain_selection_screen.dart';
import 'daily_challenge_screen.dart';
import 'personalized_words_page.dart';
import 'history_screen.dart';
import 'speed_selection.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late User? user;
  DateTime _focusedDay = DateTime.now();
  List<Map<String, dynamic>> _sessions = [];
  Set<DateTime> _sessionDates = {}; // Using Set for quick lookup
  bool _showLastFiveSessions = true;
  int _selectedIndex = 0;

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
        _sessions = snapshot.docs.map((doc) => doc.data()).toList();
        _sessionDates = snapshot.docs.map((doc) {
          DateTime date = DateTime.parse(doc['date']);
          return DateTime(
              date.year, date.month, date.day); // Normalize date to YYYY-MM-DD
        }).toSet();
      });
    }
  }

  bool _isSessionDate(DateTime date) {
    return _sessionDates.contains(DateTime(date.year, date.month, date.day));
  }

  Widget _buildLineChart() {
    List<Map<String, dynamic>> sessionsToShow = _showLastFiveSessions
        ? _sessions
            .skip(_sessions.length > 5 ? _sessions.length - 5 : 0)
            .toList()
        : _sessions;

    List<ChartLineDataItem> dataPoints = sessionsToShow
        .asMap()
        .entries
        .map((entry) => ChartLineDataItem(
              x: entry.key.toDouble() + 1,
              value: entry.value['withinLimitPercentage'].toDouble(),
            ))
        .toList();

    List<String> dateLabels = sessionsToShow
        .map((session) => DateFormat('yyyy-MM-dd')
            .format(DateTime.parse(session['date'] as String)))
        .toList();

    return _sessions.isEmpty
        ? Container(
            height: 200,
            child: Center(
              child: Text(
                'No session data available',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          )
        : Column(
            children: [
              const Text(
                'Your Progress Over Time',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'This chart shows how well your speech fits within the selected speed limits over time. Higher percentages indicate better alignment with the speed limit.',
                style: TextStyle(fontSize: 14, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _showLastFiveSessions ? Colors.blue[100] : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showLastFiveSessions = true;
                      });
                    },
                    child: const Text('Last 5 Sessions'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          !_showLastFiveSessions ? Colors.blue[100] : null,
                    ),
                    onPressed: () {
                      setState(() {
                        _showLastFiveSessions = false;
                      });
                    },
                    child: const Text('All Time Progress'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Container(
                  width: dataPoints.length * 100.0,
                  height: 200,
                  child: Chart(
                    layers: [
                      ChartAxisLayer(
                        settings: ChartAxisSettings(
                          x: ChartAxisSettingsAxis(
                            frequency: 1.0,
                            max: dataPoints.length.toDouble(),
                            min: 1.0,
                            textStyle:
                                TextStyle(color: Colors.black, fontSize: 12.0),
                          ),
                          y: ChartAxisSettingsAxis(
                            frequency: 10.0,
                            max: 100.0,
                            min: 0.0,
                            textStyle:
                                TextStyle(color: Colors.black, fontSize: 12.0),
                          ),
                        ),
                        labelX: (value) => dateLabels[value.toInt() - 1],
                        labelY: (value) => value.toString(),
                      ),
                      ChartLineLayer(
                        items: dataPoints,
                        settings: ChartLineSettings(
                          color: Colors.blue,
                          thickness: 2.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Scroll for more data',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              )
            ],
          );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    switch (index) {
      case 0:
        // Home is the current screen
        break;
      case 1:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const HistoryScreen()),
        );
        break;
      case 2:
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => const PersonalizedWordsPage()),
        );
        break;
      case 3:
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const SettingsScreen()),
        );
        break;
    }
  }

  void _navigateToSpeedSelection(BuildContext context, String nextPageRoute) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SpeedSelectionPage(nextPageRoute: nextPageRoute),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Home',
          style: TextStyle(color: Colors.black),
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const CircleAvatar(
              backgroundColor: Colors.grey,
              child: Icon(Icons.person, color: Colors.white),
            ),
            onSelected: (value) {
              if (value == 'Settings') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const SettingsScreen()),
                );
              } else if (value == 'Logout') {
                FirebaseAuth.instance.signOut().then((_) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SigninScreen()),
                    (route) => false,
                  );
                });
              } else if (value == 'Filler Words') {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PersonalizedWordsPage()),
                );
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'Settings', child: Text('Settings')),
              const PopupMenuItem(value: 'Logout', child: Text('Logout')),
              const PopupMenuItem(
                  value: 'Filler Words', child: Text('Filler Words')),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Daily Streak',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton.icon(
                    icon: const Icon(Icons.calendar_today, color: Colors.blue),
                    label: const Text(
                      'Full Streak Calendar',
                      style: TextStyle(color: Colors.blue),
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const CalendarScreen()),
                      );
                    },
                  ),
                ],
              ),
              TableCalendar(
                firstDay: DateTime.utc(2010, 10, 16),
                lastDay: DateTime.utc(2030, 3, 14),
                focusedDay: _focusedDay,
                calendarFormat: CalendarFormat.week,
                onFormatChanged: (format) {},
                onPageChanged: (focusedDay) => _focusedDay = focusedDay,
                locale: 'en_US',
                calendarBuilders: CalendarBuilders(
                  defaultBuilder: (context, day, _) {
                    if (_isSessionDate(day)) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.green, // Green for session days
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                  todayBuilder: (context, day, _) {
                    if (_isSessionDate(day)) {
                      return Container(
                        margin: const EdgeInsets.all(6.0),
                        decoration: BoxDecoration(
                          color: Colors.green, // Green if session exists today
                          borderRadius: BorderRadius.circular(12.0),
                        ),
                        child: Center(
                          child: Text(
                            '${day.day}',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      );
                    }
                    return Center(
                      child: Text(
                        '${day.day}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
              buildCard(
                title: "Real-Time Sessions",
                description: "Engage in live sessions with our tool.",
                context: context,
                onTap: () {
                  _navigateToSpeedSelection(context, '/speech_to_text');
                },
              ),
              buildCard(
                title: "Practice Exercises",
                description: "Enhance your skills with practice tasks.",
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => DomainSelectionPage()),
                  );
                },
              ),
              buildCard(
                title: "Daily Challenge",
                description: "Try a new challenge every day.",
                context: context,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DailyChallengePage()),
                  );
                },
              ),
              const SizedBox(height: 20),
              _buildLineChart(),
            ],
          ),
        ),
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
      ),
    );
  }

  Widget buildCard({
    required String title,
    required String description,
    required BuildContext context,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(description),
        trailing: ElevatedButton(
          onPressed: onTap,
          child: const Text("Start"),
        ),
      ),
    );
  }
}
